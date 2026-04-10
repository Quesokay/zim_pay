import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

import '../constants.dart';

class UserRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<User> getUser(int id) async {
    print('Fetching user $id from: $baseUrl/user/$id');
    final response = await http.get(
      Uri.parse('$baseUrl/user/$id'),
    );

    print('GetUser response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      print('Failed to load user: ${response.body}');
      throw Exception('Failed to load user');
    }
  }

  Future<User> createUser(String email, String name, String phone) async {
    print('Creating user: $email at: $baseUrl/user');
    final response = await http.post(
      Uri.parse('$baseUrl/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'name': name, 'phone': phone}),
    );

    print('CreateUser response: ${response.statusCode}');
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to create user: ${response.body}');
      throw Exception('Failed to create user');
    }
  }
}