using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class UpdateUserCommand : IRequest<UserDetailDto>
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Phone { get; set; }
        public bool? FingerprintEnabled { get; set; }
        public bool? ContactlessEnabled { get; set; }
        public decimal? TapLimit { get; set; }

        public UpdateUserCommand(int id, UpdateUserDto dto)
        {
            Id = id;
            Name = dto.Name;
            Phone = dto.Phone;
            FingerprintEnabled = dto.FingerprintEnabled;
            ContactlessEnabled = dto.ContactlessEnabled;
            TapLimit = dto.TapLimit;
        }
    }
}