using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class AddPassCommand : IRequest<int>
    {
        public int UserId { get; set; }
        public CreatePassDto Pass { get; set; }
    }
}
