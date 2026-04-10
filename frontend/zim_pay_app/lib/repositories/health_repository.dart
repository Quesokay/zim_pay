import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class HealthRepository {
  Future<bool> checkHealth() async {
    const url = ApiConstants.healthUrl;
    print('Starting health check request to: $url');
    
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      
      print('Health Check Response Status: ${response.statusCode}');
      print('Health Check Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final isHealthy = data['status'] == 'Healthy';
          print('Health Check Parsed Result: $isHealthy');
          return isHealthy;
        } catch (e) {
          print('Failed to parse health JSON: $e');
          // Fallback: if status is 200 but not JSON, check if it's the old plain text
          return response.body.trim() == "Healthy";
        }
      }
      return false;
    } on http.ClientException catch (e) {
      print('Network Error (ClientException): $e');
      return false;
    } catch (e) {
      print('Unexpected Health Check Error: $e');
      return false;
    }
  }
}
