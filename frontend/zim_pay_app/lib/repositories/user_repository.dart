import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

import '../constants.dart';

class UserRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<User> getUser(int id) async {
    developer.log('Fetching user $id from: $baseUrl/User/$id');
    final response = await http.get(
      Uri.parse('$baseUrl/User/$id'),
    );

    developer.log('GetUser response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      developer.log('Failed to load user: ${response.body}');
      throw Exception('Failed to load user');
    }
  }

  Future<User> login(String email) async {
    developer.log('Logging in user: $email at: $baseUrl/User/login');
    final response = await http.post(
      Uri.parse('$baseUrl/User/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    developer.log('Login response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      developer.log('Failed to login: ${response.body}');
      throw Exception('Failed to login');
    }
  }

  Future<User> createUser(String email, String name, String phone) async {
    developer.log('Creating user: $email at: $baseUrl/User');
    final response = await http.post(
      Uri.parse('$baseUrl/User'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'name': name, 'phone': phone}),
    );

    developer.log('CreateUser response: ${response.statusCode}');
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      developer.log('Failed to create user: ${response.body}');
      throw Exception('Failed to create user');
    }
  }

  Future<User> updateUser(int id, {String? name, String? phone, bool? fingerprintEnabled, bool? contactlessEnabled, double? tapLimit}) async {
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (fingerprintEnabled != null) updateData['fingerprintEnabled'] = fingerprintEnabled;
    if (contactlessEnabled != null) updateData['contactlessEnabled'] = contactlessEnabled;
    if (tapLimit != null) updateData['tapLimit'] = tapLimit;

    final response = await http.patch(
      Uri.parse('$baseUrl/User/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      throw Exception('Failed to update user');
    }
  }
}
