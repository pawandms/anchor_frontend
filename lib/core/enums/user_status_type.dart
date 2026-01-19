enum UserStatusType {
  unknown(0),
  normal(2),
  forbidden(3),
  virtual(4),
  operation(5),
  unverified(6);

  final int value;
  const UserStatusType(this.value);

  static UserStatusType fromValue(dynamic value) {
    if (value is int) {
      return UserStatusType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => UserStatusType.unknown,
      );
    } else if (value is String) {
      // Try parsing int if string is a number
      final intVal = int.tryParse(value);
      if (intVal != null) {
        return UserStatusType.values.firstWhere(
          (e) => e.value == intVal,
          orElse: () => UserStatusType.unknown,
        );
      }
      // Fallback for name matching if needed (optional)
      return UserStatusType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => UserStatusType.unknown,
      );
    }
    return UserStatusType.unknown;
  }
}
