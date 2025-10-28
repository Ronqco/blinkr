import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';
import '../storage/secure_storage_service.dart';

class EncryptionService {
  final SecureStorageService _secureStorage;
  static const String _privateKeyKey = 'private_key';
  static const String _publicKeyKey = 'public_key';

  EncryptionService(this._secureStorage);

  // Generate RSA key pair for E2E encryption
  Future<Map<String, String>> generateKeyPair() async {
    // Usar pointycastle directamente para generar keys
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final rsaParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
    final params = ParametersWithRandom(rsaParams, secureRandom);
    final keyGen = RSAKeyGenerator()..init(params);
    final pair = keyGen.generateKeyPair();

    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    final publicKeyString = _encodePublicKey(publicKey);
    final privateKeyString = _encodePrivateKey(privateKey);

    // Store private key securely
    await _secureStorage.write(_privateKeyKey, privateKeyString);
    await _secureStorage.write(_publicKeyKey, publicKeyString);

    return {
      'publicKey': publicKeyString,
      'privateKey': privateKeyString,
    };
  }

  // Encrypt message with recipient's public key
  String encryptMessage(String message, String recipientPublicKey) {
    final publicKey = _decodePublicKey(recipientPublicKey);
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(message);
    return encrypted.base64;
  }

  // Decrypt message with own private key
  Future<String> decryptMessage(String encryptedMessage) async {
    final privateKeyString = await _secureStorage.read(_privateKeyKey);
    if (privateKeyString == null) {
      throw Exception('Private key not found');
    }

    final privateKey = _decodePrivateKey(privateKeyString);
    final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    final decrypted = encrypter.decrypt64(encryptedMessage);
    return decrypted;
  }

 // Generate a random IV for AES encryption
  String generateIV() {
  final iv = encrypt.IV.fromLength(16);
  return iv.base64;
}

  // Symmetric encryption for shared keys
  String encryptWithSharedKey(String message, String sharedKey) {
    final key = encrypt.Key.fromBase64(sharedKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(message, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptWithSharedKey(String encryptedMessage, String sharedKey) {
    final parts = encryptedMessage.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    final key = encrypt.Key.fromBase64(sharedKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  // Helper methods for key encoding/decoding
  String _encodePublicKey(RSAPublicKey publicKey) {
    final modulus = publicKey.modulus!.toRadixString(16);
    final exponent = publicKey.exponent!.toRadixString(16);
    return base64Encode(utf8.encode('$modulus:$exponent'));
  }

  String _encodePrivateKey(RSAPrivateKey privateKey) {
    final modulus = privateKey.modulus!.toRadixString(16);
    final exponent = privateKey.exponent!.toRadixString(16);
    final d = privateKey.privateExponent!.toRadixString(16);
    final p = privateKey.p!.toRadixString(16);
    final q = privateKey.q!.toRadixString(16);
    return base64Encode(utf8.encode('$modulus:$exponent:$d:$p:$q'));
  }

  RSAPublicKey _decodePublicKey(String encoded) {
    final decoded = utf8.decode(base64Decode(encoded));
    final parts = decoded.split(':');
    return RSAPublicKey(
      BigInt.parse(parts[0], radix: 16),
      BigInt.parse(parts[1], radix: 16),
    );
  }

  RSAPrivateKey _decodePrivateKey(String encoded) {
    final decoded = utf8.decode(base64Decode(encoded));
    final parts = decoded.split(':');
    return RSAPrivateKey(
      BigInt.parse(parts[0], radix: 16),  // modulus
      BigInt.parse(parts[2], radix: 16),  // privateExponent (d)
      BigInt.parse(parts[3], radix: 16),  // p
      BigInt.parse(parts[4], radix: 16),  // q
    );
  }
}