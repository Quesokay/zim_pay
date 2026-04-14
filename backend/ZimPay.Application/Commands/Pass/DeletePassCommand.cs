using MediatR;

namespace ZimPay.Application.Commands
{
    public class DeletePassCommand : IRequest<bool>
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DeletePassCommand(int id, int userId)
        {
            Id = id;
            UserId = userId;
        }
    }
}
