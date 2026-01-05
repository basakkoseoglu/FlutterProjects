import 'package:flutter/material.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/models/advance.dart';
import 'package:workdayapp/models/attendance.dart';
import 'package:workdayapp/models/salary_settings.dart';
import 'package:workdayapp/services/local_storage_service.dart';

class AttendanceViewModel extends ChangeNotifier {

  // fields
  final List<Attendance> _attendances = [];
  final LocalStorageService _storageService = LocalStorageService();
  DateTime _selectedDate = DateTime.now();
  WorkType? _selectedWorkType;
  DateTime _currentMonth = DateTime.now();
  SalarySettings _salarySettings = SalarySettings.defaultSettings();
  List<Advance> _advances = [];

  // getters
  DateTime get selectedDate => _selectedDate;
  WorkType? get selectedWorkType => _selectedWorkType;
  List<Attendance> get attendanceDates => _attendances;
  DateTime get currentMonth => _currentMonth;
  SalarySettings get salarySettings => _salarySettings;
  List<Advance> get advances => _advances;
  
  int get currentMonthFullDayCount => 
    getFullDayCount(_currentMonth.month, _currentMonth.year);
  
  int get currentMonthHalfDayCount => 
    getHalfDayCount(_currentMonth.month, _currentMonth.year);
  
  int get currentMonthLeaveCount => 
    getLeaveCount(_currentMonth.month, _currentMonth.year);
  
  double get currentMonthGrossSalary => 
    calculateMonthlySalary(_currentMonth.month, _currentMonth.year);
  
  double get currentMonthNetSalary => 
    calculateNetSalary(_currentMonth.month, _currentMonth.year);

  String get todayStatus {
    final today = DateTime.now();
    final attendance = _attendances.where((a) => _isSameDay(a.date, today)).toList();
    if (attendance.isEmpty) return '';

    switch (attendance.first.workType) {
      case WorkType.fullDay: return 'Tam Gün';
      case WorkType.halfDay: return 'Yarım Gün';
      case WorkType.leave: return 'İzin';
    }
  }

  // data loading
  Future<void> loadAttendances() async {
    _attendances.clear();
    _attendances.addAll(await _storageService.loadAttendances());
    notifyListeners();
  }

  Future<void> loadAdvances() async {
    _advances = await _storageService.loadAdvances();
    notifyListeners();
  }

  Future<void> loadSalarySettings() async {
    _salarySettings = await _storageService.loadSalarySettings();
    notifyListeners();
  }

  // attendance operations 
  void selectDate(DateTime date) {
    _selectedDate = date;
    _loadAttendanceForSelectedDate();
    notifyListeners();
  }

  void selectWorkType(WorkType type) {
    _selectedWorkType = type;
    notifyListeners();
  }

  Future<void> saveAttendance() async {
    if (_selectedWorkType == null) return;

    final index = _attendances.indexWhere((a) => _isSameDay(a.date, _selectedDate));

    if (index >= 0) {
      _attendances[index] = Attendance(date: _selectedDate, workType: _selectedWorkType!);
    } else {
      _attendances.add(Attendance(date: _selectedDate, workType: _selectedWorkType!));
    }

    await _storageService.saveAttendances(_attendances);
    notifyListeners();
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

  void _loadAttendanceForSelectedDate() {
    final attendance = _attendances.where((a) => _isSameDay(a.date, _selectedDate));
    _selectedWorkType = attendance.isEmpty ? null : attendance.first.workType;
  }

  // attendance queries
  WorkType? getWorkTypeForDate(DateTime date) {
    try {
      return _attendances.firstWhere((a) => _isSameDay(a.date, date)).workType;
    } catch (_) {
      return null;
    }
  }

  String getStatusTextForDate(DateTime date) {
    final workType = getWorkTypeForDate(date);
    if (workType == null) return 'Kayıt yok';

    switch (workType) {
      case WorkType.fullDay: return 'Tam Gün';
      case WorkType.halfDay: return 'Yarım Gün';
      case WorkType.leave: return 'İzin';
    }
  }

  int getFullDayCount(int month, int year) {
    return _attendances
        .where((a) => a.workType == WorkType.fullDay && 
                      a.date.month == month && 
                      a.date.year == year)
        .length;
  }

  int getHalfDayCount(int month, int year) {
    return _attendances
        .where((a) => a.date.month == month && 
                      a.date.year == year && 
                      a.workType == WorkType.halfDay)
        .length;
  }

  int getLeaveCount(int month, int year) {
    return _attendances
        .where((a) => a.date.month == month && 
                      a.date.year == year && 
                      a.workType == WorkType.leave)
        .length;
  }

  // advance operations
  void addAdvance(double amount, DateTime date, {String? note}) {
    if (amount <= 0) return;
    _advances.add(Advance(amount: amount, date: date, note: note));
    _storageService.saveAdvances(_advances);
    notifyListeners();
  }

  void removeAdvance(Advance advance) {
    _advances.remove(advance);
    _storageService.saveAdvances(_advances);
    notifyListeners();
  }

  List<Advance> getAdvancesForMonth(int month, int year) {
    return _advances
        .where((a) => a.date.month == month && a.date.year == year)
        .toList();
  }

  double getMonthlyAdvance(int month, int year) {
    return _advances
        .where((a) => a.date.month == month && a.date.year == year)
        .fold(0, (sum, a) => sum + a.amount);
  }

  // salary operations
  Future<void> updateSalarySettings({double? dailyWage}) async {
    _salarySettings = _salarySettings.copyWith(dailyWage: dailyWage);
    await _storageService.saveSalarySettings(_salarySettings);
    notifyListeners();
  }

  double calculateMonthlySalary(int month, int year) {
    final fullDays = getFullDayCount(month, year);
    final halfDays = getHalfDayCount(month, year);
    final fullDayTotal = fullDays * _salarySettings.fullDayWage;
    final halfDayTotal = halfDays * _salarySettings.halfDayWage;
    return fullDayTotal + halfDayTotal;
  }

  double calculateNetSalary(int month, int year) {
    final gross = calculateMonthlySalary(month, year);
    final advance = getMonthlyAdvance(month, year);
    return gross - advance;
  }

  // date navigation
  void goToPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    notifyListeners();
  }

  // helper method
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}