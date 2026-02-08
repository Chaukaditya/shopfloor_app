import 'package:flutter/material.dart';
import 'db_helper.dart';

class DataEntryScreen extends StatefulWidget {
  final String lineName;
  final String documentName;

  const DataEntryScreen({
    super.key,
    required this.lineName,
    required this.documentName,
  });

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {

  // 👉 STEP-1: TextField controller
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Line: ${widget.lineName}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              "Document: ${widget.documentName}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 👉 STEP-2: TextField with controller
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: "Enter Value",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 👉 STEP-3: Save Button
            ElevatedButton(
              onPressed: () async {

                await DBHelper.insertEntry(
                  widget.lineName,
                  widget.documentName,
                  _valueController.text,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data saved offline"),
                  ),
                );

                // Clear text after save
                _valueController.clear();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
