# Walkthrough - EcoCash EIP Sandbox Integration

I have updated the backend to integrate with the new EcoCash EIP (Express Interaction Platform) Sandbox API. This update transitions the payment initiation logic from the legacy V2 API to the modern EIP system.

## Changes Made

### 1. Configuration Update
Updated `appsettings.json` in `ZimPay.Presentation` with the new EIP Sandbox credentials and Ngrok Notify URL:
- **Base URL:** `https://developers.ecocash.co.zw/sandbox/payment/v1`
- **Merchant Details:** Updated `MerchantCode`, `MerchantPin`, and `MerchantNumber`.
- **Authentication:** Added `Username` and `Password` for Basic Auth.
- **Notify URL:** Set to the base ngrok URL `https://edition-pecan-evacuate.ngrok-free.dev`.

### 2. DTO Definition
Created and refined `EcoCashEipDtos.cs` in `ZimPay.Application/DTOs` to perfectly match the sandbox API:
- **Request Payload:** Renamed `purchaseCategoryCode` to `channel` as required by the latest EIP documentation.
- **Enhanced Response:** Expanded `EcoCashEipResponse` to capture all 20+ fields from the sandbox, including `transactionOperationStatus`, `text`, and `statusMessage`.
- **Intelligent Status Mapping:** Implemented logic to normalize diverse status indicators (e.g., mapping "Transaction Successful" messages to a standard `SUCCESS` state).

### 3. Service Implementation
Modified `EcoCashService.cs` in `ZimPay.Infrastructure/Services`:
- **Official Documentation Alignment:** Re-verified all endpoints against the provided documentation image (POST `/transactions/amount/` and GET `/{endUserId}/transactions/amount/{correlator}`).
- **Merchant Credential Update:** Switched to the `001535` merchant profile with `UAT00003` terminal ID and `POS` channel.
- **Enhanced Debugging:** Added explicit console logging for the `Authorization` header and target URL to verify standard `Basic c2J4X2FiZGQxNGQ0MjMwNzpjN1pAbiRtVFE4NW1XV0I4dmRaTQ==` usage.
- **WAF/Cloudflare Compatibility:** Maintained standard `User-Agent` and `Accept` headers to bypass automated bot detection blocks.

### 4. Controller & Handler Updates
Modified `TransactionController.cs` in `ZimPay.Presentation`:
- **Status Check Endpoint:** Added `GET /ecocash-status/{endUserId}/{clientCorrelator}` to expose the status check functionality.
- **Detailed Responses:** Updated `POST /process` to return structured JSON with `isEcoCash` and `clientCorrelator` info instead of simple booleans.
- **Improved Webhook:** Enhanced the `ecocash-webhook` to extract `clientCorrelator` and `referenceCode` from the EIP payload.

Refined Application Layer logic:
- **Identifier Tracking:** Updated handlers to store the `clientCorrelator` in the transaction records.
- **Command Return Type:** Changed `ProcessTransactionCommand` to return an `object` (DTO) for rich frontend feedback.

### 5. Database Schema & Persistence
Optimized the backend data layer for faster EcoCash lookups:
- **New Columns:** Added `ReferenceCode` and `ClientCorrelator` to the `Transactions` table.
- **Migration:** Successfully ran a database migration to apply these schema changes.
- **Repository Optimization:** Implemented `GetByEcoCashIdentifiersAsync` in the repository, replacing inefficient in-memory filtering with direct indexed database queries.

## Frontend Integration

### 1. Model & Repository Enhancements
- **Transaction Model:** Added `isEcoCash` and `clientCorrelator` detection logic.
- **Transaction Repository:** Added `getEcoCashStatus` to poll the new backend status endpoint.

### 2. Merchant Experience (POS Screen)
- **Real-time Polling:** Added a "Processing EcoCash Payment" dialog that polls the backend every 2 seconds after a push is sent.
- **Robust Status Handling:** The polling mechanism now recognizes `CHARGED` as a successful state and handles `EXPIRED` or `CANCELLED` errors gracefully.
- **Live Feedback:** The merchant now sees a success dialog *only* after the customer has successfully entered their PIN on their phone.

### 3. Customer Experience (Home Screen)
- **Contextual Alerts:** Pending EcoCash transactions now show as "EcoCash PIN Required" with a distinct green theme and mobile icon.
- **Status Refresh:** The "Check" button allows users to manually trigger a refresh to see if their payment was finalized.

## Verification Results

### Configuration Check
- Verified `appsettings.json` matches the provided sandbox credentials.
- Verified `HttpClient` is correctly registered in `Program.cs`.

### Code Review
- The payload structure in `EcoCashService.cs` now correctly maps to the EcoCash EIP requirements:
    - Currency: `ZWG` (Zimbabwe Gold)
    - TranType: `MER`
    - Category: `WEB`

### 4. Build & Reliability Fixes
- **Import Resolution:** Fixed compilation errors by adding missing `dart:async` and `transaction.dart` imports in `merchant_pos_screen.dart` and `home_screen.dart`.
- **Type Safety:** Ensured `Transaction` type is recognized in widget builder functions.

## How to Test
1. Start the backend server.
2. Trigger a payment from the ZimPay app (or use Swagger on the `Transaction/process` endpoint).
3. Monitor the console logs for the "EcoCash EIP Response". You should see a successful initiation response from the sandbox.
