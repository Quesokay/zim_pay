using System;

namespace ZimPay.Application.DTOs
{
    public class PassDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; }
        public string Title { get; set; }
        public string Details { get; set; }
        public string IssuerId { get; set; }
        public string IssuerName { get; set; }
        public string PassNumber { get; set; }
        public string Barcode { get; set; }
        public decimal? Balance { get; set; }
        public string Color { get; set; }
        public string ImageUrl { get; set; }
        public DateTime IssuedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; }
    }

    public class CreatePassDto
    {
        public string Type { get; set; } // "Ticket", "Loyalty", "TransitPass", "BoardingPass", "EventPass"
        public string Title { get; set; }
        public string Details { get; set; }
        public string IssuerId { get; set; }
        public string IssuerName { get; set; }
        public string PassNumber { get; set; }
        public string Barcode { get; set; }
        public decimal? Balance { get; set; }
        public string Color { get; set; }
        public string ImageUrl { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class UpdatePassDto
    {
        public string Title { get; set; }
        public string Details { get; set; }
        public decimal? Balance { get; set; }
        public bool IsActive { get; set; }
    }
}
