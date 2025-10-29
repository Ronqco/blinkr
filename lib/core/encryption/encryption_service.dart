// 📁 lib/core/encryption/encryption_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/asn1.dart';
import '../storage/secure_storage_service.dart';

class EncryptionService {
  final SecureStorageService _secureStorage;
  
  EncryptionService(this._secureStorage);

  // Genera clave AES-256 aleatoria
  String generateAESKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Genera IV de 16 bytes
  String generateIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Encripta mensaje con AES-GCM
  Map<String, String> encryptWithAES(String plaintext, String aesKeyBase64) {
    try {
      final key = Key.fromBase64(aesKeyBase64);
      final iv = IV.fromSecureRandom(16);
      
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(plaintext, iv: iv);
      
      return {
        'ciphertext': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      throw Exception('AES encryption failed: $e');
    }
  }

  // Desencripta mensaje con AES-GCM
  String decryptWithAES(
    String ciphertextBase64,
    String aesKeyBase64,
    String ivBase64,
  ) {
    try {
      final key = Key.fromBase64(aesKeyBase64);
      final iv = IV.fromBase64(ivBase64);
      
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = Encrypted.fromBase64(ciphertextBase64);
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('AES decryption failed: $e');
    }
  }

  // RSA solo para claves (máx 245 bytes)
  String encryptWithRSA(String data, String publicKeyPem) {
    try {
      if (data.length > 245) {
        throw Exception('RSA can only encrypt up to 245 bytes');
      }
      
      final publicKey = _parsePublicKeyFromPem(publicKeyPem);
      
      final cipher = OAEPEncoding(RSAEngine())
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      
      final dataBytes = Uint8List.fromList(utf8.encode(data));
      final encrypted = cipher.process(dataBytes);
      
      return base64Encode(encrypted);
    } catch (e) {
      throw Exception('RSA encryption failed: $e');
    }
  }

  // RSA desencriptación
  Future<String> decryptWithRSA(String encryptedBase64, String privateKeyPem) async {
    try {
      final privateKey = _parsePrivateKeyFromPem(privateKeyPem);
      
      final cipher = OAEPEncoding(RSAEngine())
        ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
      
      final encryptedBytes = base64Decode(encryptedBase64);
      final decrypted = cipher.process(Uint8List.fromList(encryptedBytes));
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('RSA decryption failed: $e');
    }
  }

  // Desencriptar mensaje (wrapper público)
  Future<String> decryptMessage(String encryptedMessage) async {
    final privateKeyPem = await _secureStorage.read('rsa_private_key');
    if (privateKeyPem == null) {
      throw Exception('Private key not found');
    }
    return decryptWithRSA(encryptedMessage, privateKeyPem);
  }

  // Generación de par de claves RSA
  Future<Map<String, String>> generateKeyPair() async {
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

    final publicKeyPem = _encodePublicKeyToPem(publicKey);
    final privateKeyPem = _encodePrivateKeyToPem(privateKey);

    await _secureStorage.write('rsa_private_key', privateKeyPem);
    await _secureStorage.write('rsa_public_key', publicKeyPem);

    return {
      'publicKey': publicKeyPem,
      'privateKey': privateKeyPem,
    };
  }

  // Parse public key from PEM
  RSAPublicKey _parsePublicKeyFromPem(String pem) {
    final lines = pem.split('\n').where((line) => 
      !line.contains('BEGIN') && !line.contains('END')).join('');
    final bytes = base64Decode(lines);
    
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
    
    final publicKeyAsn1 = ASN1Parser(publicKeyBitString.valueBytes!);
    final publicKeySeq = publicKeyAsn1.nextObject() as ASN1Sequence;
    
    final modulus = (publicKeySeq.elements![0] as ASN1Integer).integer!;
    final exponent = (publicKeySeq.elements![1] as ASN1Integer).integer!;
    
    return RSAPublicKey(modulus, exponent);
  }

  // Parse private key from PEM
  RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    final lines = pem.split('\n').where((line) => 
      !line.contains('BEGIN') && !line.contains('END')).join('');
    final bytes = base64Decode(lines);
    
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;
    
    final privateKeyAsn1 = ASN1Parser(privateKeyOctet.valueBytes!);
    final privateKeySeq = privateKeyAsn1.nextObject() as ASN1Sequence;
    
    final modulus = (privateKeySeq.elements![1] as ASN1Integer).integer!;
    final privateExponent = (privateKeySeq.elements![3] as ASN1Integer).integer!;
    final p = (privateKeySeq.elements![4] as ASN1Integer).integer!;
    final q = (privateKeySeq.elements![5] as ASN1Integer).integer!;
    
    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  // ✅ CORREGIDO: Encode public key to PEM
  String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    final algorithmSeq = ASN1Sequence();
    final algorithmOid = ASN1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 1]);
    algorithmSeq.add(algorithmOid);
    algorithmSeq.add(ASN1Null());

    final publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus!));
    publicKeySeq.add(ASN1Integer(publicKey.exponent!));
    final publicKeySeqBytes = publicKeySeq.encode();
    
    // ✅ ASN1BitString con argumento nombrado 'stringValues'
    final publicKeyBitString = ASN1BitString(stringValues: publicKeySeqBytes);

    final topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeyBitString);

    final dataBase64 = base64Encode(topLevelSeq.encode());
    return '-----BEGIN PUBLIC KEY-----\n$dataBase64\n-----END PUBLIC KEY-----';
  }

  // ✅ CORREGIDO: Encode private key to PEM
  String _encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final version = ASN1Integer(BigInt.from(0));

    final algorithmSeq = ASN1Sequence();
    final algorithmOid = ASN1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 1]);
    algorithmSeq.add(algorithmOid);
    algorithmSeq.add(ASN1Null());

    final privateKeySeq = ASN1Sequence();
    privateKeySeq.add(ASN1Integer(BigInt.from(0))); // version
    privateKeySeq.add(ASN1Integer(privateKey.modulus!));
    privateKeySeq.add(ASN1Integer(privateKey.exponent!));
    privateKeySeq.add(ASN1Integer(privateKey.privateExponent!));
    privateKeySeq.add(ASN1Integer(privateKey.p!));
    privateKeySeq.add(ASN1Integer(privateKey.q!));
    
    // dP, dQ, qInv
    final dP = privateKey.privateExponent! % (privateKey.p! - BigInt.one);
    final dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.one);
    final qInv = privateKey.q!.modInverse(privateKey.p!);
    
    privateKeySeq.add(ASN1Integer(dP));
    privateKeySeq.add(ASN1Integer(dQ));
    privateKeySeq.add(ASN1Integer(qInv));

    final privateKeySeqBytes = privateKeySeq.encode();
    
    // ✅ ASN1OctetString con argumento nombrado 'octets'
    final publicKeyOctetString = ASN1OctetString(octets: privateKeySeqBytes);

    final topLevelSeq = ASN1Sequence();
    topLevelSeq.add(version);
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeyOctetString);

    final dataBase64 = base64Encode(topLevelSeq.encode());
    return '-----BEGIN PRIVATE KEY-----\n$dataBase64\n-----END PRIVATE KEY-----';
  }
}