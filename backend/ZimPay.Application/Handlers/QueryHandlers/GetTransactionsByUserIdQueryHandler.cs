using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;
using ZimPay.Application.Queries;

namespace ZimPay.Application.Handlers.QueryHandlers
{
    public class GetTransactionsByUserIdQueryHandler : IRequestHandler<GetTransactionsByUserIdQuery, List<TransactionDto>>
    {
        private readonly ITransactionRepository _transactionRepository;

        public GetTransactionsByUserIdQueryHandler(ITransactionRepository transactionRepository)
        {
            _transactionRepository = transactionRepository;
        }

        public async Task<List<TransactionDto>> Handle(GetTransactionsByUserIdQuery request, CancellationToken cancellationToken)
        {
            IEnumerable<ZimPay.Domain.Transaction> transactions;

            if (request.PageNumber.HasValue && request.PageSize.HasValue)
            {
                transactions = await _transactionRepository.GetByUserIdPaginatedAsync(
                    request.UserId, 
                    request.PageNumber.Value, 
                    request.PageSize.Value);
            }
            else
            {
                transactions = await _transactionRepository.GetByUserIdAsync(request.UserId);
            }

            return transactions.Select(t => new TransactionDto
            {
                Id = t.Id,
                UserId = t.UserId,
                Type = t.Type,
                Amount = t.Amount,
                Description = t.Description,
                Status = t.Status,
                Date = t.Date,
                CompletedAt = t.CompletedAt,
                RecipientUserId = t.RecipientUserId,
                PaymentMethodId = t.PaymentMethodId,
                User = t.User != null ? new UserDto
                {
                    Id = t.User.Id,
                    Email = t.User.Email,
                    Name = t.User.Name,
                    Phone = t.User.Phone,
                    CreatedAt = t.User.CreatedAt,
                    UpdatedAt = t.User.UpdatedAt,
                    IsActive = t.User.IsActive
                } : null,
                Recipient = t.Recipient != null ? new UserDto
                {
                    Id = t.Recipient.Id,
                    Email = t.Recipient.Email,
                    Name = t.Recipient.Name,
                    Phone = t.Recipient.Phone,
                    CreatedAt = t.Recipient.CreatedAt,
                    UpdatedAt = t.Recipient.UpdatedAt,
                    IsActive = t.Recipient.IsActive
                } : null
            }).ToList();
        }
    }
}
