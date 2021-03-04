//
//  RSA.swift
//  Runner
//
//  Created by Ulises Atonatiuh González Hernández on 07/02/21.
//

import Foundation
import Security
struct RSA {

    @available(iOS 10.0, *)
    static func encrypt(string: String, publicKey: String?) -> String? {
    guard let publicKey = publicKey else { return nil }

    let keyString = publicKey.replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END RSA PUBLIC KEY-----", with: "")
    guard let data = Data(base64Encoded: keyString) else { return nil }

    var attributes: CFDictionary {
        return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits   : 2048,
                kSecReturnPersistentRef : true] as CFDictionary
    }

    var error: Unmanaged<CFError>? = nil
    guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
        print(error.debugDescription)
        return nil
    }
    return encrypt(string: string, publicKey: secKey)
}

static func encrypt(string: String, publicKey: SecKey) -> String? {
    let buffer = [UInt8](string.utf8)

    var keySize   = SecKeyGetBlockSize(publicKey)
    var keyBuffer = [UInt8](repeating: 0, count: keySize)

    // Encrypto  should less than key length
    guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }
    return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
   }
}
