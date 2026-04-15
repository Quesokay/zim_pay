using MediatR;

namespace ZimPay.Application.Commands.Transaction
{
    public class ApproveTransactionCommand : IRequest<bool>
    {
        public int TransactionId { get; set; }

        public ApproveTransactionCommand(int transactionId)
        {
            TransactionId = transactionId;
        }
    }
}
