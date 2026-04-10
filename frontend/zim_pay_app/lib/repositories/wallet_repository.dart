import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_item.dart';
import '../constants.dart';

class WalletRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<WalletItem>> getWalletItems(int userId) async {
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

  Future<void> addPaymentMethod(int userId, Map<String, dynamic> cardData) async {
    final url = '$baseUrl/PaymentMethod';
    developer.log('WALLET_REPO: Adding payment method at: $url');
    
    // Wrap data in the AddPaymentMethodCommand structure expected by backend
    final command = {
      'userId': userId,
      'paymentMethod': {
        'type': 'CreditCard', // Default to CreditCard for manual entry
        'cardNumber': cardData['cardNumber'].toString().replaceAll(' ', ''),
        'bankName': _detectBankName(cardData['cardNumber']),
        'accountNumber': '', // Optional for cards
        'holderName': cardData['cardHolderName'],
        'expiryDate': cardData['expiryDate'],
        'isDefault': true,
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(command),
    );

    developer.log('WALLET_REPO: AddPaymentMethod response: ${response.statusCode}');
    if (response.statusCode != 201 && response.statusCode != 200) {
      developer.log('WALLET_REPO: Failed to add PM: ${response.body}');
      throw Exception('Failed to add payment method');
    }
  }

  String _detectBankName(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    return 'Generic Bank';
  }

  Future<void> addPass(int userId, Map<String, dynamic> passData) async {
    final url = '$baseUrl/Pass';
    developer.log('WALLET_REPO: Adding pass at: $url');
    
    // Wrap data in the AddPassCommand structure expected by backend
    final command = {
      'userId': userId,
      'pass': {
        'type': passData['type'],
        'title': passData['title'],
        'details': passData['details'] ?? '',
        'issuerId': '', 
        'issuerName': '',
        'passNumber': '',
        'barcode': '',
        'balance': passData['balance'],
        'color': passData['color'] ?? '',
        'imageUrl': passData['imageUrl'] ?? '',
      }
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

  Future<List<LoyaltyCard>> getLoyaltyCards(int userId) async {
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
