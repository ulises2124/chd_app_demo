package com.example.chd_app_demo

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.urllauncher.WebViewActivity
import mx.openpay.android.Openpay
import com.example.chd_app_demo.config.EnviromentManager as ENV


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.cheadrui.com/paymethods"
    private val CHANNELDECYPHER = "com.cheadrui.com/decypher"
    private var paypalUrl: String? = null
    private var paymentMethod: String? = null
    private var amount: Double? = null
    private var email: String? = null

    private var pendingResult: Result? = null

    val PAYPALURL_KEY = "PAYPALURL_KEY"
    val PAYMENTMETHOD_KEY = "PAYMENTMETHOD_KEY"
    val AMOUNT_KEY = "AMOUNT_KEY"
    val EMAIL_KEY = "EMAIL_KEY"
    private val TAG = "WebViewActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val arguments = call.arguments;

            if (call.method.equals("getVista")) {
                pendingResult = result
                paypalUrl = call.argument("paypalUrl")
                paymentMethod = call.argument("paymentMethod")
                amount = call.argument("amount")
                email = call.argument("email")
                Log.e(TAG, "paypalUrl: $paypalUrl")
                Log.e(TAG, "paymentMethod: $paymentMethod")
                Log.e(TAG, "amount: $amount")
                Log.e(TAG, "email: $email")
                Log.e(TAG, "===========================> Antes  openWebPage()")
                openWebPage()
                Log.e(TAG, "===========================> Despues  openWebPage()")
            }
            if (call.method.equals("getID")) {
                //Openpay openpay = new Openpay("maguopugd9yegq2h8bhy", "sk_16ca01aaec244c1d8b0e6eebc1e9ca3c", true); PROD
                //val openpay = Openpay("ml7ihaxhfomook7tp9ei", "sk_3f361eae4f5c4b3f9d6f5f0cbec64c38", false) // STAGE
                val openpay = Openpay(ENV.getEnv().openPayGetMerchantId(), ENV.getEnv().openPayGetApiKey(), ENV.getEnv().openPayIsProductionMode())
                val deviceIdString = openpay.deviceCollectorDefaultImpl.setup(this@MainActivity)
                result.success(deviceIdString)
            }
        }


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNELDECYPHER).setMethodCallHandler { call, result ->

                if (call.method.equals("decypher")) {
                    var text: String? = call.argument("text")
                    Log.e(TAG, "Text to decript ---->$text")
                    text = RSA.decrypt(text.toString())
                    Log.e(TAG, "Decript java ---->$text")
                    result.success(text)
                } else if (call.method.equals("encrypter")) {
                    var text: String? = call.argument("text")
                    Log.e(TAG, "Text to encrypt ---->$text")
                    text = RSA.encrypt(text.toString())
                    Log.e(TAG, "Encrypt java ---->$text")
                    result.success(text)
                }
            }
        }

    fun openWebPage() {
        val i = Intent(this, WebViewActivity::class.java)
        i.putExtra(PAYPALURL_KEY, paypalUrl)
        i.putExtra(PAYMENTMETHOD_KEY, paymentMethod)
        i.putExtra(AMOUNT_KEY, amount.toString())
        i.putExtra(EMAIL_KEY, email.toString())
        startActivityForResult(i, 2)
    }

}


