import UIKit
import Flutter
import GoogleMaps
//#import "GoogleMaps/GoogleMaps.h"
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

   // GMSServices provideAPIKey "";
  // [GMSServices provideAPIKey:@"AIzaSyAe2bHPLoGQqkqizRjtvsyFF2bfEuLd6Xg"];
    GMSServices.provideAPIKey("AIzaSyAe2bHPLoGQqkqizRjtvsyFF2bfEuLd6Xg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
