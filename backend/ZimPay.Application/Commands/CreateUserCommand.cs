using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class CreateUserCommand : IRequest<ApiResponse<UserDto>>
    {
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public string Pin { get; set; } // Added PIN to command
    }
}
