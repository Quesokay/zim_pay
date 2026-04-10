using System;
using System.ComponentModel.DataAnnotations;

namespace ZimPay.Domain
{
    public class PaymentMethod
    {
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } // "CreditCard", "DebitCard", "BankAccount"
        
        [MaxLength(20)]
        public string CardNumber { get; set; } = string.Empty; // Last 4 digits and masked
        
        [MaxLength(100)]
        public string BankName { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string AccountNumber { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string HolderName { get; set; } = string.Empty;
        
        public string ExpiryDate { get; set; } = string.Empty; // For cards: MM/YY
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime AddedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        
        // Navigation properties
        public User User { get; set; }
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }
}