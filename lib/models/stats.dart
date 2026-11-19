class Stats {
  final int duasMade;
  final int subscribers;
  final int downloads;
  final double charityImpact;
  final DateTime updatedAt;

  const Stats({
    required this.duasMade,
    required this.subscribers,
    required this.downloads,
    required this.charityImpact,
    required this.updatedAt,
  });

  Stats copyWith({
    int? duasMade,
    int? subscribers,
    int? downloads,
    double? charityImpact,
    DateTime? updatedAt,
  }) {
    return Stats(
      duasMade: duasMade ?? this.duasMade,
      subscribers: subscribers ?? this.subscribers,
      downloads: downloads ?? this.downloads,
      charityImpact: charityImpact ?? this.charityImpact,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duasMade': duasMade,
      'subscribers': subscribers,
      'downloads': downloads,
      'charityImpact': charityImpact,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      duasMade: json['duasMade'] as int,
      subscribers: json['subscribers'] as int,
      downloads: json['downloads'] as int,
      charityImpact: json['charityImpact'] as double,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}