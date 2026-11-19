import 'package:flutter/material.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();

  factory ReminderService() => _instance;
  ReminderService._internal();

  bool _tahajjudReminderEnabled = false;
  bool _fridayHourReminderEnabled = false;

  bool get tahajjudReminderEnabled => _tahajjudReminderEnabled;
  bool get fridayHourReminderEnabled => _fridayHourReminderEnabled;

  Future<void> scheduleTahajjudReminder(bool enabled) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _tahajjudReminderEnabled = enabled;
      showToast(enabled ? 'Tahajjud reminder enabled' : 'Tahajjud reminder disabled');
    } catch (e) {
      showToast('Failed to schedule reminder: $e');
    }
  }

  Future<void> scheduleFridayHourReminder(bool enabled) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _fridayHourReminderEnabled = enabled;
      showToast(enabled ? 'Friday hour reminder enabled' : 'Friday hour reminder disabled');
    } catch (e) {
      showToast('Failed to schedule reminder: $e');
    }
  }

  void showToast(String message) {
    debugPrint('Toast: $message');
  }
}
