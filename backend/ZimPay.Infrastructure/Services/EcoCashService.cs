using System;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using ZimPay.Application.Interfaces;
using ZimPay.Application.DTOs;

namespace ZimPay.Infrastructure.Services
{
    public class EcoCashService : IEcoCashService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _config;
        
        private readonly string _baseUrl;
        private readonly string _username;
        private readonly string _password;
        private readonly string _merchantCode;
        private readonly string _merchantPin;
        private readonly string _merchantNumber;
        private readonly string _notifyUrl;

        public EcoCashService(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _config = config;
            
            _baseUrl = _config["EcoCash:BaseUrl"];
            _username = _config["EcoCash:Username"];
            _password = _config["EcoCash:Password"];
            _merchantCode = _config["EcoCash:MerchantCode"];
            _merchantPin = _config["EcoCash:MerchantPin"];
            _merchantNumber = _config["EcoCash:MerchantNumber"];
            _notifyUrl = _config["EcoCash:NotifyUrl"];
        }

        public async Task<string> GetAccessTokenAsync()
        {
            return string.Empty;
        }

        public async Task<string> InitiateMerchantPaymentAsync(string customerPhone, decimal amount, string merchantCode, string referenceCode)
        {
            try
            {
                string formattedPhone = FormatMsisdn(customerPhone);
                string clientCorrelator = Guid.NewGuid().ToString().Substring(0, 8).ToUpper();

                // Ensure the notify URL has the correct endpoint path
                string fullNotifyUrl = _notifyUrl;
                if (!string.IsNullOrEmpty(fullNotifyUrl) && !fullNotifyUrl.Contains("/api/Transaction/ecocash-webhook"))
                {
                    fullNotifyUrl = fullNotifyUrl.TrimEnd('/') + "/api/Transaction/ecocash-webhook";
                }

                var payload = new EcoCashEipRequest
                {
                    clientCorrelator = clientCorrelator,
                    notifyUrl = fullNotifyUrl,
                    referenceCode = referenceCode,
                    tranType = "MER",
                    endUserId = formattedPhone,
                    remarks = "ZimPay Payment",
                    transactionOperationStatus = "Charged",
                    paymentAmount = new PaymentAmount
                    {
                        charginginformation = new ChargingInformation
                        {
                            amount = amount.ToString("F2"),
                            currency = "ZWG",
                            description = "ZimPay Online Payment"
                        },
                        chargeMetaData = new ChargeMetaData { purchaseCategoryCode = "WEB" }
                    },
                    merchantCode = _merchantCode,
                    merchantPin = _merchantPin,
                    merchantNumber = _merchantNumber,
                    countryCode = "ZW",
                    terminalID = "TERM001",
                    location = "Harare",
                    superMerchantName = "EcoCash Sandbox",
                    merchantName = "ZimPay Merchant"
                };

                var request = new HttpRequestMessage(HttpMethod.Post, $"{_baseUrl}/transactions/amount/");

                string authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_username}:{_password}"));
                request.Headers.Authorization = new AuthenticationHeaderValue("Basic", authString);

                request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

                var response = await _httpClient.SendAsync(request);
                string responseContent = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"EcoCash EIP Response: {response.StatusCode} - {responseContent}");

                return response.IsSuccessStatusCode ? clientCorrelator : string.Empty;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EcoCash EIP Error: {ex.Message}");
                return string.Empty;
            }
        }

        public async Task<string> GetTransactionStatusAsync(string endUserId, string clientCorrelator)
        {
            try
            {
                string formattedPhone = FormatMsisdn(endUserId);
                var request = new HttpRequestMessage(HttpMethod.Get, $"{_baseUrl}/{formattedPhone}/transactions/amount/{clientCorrelator}");

                string authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_username}:{_password}"));
                request.Headers.Authorization = new AuthenticationHeaderValue("Basic", authString);

                var response = await _httpClient.SendAsync(request);
                string responseContent = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    var statusResponse = JsonSerializer.Deserialize<EcoCashEipResponse>(responseContent);
                    return statusResponse?.transactionStatus ?? "UNKNOWN";
                }

                return "FAILED";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EcoCash EIP Status Error: {ex.Message}");
                return "ERROR";
            }
        }

        private string FormatMsisdn(string phone)
        {
            if (string.IsNullOrEmpty(phone)) return string.Empty;
            string digitsOnly = new string(phone.Where(char.IsDigit).ToArray());
            if (digitsOnly.Length >= 9)
            {
                return "263" + digitsOnly.Substring(digitsOnly.Length - 9);
            }
            return digitsOnly;
        }
    }
}
