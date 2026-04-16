using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class ApproveTransactionCommandHandler : IRequestHandler<ApproveTransactionCommand, bool>
    {
        private readonly ITransactionRepository _transactionRepository;
        private readonly IUserRepository _userRepository;
        private readonly ILogger<ApproveTransactionCommandHandler> _logger;
        private readonly IPaymentMethodRepository _paymentMethodRepository;

        public ApproveTransactionCommandHandler(
            ITransactionRepository transactionRepository,
            IUserRepository userRepository,
            ILogger<ApproveTransactionCommandHandler> logger,
            IPaymentMethodRepository paymentMethodRepository)
        {
            _transactionRepository = transactionRepository;
            _userRepository = userRepository;
            _logger = logger;
            _paymentMethodRepository = paymentMethodRepository;
        }

        public async Task<bool> Handle(ApproveTransactionCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("🚀 [API] Approval requested for Transaction ID: {TransactionId}", request.TransactionId);

            var transaction = await _transactionRepository.GetByIdAsync(request.TransactionId);
            if (transaction == null)
            {
                _logger.LogWarning("❌ [API] Approval failed: Transaction {Id} not found.", request.TransactionId);
                throw new InvalidOperationException("Invalid or already processed transaction.");
            }

            if (transaction.Status != "Pending")
            {
                _logger.LogWarning("⚠️ [API] Approval ignored: Transaction {Id} is already in {Status} state.",
                    request.TransactionId, transaction.Status);
                throw new InvalidOperationException("Invalid or already processed transaction.");
            }

            // 1. Fetch the specific card tied to this pending transaction
            _logger.LogInformation("💳 [API] Identifying payment method ID: {MethodId} for transaction...", transaction.PaymentMethodId);
            var activeCard = await _paymentMethodRepository.GetByIdAsync(transaction.PaymentMethodId.Value);
            
            if (activeCard == null)
            {
                _logger.LogError("❌ [API] CRITICAL: Payment method {Id} associated with transaction {TxId} no longer exists.",
                    transaction.PaymentMethodId, request.TransactionId);
                throw new InvalidOperationException("Payment method not found.");
            }

            // 2. Deduct from the card
            _logger.LogInformation("💰 [API] Deducting ${Amount} from balance on {BankName} card...", transaction.Amount, activeCard.BankName);
            activeCard.DeductFunds(transaction.Amount);
            await _paymentMethodRepository.UpdateAsync(activeCard);

            // 3. Complete transaction
            transaction.Status = "Completed";
            _logger.LogInformation("📝 [API] Updating transaction status to 'Completed' in database.");
            await _transactionRepository.UpdateAsync(transaction);

            _logger.LogInformation("✅ [API] SUCCESS: Transaction {Id} approved and funds settled.", request.TransactionId);

            return true;
        }
    }
}
