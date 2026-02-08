import 'dart:convert';
import 'package:flutter/material.dart';
import 'report_detail_screen.dart';
import 'storage/local_storage.dart';

class ViewSavedReportsScreen extends StatefulWidget {
  const ViewSavedReportsScreen({super.key});

  @override
  State<ViewSavedReportsScreen> createState() =>
      _ViewSavedReportsScreenState();
}

class _ViewSavedReportsScreenState extends State<ViewSavedReportsScreen> {
  List<String> reportKeys = [];

  @override
  void initState() {
    super.initState();
    _loadSavedReports();
  }

  void _loadSavedReports() async {
    final prefs = await LocalStorage.getPrefsInstance();
    // Get all keys
    final keys = prefs.getKeys().toList();
    // Filter only report keys (you’re saving with "REPORT_" prefix)
    reportKeys = keys.where((k) => k.startsWith("REPORT_")).toList();
    // Sort latest on top
    reportKeys.sort((a, b) => b.compareTo(a));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Reports")),
      body: reportKeys.isEmpty
          ? const Center(child: Text("No saved reports found"))
          : ListView.builder(
        itemCount: reportKeys.length,
        itemBuilder: (context, index) {
          final key = reportKeys[index];
          final parts = key.split("_");
          // Example key format: REPORT_2025-02-10_LineName_A
          String date = parts.length > 1 ? parts[1] : "";
          String line = parts.length > 2 ? parts[2] : "";
          String shift = parts.isNotEmpty ? parts.last : "";

          return ListTile(
            title: Text("$date  |  $line  | Shift: $shift"),
            subtitle: Text(key),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final reportJson = await LocalStorage.loadReport(key);
              if (reportJson != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportDetailScreen(
                      reportKey: key,
                      reportJson: reportJson,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
