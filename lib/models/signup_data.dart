class SignupData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  String? pendingDuaText;
  String? pendingDuaLanguage;

  SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.pendingDuaText,
    this.pendingDuaLanguage,
  });
}
