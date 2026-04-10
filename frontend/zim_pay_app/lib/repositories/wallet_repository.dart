import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_item.dart';
import '../constants.dart';

class WalletRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<WalletItem>> getWalletItems(int userId) async {
    print('Fetching wallet items for user $userId');
    // 1. Fetch Payment Methods (Credit/Debit Cards)
    final pmUrl = '$baseUrl/user/$userId/payment-methods';
    print('Fetching payment methods from: $pmUrl');
    final pmResponse = await http.get(
      Uri.parse(pmUrl),
    );
    
    // 2. Fetch Passes (Transit, Tickets, etc.)
    final passUrl = '$baseUrl/user/$userId/passes';
    print('Fetching passes from: $passUrl');
    final passResponse = await http.get(
      Uri.parse(passUrl),
    );

    print('PM response: ${pmResponse.statusCode}, Pass response: ${passResponse.statusCode}');
    List<WalletItem> items = [];

    if (pmResponse.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(pmResponse.body);
      final List<dynamic> pmsJson = data['data'];
      items.addAll(pmsJson.map((json) => CreditCard.fromJson(json)).toList());
    } else {
      print('PM fetch failed: ${pmResponse.body}');
    }

    if (passResponse.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(passResponse.body);
      final List<dynamic> passesJson = data['data'];
      for (var json in passesJson) {
        if (json['type'] == 'TransitPass') {
          items.add(TransitPass.fromJson(json));
        }
      }
    } else {
      print('Passes fetch failed: ${passResponse.body}');
    }

    return items;
  }

  Future<List<LoyaltyCard>> getLoyaltyCards(int userId) async {
    print('Fetching loyalty cards for user $userId');
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/passes'),
    );

    print('Loyalty cards response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> passesJson = data['data'];
      return passesJson
          .where((json) => json['type'] == 'Loyalty')
          .map((json) => LoyaltyCard.fromJson(json))
          .toList();
    } else {
      print('Failed to load loyalty cards: ${response.body}');
      throw Exception('Failed to load loyalty cards');
    }
  }
}
