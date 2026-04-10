using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using GoogleWalletClone.Application.Commands;
using GoogleWalletClone.Application.Interfaces;
using GoogleWalletClone.Domain;

namespace GoogleWalletClone.Application.Handlers.CommandHandlers
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
            // Check if user with this email already exists
            var existingUser = await _userRepository.GetByEmailAsync(request.Email);
            if (existingUser != null)
                throw new InvalidOperationException($"User with email {request.Email} already exists.");

            var user = new User
            {
                Email = request.Email,
                Name = request.Name,
                Phone = request.Phone,
                Balance = 0,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            await _userRepository.AddAsync(user);
            return user.Id;
        }
    }
}
