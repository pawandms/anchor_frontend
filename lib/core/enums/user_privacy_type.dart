enum UserPrivacyType {
  everyone('EveryOne'),
  contacts('Contacts'),
  nobody('NoBody');

  final String value;
  const UserPrivacyType(this.value);

  static UserPrivacyType fromString(String? key) {
    return UserPrivacyType.values.firstWhere(
      (e) => e.value.toLowerCase() == (key?.toLowerCase() ?? ''),
      orElse: () => UserPrivacyType.everyone,
    );
  }
}
