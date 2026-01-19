enum ProfileType {
  public('Public'),
  private('Private'),
  protected('Protected');

  final String value;
  const ProfileType(this.value);

  static ProfileType fromString(String? key) {
    return ProfileType.values.firstWhere(
      (e) => e.value.toLowerCase() == (key?.toLowerCase() ?? ''),
      orElse: () => ProfileType.public,
    );
  }
}
