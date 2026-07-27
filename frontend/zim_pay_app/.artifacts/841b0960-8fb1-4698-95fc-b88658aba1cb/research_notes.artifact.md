# EcoCash EIP Integration Research

## Current State
- **Backend:** .NET Web API (C#)
- **EcoCash Service:** `EcoCashService.cs` uses an old V2 API with `X-API-KEY`.
- **Configuration:** `appsettings.json` has old `EcoCash` section.
- **Frontend:** Flutter app calling the .NET backend.

## New EcoCash EIP API Requirements
- **Base URL:** `https://developers.ecocash.co.zw/sandbox/payment/v1`
- **Authentication:** Basic Auth (`sbx_abdd14d42307:c7Z@n$mTQ85mWWB8vdZM`)
- **Endpoints:**
    - Initiate Payment (POST): `/transactions/amount/`
    - Check Status (GET): `/{endUserId}/transactions/amount/{clientCorrelator}`
    - Refund (POST): `/transactions/refund/`

## Proposed Changes
1. **Update `appsettings.json`:** Replace `EcoCash` section with `EIP` (or update existing).
2. **Update `IEcoCashService.cs`:** Add status check and potentially change return types to include more detail.
3. **Update `EcoCashService.cs`:**
    - Use Basic Authentication.
    - Implement `InitiatePaymentAsync` with the new payload structure.
    - Implement `GetTransactionStatusAsync`.
4. **Create DTOs:** Define `PaymentRequest`, `PaymentAmount`, `ChargingInfo`, `ChargeMetaData`, and `TransactionResponse` in the C# backend.

## New Payload Structure (C#)
```csharp
public class PaymentRequest
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
    public ChargingInfo charginginformation { get; set; }
    public ChargeMetaData chargeMetaData { get; set; }
}

public class ChargingInfo
{
    public string amount { get; set; }
    public string currency { get; set; }
    public string description { get; set; }
}

public class ChargeMetaData
{
    public string purchaseCategoryCode { get; set; }
    public ChargeMetaData(string code) => purchaseCategoryCode = code;
}
```
