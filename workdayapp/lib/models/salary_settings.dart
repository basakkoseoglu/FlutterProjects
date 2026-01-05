import 'package:workdayapp/models/advance.dart';

class SalarySettings {
  final double dailyWage;
  final List<Advance> advances;

  SalarySettings({
    required this.dailyWage,
    List<Advance>? advances,
  }) : advances = advances ?? [];

  double get fullDayWage => dailyWage;
  double get halfDayWage => dailyWage / 2;

  double get totalAdvance {
    return advances.fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyWage': dailyWage,
      'advances': advances.map((e) => e.toJson()).toList(),
    };
  }

  factory SalarySettings.fromJson(Map<String, dynamic> json) {
    return SalarySettings(
      dailyWage: (json['dailyWage'] ?? 0.0).toDouble(),
      advances: (json['advances'] as List<dynamic>? ?? [])
          .map((e) => Advance.fromJson(e))
          .toList(),
    );
  }

  factory SalarySettings.defaultSettings() {
    return SalarySettings(
      dailyWage: 0.0,
      advances: [],
    );
  }

  SalarySettings copyWith({
    double? dailyWage,
    List<Advance>? advances,
  }) {
    return SalarySettings(
      dailyWage: dailyWage ?? this.dailyWage,
      advances: advances ?? this.advances,
    );
  }
}
