using System;

namespace ZimPay.Application.DTOs
{
    public class TransactionDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public string Status { get; set; }
        public DateTime Date { get; set; }
        public DateTime? CompletedAt { get; set; }
        public int? RecipientUserId { get; set; }
        public int? PaymentMethodId { get; set; }
        public UserDto User { get; set; }
        public UserDto Recipient { get; set; }
    }

    public class CreateTransactionDto
    {
        public string Type { get; set; } // "Payment", "Transfer", "TopUp", "Refund"
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public int? RecipientUserId { get; set; }
        public int? PaymentMethodId { get; set; }
    }

    public class UpdateTransactionStatusDto
    {
        public string Status { get; set; } // "Completed", "Pending", "Declined", "Cancelled"
    }
}
