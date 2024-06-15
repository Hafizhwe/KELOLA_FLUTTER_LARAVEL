import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kelola_application_1_1/models/transaction.dart'; // Sesuaikan dengan path yang sesuai

class DataController {
  static const String baseUrl =
      'http://192.168.1.6:8000/api/data'; // Ganti dengan URL API Laravel Anda

  Future<List<Transaction>> fetchTransactions(String month, String year) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/data?month=$month&year=$year'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['transactions'];
      List<Transaction> transactions =
          data.map((item) => Transaction.fromJson(item)).toList();
      return transactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}

class Transaction {
  final int id;
  final String type;
  final double amount;
  final String sourceBank;
  final String notes;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.sourceBank,
    required this.notes,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      sourceBank: json['sourceBank'],
      notes: json['notes'],
      date: DateTime.parse(
          json['date']), // Adjust date parsing based on API response
    );
  }
}
