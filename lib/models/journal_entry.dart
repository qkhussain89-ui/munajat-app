import 'package:flutter/foundation.dart';

@immutable
class JournalEntry {
  final String id;
  final List<String> moods;
  final List<String> blessings;
  final List<String> weights;
  final List<String> challenges;
  final String dua;
  final String reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.createdAt,
    this.moods = const [],
    this.blessings = const [],
    this.weights = const [],
    this.challenges = const [],
    this.dua = '',
    this.reminder = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'moods': moods,
    'blessings': blessings,
    'weights': weights,
    'challenges': challenges,
    'dua': dua,
    'reminder': reminder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static JournalEntry fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    moods: List<String>.from(json['moods'] as List? ?? []),
    blessings: List<String>.from(json['blessings'] as List? ?? []),
    weights: List<String>.from(json['weights'] as List? ?? []),
    challenges: List<String>.from(json['challenges'] as List? ?? []),
    dua: json['dua'] as String? ?? '',
    reminder: json['reminder'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );

  JournalEntry copyWith({
    String? id,
    List<String>? moods,
    List<String>? blessings,
    List<String>? weights,
    List<String>? challenges,
    String? dua,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JournalEntry(
    id: id ?? this.id,
    moods: moods ?? this.moods,
    blessings: blessings ?? this.blessings,
    weights: weights ?? this.weights,
    challenges: challenges ?? this.challenges,
    dua: dua ?? this.dua,
    reminder: reminder ?? this.reminder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
