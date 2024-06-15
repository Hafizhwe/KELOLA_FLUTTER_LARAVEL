import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:kelola_application_1_1/controllers/transaction.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Transaction> transactionsIncome = [];
  final List<Transaction> transactionsExpense = [];
  final List<Transaction> transactionsBill = [];
  final box = GetStorage();
  bool isLoading = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan timer saat widget di dispose
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = box.read('token');

      final response = await http.get(
        Uri.parse('http://192.168.1.6:8000/api/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['transactions'];
        final List<Transaction> income = [];
        final List<Transaction> expense = [];
        final List<Transaction> bill = [];

        for (var item in data) {
          final transaction = Transaction.fromJson(item);
          if (item['type'] == 'income') {
            income.add(transaction);
          } else if (item['type'] == 'expense') {
            expense.add(transaction);
          } else if (item['type'] == 'tagihan') {
            bill.add(transaction);
          }
        }

        setState(() {
          transactionsIncome.clear();
          transactionsExpense.clear();
          transactionsBill.clear();
          transactionsIncome.addAll(income);
          transactionsExpense.addAll(expense);
          transactionsBill.addAll(bill);
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to load transactions'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error fetching transactions'),
            content: Text('$e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/Background 2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _refreshData,
            child: Center(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            currentDate,
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    isLoading
                        ? CircularProgressIndicator() // Menambahkan loading indicator
                        : Column(
                            children: [
                              // Menampilkan daftar transaksi pendapatan
                              TransactionList(
                                title: 'Income',
                                transactions: transactionsIncome,
                              ),
                              // Menampilkan daftar transaksi pengeluaran
                              TransactionList(
                                title: 'Expenses',
                                transactions: transactionsExpense,
                              ),
                              // Menampilkan daftar transaksi tagihan
                              TransactionList(
                                title: 'Bills',
                                transactions: transactionsBill,
                              ),
                            ],
                          ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/input');
                print('Add transaction button pressed');
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
              backgroundColor: const Color.fromRGBO(140, 226, 218, 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String title;
  final List<Transaction> transactions;

  const TransactionList({
    required this.title,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 335,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransaksiItem(
                    tanggal: transaction.date,
                    keterangan: transaction.notes,
                    nominal: transaction.amount,
                    bank: transaction.bank,
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class TransaksiItem extends StatelessWidget {
  final String tanggal;
  final String keterangan;
  final double nominal;
  final String bank;

  const TransaksiItem({
    required this.tanggal,
    required this.keterangan,
    required this.nominal,
    required this.bank,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(keterangan),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tanggal),
          Text('Nominal: $nominal'),
          Text('Bank: $bank'),
        ],
      ),
    );
  }
}
