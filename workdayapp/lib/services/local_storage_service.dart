import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdayapp/models/advance.dart';
import 'package:workdayapp/models/attendance.dart';
import 'package:workdayapp/models/salary_settings.dart';

class LocalStorageService {
  //storage keys
  static const _key = 'attendances';
  static const String _salaryKey = 'salary_settings';
  static const String _advanceKey = 'advances';

  //devamsızlık kayıtlarını kaydeder
  Future<void> saveAttendances(List<Attendance> attendances) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = attendances.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  //devamszılık kayıtlarını yükler
  Future<List<Attendance>> loadAttendances() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.map((e) => Attendance.fromJson(jsonDecode(e))).toList();
  }

  //maaş ayarlarını kaydeder
  Future<void> saveSalarySettings(SalarySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(settings.toJson());
    await prefs.setString(_salaryKey, jsonString);
  }

  //maaş ayarlarını yükler
  Future<SalarySettings> loadSalarySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_salaryKey);

    if (jsonString == null) {
      return SalarySettings.defaultSettings();
    }

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return SalarySettings.fromJson(jsonMap);
  }

  //avans kayıtlarını kaydeder
  Future<void> saveAdvances(List<Advance> advances) async {
    final prefs = await SharedPreferences.getInstance();
    final list = advances.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_advanceKey, list);
  }

  //avans kayıtlarını yükler
  Future<List<Advance>> loadAdvances() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_advanceKey) ?? [];

    return list.map((e) => Advance.fromJson(jsonDecode(e))).toList();
  }
}
