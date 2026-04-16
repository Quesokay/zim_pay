using MediatR;

namespace ZimPay.Application.Commands.Transaction
{
    public class ProcessTransactionCommand : IRequest<bool>
    {
        public string DigitalToken { get; set; }
        public decimal Amount { get; set; }
        public string MerchantName { get; set; }
    }
}