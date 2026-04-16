using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;
using System.Threading;
using System.Threading.Tasks;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, UserDetailDto>
    {
        private readonly IUserRepository _userRepository;

        public UpdateUserCommandHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<UserDetailDto> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(request.Id);

            if (user == null)
                return null;

            if (request.Name != null) user.Name = request.Name;
            if (request.Phone != null) user.Phone = request.Phone;
            if (request.FingerprintEnabled.HasValue) user.FingerprintEnabled = request.FingerprintEnabled.Value;
            if (request.ContactlessEnabled.HasValue) user.ContactlessEnabled = request.ContactlessEnabled.Value;
            if (request.TapLimit.HasValue) user.TapLimit = request.TapLimit.Value;

            user.UpdatedAt = System.DateTime.UtcNow;

            await _userRepository.UpdateAsync(user);

            return new UserDetailDto
            {
                Id = user.Id,
                Email = user.Email,
                Name = user.Name,
                Phone = user.Phone,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt,
                FingerprintEnabled = user.FingerprintEnabled,
                ContactlessEnabled = user.ContactlessEnabled,
                TapLimit = user.TapLimit
            };
        }
    }
}