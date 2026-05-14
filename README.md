# Zim Pay

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

The backend creates and manages the SQLite database automatically upon startup and listens on port 5000\.

1. Open a terminal and navigate to the `backend` folder

2. Apply the database migrations to build your initial SQLite database structure:

   `dotnet ef database update --project ZimPay.Infrastructure/ZimPay.Infrastructure.csproj --startup-project ZimPay.Presentation/ZimPay.Presentation.csproj`

3. Start the API server: navigate to `cd ZimPay.Presentation`, and execute `dotnet run`
The server is now actively listening at http://localhost:5000.

## 4. Connect Device & Bridge the Network (adb reverse)

By default, an Android device checking localhost:5000 looks inside its own internal network loopback, not your PC. You must connect the device to your PC and map the ports using Android Debug Bridge (ADB).

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
3. Tap on Wireless Debugging to open its settings page, then select Pair device with pairing code. Note the pairing IP address, port, and 6-digit code displayed.  
4. On your PC terminal, run the pair command:

   `adb pair 192.168.1.X:PORT`

   (Replace with the exact pairing IP and port shown on your screen, then enter the 6-digit code when prompted).

5. Once successfully paired, check the main Wireless Debugging screen on your phone for the primary connection IP and port under "IP address & Port". Connect to it:

   `adb connect 192.168.1.X:PORT`

6. Establish the network bridge over Wi-Fi:

   `adb reverse tcp:5000 tcp:5000`

## 5. Run the Frontend (Flutter App)

1. Open a terminal tab and navigate to the Flutter project directory:

   `cd frontend/zim_pay_app`

2. Fetch the required Flutter dependencies:

   `flutter pub get`

3. Build and launch the app onto your connected testing device:

   `flutter run`

## 6. Hardware Testing Notes (NTAG215)

Once the app is running on your phone with NFC enabled:

* Link a Tag: Navigate to Settings -> Link NFC Tag in the app and hold a physical NTAG215 sticker to the back of the phone to commit your unique identity hash.  
* Tap-to-Pay: Open the Merchant POS Screen, input a charge amount, and tap your programmed tag to trigger backend routing, local SQLite ledger updates, or mobile money push authentication.
