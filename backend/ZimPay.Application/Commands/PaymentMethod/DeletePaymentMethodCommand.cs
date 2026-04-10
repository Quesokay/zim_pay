using MediatR;

namespace ZimPay.Application.Commands
{
    public class DeletePaymentMethodCommand : IRequest<bool>
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DeletePaymentMethodCommand(int id, int userId)
        {
            Id = id;
            UserId = userId;
        }
    }
}
