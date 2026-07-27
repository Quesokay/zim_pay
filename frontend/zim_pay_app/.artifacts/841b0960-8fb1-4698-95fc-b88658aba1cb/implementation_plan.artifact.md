# Implementation Plan - Official Sandbox Alignment

Align the backend with the official EcoCash EIP Sandbox documentation as shown in the provided image.

## User Review Required

> [!IMPORTANT]
> We are sticking to the **official sandbox URL** (`https://developers.ecocash.co.zw/sandbox/payment/v1`) and endpoints as per the documentation image, bypassing the `localhost:8080` trial.

## Proposed Changes

### [Backend] Configuration

#### [MODIFY] [appsettings.json](file:///C:/Sources/zim_pay/backend/ZimPay.Presentation/appsettings.json)
- Re-verify `EcoCash:BaseUrl` is `https://developers.ecocash.co.zw/sandbox/payment/v1`.

### [Backend] Infrastructure Layer (Services)

#### [MODIFY] [EcoCashService.cs](file:///C:/Sources/zim_pay/backend/ZimPay.Infrastructure/Services/EcoCashService.cs)
- **Initiate Payment:**
    - Target URI: `$"{_baseUrl}/transactions/amount/"`.
    - Authorization: Ensure `Basic c2J4X2...` is correctly generated.
    - Payload: Use the numeric 10-digit `clientCorrelator` and `TEST_` reference code prefix.
- **Status Lookup:**
    - Target URI: `$"{_baseUrl}/{formattedPhone}/transactions/amount/{clientCorrelator}"`.

## Verification Plan

### Manual Verification
- Log and verify the full request URL and headers to ensure they match:
    - URL: `https://developers.ecocash.co.zw/sandbox/payment/v1/transactions/amount/`
    - Auth: `Basic c2J4X2FiZGQxNGQ0MjMwNzpjN1pAbiRtVFE4NW1XV0I4dmRaTQ==`
