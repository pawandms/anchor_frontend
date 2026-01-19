enum Gender {
  unknown('Unknown'),
  male('Male'),
  female('Female'),
  other('Other');

  final String value;
  const Gender(this.value);

  static Gender fromString(String? key) {
    return Gender.values.firstWhere(
      (e) => e.value.toLowerCase() == (key?.toLowerCase() ?? ''),
      orElse: () => Gender.unknown,
    );
  }
}
