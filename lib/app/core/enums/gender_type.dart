enum GenderType {
  unknow('Unknown'),
  male('Male'),
  female('Female'),
  other('Other');

  final String value;
  const GenderType(this.value);

  @override
  String toString() => value;

  /// Convert string to GenderType enum
  static GenderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return GenderType.male;
      case 'female':
        return GenderType.female;
      case 'other':
        return GenderType.other;
      case 'unknown':
      default:
        return GenderType.unknow;
    }
  }

  /// Get value for API
  String toApiValue() => value;
}
