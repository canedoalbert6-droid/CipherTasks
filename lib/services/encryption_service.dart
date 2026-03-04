import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  final String keyString; // Base64 encoded 32-byte key

  EncryptionService(this.keyString);

  String encryptData(String plaintext) {
    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromLength(16); // In a production app, IV should be stored with ciphertext
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    // Combine IV and Ciphertext for storage (simplification for lab)
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptData(String ciphertextWithIv) {
    final parts = ciphertextWithIv.split(":");
    if (parts.length != 2) return "Error: Invalid Ciphertext";

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedData = parts[1];

    final key = encrypt.Key.fromBase64(keyString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedData), iv: iv);
  }
}
