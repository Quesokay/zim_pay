using MediatR;

namespace ZimPay.Application.Commands
{
    public class SetDefaultPaymentMethodCommand : IRequest<bool>
    {
        public int UserId { get; set; }
        public int PaymentMethodId { get; set; }

        public SetDefaultPaymentMethodCommand(int userId, int paymentMethodId)
        {
            UserId = userId;
            PaymentMethodId = paymentMethodId;
        }
    }
}