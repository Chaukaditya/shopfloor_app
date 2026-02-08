import 'package:flutter/material.dart';
import 'shift_end_screen.dart';
import 'models/hourly_entry.dart';
import 'storage/local_storage.dart';

class ProductionEntryScreen extends StatefulWidget {
  final String lineName;
  final String date;

  const ProductionEntryScreen({
    super.key,
    required this.lineName,
    required this.date,
  });

  @override
  State<ProductionEntryScreen> createState() => _ProductionEntryScreenState();
}

class _ProductionEntryScreenState extends State<ProductionEntryScreen> {
  late String storageKey;
  List<HourlyEntry> savedEntries = [];

  final productionController = TextEditingController();
  final downtimeController = TextEditingController();
  final downtimeDetailController = TextEditingController();

  String selectedShift = "A";
  String selectedHour = "";
  String selectedVariant = "High";
  String selectedSide = "LH";
  String downtimeReason = "No Downtime";
  String responsibleDept = "Assembly";

  final variants = ["High", "Base", "Mid"];
  final sides = ["LH", "RH", "Common"];

  final downtimeReasons = [
    "No Downtime",
    "Manpower Shortage",
    "Machine Breakdown",
    "Material Shortage",
    "Quality Issue",
    "Change Over",
    "Others",
  ];

  final departments = [
    "Assembly",
    "Moulding",
    "Surface Treatment",
    "Inprocess Quality",
    "IQC",
    "HR",
    "Maintenance",
    "Store",
    "Purchase",
  ];

  bool isEditMode = false;
  int editingIndex = -1;

  List<String> get hourSlots {
    return selectedShift == "A"
        ? [
      "06:30-07:30",
      "07:30-08:30",
      "08:30-09:30",
      "09:30-10:30",
      "10:30-11:30",
      "11:30-12:30",
      "12:30-13:30",
      "13:30-14:30",
      "14:30-15:30",
      "15:30-16:30",
      "16:30-17:30",
      "17:30-18:30",
    ]
        : [
      "18:30-19:30",
      "19:30-20:30",
      "20:30-21:30",
      "21:30-22:30",
      "22:30-23:30",
      "23:30-00:30",
      "00:30-01:30",
      "01:30-02:30",
      "02:30-03:30",
      "03:30-04:30",
      "04:30-05:30",
      "05:30-06:30",
    ];
  }

  bool isHourLocked(String hour) {
    if (isEditMode && editingIndex >= 0) {
      final e = sortedEntries()[editingIndex];
      if (e.hour == hour) return false;
    }
    return sortedEntries()
        .any((e) => e.shift == selectedShift && e.hour == hour);
  }

  @override
  void initState() {
    super.initState();
    storageKey = "${widget.date}_${widget.lineName}";
    selectedHour = hourSlots.first;
    _loadData();
  }

  Future<void> _loadData() async {
    savedEntries = await LocalStorage.loadEntries(storageKey);
    setState(() {});
  }

  Future<void> _saveData() async {
    await LocalStorage.saveEntries(storageKey, savedEntries);
  }

  List<HourlyEntry> sortedEntries() {
    final list =
    savedEntries.where((e) => e.shift == selectedShift).toList();
    list.sort((a, b) =>
        hourSlots.indexOf(a.hour).compareTo(hourSlots.indexOf(b.hour)));
    return list;
  }

  void startEdit(int index) {
    final e = sortedEntries()[index];
    isEditMode = true;
    editingIndex = index;

    selectedHour = e.hour;
    selectedVariant = e.variant;
    selectedSide = e.side;
    productionController.text = e.production.toString();
    downtimeController.text = e.downtime.toString();
    downtimeReason = e.downtimeReason;
    downtimeDetailController.text = e.downtimeRemark;
    responsibleDept = e.department;

    setState(() {});
  }

  void deleteEntry(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Entry?"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final e = sortedEntries()[index];
      savedEntries.removeWhere((item) =>
      item.date == e.date &&
          item.shift == e.shift &&
          item.hour == e.hour);
      await _saveData();
      setState(() {});
    }
  }

  /// ✅ FIXED SAVE LOGIC (NO DOUBLE ENTRY)
  void saveEntry() async {
    if (productionController.text.isEmpty) return;

    /// 🚫 HARD BLOCK FOR DOUBLE ENTRY
    if (!isEditMode) {
      final alreadyExists = savedEntries.any(
            (e) =>
        e.date == widget.date &&
            e.shift == selectedShift &&
            e.hour == selectedHour,
      );

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "⚠️ This hour is already locked. Double entry not allowed.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (isEditMode && editingIndex >= 0) {
      final old = sortedEntries()[editingIndex];
      final idx = savedEntries.indexWhere((e) =>
      e.date == old.date &&
          e.shift == old.shift &&
          e.hour == old.hour);

      if (idx >= 0) {
        savedEntries[idx] = HourlyEntry(
          date: widget.date,
          shift: selectedShift,
          hour: selectedHour,
          variant: selectedVariant,
          side: selectedSide,
          production: int.parse(productionController.text),
          downtime: downtimeController.text.isEmpty
              ? 0
              : int.parse(downtimeController.text),
          downtimeReason: downtimeReason,
          downtimeRemark: downtimeDetailController.text,
          department: responsibleDept,
        );
      }

      isEditMode = false;
      editingIndex = -1;
    } else {
      savedEntries.add(
        HourlyEntry(
          date: widget.date,
          shift: selectedShift,
          hour: selectedHour,
          variant: selectedVariant,
          side: selectedSide,
          production: int.parse(productionController.text),
          downtime: downtimeController.text.isEmpty
              ? 0
              : int.parse(downtimeController.text),
          downtimeReason: downtimeReason,
          downtimeRemark: downtimeDetailController.text,
          department: responsibleDept,
        ),
      );
    }

    await _saveData();

    productionController.clear();
    downtimeController.clear();
    downtimeDetailController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final displayList = sortedEntries();

    return Scaffold(
      appBar: AppBar(title: const Text("Hourly Production Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Line : ${widget.lineName}"),
            Text("Date : ${widget.date}"),
            const SizedBox(height: 12),

            /// SHIFT
            DropdownButtonFormField<String>(
              value: selectedShift,
              items: ["A", "B"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedShift = v!;
                  selectedHour = hourSlots.first;
                  isEditMode = false;
                });
              },
              decoration: const InputDecoration(
                labelText: "Shift",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            /// HOUR
            DropdownButtonFormField<String>(
              value: selectedHour,
              items: hourSlots.map((hour) {
                final locked = isHourLocked(hour);
                return DropdownMenuItem(
                  value: hour,
                  enabled: !locked,
                  child: Text(
                    hour,
                    style: TextStyle(
                      color: locked ? Colors.grey : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (!isHourLocked(v!)) {
                  setState(() => selectedHour = v);
                }
              },
              decoration: const InputDecoration(
                labelText: "Hour Slot",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            /// VARIANT
            DropdownButtonFormField(
              value: selectedVariant,
              items: variants
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedVariant = v!),
              decoration: const InputDecoration(
                labelText: "Variant",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            /// SIDE
            DropdownButtonFormField(
              value: selectedSide,
              items: sides
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedSide = v!),
              decoration: const InputDecoration(
                labelText: "Side",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: productionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Production Qty",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: downtimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Downtime Minutes",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: downtimeReason,
              items: downtimeReasons
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => downtimeReason = v!),
              decoration: const InputDecoration(
                labelText: "Downtime Reason",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: downtimeDetailController,
              decoration: const InputDecoration(
                labelText: "Downtime Exact Issue / Details",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: responsibleDept,
              items: departments
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => responsibleDept = v!),
              decoration: const InputDecoration(
                labelText: "Responsible Department",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: saveEntry,
              child: Text(isEditMode ? "UPDATE ENTRY" : "SAVE HOURLY ENTRY"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Saved Hourly Production",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Shift")),
                  DataColumn(label: Text("Hour")),
                  DataColumn(label: Text("Variant")),
                  DataColumn(label: Text("Side")),
                  DataColumn(label: Text("Prod")),
                  DataColumn(label: Text("DT")),
                  DataColumn(label: Text("Reason")),
                  DataColumn(label: Text("Details")),
                  DataColumn(label: Text("Dept")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: List.generate(displayList.length, (index) {
                  final e = displayList[index];
                  return DataRow(cells: [
                    DataCell(Text(e.shift)),
                    DataCell(Text(e.hour)),
                    DataCell(Text(e.variant)),
                    DataCell(Text(e.side)),
                    DataCell(Text(e.production.toString())),
                    DataCell(Text(e.downtime.toString())),
                    DataCell(Text(e.downtimeReason)),
                    DataCell(Text(e.downtimeRemark)),
                    DataCell(Text(e.department)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => startEdit(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteEntry(index),
                        ),
                      ],
                    )),
                  ]);
                }),
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              child: const Text("SHIFT END ENTRY"),
              onPressed: () async {
                // 1️⃣ expected hours for selected shift
                final expectedHours = hourSlots;

                // 2️⃣ filled hours for selected shift
                final filledHours = savedEntries
                    .where((e) => e.shift == selectedShift)
                    .map((e) => e.hour)
                    .toSet();

                // 3️⃣ find missing hours
                final missingHours =
                expectedHours.where((h) => !filledHours.contains(h)).toList();

                bool proceed = true;

                // 4️⃣ if missing → show dialog
                if (missingHours.isNotEmpty) {
                  proceed = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Incomplete Shift Data"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Following hour entries are missing:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...missingHours.map((h) => Text("• $h")),
                          const SizedBox(height: 12),
                          const Text(
                            "Still you want to continue to Shift End Entry?",
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("NO"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("YES"),
                        ),
                      ],
                    ),
                  ) ??
                      false;
                }

                // 5️⃣ if user said NO → stay here
                if (!proceed) return;

                // 6️⃣ navigate to shift end screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShiftEndScreen(
                      date: widget.date,
                      lineName: widget.lineName,
                      shift: selectedShift,
                    ),
                  ),
                );

                if (result == true) {
                  await _loadData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
/// ksurhfksrfjs 