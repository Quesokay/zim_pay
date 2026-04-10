using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class AddPaymentMethodCommand : IRequest<int>
    {
        public int UserId { get; set; }
        public CreatePaymentMethodDto PaymentMethod { get; set; }
    }
}
