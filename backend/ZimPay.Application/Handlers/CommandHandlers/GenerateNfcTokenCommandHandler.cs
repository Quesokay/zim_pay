using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class GenerateNfcTokenCommandHandler : IRequestHandler<GenerateNfcTokenCommand, ApiResponse<string>>
    {
        private readonly IUserRepository _userRepository;

        public GenerateNfcTokenCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<ApiResponse<string>> Handle(GenerateNfcTokenCommand request, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);

            if (user == null)
                return ApiResponse<string>.ErrorResponse("User not found.");

            // Generate a brand new token
            string newNfcToken = $"ZIMPAY-ID-{Guid.NewGuid()}";

            // Save it to the user's profile
            user.NfcIdentityToken = newNfcToken;
            await _userRepository.UpdateAsync(user);

            return ApiResponse<string>.SuccessResponse(newNfcToken, "New tag token generated.");
        }
    }
}