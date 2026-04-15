class ApiConstants {
  // We use localhost because 'adb reverse' bridges the device port to the PC.
  // Command: adb reverse tcp:5000 tcp:5000
  static const String baseUrl = 'http://localhost:5000/api';
  static const String healthUrl = 'http://localhost:5000/health';
}
