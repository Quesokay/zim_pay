using System.Threading.Tasks;

namespace ZimPay.Application.Interfaces
{
    public interface IEcoCashService
    {
        Task<string> GetAccessTokenAsync();
        
        /// <summary>
        /// Initiates an EcoCash Merchant Payment prompt on the customer's phone.
        /// </summary>
        Task<bool> InitiateMerchantPaymentAsync(string customerPhone, decimal amount, string merchantCode, string referenceCode);
    }
}