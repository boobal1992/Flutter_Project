import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'database_services.dart'; // Make sure DatabaseServices is imported
import 'sales_list.dart'; // Sales List screen import
import 'dart:io';

class SalesFormWidget extends StatefulWidget {
  const SalesFormWidget({super.key});

  @override
  State<SalesFormWidget> createState() => _SalesFormWidgetState();
}

class _SalesFormWidgetState extends State<SalesFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _morningTeaController = TextEditingController();
  final TextEditingController _eveningTeaController = TextEditingController();
  final TextEditingController _eveningSnacksController =
      TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _billingDateController = TextEditingController();

  Future<void> _insertData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return; // Validate form first

    try {
      final db = await DatabaseServices.instance.getDatabase();
      await db.insert(
        'sales', // Ensure correct table name
        {
          'customer_name': _customerNameController.text.trim(),
          'morningTea': int.tryParse(_morningTeaController.text.trim()) ?? 0,
          'eveningTea': int.tryParse(_eveningTeaController.text.trim()) ?? 0,
          'eveningSnacks':
              int.tryParse(_eveningSnacksController.text.trim()) ?? 0,
          'advance': int.tryParse(_advanceController.text.trim()) ?? 0,
          'billing_date': _billingDateController.text.trim(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data Inserted Successfully!")),
      );

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error inserting data: $e")),
      );
    }
  }

  void _clearFields() {
    _customerNameController.clear();
    _morningTeaController.clear();
    _eveningTeaController.clear();
    _eveningSnacksController.clear();
    _advanceController.clear();
    _billingDateController.clear();
  }

  Future<void> _selectBillingDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final formattedDate =
          DateFormat('dd/MM/yyyy').format(pickedDate); // Format as dd/MM/yyyy
      _billingDateController.text = formattedDate;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
              "Are you sure you want to delete the entire database? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Do not delete
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm delete
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteDatabase(context);
    }
  }

  Future<void> deleteDatabase(BuildContext context) async {
    try {
      final databaseDir = await getDatabasesPath();
      final databasePath = join(databaseDir, "TeaBoy.db");

      final file = File(databasePath);

      if (await file.exists()) {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Database Deleted Successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ No Database Found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting database: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Sales Form"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_customerNameController, "Customer Name",
                      required: true),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectBillingDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(_billingDateController,
                          "Billing Date (Tap to Select)",
                          required: true),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(_morningTeaController, "Morning Tea",
                      isNumeric: true, required: true),
                  SizedBox(height: 10),
                  _buildTextField(_eveningTeaController, "Evening Tea",
                      isNumeric: true, required: true),
                  SizedBox(height: 10),
                  _buildTextField(_eveningSnacksController, "Evening Snacks",
                      isNumeric: true, required: true),
                  SizedBox(height: 10),
                  _buildTextField(_advanceController, "Advance Amount",
                      isNumeric: true, required: true),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _insertData(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Save", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesListScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_list, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Record Show",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _confirmDelete(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Delete Database",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false, bool required = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return "$label is required";
        }
        if (isNumeric && value != null && value.trim().isNotEmpty) {
          if (int.tryParse(value.trim()) == null) {
            return "Enter a valid number";
          }
        }
        return null;
      },
    );
  }
}
