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

        public ApproveTransactionCommandHandler(
            ITransactionRepository transactionRepository,
            IUserRepository userRepository,
            ILogger<ApproveTransactionCommandHandler> logger)
        {
            _transactionRepository = transactionRepository;
            _userRepository = userRepository;
            _logger = logger;
        }

        public async Task<bool> Handle(ApproveTransactionCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("✅ [API] Approving pending transaction ID: {TransactionId}", request.TransactionId);

            // 1. Fetch the pending transaction
            var transaction = await _transactionRepository.GetByIdAsync(request.TransactionId);
            if (transaction == null)
            {
                _logger.LogWarning("❌ [API] Transaction {Id} not found.", request.TransactionId);
                throw new InvalidOperationException("Transaction not found.");
            }

            if (transaction.Status != "Pending")
            {
                _logger.LogWarning("❌ [API] Transaction {Id} is already {Status}.", request.TransactionId, transaction.Status);
                throw new InvalidOperationException("Transaction already processed.");
            }

            // 2. Fetch the user
            var user = await _userRepository.GetByIdAsync(transaction.UserId);
            if (user == null)
            {
                _logger.LogWarning("❌ [API] User {UserId} for transaction {Id} not found.", transaction.UserId, request.TransactionId);
                throw new InvalidOperationException("User not found.");
            }

            // 3. Deduct the funds
            if (user.Balance < transaction.Amount)
            {
                _logger.LogWarning("❌ [API] User {UserId} has insufficient funds for transaction {Id}.", transaction.UserId, request.TransactionId);
                throw new InvalidOperationException("Insufficient funds.");
            }

            user.Balance -= transaction.Amount;
            await _userRepository.UpdateAsync(user);

            // 4. Mark as completed
            transaction.Status = "Completed";
            await _transactionRepository.UpdateAsync(transaction);

            _logger.LogInformation("✅ [API] Transaction {Id} approved and completed. New Balance: ${Balance}",
                request.TransactionId, user.Balance);

            return true;
        }
    }
}
