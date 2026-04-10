using System.Threading;
using System.Threading.Tasks;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;
using MediatR;

namespace ZimPay.Application.Handlers
{
    public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, int>
    {
        private readonly IUserRepository _userRepository;

        public CreateUserCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<int> Handle(CreateUserCommand request, CancellationToken cancellationToken)
        {
            var user = new User
            {
                Email = request.Email,
                Name = request.Name,
                Phone = request.Phone,
                Balance = 0,
                CreatedAt = DateTime.UtcNow
            };

            await _userRepository.AddAsync(user);
            return user.Id;
        }
    }
}