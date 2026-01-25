enum UserLanguageType {
  english('English', 'English'),
  hindi('Hindi', 'हिन्दी');

  final String value;
  final String nativeName;
  const UserLanguageType(this.value, this.nativeName);

  static UserLanguageType fromString(String value) {
    return UserLanguageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserLanguageType.english,
    );
  }
}
