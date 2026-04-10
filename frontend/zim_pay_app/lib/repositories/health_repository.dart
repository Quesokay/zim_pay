import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class HealthRepository {
  Future<bool> checkHealth() async {
    // Explicitly construct the URL string
    const String url = ApiConstants.healthUrl;
    print('DEBUG: Health Check URL is "$url"');
    
    try {
      final uri = Uri.parse(url);
      print('DEBUG: Parsed URI: $uri');
      
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));
      
      print('DEBUG: Health Response Code: ${response.statusCode}');
      print('DEBUG: Health Response Body: "${response.body}"');
      
      if (response.statusCode == 200) {
        final String body = response.body.trim();
        
        // Handle both JSON and Plain Text
        if (body.startsWith('{')) {
          final Map<String, dynamic> data = jsonDecode(body);
          return data['status'] == 'Healthy';
        } else {
          return body == "Healthy";
        }
      }
      return false;
    } catch (e) {
      print('DEBUG: Health Check Failed with Error: $e');
      return false;
    }
  }
}
