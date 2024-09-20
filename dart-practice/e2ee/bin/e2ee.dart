import 'dart:convert';
import 'dart:typed_data';
import 'package:e2ee/aes.dart';
import 'package:e2ee/rsa.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:pointycastle/export.dart';

void main(List<String> arguments) {
  // Alice 生成公鑰私鑰對
  final secureRandom = SecureRandom('Fortuna')
    ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  final pair = generateRSAkeyPair(secureRandom);

  RSAPublicKey public = pair.publicKey;
  RSAPrivateKey private = pair.privateKey;

  // Alice 將公鑰傳給 Bob
  String publicBase64 = encodePublicKeyToBase64(public);

  // ... 伺服器 ...

  // Bob 收到 Alice 的公鑰
  RSAPublicKey publicKeyFromAlice = decodePublicKeyFromBase64(publicBase64);

  // Bob 產生 AES KEY 即初始向量
  Uint8List aesKey = generateAESKey(256);
  Uint8List aesIV = generateIV();

  // Bob 將 aesKey 以及 aesIV 編碼成 base64 並以 publicKey 接密 轉送給 Alice
  Uint8List encryptedAESKey = rsaEncrypt(publicKeyFromAlice, aesKey);
  Uint8List encryptedAESIV = rsaEncrypt(publicKeyFromAlice, aesIV);

  // ... 伺服器 ...

  // Alice 利用自己的 private key 將 encryptedAESKey 及 encryptedAESIV 解碼
  Uint8List decryptedAESKey = rsaDecrypt(private, encryptedAESKey);
  Uint8List decryptedAESIV = rsaDecrypt(private, encryptedAESIV);

  // 開始互相傳送訊息
  // 假設 Bob 向 Alice 傳送訊息

  String someText = "呵呵你好（摸頭（燦笑 ❤️";
  Uint8List encryptedSomeText =
      aesCbcEncrypt(aesKey, aesIV, utf8.encode(someText));

  // 以 base64 傳給伺服器
  String encryptedSomeTextBase64 = base64Encode(encryptedSomeText);

  print("伺服器上加密訊息：$encryptedSomeTextBase64");

  // Alice 解密
  Uint8List decryptedSomeText = aesCbcDecrypt(
      decryptedAESKey, decryptedAESIV, base64Decode(encryptedSomeTextBase64));

  print("Alice解密後的訊息：${utf8.decode(decryptedSomeText)}");
}
