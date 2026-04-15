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

            // 1. Find the card tied to this NFC tag
            var paymentMethod = await _paymentMethodRepository.GetByTokenAsync(request.DigitalToken);
            
            if (paymentMethod == null || !paymentMethod.IsActive)
            {
                _logger.LogWarning("❌ [POS] Transaction declined: Invalid or deactivated NFC token.");
                throw new InvalidOperationException("Transaction Declined: Invalid or deactivated NFC card.");
            }

            // 2. Fetch the User and Check Balance
            var user = await _userRepository.GetByIdAsync(paymentMethod.UserId);
            if (user == null)
            {
                _logger.LogWarning("❌ [POS] Transaction declined: User not found.");
                throw new InvalidOperationException("Transaction Declined: User account not found.");
            }

            // ✨ THE BALANCE CHECK ✨
            if (user.Balance < request.Amount)
            {
                _logger.LogWarning("❌ [POS] Transaction Declined: Insufficient Funds. Wallet Balance: ${Balance}, Requested: ${Amount}", user.Balance, request.Amount);
                throw new InvalidOperationException("Transaction Declined: Insufficient funds in ZimPay Wallet.");
            }

            // ✨ THE NEW BIOMETRIC LIMIT CHECK ✨
            if (request.Amount > user.TapLimit)
            {
                _logger.LogWarning("⚠️ [POS] Amount ${Amount} exceeds user limit of ${Limit}. Requiring Biometrics.", request.Amount, user.TapLimit);
                
                // 1. Save it as PENDING so the user's phone can see it
                var pendingTransaction = new Transaction
                {
                    UserId = paymentMethod.UserId,
                    PaymentMethodId = paymentMethod.Id,
                    Amount = request.Amount,
                    Type = "Payment",
                    Status = "Pending", // IMPORTANT: It is not completed yet!
                    Date = DateTime.UtcNow,
                    Description = "ZimPay Tap-to-Pay POS"
                };
                await _transactionRepository.AddAsync(pendingTransaction);

                // 2. Throw a specific error code so the API Controller knows what happened.
                // We pass the new Transaction ID so the phone knows exactly which one to approve.
                throw new InvalidOperationException($"BIOMETRIC_REQUIRED:{pendingTransaction.Id}");
            }

            // 3. Deduct the Funds & Save
            user.Balance -= request.Amount;
            
            // Make sure you have added UpdateAsync to your IUserRepository and UserRepository!
            await _userRepository.UpdateAsync(user);

            // 4. Create the Transaction Record
            var transaction = new Transaction
            {
                UserId = paymentMethod.UserId,
                PaymentMethodId = paymentMethod.Id,
                Amount = request.Amount,
                Type = "Payment",
                Status = "Completed",
                Date = DateTime.UtcNow,
                Description = "ZimPay Tap-to-Pay POS"
            };

            await _transactionRepository.AddAsync(transaction);
            
            _logger.LogInformation("✅ [POS] SUCCESS! Charged ${Amount} to User {UserId}. New Balance: ${Balance}", 
                request.Amount, paymentMethod.UserId, user.Balance);

            return true;
        }
    }
}