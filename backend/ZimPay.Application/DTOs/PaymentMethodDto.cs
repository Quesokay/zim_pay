using System;

namespace ZimPay.Application.DTOs
{
    public class PaymentMethodDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; }
        public string CardNumber { get; set; }
        public string BankName { get; set; }
        public string AccountNumber { get; set; }
        public string HolderName { get; set; }
        public string ExpiryDate { get; set; }
        public decimal Balance { get; set; }
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; }
        public DateTime AddedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string DigitalToken { get; set; }
    }

    public class CreatePaymentMethodDto
    {
        public string Type { get; set; } // "CreditCard", "DebitCard", "BankAccount"
        public string CardNumber { get; set; }
        public string BankName { get; set; }
        public string AccountNumber { get; set; }
        public string HolderName { get; set; }
        public string ExpiryDate { get; set; }
        public bool IsDefault { get; set; }
        public decimal Balance { get; set; }
    }

    public class UpdatePaymentMethodDto
    {
        public string HolderName { get; set; }
        public string ExpiryDate { get; set; }
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; }
    }
}
