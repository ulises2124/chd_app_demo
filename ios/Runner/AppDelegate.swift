import UIKit
import Flutter
import GoogleMaps
import CommonCrypto

//#import "GoogleMaps/GoogleMaps.h"
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let channel: FlutterMethodChannel? = nil
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let  CHANNELPayMethods = "com.cheadrui.com/paymethods"
    let ChannelDecrypterEncrypter = "com.cheadrui.com/decypher"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let PLATFORM_CHANNEL_DECRYPT = FlutterMethodChannel.init(name: ChannelDecrypterEncrypter, binaryMessenger: controller as! FlutterBinaryMessenger)
    let PLATFORM_CHANNEL_PAYMENTS = FlutterMethodChannel.init(name: ChannelDecrypterEncrypter, binaryMessenger: controller as! FlutterBinaryMessenger)
 
    PLATFORM_CHANNEL_DECRYPT.setMethodCallHandler({ [self]
           (call: FlutterMethodCall, result: FlutterResult) -> Void in
           
        
        if ("decypher" == call.method) {
                if let args = call.arguments as? Dictionary<String, Any> {
                    let text = args["text"] as? String
                   // result(decryptFunction(result: result, data: text ?? ""))
                  } else {
                    result(FlutterError.init(code: "bad args", message: nil, details: nil))
                  }

            }
            
            else  if ("encrypter" == call.method) {
                if let args = call.arguments as? Dictionary<String, Any> {
                    let text = args["text"] as? String
                    result(encryptFunction(result: result, data: text ?? ""))
                  } else {
                    result(FlutterError.init(code: "bad args", message: nil, details: nil))
                  }

            }
           
           else {
               result(FlutterMethodNotImplemented)
           }
       })
     
    
    
    
   // GMSServices provideAPIKey "";
  // [GMSServices provideAPIKey:@"AIzaSyAe2bHPLoGQqkqizRjtvsyFF2bfEuLd6Xg"];
    GMSServices.provideAPIKey("AIzaSyAe2bHPLoGQqkqizRjtvsyFF2bfEuLd6Xg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func decryptFunction(result: FlutterResult, data: String) {
       
        if (true) {
            
            result(ManagerEncrypt.init().decryptRsaBase64Encrypted(data: data))
                
            
              
        }else {
            result(FlutterError.init(
                  code: "ERROR",
                  message: "Error message description!",
                  details: nil
              )) // INFO: error response should return through this method
          }
        
    }
    
    func encryptFunction(result: FlutterResult, data: String) {
        
        if (true) {
           
            if #available(iOS 10.0, *) {
                result(ManagerEncrypt.init().encryptRsaBase64(data: data))
            } else {
                // Fallback on earlier versions
            }
        } else {
          result(FlutterError.init(
                code: "ERROR",
                message: "Error message description!",
                details: nil
            )) // INFO: error response should return through this method
        }
    }
    
   
    
   
}



