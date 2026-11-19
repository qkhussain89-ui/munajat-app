import 'package:flutter/material.dart';

class AIDuaService {
  static final AIDuaService _instance = AIDuaService._internal();

  factory AIDuaService() => _instance;
  AIDuaService._internal();

  Future<String> generateDuaAI(String prompt) async {
    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      return '''Allāhumma, grant me wisdom and understanding. By Your Names, the Most Wise and the Most Merciful, guide my steps and illuminate my path. Accept from me this sincere effort and bless it with goodness. Āmīn.''';
    } catch (e) {
      throw Exception('Failed to generate duʿā: $e');
    }
  }

  void showToast(String message) {
    debugPrint('Toast: $message');
  }
}
