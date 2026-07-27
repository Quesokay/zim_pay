using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class ProcessEcoCashCallbackCommandHandler : IRequestHandler<ProcessEcoCashCallbackCommand, bool>
    {
        private readonly ITransactionRepository _transactionRepository;
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly ILogger<ProcessEcoCashCallbackCommandHandler> _logger;

        public ProcessEcoCashCallbackCommandHandler(
            ITransactionRepository transactionRepository,
            IPaymentMethodRepository paymentMethodRepository,
            ILogger<ProcessEcoCashCallbackCommandHandler> logger)
        {
            _transactionRepository = transactionRepository;
            _paymentMethodRepository = paymentMethodRepository;
            _logger = logger;
        }

        public async Task<bool> Handle(ProcessEcoCashCallbackCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("🔔 [WEBHOOK] Received EcoCash Callback for Ref: {RefCode}, Corr: {Corr} with Status: {Status}",
                request.ReferenceCode, request.ClientCorrelator, request.TransactionStatus);

            // 1. Find the pending transaction using the Reference Code or Correlator
            var pendingTransaction = await _transactionRepository.GetByEcoCashIdentifiersAsync(request.ReferenceCode, request.ClientCorrelator);

            if (pendingTransaction == null)
            {
                _logger.LogWarning("⚠️ [WEBHOOK] Could not find a pending transaction for Ref: {RefCode} or Corr: {Corr}",
                    request.ReferenceCode, request.ClientCorrelator);
                return false;
            }

            // 2. Process based on EcoCash Status
            string status = request.TransactionStatus?.ToUpper();
            if (status == "COMPLETED" || status == "SUCCESS")
            {
                // Update Transaction
                pendingTransaction.Status = "Completed";
                await _transactionRepository.UpdateAsync(pendingTransaction);

                // Deduct from the local digital twin balance
                if (pendingTransaction.PaymentMethodId.HasValue)
                {
                    var card = await _paymentMethodRepository.GetByIdAsync(pendingTransaction.PaymentMethodId.Value);
                    if (card != null)
                    {
                        card.DeductFunds(pendingTransaction.Amount);
                        await _paymentMethodRepository.UpdateAsync(card);
                        _logger.LogInformation("✅ [WEBHOOK] EcoCash payment successful! Deducted ${Amount} from local balance.", pendingTransaction.Amount);
                    }
                }
            }
            else
            {
                // If the user cancelled the USSD prompt or had insufficient funds on EcoCash
                pendingTransaction.Status = "Declined";
                pendingTransaction.Description += " (Failed at Operator)";
                await _transactionRepository.UpdateAsync(pendingTransaction);
                _logger.LogWarning("❌ [WEBHOOK] EcoCash payment failed or was cancelled by user.");
            }

            return true;
        }
    }
}