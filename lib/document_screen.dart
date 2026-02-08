import 'package:flutter/material.dart';
import 'data_entry_screen.dart';
import 'production_entry_screen.dart';
import 'view_saved_reports_screen.dart';  // ✅ add import

class DocumentScreen extends StatelessWidget {
  final String lineName;

  const DocumentScreen({super.key, required this.lineName});

  @override
  Widget build(BuildContext context) {
    final List<String> documents = [
      "Production Report",
      "Hourly Production",
      "Layered Process Audit (LPA)",
      "Manpower Attendance",
      "Rejection Report",
      "OEE Sheet",
      "Daily Summary",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(lineName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(documents[index]),
                  onTap: () {
                    // For Production Report and Hourly Production only
                    if (documents[index] == "Hourly Production") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductionEntryScreen(
                            lineName: lineName,
                            date: DateTime.now().toString().split(" ")[0],
                          ),
                        ),
                      );
                    } else {
                      // DataEntryScreen for other docs
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataEntryScreen(
                            lineName: lineName,
                            documentName: documents[index],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),

          const Divider(),

          // 🔵 NEW BUTTON — View Saved Reports
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text("View Saved Reports"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewSavedReportsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
