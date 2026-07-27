using MediatR;

namespace ZimPay.Application.Commands.Transaction
{
    public class ProcessEcoCashCallbackCommand : IRequest<bool>
    {
        public string ReferenceCode { get; set; }
        public string ClientCorrelator { get; set; }
        public string TransactionStatus { get; set; } // e.g., "COMPLETED" or "SUCCESS"
    }
}