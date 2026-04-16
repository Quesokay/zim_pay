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
        
        public string CardNumber { get; set; } // We will now ensure this only holds "•••• 1234"

        [MaxLength(500)]
        public string DigitalToken { get; set; } // Store the JWT here
        
        [MaxLength(100)]
        public string BankName { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string AccountNumber { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string HolderName { get; set; } = string.Empty;
        
        public string ExpiryDate { get; set; } = string.Empty; // For cards: MM/YY
        public decimal Balance { get; set; }
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime AddedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        
        
        // Navigation properties
        public User User { get; set; }
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();

        public void DeductFunds(decimal amount)
        {
            if (Balance < amount)
                throw new System.InvalidOperationException("Insufficient funds on this payment method.");
            
            Balance -= amount;
        }
    }
}