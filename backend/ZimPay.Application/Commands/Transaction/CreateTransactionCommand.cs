using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Commands
{
    public class CreateTransactionCommand : IRequest<int>
    {
        public int UserId { get; set; }
        public CreateTransactionDto Transaction { get; set; }
    }
}
