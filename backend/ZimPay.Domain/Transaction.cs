using System;
using System.ComponentModel.DataAnnotations;

namespace ZimPay.Domain
{
    public class Transaction
    {
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } // "Payment", "Transfer", "TopUp", "Refund"
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Amount { get; set; }
        
        [MaxLength(500)]
        public string Description { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Pending"; // "Completed", "Pending", "Declined", "Cancelled"
        
        public DateTime Date { get; set; }
        public DateTime? CompletedAt { get; set; }
        
        public int? RecipientUserId { get; set; } // For transfers
        public int? PaymentMethodId { get; set; }
        
        // Navigation properties
        public User User { get; set; }
        public User Recipient { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
    }
}
