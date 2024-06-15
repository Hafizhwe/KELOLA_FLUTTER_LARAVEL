import 'package:flutter/material.dart';
import 'dart:math' as Math;

void main() {
  runApp(
    const MaterialApp(
      home: SafeArea(
        child: Budget(),
      ),
    ),
  );
}

class Budget extends StatefulWidget {
  const Budget({Key? key}) : super(key: key);

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  String selectedMonth = 'January';
  String selectedYear = DateTime.now().year.toString();

  List<BudgetItem> _budgetItems = [
    BudgetItem(
      label: 'Rumah Tangga',
      amount: 50000,
      color: Color.fromARGB(255, 255, 0, 0),
    ),
    BudgetItem(
      label: 'Makanan',
      amount: 10000,
      color: const Color.fromARGB(255, 77, 255, 83),
    ),
  ];

  double totalIncome = 100000;
  double totalExpense = 60000;
  double totalBill = 30000;

  String getSelectedMonthYear() {
    return '$selectedMonth $selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    double expensePercentage = ((totalExpense + totalBill) / totalIncome) * 100;
    List<String> years =
        List.generate(10, (index) => (DateTime.now().year - index).toString());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/Background 2.png'), // Ganti dengan path gambar latar belakang Anda
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 1.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: selectedMonth,
                          items: <String>[
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
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                          },
                        ),
                        DropdownButton<String>(
                          value: selectedYear,
                          items: years
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue!;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigasi ke halaman transaksi
                            Navigator.pushNamed(context, '/transactions');
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromRGBO(140, 226, 218, 0.8)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text('Lihat Transaksi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% dari lebar layar
                decoration: BoxDecoration(
                  color: Colors.white, // Warna latar belakang putih
                  borderRadius: BorderRadius.circular(20.0), // Sudut bulat
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        getSelectedMonthYear(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Total Income: $totalIncome',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Total Expense: $totalExpense',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Total Bill: $totalBill',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildDonutChartWithLegend(expensePercentage),
                      const SizedBox(height: 10),
                      // Dropdown untuk filter bulan dan tahun dan tombol Lihat Transaksi
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonutChartWithLegend(double expensePercentage) {
    return Container(
      height: 250,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildDonutChart(expensePercentage),
              Positioned(
                child: Text(
                  '${expensePercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 19, 6, 5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: Colors.green,
                label: 'Income',
              ),
              const SizedBox(width: 10),
              _buildLegendItem(
                color: Colors.red,
                label: 'Expense',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildDonutChart(double expensePercentage) {
    return Container(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: _DonutChartPainter(
          budgetItems: _budgetItems,
          expensePercentage: expensePercentage,
        ),
      ),
    );
  }
}

class BudgetItem {
  final String label;
  final int amount;
  final Color color;

  BudgetItem({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<BudgetItem> budgetItems;
  final double expensePercentage;

  _DonutChartPainter({
    required this.budgetItems,
    required this.expensePercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerRadius = size.width / 5;
    final double ringRadius = size.width / 2;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringRadius - centerRadius;
    final double total =
        budgetItems.fold(0, (sum, item) => sum + item.amount).toDouble();
    double startAngle = -90;
    for (final item in budgetItems) {
      final sweepAngle = 360 * (item.amount / total);
      paint.color = item.color;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: ringRadius,
        ),
        _toRad(startAngle),
        _toRad(sweepAngle),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      centerRadius,
      Paint()..color = Color.fromARGB(255, 255, 255, 255),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _toRad(double degree) => degree * Math.pi / 180.0;
}
