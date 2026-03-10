import 'dart:math';

class PasswordGenerator {
  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecial = true,
  }) {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String allowedChars = '';
    if (includeLowercase) allowedChars += lowercase;
    if (includeUppercase) allowedChars += uppercase;
    if (includeNumbers) allowedChars += numbers;
    if (includeSpecial) allowedChars += special;

    if (allowedChars.isEmpty) return '';

    final Random random = Random.secure();
    return List.generate(length, (index) {
      return allowedChars[random.nextInt(allowedChars.length)];
    }).join();
  }
}
