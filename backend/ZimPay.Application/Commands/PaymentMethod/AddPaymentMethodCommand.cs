using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class AddPaymentMethodCommand : IRequest<string>
    {
        public int UserId { get; set; }
        public CreatePaymentMethodDto PaymentMethod { get; set; }
    }
}
