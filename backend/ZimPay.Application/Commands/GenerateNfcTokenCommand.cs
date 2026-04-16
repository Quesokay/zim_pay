using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class GenerateNfcTokenCommand : IRequest<ApiResponse<string>>
    {
        public int UserId { get; set; }
    }
}