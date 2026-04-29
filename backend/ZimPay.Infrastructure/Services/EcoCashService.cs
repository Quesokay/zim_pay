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
        
        private readonly string _consumerKey;
        private readonly string _consumerSecret;
        private readonly string _baseUrl;

        public EcoCashService(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _config = config;
            
            _consumerKey = _config["EcoCash:ConsumerKey"];
            _consumerSecret = _config["EcoCash:ConsumerSecret"];
            _baseUrl = _config["EcoCash:BaseUrl"]; 
        }

        public async Task<string> GetAccessTokenAsync()
        {
            // EcoCash OAuth2 Basic Authentication
            var credentials = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_consumerKey}:{_consumerSecret}"));

            var request = new HttpRequestMessage(HttpMethod.Post, $"{_baseUrl}/oauth2/token");
            request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
            request.Content = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/x-www-form-urlencoded");

            var response = await _httpClient.SendAsync(request);
            response.EnsureSuccessStatusCode();

            var responseString = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(responseString);
            
            return document.RootElement.GetProperty("access_token").GetString();
        }

        public async Task<bool> InitiateMerchantPaymentAsync(string customerPhone, decimal amount, string merchantCode, string referenceCode)
        {
            try
            {
                var token = await GetAccessTokenAsync();

                // Payload matches exactly with the provided EcoCash API documentation image
                var payload = new
                {
                    clientCorrelator = Guid.NewGuid().ToString(), // Unique ID per request
                    notifyUrl = _config["EcoCash:NotifyUrl"],     // Where EcoCash sends the success receipt
                    referenceCode = referenceCode,
                    tranType = "MERCH",
                    amount = amount.ToString("0.00"),             // API requires string formatted to 2 decimal places
                    currency = "ZWL",                             // Or USD based on your sandbox setup
                    customerMsisdn = customerPhone,               // e.g., "0771234567"
                    merchantCode = merchantCode                   // e.g., "12345"
                };

                var request = new HttpRequestMessage(HttpMethod.Post, $"{_baseUrl}/transactions/merchantPay");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
                request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

                var response = await _httpClient.SendAsync(request);
                
                // Returns true if EcoCash responds with 200/201 (Push prompt successfully sent to phone)
                return response.IsSuccessStatusCode; 
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EcoCash API Error: {ex.Message}");
                return false;
            }
        }
    }
}