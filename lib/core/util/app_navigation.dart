import 'package:flutter/material.dart';



class AppNavigation {
  AppNavigation._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static NavigatorState get _navigator => navigatorKey.currentState!;

  /// Push using NESTED navigator (keeps bottom navbar visible) ✅
  static Future<T?> push<T>(Widget page, {BuildContext? context}) {
    if (context != null) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
    }
    return _navigator.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pop using NESTED navigator (keeps bottom navbar visible) ✅
  static void pop<T extends Object?>([T? result, BuildContext? context]) {
    if (context != null) {
      Navigator.of(context).pop(result);
      return;
    }
    _navigator.pop(result);
  }

  /// Replace using NESTED navigator ✅
  static Future<T?> pushReplacement<T, TO>(Widget page, {BuildContext? context}) {
    if (context != null) {
      return Navigator.of(context).pushReplacement<T, TO>(
        MaterialPageRoute(builder: (_) => page),
      );
    }
    return _navigator.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Clear stack — use ROOT navigator (for logout/onboarding) ✅
  static Future<T?> pushAndClear<T>(Widget page) {
    return _navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }
}

//
// class AppNavigation {
//   AppNavigation._();
//
//   static final GlobalKey<NavigatorState> navigatorKey =
//   GlobalKey<NavigatorState>();
//
//   static NavigatorState get _navigator => navigatorKey.currentState!;
//
//   /// Push a new screen
//   static Future<T?> push<T>(Widget page) {
//     return _navigator.push<T>(
//       MaterialPageRoute(builder: (_) => page),
//     );
//   }
//
//   /// Pop current screen
//   static void pop<T extends Object?>([T? result]) {
//     _navigator.pop(result);
//   }
//
//   /// Replace current screen
//   static Future<T?> pushReplacement<T, TO>(Widget page) {
//     return _navigator.pushReplacement<T, TO>(
//       MaterialPageRoute(builder: (_) => page),
//     );
//   }
//
//   /// Clear stack and push new screen
//   static Future<T?> pushAndClear<T>(Widget page) {
//     return _navigator.pushAndRemoveUntil<T>(
//       MaterialPageRoute(builder: (_) => page),
//           (route) => false,
//     );
//   }
// }
