import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportKey;
  final Map<String, dynamic> reportJson;

  const ReportDetailScreen({
    super.key,
    required this.reportKey,
    required this.reportJson,
  });

  @override
  Widget build(BuildContext context) {
    final entries = List<Map<String, dynamic>>.from(reportJson["entries"]);
    final qualityBlocks =
    List<Map<String, dynamic>>.from(reportJson["finalQuality"] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text("Report Details")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("Report Key: $reportKey", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          const Text("Hourly Entries:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...entries.map((e) {
            return ListTile(
              title: Text("${e["hour"]}  |  Prod: ${e["production"]}"),
              subtitle: Text("DT: ${e["downtime"]}, Reason: ${e["downtimeReason"]}"),
            );
          }).toList(),

          const Divider(),

          const Text("Final Quality Blocks:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...qualityBlocks.map((q) {
            return ListTile(
              title: Text("${q["variant"]} - ${q["side"]}"),
              trailing: Text("${q["qty"]}"),
            );
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
