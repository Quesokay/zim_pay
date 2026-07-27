using System;
using System.Text.Json.Serialization;

namespace ZimPay.Application.DTOs
{
    public class EcoCashEipRequest
    {
        public string clientCorrelator { get; set; }
        public string notifyUrl { get; set; }
        public string referenceCode { get; set; }
        public string tranType { get; set; }
        public string endUserId { get; set; }
        public string remarks { get; set; }
        public string transactionOperationStatus { get; set; }
        public PaymentAmount paymentAmount { get; set; }
        public string merchantCode { get; set; }
        public string merchantPin { get; set; }
        public string merchantNumber { get; set; }
        public string countryCode { get; set; }
        public string terminalID { get; set; }
        public string location { get; set; }
        public string superMerchantName { get; set; }
        public string merchantName { get; set; }
    }

    public class PaymentAmount
    {
        public ChargingInformation charginginformation { get; set; }
        public ChargeMetaData chargeMetaData { get; set; }
    }

    public class ChargingInformation
    {
        public decimal amount { get; set; }
        public string currency { get; set; }
        public string description { get; set; }
    }

    public class ChargeMetaData
    {
        public string channel { get; set; }
    }

    public class EcoCashEipResponse
    {
        public long id { get; set; }
        public int version { get; set; }
        public string clientCorrelator { get; set; }
        public long? endTime { get; set; }
        public long? startTime { get; set; }
        public string notifyUrl { get; set; }
        public string referenceCode { get; set; }
        public string endUserId { get; set; }
        public string serverReferenceCode { get; set; }
        public string transactionOperationStatus { get; set; }
        public string status { get; set; }
        public string statusMessage { get; set; }
        public string statusCode { get; set; }
        public PaymentAmountResponse paymentAmount { get; set; }
        public string merchantCode { get; set; }
        public string merchantPin { get; set; }
        public string merchantNumber { get; set; }
        public string notificationFormat { get; set; }
        public long transactionDate { get; set; }
        public string countryCode { get; set; }
        public string currencyCode { get; set; }
        public string superMerchantName { get; set; }
        public string remarks { get; set; }
        public string text { get; set; }

        // Robust status mapping
        public string transactionStatus
        {
            get
            {
                if (!string.IsNullOrEmpty(statusMessage) && statusMessage.Contains("Successful", StringComparison.OrdinalIgnoreCase))
                    return "SUCCESS";

                return transactionOperationStatus ?? status ?? "UNKNOWN";
            }
        }
    }

    public class PaymentAmountResponse
    {
        public decimal totalAmountCharged { get; set; }
        public ChargingInformation charginginformation { get; set; }
        public ChargeMetaData chargeMetaData { get; set; }
    }
}
