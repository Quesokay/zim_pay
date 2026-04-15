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

  Future<List<Transaction>> getPendingTransactions(int userId) async {
    developer.log('Fetching pending transactions for user $userId from: $baseUrl/Transaction/user/$userId/pending');
    final response = await http.get(
      Uri.parse('$baseUrl/Transaction/user/$userId/pending'),
    );

    developer.log('GetPendingTransactions response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> transactionsJson = data['data'];
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    } else {
      developer.log('Failed to load pending transactions: ${response.body}');
      throw Exception('Failed to load pending transactions');
    }
  }

  Future<bool> approveTransaction(int transactionId) async {
    developer.log('Approving transaction $transactionId at: $baseUrl/Transaction/$transactionId/approve');
    final response = await http.post(
      Uri.parse('$baseUrl/Transaction/$transactionId/approve'),
    );

    developer.log('ApproveTransaction response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to approve transaction');
    }
  }
}
