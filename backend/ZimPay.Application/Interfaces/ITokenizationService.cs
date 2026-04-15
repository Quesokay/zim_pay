using ZimPay.Application.DTOs;
using ZimPay.Domain;

namespace ZimPay.Application.Interfaces
{
    public interface ITokenizationService
    {
        string GenerateDigitalToken(PaymentMethod paymentMethod, string rawCardNumber);
        bool ValidateDigitalToken(string token);
    }
}