enum GenderType {
  unknown('Unknown'),
  male('Male'),
  female('Female'),
  other('Other');

  final String value;
  const GenderType(this.value);

  static GenderType fromString(String? key) {
    return GenderType.values.firstWhere(
      (e) => e.value.toLowerCase() == (key?.toLowerCase() ?? ''),
      orElse: () => GenderType.unknown,
    );
  }
}
