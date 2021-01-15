package com.example.chd_app_demo

import java.security.KeyFactory
import java.security.NoSuchAlgorithmException
import java.security.PrivateKey
import java.security.PublicKey
import java.security.spec.InvalidKeySpecException
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import javax.crypto.Cipher
import android.util.Base64;

object RSA {
    private const val publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUM0DjyqV4IMbp7gnOLetlWNzOErf/T46UBh/GsRT8Mw3s5T6n6gk6p2pwy2QMe48uacdTEDlTXNRC66/Nk7fU0ocdYg/sD2NJwpiW/O5KZnRXV5jGmvz2EEoOOkzFVAKYJm5BZhwMk4tkqL3Jh6NpPP2w3Lb7qBhrXc17894yFwIDAQAB"
    private const val privateKey = "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAJQzQOPKpXggxunuCc4t62VY3M4St/9PjpQGH8axFPwzDezlPqfqCTqnanDLZAx7jy5px1MQOVNc1ELrr82Tt9TShx1iD+wPY0nCmJb87kpmdFdXmMaa/PYQSg46TMVUApgmbkFmHAyTi2SovcmHo2k8/bDctvuoGGtdzXvz3jIXAgMBAAECgYAfeRsIxVqKvns/5tuSO9JH/a023mbRA7ZF3V8WNTk9riIA81ZxFpTLLg6+0ZL3y63Gr5QzIbjq6UXyyFbXk81wQ4TiyLxEv+hwoP74yEEAzP+JqlOePtB886hXAnHTU2FsIwxi4Y0L2Oydc6jXFcnNoIgaDc+DN5vsylflG1fF4QJBAOENLIMSywQNYGryi2mcxc/yEWwBuml3s6iJKzpNwfPDzelq6p3Uk6pR816f9YJADbVdAaZZQtdvqhfWo2aIUU8CQQColJGsbJpT0hgb4JPGWIZaij5hpwCr0s96+CDccdRNp3UkPu9gIwcOXuJ6TU5vr5c6kGnxus+HW9ODwO0qsZC5AkEAr2nfSgL57pymjHWkqJsjrCOX5MGsFMzSYgkYgoddJ6107/0ABilNN7JMqXKwn+dhR/3IbWqhqN5Gi/ImxqJ2DQJBAJZXwT7DsDKWyLd75m5anp96cL3IIVobbLwfM7dFsO/8KwVDN1pGgtF3H4WxEgWa1ET/a+yQDOqLoyv6T8jmiMkCQQDgZoWB537rb5qgu+zhNCT6bUCiEYn/xnRqhyKmccRZ/WlnuvN8Ge/TdCXH/M0EEoShSpiYlQPCfn0mszXYpoRz"

    fun getPublicKey(base64PublicKey: String): PublicKey? {
        var publicKey: PublicKey? = null
        try {
            val publicKeyBytes = base64PublicKey.toByteArray()
            val keySpec = X509EncodedKeySpec(Base64.decode(publicKeyBytes, Base64.DEFAULT))
            val keyFactory = KeyFactory.getInstance("RSA")
            publicKey = keyFactory.generatePublic(keySpec)
            return publicKey
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: InvalidKeySpecException) {
            e.printStackTrace()
        }
        return publicKey
    }

    fun getPrivateKey(base64PrivateKey: String): PrivateKey? {
        var privateKey: PrivateKey? = null
        val privateKeyBytes = base64PrivateKey.toByteArray()
        val keySpec = PKCS8EncodedKeySpec(Base64.decode(privateKeyBytes, Base64.DEFAULT))
        var keyFactory: KeyFactory? = null
        try {
            keyFactory = KeyFactory.getInstance("RSA")
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        try {
            privateKey = keyFactory!!.generatePrivate(keySpec)
        } catch (e: InvalidKeySpecException) {
            e.printStackTrace()
        }
        return privateKey
    }

    fun encrypt(data: String): String? {
        var resultado = ""
        var result: ByteArray? = null
        try {
            val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
            cipher.init(Cipher.ENCRYPT_MODE, getPublicKey(publicKey))
            result = cipher.doFinal(data.toByteArray())
            resultado = Base64.encodeToString(result, Base64.DEFAULT)
            resultado = resultado.replace("\\s+".toRegex(), "")
        } catch (e: Exception) {
            e.printStackTrace()
            resultado = ""
        }
        return resultado
    }

    fun decrypt(data: ByteArray?, privateKey: PrivateKey?): String? {
        var resultado = ""
        resultado = try {
            val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
            cipher.init(Cipher.DECRYPT_MODE, privateKey)
            String(cipher.doFinal(data))
        } catch (e: Exception) {
            e.printStackTrace()
            ""
        }
        return resultado
    }

    fun decrypt(data: String): String? {
        return decrypt(Base64.decode(data.toByteArray(), Base64.DEFAULT), getPrivateKey(privateKey))
    }
}