class CommunityDua {
  final String id;
  final String name;
  final String title;
  final int hearts;
  final String avatarUrl;
  final DateTime createdAt;

  const CommunityDua({
    required this.id,
    required this.name,
    required this.title,
    required this.hearts,
    this.avatarUrl = '',
    required this.createdAt,
  });

  CommunityDua copyWith({
    String? id,
    String? name,
    String? title,
    int? hearts,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return CommunityDua(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      hearts: hearts ?? this.hearts,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'hearts': hearts,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityDua.fromJson(Map<String, dynamic> json) {
    return CommunityDua(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      hearts: json['hearts'] as int,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
