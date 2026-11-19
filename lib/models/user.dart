class User {
  final String id;
  final String name;           // DEPRECATED - Use firstName + lastName
  final String? firstName;
  final String? lastName;
  final String email;
  final String subscriptionStatus; // trial, active, expired
  final Map<String, dynamic> preferences;
  final int duasCreated;
  final int daysSinceJoined;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final bool profileCompleted;
  final bool hasSeenInauguralDua;
  final String themePreference;

  const User({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    this.subscriptionStatus = 'trial',
    this.preferences = const <String, dynamic>{},
    this.duasCreated = 0,
    this.daysSinceJoined = 0,
    required this.createdAt,
    required this.updatedAt,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.profileCompleted = false,
    this.hasSeenInauguralDua = false,
    this.themePreference = 'dark',
  });

  User copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? subscriptionStatus,
    Map<String, dynamic>? preferences,
    int? duasCreated,
    int? daysSinceJoined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
    String? gender,
    String? location,
    bool? profileCompleted,
    bool? hasSeenInauguralDua,
    String? themePreference,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      preferences: preferences ?? this.preferences,
      duasCreated: duasCreated ?? this.duasCreated,
      daysSinceJoined: daysSinceJoined ?? this.daysSinceJoined,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      hasSeenInauguralDua: hasSeenInauguralDua ?? this.hasSeenInauguralDua,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'subscriptionStatus': subscriptionStatus,
      'preferences': preferences,
      'duasCreated': duasCreated,
      'daysSinceJoined': daysSinceJoined,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'date_of_birth': dateOfBirth != null
          ? '${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}'
          : null,
      'gender': gender,
      'location': location,
      'profile_completed': profileCompleted,
      'has_seen_inaugural_dua': hasSeenInauguralDua,
      'theme_preference': themePreference,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final prefsRaw = json['preferences'];
    final prefs = (prefsRaw is Map)
        ? Map<String, dynamic>.from(prefsRaw)
        : <String, dynamic>{};
    
    // Parse date_of_birth
    DateTime? parseDateOfBirth(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    // Parse profile_completed
    bool parseProfileCompleted(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }
    
    // Parse createdAt/updatedAt
    DateTime parseDateTime(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw ArgumentError('Invalid datetime value');
    }
    
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: (json['email'] as String?) ?? '',
      subscriptionStatus: json['subscription_status'] as String? ?? json['subscriptionStatus'] as String? ?? 'trial',
      preferences: prefs,
      duasCreated: (json['duas_created'] as num?)?.toInt() ?? (json['duasCreated'] as num?)?.toInt() ?? 0,
      daysSinceJoined: (json['days_since_joined'] as num?)?.toInt() ?? (json['daysSinceJoined'] as num?)?.toInt() ?? 0,
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
      dateOfBirth: parseDateOfBirth(json['date_of_birth'] ?? json['dateOfBirth']),
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      profileCompleted: parseProfileCompleted(json['profile_completed'] ?? json['profileCompleted']),
      hasSeenInauguralDua: (json['has_seen_inaugural_dua'] as bool?) ?? false,
      themePreference: (json['theme_preference'] as String?) ?? 'dark',
    );
  }
}