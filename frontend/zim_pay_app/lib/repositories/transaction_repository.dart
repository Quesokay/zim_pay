import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../constants.dart';

class TransactionRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Transaction>> getTransactions(int userId) async {
    developer.log('Fetching transactions for user $userId from: $baseUrl/User/$userId/transactions');
    final response = await http.get(
      Uri.parse('$baseUrl/User/$userId/transactions'),
    );

    developer.log('GetTransactions response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> transactionsJson = data['data'];
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    } else {
      developer.log('Failed to load transactions: ${response.body}');
      throw Exception('Failed to load transactions');
    }
  }
}
