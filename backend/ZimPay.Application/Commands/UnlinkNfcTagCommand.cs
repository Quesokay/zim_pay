using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class UnlinkNfcTagCommand : IRequest<ApiResponse<bool>>
    {
        public int UserId { get; set; }
    }
}