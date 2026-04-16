using System;
using System.Collections.Generic;

namespace ZimPay.Application.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; }
        public bool FingerprintEnabled { get; set; }
        public bool ContactlessEnabled { get; set; }
        public decimal TapLimit { get; set; }
    }

    public class UserDetailDto
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; }
        public bool FingerprintEnabled { get; set; }
        public bool ContactlessEnabled { get; set; }
        public decimal TapLimit { get; set; }

        public List<PaymentMethodDto> PaymentMethods { get; set; } = new();
        public List<TransactionDto> Transactions { get; set; } = new();
        public List<PassDto> Passes { get; set; } = new();
    }

    public class CreateUserDto
    {
        public string Email { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
    }

    public class UpdateUserDto
    {
        public string? Name { get; set; }
        public string? Phone { get; set; }
        public bool? FingerprintEnabled { get; set; }
        public bool? ContactlessEnabled { get; set; }
        public decimal? TapLimit { get; set; }
    }
}
