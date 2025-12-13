import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service to handle data encryption and decryption.
class EncryptionService {
  // Use a 32-byte (256-bit) key for AES-256 encryption
  // Ensure exactly 32 bytes for AES-256
  static encrypt.Key _createKey() {
    const keyString = '32charslongsecretkeymustbeused!';
    // Use UTF-8 encoding to get byte representation
    final keyBytes = utf8.encode(keyString);

    // Ensure exactly 32 bytes (256 bits) for AES-256
    if (keyBytes.length == 32) {
      return encrypt.Key(Uint8List.fromList(keyBytes));
    } else if (keyBytes.length > 32) {
      return encrypt.Key(Uint8List.fromList(keyBytes.sublist(0, 32)));
    } else {
      // Pad with zeros if less than 32 bytes
      final padded = Uint8List(32);
      for (int i = 0; i < keyBytes.length && i < 32; i++) {
        padded[i] = keyBytes[i];
      }
      return encrypt.Key(padded);
    }
  }

  static final _key = _createKey();
  // Use a fixed zero IV to ensure decryption works with existing encrypted data
  // This matches the original behavior where IV.fromLength(16) was used statically
  // For better security in production, consider storing IV with each encrypted value
  static final _iv = encrypt.IV
      .fromBase64('AAAAAAAAAAAAAAAAAAAAAA=='); // 16 zero bytes as base64
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String encryptText(String plainText) {
    try {
      if (plainText.isEmpty) {
        return '';
      }
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  static String decryptText(String encryptedText) {
    try {
      if (encryptedText.isEmpty) {
        return '';
      }
      return _encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      // Try with zero IV as fallback for old data compatibility
      try {
        final zeroIV = encrypt.IV.fromLength(16);
        final fallbackEncrypter = encrypt.Encrypter(encrypt.AES(_key));
        return fallbackEncrypter.decrypt64(encryptedText, iv: zeroIV);
      } catch (_) {
        // If both fail, return empty string or throw based on use case
        // For now, return empty to prevent app crash
        debugPrint('Decryption failed for: $encryptedText');
        return '';
      }
    }
  }
}
