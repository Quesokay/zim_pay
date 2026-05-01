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

  Future<User> login(String pin) async {
    developer.log('Logging in user with PIN at: $baseUrl/Auth/login');
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pin': pin}),
    );

    developer.log('Login response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['user']); // Note: AuthController returns { user: ... }
    } else {
      developer.log('Failed to login: ${response.body}');
      throw Exception('Failed to login: Invalid PIN');
    }
  }

  Future<User> createUser(String email, String name, String pin) async {
    developer.log('Creating user: $email at: $baseUrl/User');
    final response = await http.post(
      Uri.parse('$baseUrl/User'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'name': name, 'pin': pin}),
    );

    developer.log('CreateUser response: ${response.statusCode}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return User.fromJson(body['data']); // CreateUserCommandHandler returns ApiResponse<UserDto>
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
