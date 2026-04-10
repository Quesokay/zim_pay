using MediatR;

namespace ZimPay.Application.Commands
{
    public class CreateUserCommand : IRequest<int>
    {
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
    }
}