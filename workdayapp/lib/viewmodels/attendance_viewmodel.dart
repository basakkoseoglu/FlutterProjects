import 'package:flutter/material.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/models/attendance.dart';
import 'package:workdayapp/services/local_storage_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final List<Attendance> _attendances = [];
  final LocalStorageService _storageService = LocalStorageService();

  DateTime _selectedDate = DateTime.now();
  WorkType? _selectedWorkType;
  DateTime _currentMonth = DateTime.now();

  //getters
  DateTime get selectedDate => _selectedDate;
  WorkType? get selectedWorkType => _selectedWorkType;
  List<Attendance> get attendanceDates => _attendances;
  DateTime get currentMonth => _currentMonth;

  Future<void> loadAttendances() async {
    _attendances.clear();
    _attendances.addAll(await _storageService.loadAttendances());
    notifyListeners();
  }

  //gün seç
  void selectDate(DateTime date) {
    _selectedDate = date;
    _loadAttendanceForSelectedDate();
    notifyListeners();
  }

  //çalışma türü seç
  void selectWorkType(WorkType type) {
    _selectedWorkType = type;
    notifyListeners();
  }

  //günü kaydet
  Future<void> saveAttendance() async {
    if (_selectedWorkType == null) return;

    final index = _attendances.indexWhere(
      (a) => _isSameDay(a.date, _selectedDate),
    );

    if (index >= 0) {
      //gün zaten kayıtlı, güncelle
      _attendances[index] = Attendance(
        date: _selectedDate,
        workType: _selectedWorkType!,
      );
    } else {
      //yeni gün ekle
      _attendances.add(
        Attendance(date: _selectedDate, workType: _selectedWorkType!),
      );
    }

    await _storageService.saveAttendances(_attendances);
    notifyListeners();
  }

  //seçilen günde kayıt varmı kontrol et
  void _loadAttendanceForSelectedDate() {
    final attendance = _attendances.where(
      (a) => _isSameDay(a.date, _selectedDate),
    );

    if (attendance.isEmpty) {
      _selectedWorkType = null;
    } else {
      _selectedWorkType = attendance.first.workType;
    }
  }

  String get todayStatus {
    final today = DateTime.now();

    final attendance = _attendances
        .where((a) => _isSameDay(a.date, today))
        .toList();

    if (attendance.isEmpty) return '';

    switch (attendance.first.workType) {
      case WorkType.fullDay:
        return 'Tam Gün';
      case WorkType.halfDay:
        return 'Yarım Gün';
      case WorkType.leave:
        return 'İzin';
    }
  }

  //aylık özet
  int getFullDayCount(int month, int year) {
    return _attendances
        .where(
          (a) =>
              a.workType == WorkType.fullDay &&
              a.date.month == month &&
              a.date.year == year,
        )
        .length;
  }

  int getHalfDayCount(int month, int year) {
    return _attendances
        .where(
          (a) =>
              a.date.month == month &&
              a.date.year == year &&
              a.workType == WorkType.halfDay,
        )
        .length;
  }

  int getLeaveCount(int month, int year) {
    return _attendances
        .where(
          (a) =>
              a.date.month == month &&
              a.date.year == year &&
              a.workType == WorkType.leave,
        )
        .length;
  }

  //yardımcı
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get currentMonthFullDayCount {
    return getFullDayCount(_currentMonth.month, _currentMonth.year);
  }

  int get currentMonthHalfDayCount {
    return getHalfDayCount(_currentMonth.month, _currentMonth.year);
  }

  int get currentMonthLeaveCount {
    return getLeaveCount(_currentMonth.month, _currentMonth.year);
  }

  WorkType? getWorkTypeForDate(DateTime date) {
    try {
      return _attendances.firstWhere((a) => _isSameDay(a.date, date)).workType;
    } catch (_) {
      return null;
    }
  }

  //ay değiştir
  void goToPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    notifyListeners();
  }

  String getStatusTextForDate(DateTime date) {
    final workType = getWorkTypeForDate(date);

    if (workType == null) return 'Kayıt yok';

    switch (workType) {
      case WorkType.fullDay:
        return 'Tam Gün';
      case WorkType.halfDay:
        return 'Yarım Gün';
      case WorkType.leave:
        return 'İzin';
    }
  }

  Future<void> deleteAttendanceForSelectedDate() async {
    final before = _attendances.length;

    _attendances.removeWhere((a) => _isSameDay(a.date, _selectedDate));

    if (_attendances.length != before) {
      _selectedWorkType = null;
      await _storageService.saveAttendances(_attendances);
      notifyListeners();
    }
  }
}