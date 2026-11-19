import 'package:flutter/material.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();

  factory TTSService() => _instance;
  TTSService._internal();

  bool _isPlaying = false;
  double _speed = 1.0;

  bool get isPlaying => _isPlaying;
  double get speed => _speed;

  Future<void> play(String text) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isPlaying = true;
      showToast('Playing: ${text.substring(0, 30)}...');
    } catch (e) {
      showToast('Failed to play: $e');
    }
  }

  Future<void> stop() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _isPlaying = false;
      showToast('Audio stopped');
    } catch (e) {
      showToast('Failed to stop: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _speed = speed;
      showToast('Speed set to ${speed.toStringAsFixed(2)}x');
    } catch (e) {
      showToast('Failed to set speed: $e');
    }
  }

  void showToast(String message) {
    debugPrint('Toast: $message');
  }
}
