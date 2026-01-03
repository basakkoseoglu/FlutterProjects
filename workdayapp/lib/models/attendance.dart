import 'package:workdayapp/core/enums/work_type.dart';

class Attendance {
  final DateTime date;
  final WorkType workType;

  Attendance({required this.date, required this.workType});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'workType': workType.index,
  };

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: DateTime.parse(json['date']),
      workType: WorkType.values[json['workType']],
    );
  }
}
