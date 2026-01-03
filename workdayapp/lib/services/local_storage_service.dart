import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdayapp/models/attendance.dart';

class LocalStorageService {
  static const _key='attendances';

  Future<void> saveAttendances(List<Attendance> attendances) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        attendances.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

   Future<List<Attendance>> loadAttendances() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((e) => Attendance.fromJson(jsonDecode(e)))
        .toList();
  }
}