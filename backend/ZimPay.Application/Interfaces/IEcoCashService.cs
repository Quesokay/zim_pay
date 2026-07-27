using System.Threading.Tasks;

namespace ZimPay.Application.Interfaces
{
    public interface IEcoCashService
    {
        Task<string> GetAccessTokenAsync();
        
        /// <summary>
        /// Initiates an EcoCash Merchant Payment prompt on the customer's phone using EIP API.
        /// Returns the clientCorrelator if successful.
        /// </summary>
        Task<string> InitiateMerchantPaymentAsync(string customerPhone, decimal amount, string merchantCode, string referenceCode);

        /// <summary>
        /// Checks the status of a transaction.
        /// </summary>
        Task<string> GetTransactionStatusAsync(string endUserId, string clientCorrelator);
    }
}