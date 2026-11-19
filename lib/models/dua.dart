import 'package:flutter/foundation.dart';

@immutable
class Dua {
  final String id;
  final String title;
  final String preview;
  final List<String> tags;
  final DateTime createdAt;
  final bool favorite;
  final String englishText;
  final String body;
  final String? userId;
  final String folderId;
  final bool isBookmarked;
  // New field: whether the duʿā has been marked as answered by the user
  final bool isAnswered;
  final DateTime updatedAt;
  final String outputLanguage;
  final bool isInaugural;

  const Dua({
    required this.id,
    required this.title,
    required this.preview,
    this.tags = const [],
    required this.createdAt,
    this.favorite = false,
    this.englishText = '',
    this.body = '',
    this.userId,
    String? folderId,
    this.isBookmarked = false,
    this.isAnswered = false,
    DateTime? updatedAt,
    this.outputLanguage = 'english',
    this.isInaugural = false,
  }) : folderId = folderId ?? '',
       updatedAt = updatedAt ?? createdAt;

  bool get isRtl => outputLanguage == 'arabic' || outputLanguage == 'urdu';

  bool isNew({int days = 7}) =>
    DateTime.now().difference(createdAt).inDays <= days;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'preview': preview,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'favorite': favorite,
    'englishText': englishText,
    'body': body,
    'userId': userId,
    'folderId': folderId,
    'isBookmarked': isBookmarked,
    'isAnswered': isAnswered,
    'updatedAt': updatedAt.toIso8601String(),
    'outputLanguage': outputLanguage,
    'isInaugural': isInaugural,
  };

  static Dua fromJson(Map<String, dynamic> json) => Dua(
    id: json['id'] as String,
    title: json['title'] as String,
    preview: json['preview'] as String,
    tags: List<String>.from(json['tags'] as List? ?? []),
    createdAt: DateTime.parse(json['createdAt'] as String),
    favorite: json['favorite'] as bool? ?? false,
    englishText: json['englishText'] as String? ?? '',
    body: json['body'] as String? ?? '',
    userId: json['userId'] as String?,
    folderId: json['folderId'] as String? ?? '',
    isBookmarked: json['isBookmarked'] as bool? ?? false,
    isAnswered: json['isAnswered'] as bool? ?? false,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    outputLanguage: json['outputLanguage'] as String? ?? 'english',
    isInaugural: json['isInaugural'] as bool? ?? false,
  );

  Dua copyWith({
    String? id,
    String? title,
    String? preview,
    List<String>? tags,
    DateTime? createdAt,
    bool? favorite,
    String? englishText,
    String? body,
    String? userId,
    String? folderId,
    bool? isBookmarked,
    bool? isAnswered,
    DateTime? updatedAt,
    String? outputLanguage,
    bool? isInaugural,
  }) =>
    Dua(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      favorite: favorite ?? this.favorite,
      englishText: englishText ?? this.englishText,
      body: body ?? this.body,
      userId: userId,
      folderId: folderId ?? this.folderId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isAnswered: isAnswered ?? this.isAnswered,
      updatedAt: updatedAt ?? this.updatedAt,
      outputLanguage: outputLanguage ?? this.outputLanguage,
      isInaugural: isInaugural ?? this.isInaugural,
    );
}
