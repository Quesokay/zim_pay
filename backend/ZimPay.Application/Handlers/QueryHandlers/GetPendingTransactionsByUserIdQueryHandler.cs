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
    public class GetPendingTransactionsByUserIdQueryHandler : IRequestHandler<GetPendingTransactionsByUserIdQuery, List<TransactionDto>>
    {
        private readonly ITransactionRepository _transactionRepository;

        public GetPendingTransactionsByUserIdQueryHandler(ITransactionRepository transactionRepository)
        {
            _transactionRepository = transactionRepository;
        }

        public async Task<List<TransactionDto>> Handle(GetPendingTransactionsByUserIdQuery request, CancellationToken cancellationToken)
        {
            var transactions = await _transactionRepository.GetPendingByUserIdAsync(request.UserId);

            return transactions.Select(t => new TransactionDto
            {
                Id = t.Id,
                UserId = t.UserId,
                Type = t.Type,
                Amount = t.Amount,
                Description = t.Description,
                Status = t.Status,
                MerchantName = t.MerchantName,
                Date = t.Date,
                CompletedAt = t.CompletedAt,
                RecipientUserId = t.RecipientUserId,
                PaymentMethodId = t.PaymentMethodId
            }).ToList();
        }
    }
}
