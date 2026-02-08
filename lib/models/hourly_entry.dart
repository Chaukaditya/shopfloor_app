class HourlyEntry {
  final String date;
  final String shift;
  final String hour;
  final String variant;
  final String side;
  final int production;
  final int? qualityOk;
  final int downtime;
  final String downtimeReason;
  final String downtimeRemark;
  final String department;

  HourlyEntry({
    required this.date,
    required this.shift,
    required this.hour,
    required this.variant,
    required this.side,
    required this.production,
    this.qualityOk,
    required this.downtime,
    required this.downtimeReason,
    required this.downtimeRemark,
    required this.department,
  });

  /// 🔄 Save to JSON
  Map<String, dynamic> toJson() => {
    "date": date,
    "shift": shift,
    "hour": hour,
    "variant": variant,
    "side": side,
    "production": production,
    "qualityOk": qualityOk,
    "downtime": downtime,
    "downtimeReason": downtimeReason,
    "downtimeRemark": downtimeRemark,
    "department": department,
  };

  /// 🔁 Load from JSON
  factory HourlyEntry.fromJson(Map<String, dynamic> json) {
    return HourlyEntry(
      date: json["date"],
      shift: json["shift"],
      hour: json["hour"],
      variant: json["variant"],
      side: json["side"],
      production: json["production"],
      qualityOk: json["qualityOk"],
      downtime: json["downtime"],
      downtimeReason: json["downtimeReason"],
      downtimeRemark: json["downtimeRemark"],
      department: json["department"],
    );
  }
}
