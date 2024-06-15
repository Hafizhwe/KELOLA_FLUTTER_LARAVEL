import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kelola_application_1_1/constants/constants.dart';

class TransactionController extends GetxController {
  final isLoading = false.obs;
  final incomeTransactions = <Transaction>[].obs;
  final expenseTransactions = <Transaction>[].obs;
  final billTransactions = <Transaction>[].obs;
  final box = GetStorage();

  Future<void> createTransaction({
    required String type,
    required String date,
    required double amount,
    required String sourceBank,
    required String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Ambil token dari penyimpanan lokal
      var token = box.read('token');

      var data = {
        'type': type,
        'date': date,
        'amount': amount.toString(),
        'source_bank': sourceBank,
        'notes': notes,
      };

      var response = await http.post(
        Uri.parse('${url}transactions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Tambahkan token ke header permintaan
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        isLoading.value = false;
        Get.snackbar(
          'Success',
          'Transaction created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(json.decode(response.body));
      }
    } catch (e) {
      isLoading.value = false;
      print(e.toString());
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      var token = box.read('token');
      var response = await http.get(
        Uri.parse('${url}transactions'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        incomeTransactions.clear();
        expenseTransactions.clear();
        billTransactions.clear();

        data.forEach((item) {
          var transaction = Transaction.fromJson(item);
          if (transaction.type == 'income') {
            incomeTransactions.add(transaction);
          } else if (transaction.type == 'expense') {
            expenseTransactions.add(transaction);
          } else if (transaction.type == 'tagihan') {
            billTransactions.add(transaction);
          }
        });

        isLoading.value = false;
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'],
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print(e.toString());
    }
  }
}

class Transaction {
  final int id;
  final String type;
  final String date;
  final double amount;
  final String bank;
  final String notes;

  Transaction({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.bank,
    required this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      amount: json['amount'] is int
          ? json['amount'].toDouble()
          : double.parse(json['amount']), // Handle amount as double
      bank: json['source_bank'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
