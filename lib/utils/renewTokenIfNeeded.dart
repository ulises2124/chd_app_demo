import 'package:chd_app_demo/services/AuthServices.dart';
//import 'package:chd_app_demo/views/LoginPage/socialWebview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenewToken {
  static Future<String> renewTokenIfNeed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('renewTokenIfNeed');
    var accessToken = prefs.getString('accessToken');
    var redSocial = prefs.getString('redSocial');
    var socialUser = prefs.getBool('socialUser') ?? false;
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    var loginTime = prefs.getDouble('loginTime');
    var expiresIn = prefs.getInt('expiresIn');
    var currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    bool needRefresh;
    var newToken;
    /*
    print("accessToken: $accessToken");
    print(accessToken == null);
    print(accessToken == 'null');
    print("isLoggedIn: $isLoggedIn");
    print("loginTime: $loginTime");
    print("expiresIn: $expiresIn");
    print("currentTime: $currentTime");
    */
    if (accessToken == null || accessToken == 'null') {
      newToken = await AuthServices.getUserToken();
      return newToken;
    } else if (loginTime != null && expiresIn != null) {
      var threshold = loginTime + expiresIn;
      needRefresh = currentTime >= threshold;
      print('########################');
      print("needRefresh: $needRefresh");
      print('########################');
      if (needRefresh) {
        if (socialUser) {
          // await AuthServices.postSocialUserToken(redSocial);
          // var socialToken = prefs.getString('socialToken');
          // var tokenHybris = await AuthServices.postSocialUserLogin(socialToken, redSocial);
          return null;
        } else {
          newToken = await AuthServices.getUserToken();
        }
        if (newToken != null) {
          return newToken;
        }
      } else {
        return accessToken;
      }
    } else {
      newToken = await AuthServices.getUserToken();
      return newToken;
    }
  }
}
