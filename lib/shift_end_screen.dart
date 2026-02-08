import 'package:flutter/material.dart';
import 'models/hourly_entry.dart';
import 'storage/local_storage.dart';
import 'report_preview_screen.dart';

class ShiftEndScreen extends StatefulWidget {
  final String date;
  final String lineName;
  final String shift;

  const ShiftEndScreen({
    super.key,
    required this.date,
    required this.lineName,
    required this.shift,
  });

  @override
  State<ShiftEndScreen> createState() => _ShiftEndScreenState();
}

class _ShiftEndScreenState extends State<ShiftEndScreen> {
  late String keyName;
  List<HourlyEntry> data = [];

  final variants = ["High", "Base", "Mid"];
  final sides = ["LH", "RH", "Common"];

  final List<String> selVariant = List.filled(4, "High");
  final List<String> selSide = List.filled(4, "LH");
  final List<TextEditingController> qtyCtrl =
  List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    keyName = "${widget.date}_${widget.lineName}";
    _load();
  }

  Future<void> _load() async {
    final all = await LocalStorage.loadEntries(keyName);
    data = all.where((e) => e.shift == widget.shift).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shift End Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Date : ${widget.date}"),
            Text("Line : ${widget.lineName}"),
            Text("Shift : ${widget.shift}"),
            const Divider(),

            /// Variant–Side blocks (4x matrix)
            const Text(
              "Final Variant / Side Quantities (Matrix)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text("Variant")),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text("Side")),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text("Qty")),
                    ),
                  ],
                ),
                // 4 Data Rows
                for (int i = 0; i < 4; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: DropdownButtonFormField(
                          value: selVariant[i],
                          items: variants
                              .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v, textAlign: TextAlign.center),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => selVariant[i] = v!),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: DropdownButtonFormField(
                          value: selSide[i],
                          items: sides
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child:
                            Text(s, textAlign: TextAlign.center),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => selSide[i] = v!),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: TextField(
                          controller: qtyCtrl[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// REPORT PREVIEW BUTTON
            OutlinedButton(
              child: const Text("REPORT PREVIEW"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportPreviewScreen(
                      date: widget.date,
                      line: widget.lineName,
                      shift: widget.shift,
                      entries: data,
                      finalQualityBlocks: List.generate(4, (i) => {
                        "variant": selVariant[i],
                        "side": selSide[i],
                        "qty": int.tryParse(qtyCtrl[i].text) ?? 0,
                      }),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            /// SUBMIT
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("SUBMIT THE REPORT"),
              onPressed: () async {
                final reportData = {
                  "entries":
                  data.map((e) => e.toJson()).toList(), // 👍 JSON safe
                  "finalQuality": List.generate(4, (i) => {
                    "variant": selVariant[i],
                    "side": selSide[i],
                    "qty": int.tryParse(qtyCtrl[i].text) ?? 0,
                  }),
                };

                await LocalStorage.saveReport(
                  "REPORT_${widget.date}_${widget.lineName}_${widget.shift}",
                  reportData,
                );

                /// remove only this shift data
                final all = await LocalStorage.loadEntries(keyName);
                all.removeWhere((e) => e.shift == widget.shift);
                await LocalStorage.saveEntries(keyName, all);

                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
