import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kelola_application_1_1/string_extensions.dart';
import 'package:kelola_application_1_1/controllers/transaction.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final List<Transaction> transactions = [];
  final box = GetStorage();
  bool isLoading = false;
  late String selectedMonth;
  late String selectedYear;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  List<String> years =
      List.generate(10, (index) => (DateTime.now().year - index).toString());

  @override
  void initState() {
    super.initState();
    selectedMonth = months[DateTime.now().month - 1];
    selectedYear = DateTime.now().year.toString();
    fetchTransactions(selectedMonth, selectedYear);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchTransactions(String month, String year) async {
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
        final List<Transaction> transactionsList = [];

        for (var item in data) {
          final transaction = Transaction.fromJson(item);
          if (DateFormat('MMMM yyyy')
                  .format(DateTime.parse(transaction.date)) ==
              '$month $year') {
            transactionsList.add(transaction);
          }
        }

        setState(() {
          transactions.clear();
          transactions.addAll(transactionsList);
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to load transactions'),
              content:
                  Text('Failed to load transactions. Please try again later.'),
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
    await fetchTransactions(selectedMonth, selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;
    double totalBill = 0;
    double remainingBudget = 0;

    transactions.forEach((transaction) {
      switch (transaction.type) {
        case 'income':
          totalIncome += transaction.amount;
          break;
        case 'expense':
          totalExpense += transaction.amount;
          break;
        case 'tagihan':
          totalBill += transaction.amount;
          break;
        default:
          break;
      }
    });

    remainingBudget = totalIncome - (totalExpense + totalBill);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Data'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Background 2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: selectedMonth,
                              items: months
                                  .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMonth = newValue;
                                  });
                                  fetchTransactions(
                                      selectedMonth, selectedYear);
                                }
                              },
                            ),
                            DropdownButton<String>(
                              value: selectedYear,
                              items: years
                                  .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedYear = newValue;
                                  });
                                  fetchTransactions(
                                      selectedMonth, selectedYear);
                                }
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/transactions');
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(140, 226, 218, 0.8),
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              child: const Text('View Transactions'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Transaction List',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: transactions.length,
                                itemBuilder: (context, index) =>
                                    TransactionListItem(
                                  transaction: transactions[index],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Transaction Summary',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Income'),
                                  Text(
                                    'Rp ${totalIncome.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Expense'),
                                  Text(
                                    'Rp ${totalExpense.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Bills'),
                                  Text(
                                    'Rp ${totalBill.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Remaining Budget'),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rp ${remainingBudget.abs().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: remainingBudget < 0
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              4), // Spasi vertikal antara angka dan status
                                      Text(
                                        remainingBudget < 0
                                            ? 'Overbudget'
                                            : 'On budget',
                                        style: TextStyle(
                                          color: remainingBudget < 0
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Export to Excel button outside the "Transaction Summary" container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Export to Excel'),
                              content: Text('Under Develop'),
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
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromRGBO(140, 226, 218, 0.8),
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Export to Excel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (transaction.type) {
      case 'income':
        icon = Icons.arrow_downward;
        iconColor = Colors.green;
        break;
      case 'expense':
      case 'bill':
        icon = Icons.arrow_upward;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.attach_money;
        iconColor = Colors.black;
        break;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(transaction.type.customCapitalizeFirst),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rp ${transaction.amount.toStringAsFixed(2)}'),
          Text('Bank: ${transaction.bank}'),
          Text('Note: ${transaction.notes}'),
        ],
      ),
      trailing: Text(
        DateFormat('dd-MM-yyyy').format(DateTime.parse(transaction.date)),
      ),
    );
  }
}
