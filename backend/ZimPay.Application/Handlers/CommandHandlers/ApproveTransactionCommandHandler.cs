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
            var transaction = await _transactionRepository.GetByIdAsync(request.TransactionId);
            if (transaction == null || transaction.Status != "Pending")
                throw new InvalidOperationException("Invalid or already processed transaction.");

            // 1. Fetch the specific card tied to this pending transaction
            var activeCard = await _paymentMethodRepository.GetByIdAsync(transaction.PaymentMethodId.Value);
            
            if (activeCard == null)
                throw new InvalidOperationException("Payment method not found.");

            // 2. Deduct from the card
            activeCard.DeductFunds(transaction.Amount);
            await _paymentMethodRepository.UpdateAsync(activeCard);

            // 3. Complete transaction
            transaction.Status = "Completed";
            await _transactionRepository.UpdateAsync(transaction);

            _logger.LogInformation("✅ [API] Transaction {Id} approved. Deducted ${Amount} from {BankName}.",
                request.TransactionId, transaction.Amount, activeCard.BankName);

            return true;
        }
    }
}
