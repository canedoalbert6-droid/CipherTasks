class UserModel {
  final String username;
  final bool isBiometricEnabled;

  UserModel({
    required this.username,
    this.isBiometricEnabled = false,
  });
}
