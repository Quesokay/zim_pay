import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_item.dart';
import '../models/create_payment_method_dto.dart';
import '../models/create_pass_dto.dart';

import '../constants.dart';

class WalletRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<WalletItem>> getWalletItems([int userId = 1]) async {
    developer.log('WALLET_REPO: Fetching items for user $userId');
    List<WalletItem> items = [];

    try {
      final pmUrl = '$baseUrl/User/$userId/payment-methods';
      developer.log('WALLET_REPO: GET $pmUrl');
      final pmResponse = await http.get(Uri.parse(pmUrl)).timeout(const Duration(seconds: 5));
      
      developer.log('WALLET_REPO: PM Status: ${pmResponse.statusCode}');
      if (pmResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(pmResponse.body);
        final List<dynamic> pmsJson = data['data'] ?? [];
        for (var json in pmsJson) {
          items.add(CreditCard.fromJson(json));
        }
      }
    } catch (e) {
      developer.log('WALLET_REPO: Error fetching PMs: $e');
    }

    try {
      final passUrl = '$baseUrl/User/$userId/passes';
      developer.log('WALLET_REPO: GET $passUrl');
      final passResponse = await http.get(Uri.parse(passUrl)).timeout(const Duration(seconds: 5));
      
      developer.log('WALLET_REPO: Pass Status: ${passResponse.statusCode}');
      if (passResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(passResponse.body);
        final List<dynamic> passesJson = data['data'] ?? [];
        for (var json in passesJson) {
          if (json['type'] == 'TransitPass') {
            items.add(TransitPass.fromJson(json));
          }
        }
      }
    } catch (e) {
      developer.log('WALLET_REPO: Error fetching passes: $e');
    }

    return items;
  }

  Future<void> addPaymentMethod(int userId, CreatePaymentMethodDto cardData) async {
    final url = Uri.parse('$baseUrl/PaymentMethod');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'paymentMethod': cardData.toJson(),
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add payment method: ${response.body}');
    }
  }

  Future<void> addPass(int userId, CreatePassDto passDetails) async {
    final url = '$baseUrl/Pass';
    developer.log('WALLET_REPO: Adding pass at: $url');
    
    // Wrap data in the AddPassCommand structure expected by backend
    final command = {
      'userId': userId,
      'pass': passDetails.toJson()
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(command),
    );

    developer.log('WALLET_REPO: AddPass response: ${response.statusCode}');
    if (response.statusCode != 201 && response.statusCode != 200) {
      developer.log('WALLET_REPO: Failed to add pass: ${response.body}');
      throw Exception('Failed to add pass');
    }
  }

  Future<List<LoyaltyCard>> getLoyaltyCards([int userId = 1]) async {
    developer.log('WALLET_REPO: Fetching loyalty cards for user $userId');
    try {
      final url = '$baseUrl/User/$userId/passes';
      developer.log('WALLET_REPO: GET $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      developer.log('WALLET_REPO: Loyalty Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> passesJson = data['data'] ?? [];
        return passesJson
            .where((json) => json['type'] == 'Loyalty')
            .map((json) => LoyaltyCard.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      developer.log('WALLET_REPO: Error fetching loyalty cards: $e');
      return [];
    }
  }

  Future<void> deletePaymentMethod(int userId, String cardId) async {
    final url = '$baseUrl/PaymentMethod/$cardId?userId=$userId';
    developer.log('WALLET_REPO: Deleting payment method at: $url');
    final response = await http.delete(Uri.parse(url));

    developer.log('WALLET_REPO: DeletePaymentMethod response: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      developer.log('WALLET_REPO: Failed to delete PM: ${response.body}');
      throw Exception('Failed to delete payment method');
    }
  }

  Future<void> deletePass(int userId, String passId) async {
    final url = '$baseUrl/Pass/$passId?userId=$userId';
    developer.log('WALLET_REPO: Deleting pass at: $url');
    final response = await http.delete(Uri.parse(url));

    developer.log('WALLET_REPO: DeletePass response: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      developer.log('WALLET_REPO: Failed to delete pass: ${response.body}');
      throw Exception('Failed to delete pass');
    }
  }
}
