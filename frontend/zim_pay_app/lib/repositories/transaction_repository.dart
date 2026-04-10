import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../constants.dart';

class TransactionRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Transaction>> getTransactions(int userId) async {
    print('Fetching transactions for user $userId from: $baseUrl/user/$userId/transactions');
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/transactions'),
    );

    print('GetTransactions response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> transactionsJson = data['data'];
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    } else {
      print('Failed to load transactions: ${response.body}');
      throw Exception('Failed to load transactions');
    }
  }
}
