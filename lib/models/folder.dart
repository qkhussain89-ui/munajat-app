import 'package:flutter/material.dart';

/// Unified Folder model (emoji-based icon + count).
class Folder {
  final String id;
  final String userId;
  String name;
  /// Emoji or short text icon, e.g. "🤲", "🗂", "⭐".
  String? emoji;
  /// Number of Duas in this folder.
  int count;
  /// Position for ordering.
  int position;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.userId,
    required this.name,
    this.emoji,
    this.count = 0,
    this.position = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Folder copyWith({String? name, String? emoji, int? count, int? position}) {
    return Folder(
      id: id,
      userId: userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      position: position ?? this.position,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'emoji': emoji,
    'count': count,
    'position': position,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? 'user_1',
    name: json['name'] as String,
    emoji: json['emoji'] as String?,
    count: json['count'] as int? ?? 0,
    position: json['position'] as int? ?? 0,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : DateTime.now(),
  );
}
