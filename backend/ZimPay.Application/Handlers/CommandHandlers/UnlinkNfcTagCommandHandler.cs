using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class UnlinkNfcTagCommandHandler : IRequestHandler<UnlinkNfcTagCommand, ApiResponse<bool>>
    {
        private readonly IUserRepository _userRepository;

        public UnlinkNfcTagCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<ApiResponse<bool>> Handle(UnlinkNfcTagCommand request, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);

            if (user == null)
            {
                return ApiResponse<bool>.ErrorResponse("User not found.");
            }

            // ✨ THE KILL SWITCH ✨
            // We wipe the token from the database. The physical tag now points to nothing.
            user.NfcIdentityToken = string.Empty;

            await _userRepository.UpdateAsync(user);

            return ApiResponse<bool>.SuccessResponse(true, "Tag unlinked successfully. Your bank cards are safe, but the physical tag is now deactivated.");
        }
    }
}