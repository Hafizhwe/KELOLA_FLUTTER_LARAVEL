import 'package:flutter/foundation.dart'; // Import library yang diperlukan

class Transaction {
  final String id;
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
      sourceBank: json['source_bank'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'source_bank': sourceBank,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }
}
