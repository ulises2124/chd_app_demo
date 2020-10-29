// import 'dart:async';
// import 'dart:convert';
// // import 'package:simple_rsa/simple_rsa.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:encrypt/encrypt.dart';
// import 'package:pointycastle/asymmetric/api.dart';
// import 'dart:io';
//
// class RSA_Crypt {
//
//   static Future<Encrypter> loadEncrypter() async{
//     var publicKeyFile = await rootBundle.loadString('assets/raw/publickey.pem');
//     var privateKeyFile = await rootBundle.loadString('assets/raw/private.pem');
//     var publicString = publicKeyFile;
//     var privateString = privateKeyFile;
//     print(publicString);
//     print(privateString);
//     final parser = RSAKeyParser();
//     final RSAPublicKey publicKey = parser.parse(publicString);
//     final RSAPrivateKey privateKey = parser.parse(privateString);
//     print(publicKey.toString());
//     print(privateKey.toString());
//     final encrypter = Encrypter(RSA( publicKey: publicKey, privateKey: privateKey));
//     return encrypter;
//
//   }
//
//   static Future<String> encrypt (String plainText) async{
//     final encrypter = await loadEncrypter();
//     final encrypted = encrypter.encrypt(plainText);
//     return encrypted.toString();
//   }
//
//   static Future<String> decrypt (String plainEncryptedText) async{
//     print("plainEncryptedText----------->"+plainEncryptedText);
//     final listCharCodes = utf8.encode(plainEncryptedText);
//     final Encrypted encryptedText = new Encrypted(listCharCodes);
//     final encrypter = await loadEncrypter();
//     final decrypted = encrypter.decrypt(encryptedText);
//     return decrypted.toString();
//   }
//
///***
//   String pubKey;
//   String priKey;
//
//   Future loadKeys() async{
//     pubKey = await rootBundle.loadString('assets/raw/publickey.pem');
//     priKey = await rootBundle.loadString('assets/raw/private.pem');
//   }
//
//   static Future encrypt (String plainText) async{
//     try{
//       var keyString = await rootBundle.loadString('assets/raw/publickey.pem');
//       keyString = keyString.replaceAll('\n', '').replaceAll('\r', '');
//       var encryptedText = await encryptString(plainText, keyString);
//       return encryptedText;
//     }catch(e){
//       return "";
//     }
//   }
//
//   static Future decrypt (String encryptedText) async{
//     try{
//       var keyString = await rootBundle.loadString('assets/raw/private.pem');
//       keyString = keyString.replaceAll('\n', '').replaceAll('\r', '');
//       var decryptedText = await decryptString(encryptedText, keyString);
//       return decryptedText;
//     } catch(e){
//       return "";
//     }
//   }*******/
//
// }
