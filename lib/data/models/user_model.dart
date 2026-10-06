class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String nationalId; // رقم الهوية الوطنية / الإقامة
  final bool isNafathVerified; // التحقق عبر نفاذ
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.nationalId,
    this.isNafathVerified = false,
    this.profileImageUrl,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? nationalId,
    bool? isNafathVerified,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      isNafathVerified: isNafathVerified ?? this.isNafathVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
