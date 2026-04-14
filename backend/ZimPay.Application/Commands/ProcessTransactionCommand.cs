using MediatR;

namespace ZimPay.Application.Commands
{
    public class ProcessTransactionCommand : IRequest<bool>
    {
        public string DigitalToken { get; set; }
        public decimal Amount { get; set; }
    }
}