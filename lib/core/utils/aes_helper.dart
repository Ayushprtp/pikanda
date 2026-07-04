import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as c;
import 'package:encrypt/encrypt.dart';

/// AES-256-CBC helper. The group key is derived from group id + per-group salt
/// (fetched from the groups table), so every group has its own key and a
/// payload can only be decrypted by that group's members.
class AesHelper {
  final Key _key;

  AesHelper.forGroup(String groupId, String salt)
      : _key = Key(Uint8List.fromList(
            c.sha256.convert(utf8.encode('$groupId:$salt:pikanda')).bytes));

  /// Encrypts [plain]; output is hex(iv).hex(cipher).
  String encryptText(String plain) {
    final iv = IV.fromSecureRandom(16);
    final enc = Encrypter(AES(_key, mode: AESMode.cbc));
    final out = enc.encrypt(plain, iv: iv);
    return '${iv.base16}.${out.base16}';
  }

  /// Decrypts a payload produced by [encryptText]. Returns null on failure.
  String? decryptText(String payload) {
    try {
      final parts = payload.split('.');
      if (parts.length != 2) return null;
      final iv = IV.fromBase16(parts[0]);
      final enc = Encrypter(AES(_key, mode: AESMode.cbc));
      return enc.decrypt(Encrypted.fromBase16(parts[1]), iv: iv);
    } catch (_) {
      return null;
    }
  }

  /// SHA-256 hash for safe codes (the plain code is never stored).
  static String hashSafeCode(String code) =>
      c.sha256.convert(utf8.encode(code.trim().toLowerCase())).toString();
}
