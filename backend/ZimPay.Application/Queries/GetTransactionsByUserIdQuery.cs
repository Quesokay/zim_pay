using System.Collections.Generic;
using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Queries
{
    public class GetTransactionsByUserIdQuery : IRequest<List<TransactionDto>>
    {
        public int UserId { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }

        public GetTransactionsByUserIdQuery(int userId, int? pageNumber = null, int? pageSize = null)
        {
            UserId = userId;
            PageNumber = pageNumber;
            PageSize = pageSize;
        }
    }
}
