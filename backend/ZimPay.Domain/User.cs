using System;
using System.Collections.Generic;

namespace ZimPay.Domain
{
    public class User
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public string NfcIdentityToken { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; } = true;
        public bool FingerprintEnabled { get; set; } = true;
        public bool ContactlessEnabled { get; set; } = true;
        public decimal TapLimit { get; set; } = 50.00m;

        // Navigation properties
        public ICollection<PaymentMethod> PaymentMethods { get; set; } = new List<PaymentMethod>();
        public ICollection<Transaction> SentTransactions { get; set; } = new List<Transaction>();
        public ICollection<Transaction> ReceivedTransactions { get; set; } = new List<Transaction>();
        public ICollection<Pass> Passes { get; set; } = new List<Pass>();
    }
}