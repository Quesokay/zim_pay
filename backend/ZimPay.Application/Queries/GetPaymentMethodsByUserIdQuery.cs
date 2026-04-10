using System.Collections.Generic;
using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Queries
{
    public class GetPaymentMethodsByUserIdQuery : IRequest<List<PaymentMethodDto>>
    {
        public int UserId { get; set; }
        public bool OnlyActive { get; set; } = false;

        public GetPaymentMethodsByUserIdQuery(int userId, bool onlyActive = false)
        {
            UserId = userId;
            OnlyActive = onlyActive;
        }
    }
}
