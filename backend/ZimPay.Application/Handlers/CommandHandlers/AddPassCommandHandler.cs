using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using GoogleWalletClone.Application.Commands;
using GoogleWalletClone.Application.Interfaces;
using GoogleWalletClone.Domain;

namespace GoogleWalletClone.Application.Handlers.CommandHandlers
{
    public class AddPassCommandHandler : IRequestHandler<AddPassCommand, int>
    {
        private readonly IPassRepository _passRepository;
        private readonly IUserRepository _userRepository;

        public AddPassCommandHandler(
            IPassRepository passRepository,
            IUserRepository userRepository)
        {
            _passRepository = passRepository;
            _userRepository = userRepository;
        }

        public async Task<int> Handle(AddPassCommand request, CancellationToken cancellationToken)
        {
            // Verify user exists
            var userExists = await _userRepository.ExistsAsync(request.UserId);
            if (!userExists)
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");

            var pass = new Pass
            {
                UserId = request.UserId,
                Type = request.Pass.Type,
                Title = request.Pass.Title,
                Details = request.Pass.Details,
                IssuerId = request.Pass.IssuerId,
                IssuerName = request.Pass.IssuerName,
                PassNumber = request.Pass.PassNumber,
                Barcode = request.Pass.Barcode,
                Balance = request.Pass.Balance,
                Color = request.Pass.Color,
                ImageUrl = request.Pass.ImageUrl,
                IssuedAt = DateTime.UtcNow,
                ExpiresAt = request.Pass.ExpiresAt,
                IsActive = true
            };

            await _passRepository.AddAsync(pass);
            return pass.Id;
        }
    }
}
