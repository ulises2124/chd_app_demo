//
//  ManagerEncrypt.swift
//  Runner
//
//  Created by Ulises Atonatiuh González Hernández on 07/02/21.
//

import Foundation
import Security
import SwiftyRSA
class ManagerEncrypt: NSObject {
    
    
    
    //    func encryptRsaBase64(_ string: String) -> String? {
    //        if let data = string.data(using: .utf8) {
    //            if let encrypted = RSAUtils.encryptWithRSAPublicKey(data, pubkeyBase64: "publicKey", keychainTag: "") {
    //                return encrypted.base64EncodedString()
    //            }
    //        }
    //        return nil
    //    }
    //
    //    /**
    //     Returns RSA decrypted Base64 encoded string with specified public key which is Base64 encoded string.
    //
    //     - parameter withPublickKeyBase64: Base64 encoded string value of public key.
    //     - returns: RSA decrypted Base64 encoded string.
    //     */
    //    func decryptRsaBase64Encrypted(_ string: String) -> String? {
    //        if let encrypted = Data(base64Encoded: string, options: Data.Base64DecodingOptions.init(rawValue: 0)) {
    //            if let data = RSAUtils.decryptWithRSAPublicKey(encrypted, pubkeyBase64: "privateKey", keychainTag: "") {
    //                return String(data: data, encoding: .utf8)
    //            }
    //        }
    //        return nil
    //    }
    //
    func decryptRsaBase64Encrypted(data: String) -> String? {
        let privateKey = "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAJQzQOPKpXggxunuCc4t62VY3M4St/9PjpQGH8axFPwzDezlPqfqCTqnanDLZAx7jy5px1MQOVNc1ELrr82Tt9TShx1iD+wPY0nCmJb87kpmdFdXmMaa/PYQSg46TMVUApgmbkFmHAyTi2SovcmHo2k8/bDctvuoGGtdzXvz3jIXAgMBAAECgYAfeRsIxVqKvns/5tuSO9JH/a023mbRA7ZF3V8WNTk9riIA81ZxFpTLLg6+0ZL3y63Gr5QzIbjq6UXyyFbXk81wQ4TiyLxEv+hwoP74yEEAzP+JqlOePtB886hXAnHTU2FsIwxi4Y0L2Oydc6jXFcnNoIgaDc+DN5vsylflG1fF4QJBAOENLIMSywQNYGryi2mcxc/yEWwBuml3s6iJKzpNwfPDzelq6p3Uk6pR816f9YJADbVdAaZZQtdvqhfWo2aIUU8CQQColJGsbJpT0hgb4JPGWIZaij5hpwCr0s96+CDccdRNp3UkPu9gIwcOXuJ6TU5vr5c6kGnxus+HW9ODwO0qsZC5AkEAr2nfSgL57pymjHWkqJsjrCOX5MGsFMzSYgkYgoddJ6107/0ABilNN7JMqXKwn+dhR/3IbWqhqN5Gi/ImxqJ2DQJBAJZXwT7DsDKWyLd75m5anp96cL3IIVobbLwfM7dFsO/8KwVDN1pGgtF3H4WxEgWa1ET/a+yQDOqLoyv6T8jmiMkCQQDgZoWB537rb5qgu+zhNCT6bUCiEYn/xnRqhyKmccRZ/WlnuvN8Ge/TdCXH/M0EEoShSpiYlQPCfn0mszXYpoRz"
        
        do {
            let privateKey = try PrivateKey(pemNamed: privateKey)
            do {
                
                
                let encrypted = try EncryptedMessage(base64Encoded: data)
                let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
                
                // Then you can use:
                let data = clear.data
                let base64String = clear.base64String
                let string = try? clear.string(encoding: .utf8)
                print("result", string)
                return string
                
            } catch let error {
                print(error)
            }
           
        } catch _ {
            return ""
        }
        return ""
    }
    @available(iOS 10.0, *)
    func encryptRsaBase64(data: String) -> String? {
        let publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUM0DjyqV4IMbp7gnOLetlWNzOErf/T46UBh/GsRT8Mw3s5T6n6gk6p2pwy2QMe48uacdTEDlTXNRC66/Nk7fU0ocdYg/sD2NJwpiW/O5KZnRXV5jGmvz2EEoOOkzFVAKYJm5BZhwMk4tkqL3Jh6NpPP2w3Lb7qBhrXc17894yFwIDAQAB"
        return RSA.encrypt(string: data, publicKey: publicKey)
    }
    
}
