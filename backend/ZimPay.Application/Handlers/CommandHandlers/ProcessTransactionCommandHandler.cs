using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class ProcessTransactionCommandHandler : IRequestHandler<ProcessTransactionCommand, bool>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly ITransactionRepository _transactionRepository;
        private readonly ILogger<ProcessTransactionCommandHandler> _logger;
        private readonly IUserRepository _userRepository;

        public ProcessTransactionCommandHandler(
            IPaymentMethodRepository paymentMethodRepository,
            ITransactionRepository transactionRepository,
            ILogger<ProcessTransactionCommandHandler> logger,
            IUserRepository userRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
            _userRepository = userRepository;
        }

    public async Task<bool> Handle(ProcessTransactionCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("💳 [POS] Received transaction request for ${Amount}", request.Amount);

            // 1. Find the token/tag that was tapped
            var nfcToken = await _paymentMethodRepository.GetByTokenAsync(request.DigitalToken);
            if (nfcToken == null || !nfcToken.IsActive)
                throw new InvalidOperationException("Transaction Declined: Invalid NFC tag.");

            var user = await _userRepository.GetByIdAsync(nfcToken.UserId);

            // 2. ✨ THE "DIGITAL CUSTODIAN" ROUTING ✨
            // Find the user's active/default payment method to charge
            var allCards = await _paymentMethodRepository.GetByUserIdAsync(user.Id);
            var activeCard = allCards.FirstOrDefault(c => c.IsDefault && c.IsActive);

            if (activeCard == null)
                throw new InvalidOperationException("Transaction Declined: No active default payment method selected.");

            // 3. Check Balance on the specific card
            if (activeCard.Balance < request.Amount)
                throw new InvalidOperationException($"Transaction Declined: Insufficient funds on {activeCard.BankName}.");

            // 4. Biometric Limit Check
            if (request.Amount > user.TapLimit)
            {
                var pendingTransaction = new Transaction
                {
                    UserId = user.Id,
                    PaymentMethodId = activeCard.Id, // Link to the specific card
                    Amount = request.Amount,
                    Type = "Payment",
                    Status = "Pending",
                    Date = DateTime.UtcNow,
                    Description = "ZimPay Tap-to-Pay POS"
                };
                await _transactionRepository.AddAsync(pendingTransaction);
                throw new InvalidOperationException($"BIOMETRIC_REQUIRED:{pendingTransaction.Id}");
            }

            // 5. Auto-Approve & Deduct
            activeCard.DeductFunds(request.Amount);
            await _paymentMethodRepository.UpdateAsync(activeCard); // Update the card's balance

            var transaction = new Transaction
            {
                UserId = user.Id,
                PaymentMethodId = activeCard.Id,
                Amount = request.Amount,
                Type = "Payment",
                Status = "Completed",
                Date = DateTime.UtcNow,
                Description = "ZimPay Tap-to-Pay POS"
            };
            await _transactionRepository.AddAsync(transaction);
            
            return true;
        }
    }
}