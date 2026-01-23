enum UserLanguageType {
  english('English'),
  hindi('Hindi');

  final String value;
  const UserLanguageType(this.value);

  static UserLanguageType fromString(String value) {
    return UserLanguageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserLanguageType.english,
    );
  }
}
