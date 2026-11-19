class IslamicEvent {
  final String id;
  final String name;
  final String date;
  final String countdownText;
  final String hadith;
  final String reference;
  final DateTime createdAt;

  const IslamicEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.countdownText,
    required this.hadith,
    required this.reference,
    required this.createdAt,
  });

  IslamicEvent copyWith({
    String? id,
    String? name,
    String? date,
    String? countdownText,
    String? hadith,
    String? reference,
    DateTime? createdAt,
  }) {
    return IslamicEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      countdownText: countdownText ?? this.countdownText,
      hadith: hadith ?? this.hadith,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'countdownText': countdownText,
      'hadith': hadith,
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      countdownText: json['countdownText'] as String,
      hadith: json['hadith'] as String,
      reference: json['reference'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
