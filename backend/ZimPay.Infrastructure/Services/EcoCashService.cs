using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using ZimPay.Application.Interfaces;

namespace ZimPay.Infrastructure.Services
{
    public class EcoCashService : IEcoCashService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _config;
        
        private readonly string _apiKey;
        private readonly string _merchantCode;
        private readonly string _baseUrl;

        public EcoCashService(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _config = config;
            
            _apiKey = _config["EcoCash:ApiKey"];
            _merchantCode = _config["EcoCash:MerchantCode"];
            _baseUrl = _config["EcoCash:BaseUrl"]; 
        }

        public async Task<string> GetAccessTokenAsync()
        {
            // EcoCash V2 Sandbox typically uses X-API-KEY directly in headers for specific endpoints
            // Keeping this for compatibility with other parts of the system if needed
            return string.Empty;
        }

        public async Task<bool> InitiateMerchantPaymentAsync(string customerPhone, decimal amount, string merchantCode, string referenceCode)
        {
            try
            {
                // Format the phone number to numeric-only 12-digit 263... format
                string formattedPhone = FormatMsisdn(customerPhone);

                // Using the specific V2 sandbox endpoint provided in the image
                string endpoint = $"{_baseUrl}/api/v2/payment/instant/c2b/sandbox";

                var payload = new
                {
                    customerMsisdn = formattedPhone,
                    amount = amount, // Numeric as per image
                    reason = "Payment",
                    currency = "USD",
                    sourceReference = Guid.NewGuid().ToString() // Valid UUID as per image
                };

                var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
                request.Headers.Add("X-API-KEY", _apiKey);
                request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

                var response = await _httpClient.SendAsync(request);
                
                string responseContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"EcoCash V2 Response: {response.StatusCode} - {responseContent}");

                return response.IsSuccessStatusCode; 
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EcoCash API V2 Error: {ex.Message}");
                return false;
            }
        }

        private string FormatMsisdn(string phone)
        {
            if (string.IsNullOrEmpty(phone)) return string.Empty;

            // Remove all non-numeric characters (including '+')
            string digitsOnly = new string(phone.Where(char.IsDigit).ToArray());

            // Extract last 9 digits and prefix with 263
            if (digitsOnly.Length >= 9)
            {
                return "263" + digitsOnly.Substring(digitsOnly.Length - 9);
            }

            return digitsOnly;
        }
    }
}