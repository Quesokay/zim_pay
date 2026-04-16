using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, ApiResponse<UserDto>>
    {
        private readonly IUserRepository _userRepository;

        public CreateUserCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<ApiResponse<UserDto>> Handle(CreateUserCommand request, CancellationToken cancellationToken)
        {
            // Check if user with this email already exists
            var existingUser = await _userRepository.GetByEmailAsync(request.Email);
            if (existingUser != null)
                throw new InvalidOperationException($"User with email {request.Email} already exists.");

            // 1. Generate a secure, unique token for their physical NFC tag
            string generatedNfcToken = $"ZIMPAY-ID-{Guid.NewGuid()}";

            var newUser = new User
            {
                Name = request.Name,
                Email = request.Email,
                Phone = request.Phone,
                NfcIdentityToken = generatedNfcToken, // Save it to the database
                CreatedAt = DateTime.UtcNow,
                IsActive = true,
                TapLimit = 50.00m // Default tap limit
            };

            await _userRepository.AddAsync(newUser);

            // 2. Return the user data AND the newly generated token back to Flutter
            var userDto = new UserDto
            {
                Id = newUser.Id,
                Name = newUser.Name,
                Email = newUser.Email,
                Phone = newUser.Phone,
                CreatedAt = newUser.CreatedAt,
                IsActive = newUser.IsActive,
                FingerprintEnabled = newUser.FingerprintEnabled,
                ContactlessEnabled = newUser.ContactlessEnabled,
                TapLimit = newUser.TapLimit,
                // We pass this back specifically so Flutter can write it to the tag
                NfcIdentityToken = generatedNfcToken
            };

            return new ApiResponse<UserDto>
            {
                Success = true,
                Message = "User registered successfully.",
                Data = userDto
            };
        }
    }
}
