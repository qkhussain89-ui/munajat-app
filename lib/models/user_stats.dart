class UserStats {
  final String userId;
  final int duasCreated;
  final int daysActive;
  final int barakahImpact;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    required this.userId,
    this.duasCreated = 0,
    this.daysActive = 0,
    this.barakahImpact = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  UserStats copyWith({
    String? userId,
    int? duasCreated,
    int? daysActive,
    int? barakahImpact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      duasCreated: duasCreated ?? this.duasCreated,
      daysActive: daysActive ?? this.daysActive,
      barakahImpact: barakahImpact ?? this.barakahImpact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'duasCreated': duasCreated,
      'daysActive': daysActive,
      'barakahImpact': barakahImpact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      duasCreated: json['duasCreated'] as int? ?? 0,
      daysActive: json['daysActive'] as int? ?? 0,
      barakahImpact: json['barakahImpact'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
