import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'database_services.dart'; // Ensure this import

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  List<Map<String, dynamic>> salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    final db = await DatabaseServices.instance.getDatabase();
    final List<Map<String, dynamic>> data = await db.query('sales');
    setState(() {
      salesData = data;
    });
  }

  // Method to generate PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Adding a title to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text("Sales Records",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                [
                  'Customer Name',
                  'Billing Date',
                  'Morning Tea',
                  'Evening Tea',
                  'Evening Snacks',
                  'Advance'
                ], // Headers
                ...salesData.map((sale) => [
                      sale['customer_name'],
                      sale['billing_date'],
                      sale['morningTea'].toString(),
                      sale['eveningTea'].toString(),
                      sale['eveningSnacks'].toString(),
                      sale['advance'].toString(),
                    ])
              ],
            ),
          ],
        );
      },
    ));

    // Show the PDF in a print preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Records'),
        backgroundColor: Colors.cyan,
      ),
      body: salesData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: salesData.length,
              itemBuilder: (context, index) {
                final sale = salesData[index];
                return ListTile(
                  title: Text(sale['customer_name']),
                  subtitle: Text(
                    'Billing Date: ${sale['billing_date']}\n'
                    'Morning Tea: ${sale['morningTea']}\n'
                    'Evening Tea: ${sale['eveningTea']}\n'
                    'Evening Snacks: ${sale['eveningSnacks']}\n'
                    'Advance: ${sale['advance']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePdf,
        child: const Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
