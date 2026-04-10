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

## Setup

### Backend

1. Navigate to `backend`
2. `dotnet build`
3. `cd ZimPay.Presentation`
4. `dotnet run`

### Frontend

1. Install Flutter
2. Navigate to `frontend/zim_pay_app`
3. `flutter pub get`
4. `flutter run`

## API

- POST /api/user - Create user