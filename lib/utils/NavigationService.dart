import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    final newRouteName = DataUI.loginRoute;
    bool isNewRouteSameAsCurrent = false;

    navigatorKey.currentState.popUntil((route) {
      if (route.settings.name == newRouteName) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      return navigatorKey.currentState.pushNamed(routeName);
    }
  }

   goBack() {
    return navigatorKey.currentState.pop();
  }
}
