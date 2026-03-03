import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class KeyStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<String> getOrCreateKey(String key) async {
    String? existingKey = await read(key);
    if (existingKey == null) {
      // Generate a random 32-byte key for AES-256
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      existingKey = base64Url.encode(values);
      await write(key, existingKey);
    }
    return existingKey;
  }
}
