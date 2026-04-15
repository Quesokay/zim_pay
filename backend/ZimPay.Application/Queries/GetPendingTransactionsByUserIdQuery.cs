using System.Collections.Generic;
using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Queries
{
    public class GetPendingTransactionsByUserIdQuery : IRequest<List<TransactionDto>>
    {
        public int UserId { get; set; }

        public GetPendingTransactionsByUserIdQuery(int userId)
        {
            UserId = userId;
        }
    }
}
