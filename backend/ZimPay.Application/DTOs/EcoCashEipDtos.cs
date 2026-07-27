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
        public string amount { get; set; }
        public string currency { get; set; }
        public string description { get; set; }
    }

    public class ChargeMetaData
    {
        public string purchaseCategoryCode { get; set; }
    }

    public class EcoCashEipResponse
    {
        public string transactionStatus { get; set; }
        public string clientCorrelator { get; set; }
        public string referenceCode { get; set; }
        public string serverReference { get; set; }
        // Add other fields as needed from the actual API response
    }
}
