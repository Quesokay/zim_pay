using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using GoogleWalletClone.Application.Commands;
using GoogleWalletClone.Application.Interfaces;
using GoogleWalletClone.Domain;

namespace GoogleWalletClone.Application.Handlers.CommandHandlers
{
    public class CreateTransactionCommandHandler : IRequestHandler<CreateTransactionCommand, int>
    {
        private readonly ITransactionRepository _transactionRepository;
        private readonly IUserRepository _userRepository;

        public CreateTransactionCommandHandler(
            ITransactionRepository transactionRepository,
            IUserRepository userRepository)
        {
            _transactionRepository = transactionRepository;
            _userRepository = userRepository;
        }

        public async Task<int> Handle(CreateTransactionCommand request, CancellationToken cancellationToken)
        {
            // Verify user exists
            var user = await _userRepository.GetByIdAsync(request.UserId);
            if (user == null)
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");

            // Validate transaction amount
            if (request.Transaction.Amount <= 0)
                throw new InvalidOperationException("Transaction amount must be greater than zero.");

            // For transfers, verify recipient exists
            if (!string.IsNullOrEmpty(request.Transaction.Type) && 
                request.Transaction.Type.Equals("Transfer", System.StringComparison.OrdinalIgnoreCase) &&
                request.Transaction.RecipientUserId.HasValue)
            {
                var recipientExists = await _userRepository.ExistsAsync(request.Transaction.RecipientUserId.Value);
                if (!recipientExists)
                    throw new InvalidOperationException($"Recipient with ID {request.Transaction.RecipientUserId} not found.");
            }

            var transaction = new Domain.Transaction
            {
                UserId = request.UserId,
                Type = request.Transaction.Type ?? "Payment",
                Amount = request.Transaction.Amount,
                Description = request.Transaction.Description,
                Status = "Pending",
                Date = DateTime.UtcNow,
                RecipientUserId = request.Transaction.RecipientUserId,
                PaymentMethodId = request.Transaction.PaymentMethodId
            };

            await _transactionRepository.AddAsync(transaction);
            return transaction.Id;
        }
    }
}
