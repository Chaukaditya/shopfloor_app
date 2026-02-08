import 'package:flutter/material.dart';
import 'models/hourly_entry.dart';

class ReportPreviewScreen extends StatelessWidget {
  final String date;
  final String line;
  final String shift;
  final List<HourlyEntry> entries;

  /// Final quality OK blocks from shift end screen
  final List<Map<String, dynamic>> finalQualityBlocks;

  const ReportPreviewScreen({
    super.key,
    required this.date,
    required this.line,
    required this.shift,
    required this.entries,
    required this.finalQualityBlocks,
  });

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Compute production totals
    final totalProd =
    entries.fold<int>(0, (s, e) => s + e.production);

    final Map<String, int> variantSideProd = {};
    for (var e in entries) {
      final key = "${e.variant}-${e.side}";
      variantSideProd[key] =
          (variantSideProd[key] ?? 0) + e.production;
    }

    // 2️⃣ Final Quality OK from shift end blocks
    // finalQualityBlocks = [
    //   {"variant": "...", "side": "...", "qty": int},
    //   ...
    // ]
    final Map<String, int> variantSideQualityOk = {};
    int overallQualityOk = 0;

    for (var b in finalQualityBlocks) {
      final key = "${b['variant']}-${b['side']}";
      // ensure qty is an int
      int qty = 0;
      if (b['qty'] is int) {
        qty = b['qty'] as int;
      } else {
        qty = int.tryParse("${b['qty']}") ?? 0;
      }

      if (qty > 0) {
        final existing = variantSideQualityOk[key] ?? 0;
        variantSideQualityOk[key] = existing + qty;
        overallQualityOk = overallQualityOk + qty;
      }
    }

    // 3️⃣ Downtime summary
    final downtime = entries.where((e) => e.downtime > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Report Preview")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Date : $date"),
          Text("Line : $line"),
          Text("Shift : $shift"),
          const Divider(),

          /// 1️⃣ Hourly Table
          const Text("Hourly Data",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Hour")),
                DataColumn(label: Text("Variant")),
                DataColumn(label: Text("Side")),
                DataColumn(label: Text("Prod")),
                DataColumn(label: Text("DT")),
                DataColumn(label: Text("Reason")),
                DataColumn(label: Text("Details")),
                DataColumn(label: Text("Dept")),
              ],
              rows: entries.map((e) {
                return DataRow(cells: [
                  DataCell(Text(e.hour)),
                  DataCell(Text(e.variant)),
                  DataCell(Text(e.side)),
                  DataCell(Text(e.production.toString())),
                  DataCell(Text(e.downtime.toString())),
                  DataCell(Text(e.downtimeReason)),
                  DataCell(Text(e.downtimeRemark)),
                  DataCell(Text(e.department)),
                ]);
              }).toList(),
            ),
          ),

          const Divider(),

          /// 2️⃣ Variant–Side Total Production
          const Text("Variant / Side Wise Production",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...variantSideProd.entries.map(
                (e) => Text("${e.key} → ${e.value}"),
          ),

          const SizedBox(height: 8),
          Text("Overall Total Production : $totalProd",
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const Divider(),

          /// 3️⃣ Final Quality OK Summary for Shift
          const Text("Quality OK Summary",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...variantSideQualityOk.entries.map(
                (e) => Text("${e.key} → ${e.value}"),
          ),
          const SizedBox(height: 6),
          Text("Overall Quality OK : $overallQualityOk",
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const Divider(),

          /// 4️⃣ Downtime Summary
          const Text("Downtime Summary",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...downtime.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                  "${e.downtimeReason} | ${e.downtimeRemark} | ${e.department} (${e.downtime} min)"),
            ),
          ),
        ],
      ),
    );
  }
}
