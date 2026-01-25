import 'package:get/get.dart';

enum GenderType {
  unknown('Unknown'),
  male('Male'),
  female('Female'),
  other('Other');

  final String value;
  const GenderType(this.value);

  String get localizedName => 'gender_${value.toLowerCase()}'.tr;

  static GenderType fromString(String? key) {
    return GenderType.values.firstWhere(
      (e) => e.value.toLowerCase() == (key?.toLowerCase() ?? ''),
      orElse: () => GenderType.unknown,
    );
  }
}
