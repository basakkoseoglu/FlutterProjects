import 'package:flutter/material.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';

class HistoryViewModel extends ChangeNotifier {
  List<DateTime> _months = [];

  List<DateTime> get months => _months;

  HistoryViewModel() {
    _init();
  }

  void _init() {
    final now = DateTime.now();
    _months = List.generate(
      3,
      (index) => DateTime(now.year, now.month - index),
    );
  }

  String formatMonth(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String getTrendText(List<int> scores) {
    if (scores.length < 2) {
      return 'Yeterli veri yok';
    }

    final first = scores.last;
    final last = scores.first;

    if (last > first) {
      return 'Son aylarda çalışma yoğunluğun artış göstermiş';
    } else if (last < first) {
      return 'Son aylarda çalışma yoğunluğun azalmış ';
    } else {
      return 'Çalışma düzenin son aylarda stabil ilerliyor ';
    }
  }

  String getSummaryText(AttendanceViewModel vm) {
    if (_months.length < 3)
      return 'Son 3 ayda çalışma düzenin genel olarak dengeli ve istikrarlı ilerliyor.';

    final scores = _months
        .map((m) => vm.getWorkScore(m.month, m.year))
        .toList();
    final salaries = _months
        .map((m) => vm.calculateNetSalary(m.month, m.year))
        .toList();

    final avgFirst2 = (scores[2] + scores[1]) / 2;
    final lastScore = scores[0];
    final improvement = lastScore - avgFirst2;

    final salaryTrend = salaries[0] - salaries[2];

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final scoreRange = maxScore - minScore;
    final isStable = scoreRange < (maxScore * 0.3);

    if (improvement > 5) {
      return 'Son 3 ayda performansın giderek artıyor! Harika bir ivmeye sahipsin 🚀';
    } else if (improvement < -5) {
      return 'Son aylarda çalışma yoğunluğun biraz azalmış görünüyor. Belki biraz mola vakti 😊';
    } else if (isStable && salaryTrend > 0) {
      return 'Son 3 ayda çalışma düzenin dengeli ve kazancın istikrarlı artıyor 📊';
    } else if (isStable) {
      return 'Son 3 ayda çalışma düzenin genel olarak dengeli ve istikrarlı ilerliyor ✨';
    } else {
      return 'Son 3 ayda farklı yoğunluklarda çalıştın, esnek bir dönem geçirdin 🔄';
    }
  }
}
