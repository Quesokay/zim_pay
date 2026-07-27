# Implementation Plan - Frontend EcoCash EIP Integration

Update the Flutter frontend to reflect backend changes for EcoCash EIP, including status polling and better handling of pending payments.

## User Review Required

> [!IMPORTANT]
> The merchant POS screen will now poll the backend for EcoCash payment status instead of showing a static success message immediately after the push is sent. This provides real-time feedback to the merchant.

## Proposed Changes

### [Frontend] Data Layer (Models & Repositories)

#### [MODIFY] [transaction.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/models/transaction.dart)
- Add `clientCorrelator` and `isEcoCash` properties.
- Update `fromJson` to extract correlation data from the description.

#### [MODIFY] [transaction_repository.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/repositories/transaction_repository.dart)
- Add `getEcoCashStatus(String endUserId, String clientCorrelator)` method.

### [Frontend] Business Logic (Blocs)

#### [MODIFY] [transaction_event.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/blocs/transaction/transaction_event.dart)
- Add `PollEcoCashStatus` event.

#### [MODIFY] [transaction_bloc.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/blocs/transaction/transaction_bloc.dart)
- Implement `_onPollEcoCashStatus` to check status and refresh pending transactions.

### [Frontend] Presentation Layer (Screens)

#### [MODIFY] [merchant_pos_screen.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/screens/merchant_pos_screen.dart)
- Update `_processPayment` to detect EcoCash payments.
- Show a "Processing EcoCash Payment..." dialog with a polling mechanism.
- Poll until the status changes from `PENDING` to `SUCCESS` or `FAILED`.

#### [MODIFY] [home_screen.dart](file:///C:/Sources/zim_pay/frontend/zim_pay_app/lib/screens/home_screen.dart)
- Update `_buildPendingTransactionCard` to show a different UI for EcoCash payments (e.g., "Waiting for EcoCash PIN" instead of "Biometric Approval").

## Verification Plan

### Manual Verification
- **Merchant POS Flow:** Charge an EcoCash user. Observe the "Polling" dialog. Verify it shows "Success" only after the USSD prompt is completed on the user's phone.
- **Home Screen UI:** Verify that pending EcoCash transactions are clearly identified.
