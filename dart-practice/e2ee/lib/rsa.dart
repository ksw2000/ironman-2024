import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/export.dart';

String encodePublicKeyToBase64(RSAPublicKey publicKey) {
  final seq = ASN1Sequence(elements: [
    ASN1Integer(publicKey.modulus),
    ASN1Integer(publicKey.exponent)
  ]);

  return base64Encode(seq.encode());
}

RSAPublicKey decodePublicKeyFromBase64(String publicKeyBase64) {
  // 解 base64 編碼
  Uint8List publicKeyDER = base64Decode(publicKeyBase64);

  // 解析
  ASN1Parser asn1Parser = ASN1Parser(publicKeyDER);
  ASN1Sequence publicKeySeq = asn1Parser.nextObject() as ASN1Sequence;

  BigInt modulus = (publicKeySeq.elements![0] as ASN1Integer).integer!;
  BigInt exponent = (publicKeySeq.elements![1] as ASN1Integer).integer!;

  return RSAPublicKey(modulus, exponent);
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    SecureRandom secureRandom,
    {int bitLength = 2048}) {
  // Create an RSA key generator and initialize it

  // final keyGen = KeyGenerator('RSA'); // Get using registry
  final keyGen = RSAKeyGenerator();

  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom));

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

// RSA 加密，第一個參數是公鑰，第二個參數是明文
Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}

// RSA 解密，第一個參數是密鑰，第二個參數是密文
Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(
        false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}
