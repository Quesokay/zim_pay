ZIMPay

A digital payment wallet application with Flutter frontend and .NET backend.

## Architecture

- **Backend**: .NET with Clean Architecture
  - Domain: Entities
  - Application: Commands, Queries, Interfaces
  - Infrastructure: EF Core, Repositories
  - Presentation: ASP.NET Core Web API

- **Frontend**: Flutter with BLoC state management

- **Database**: SQLite

## Features

- User management
- Payment methods
- Transactions
- Digital passes

# Quick Start Guide
## 1. Prerequisites
Ensure you have the following installed on your PC:
* .NET 10 SDK & globally installed EF Core tools (dotnet tool install --global dotnet-ef)
* Flutter SDK (>=3.0.0 <4.0.0)
* Android Device or Emulator with Developer Options enabled.
* ngrok installed and authenticated on your machine.
  
## 2. Install & Configure SQLite

While the .NET Entity Framework Core driver internally includes the necessary SQLite runtime libraries to execute the application, installing SQLite tools on your PC is useful to manually inspect or reset your local database (wallet.db).

### Option A: DB Browser for SQLite (Recommended GUI)

1. Download and install [DB Browser for SQLite](https://sqlitebrowser.org/dl/).  
2. Once installed, you can directly open the generated wallet.db file to visually view user tokens, masked cards, and transaction records.

### Option B: Standalone SQLite CLI (Windows)

1. Download the precompiled binaries for Windows (sqlite-tools-win-x64-*.zip) from the [SQLite Download Page](https://www.sqlite.org/download.html).  
2. Extract the contents to a permanent folder on your PC (e.g., C:\sqlite).  
3. Add C:\sqlite to your system's PATH Environment Variable.  
4. Open a terminal and verify the installation:

   `sqlite3 --version`
   
## 3. Run the Backend (.NET API)
Open a terminal and navigate to the `backend` folder:

  `cd backend`

Apply the database migrations to build your initial SQLite database structure:

  `dotnet ef database update --project ZimPay.Infrastructure/ZimPay.Infrastructure.csproj --startup-project ZimPay.Presentation/ZimPay.Presentation.csproj`

Start the API server (it will listen on port 5000 by default):

  `cd ZimPay.Presentation`
  
  `dotnet run`

## 4. Setup ngrok & Update AppSettings (For EcoCash Webhooks)
Leave your .NET server running. Open a new terminal tab to expose your local port 5000 to the internet so EcoCash can reach your webhook endpoint.
Start the ngrok tunnel pointing to your backend port:
  `ngrok http 5000`

Ngrok will display a forwarding public URL in the terminal (e.g., `https://a1b2-34-56-78-90.ngrok-free.app`). Copy this URL.
Open `backend/ZimPay.Presentation/appsettings.json` in your code editor.
Locate the EcoCash integration block and update the Webhook/Callback URL property with your new ngrok address:
`JSON:
  "EcoCashSettings": {
    "CallbackUrl": "https://a1b2-34-56-78-90.ngrok-free.app/api/Transaction/EcoCashCallback",
    // ... other settings ...
  }`

(Note: You do not need to restart the .NET server if your configuration provider supports hot-reloading appsettings.json, but if webhook calls fail, restart the server).
## 5. Connect Device & Bridge the Network (adb reverse)
Your phone still needs to communicate directly with your local PC for standard API calls.
Connect your phone via USB (with USB Debugging enabled) or pair it via Wireless Debugging.
### Option A: Standard USB Debugging

  1. On your phone, go to Settings -> Developer Options and enable USB Debugging.  
  2. Connect the phone to your PC via a USB data cable and allow the debugging prompt on the screen.  
  3. Verify the connection in a new terminal tab:

   `adb devices`

  4. Run the port reversal command:

   `adb reverse tcp:5000 tcp:5000`

### Option B: Wireless Debugging (Android 11+)

To test NFC taps freely without being tethered by a USB cable:

  1. Ensure both your Android device and PC are connected to the same Wi-Fi network.  
  2. On your phone, go to Settings -> Developer Options and enable Wireless Debugging.
  3. Tap on Wireless Debugging to open its settings page, then select Pair device with pairing code. Note the pairing IP address, port, and 6-    digit code displayed.  
  4. On your PC terminal, run the pair command:

   `adb pair 192.168.1.X:PORT`

   (Replace with the exact pairing IP and port shown on your screen, then enter the 6-digit code when prompted).

  5. Once successfully paired, check the main Wireless Debugging screen on your phone for the primary connection IP and port under "IP address & Port". Connect to it:

     `adb connect 192.168.1.X:PORT`
  6. Verify the connection:

    adb devices

  7. Establish the network bridge over Wi-Fi:

     `adb reverse tcp:5000 tcp:5000`

## 6. Run the Frontend (Flutter App)
Open a terminal tab and navigate to the Flutter project directory:

  `cd frontend/zim_pay_app`

Fetch the required Flutter dependencies:

  `flutter pub get`

Build and launch the app onto your connected testing device:

  `flutter run`

## 7. Hardware Testing Notes (NTAG215)
Link a Tag: Navigate to Settings > Link NFC Tag in the app and hold a physical NTAG215 sticker to the back of the phone to commit your unique identity hash.

Tap-to-Pay (EcoCash Flow): Open the Merchant POS Screen, input a charge amount, and tap your tag. The backend will trigger an EcoCash Push to your phone. Once you enter your PIN, the EcoCash sandbox will fire a webhook to your ngrok URL, which routes it to your local C# API to complete the transaction!

