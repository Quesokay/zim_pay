using System;
using System.ComponentModel.DataAnnotations;

namespace ZimPay.Domain
{
    public class Pass
    {
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } // "Ticket", "Loyalty", "TransitPass", "BoardingPass", "EventPass"
        
        [Required]
        [MaxLength(200)]
        public string Title { get; set; }
        
        [Required]
        [MaxLength(1000)]
        public string Details { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string IssuerId { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string IssuerName { get; set; } = string.Empty;
        
        [MaxLength(200)]
        public string PassNumber { get; set; } = string.Empty;
        
        public string Barcode { get; set; } = string.Empty;
        
        [Range(0, double.MaxValue)]
        public decimal? Balance { get; set; } // For passes with balance
        
        [MaxLength(50)]
        public string Color { get; set; } = string.Empty; // Primary color in hex
        
        [MaxLength(500)]
        public string ImageUrl { get; set; } = string.Empty;
        
        public DateTime IssuedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; } = true;
        
        // Navigation property
        public User User { get; set; }
    }
}