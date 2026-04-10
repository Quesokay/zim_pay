using System.Collections.Generic;
using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Queries
{
    public class GetPassesByUserIdQuery : IRequest<List<PassDto>>
    {
        public int UserId { get; set; }
        public bool OnlyActive { get; set; } = false;

        public GetPassesByUserIdQuery(int userId, bool onlyActive = false)
        {
            UserId = userId;
            OnlyActive = onlyActive;
        }
    }
}
