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
        private readonly string _terminalID;
        private readonly string _superMerchantName;
        private readonly string _merchantName;
        private readonly string _channel;
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
            _terminalID = _config["EcoCash:TerminalID"];
            _superMerchantName = _config["EcoCash:SuperMerchantName"];
            _merchantName = _config["EcoCash:MerchantName"];
            _channel = _config["EcoCash:Channel"];
            _notifyUrl = _config["EcoCash:NotifyUrl"];

            // Cloudflare/WAF block fixes: Set standard headers
            _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
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

                // EcoCash Sandbox requirement: 10-digit numeric correlator
                string clientCorrelator = DateTime.UtcNow.Ticks.ToString().Substring(0, 10);

                // referenceCode: TEST_{correlator} as per example
                string finalRefCode = $"TEST_{clientCorrelator}";

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
                    referenceCode = finalRefCode,
                    tranType = "MER",
                    endUserId = formattedPhone,
                    remarks = "EcoCash Sandbox",
                    transactionOperationStatus = "Charged",
                    paymentAmount = new PaymentAmount
                    {
                        charginginformation = new ChargingInformation
                        {
                            amount = amount,
                            currency = "USD",
                            description = _merchantName
                        },
                        chargeMetaData = new ChargeMetaData { channel = _channel }
                    },
                    merchantCode = _merchantCode,
                    merchantPin = _merchantPin,
                    merchantNumber = _merchantNumber,
                    countryCode = "ZW",
                    terminalID = _terminalID,
                    location = "Harare",
                    superMerchantName = _superMerchantName,
                    merchantName = _merchantName
                };

                var request = new HttpRequestMessage(HttpMethod.Post, $"{_baseUrl}/transactions/amount/");

                string authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_username}:{_password}"));
                request.Headers.Authorization = new AuthenticationHeaderValue("Basic", authString);

                Console.WriteLine($"[DEBUG] Auth Header: Basic {authString}");
                Console.WriteLine($"[DEBUG] Target URL: {request.RequestUri}");

                request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

                var response = await _httpClient.SendAsync(request);
                string responseContent = await response.Content.ReadAsStringAsync();

                Console.WriteLine($"EcoCash EIP Initiate Response: {response.StatusCode}");
                Console.WriteLine($"Body: {responseContent}");

                return response.IsSuccessStatusCode ? clientCorrelator : string.Empty;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EcoCash EIP Initiate Error: {ex.Message}");
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
                    string status = statusResponse?.transactionStatus ?? "UNKNOWN";
                    Console.WriteLine($"EcoCash Status Lookup for {clientCorrelator}: {status}");
                    return status;
                }

                Console.WriteLine($"EcoCash Status Lookup Failed: {response.StatusCode} - {responseContent}");
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

            // Remove all non-numeric characters
            string digitsOnly = new string(phone.Where(char.IsDigit).ToArray());

            // For EcoCash Sandbox, MSISDN is usually 9 digits (e.g. 773047653)
            // But documentation also shows 263...
            // I'll trim to last 9 digits to be safe as per the '773...' example
            if (digitsOnly.Length >= 9)
            {
                return digitsOnly.Substring(digitsOnly.Length - 9);
            }

            return digitsOnly;
        }
    }
}
