import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/export.dart";

const blockSize = 16; // 16bytes = 128bits

Uint8List _generateKey(int length) {
  final random = Random.secure();
  return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)));
}

// 生成隨機 AES 密鑰
Uint8List generateAESKey(int keySizeInBits) {
  return _generateKey(keySizeInBits ~/ 8);
}

// 生成隨機 IV
Uint8List generateIV() {
  return _generateKey(blockSize);
}

Uint8List aesCbcEncrypt(Uint8List key, Uint8List iv, Uint8List plainText) {
  assert([128, 192, 256].contains(key.length * 8));
  assert(128 == iv.length * 8);

  // Create a CBC block cipher with AES, and initialize with key and IV

  final cbc = CBCBlockCipher(AESEngine())
    ..init(true, ParametersWithIV(KeyParameter(key), iv)); // true=encrypt

  plainText = _pad(plainText);

  // Encrypt the plaintext block-by-block
  final cipherText = Uint8List(plainText.length); // allocate space

  var offset = 0;
  while (offset < plainText.length) {
    offset += cbc.processBlock(plainText, offset, cipherText, offset);
  }
  assert(offset == plainText.length);

  return cipherText;
}

Uint8List aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List cipherText) {
  assert([128, 192, 256].contains(key.length * 8));
  assert(128 == iv.length * 8);

  // Create a CBC block cipher with AES, and initialize with key and IV
  final cbc = CBCBlockCipher(AESEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv)); // false=decrypt

  // Decrypt the cipherText block-by-block
  final paddedPlainText = Uint8List(cipherText.length); // allocate space

  var offset = 0;
  while (offset < cipherText.length) {
    offset += cbc.processBlock(cipherText, offset, paddedPlainText, offset);
  }
  assert(offset == cipherText.length);

  return _unpad(paddedPlainText);
}

// 填充字串
Uint8List _pad(Uint8List data) {
  final padLength = blockSize - (data.length % blockSize);
  return Uint8List.fromList(data + List<int>.filled(padLength, padLength));
}

Uint8List _unpad(Uint8List paddedData) {
  final padLength = paddedData.last;
  return Uint8List.sublistView(paddedData, 0, paddedData.length - padLength);
}
