import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/bindings/app_bindings.dart';
import 'core/services/api_services.dart';
import 'core/util/app_navigation.dart';
import 'features/splash/controller/splash_controller.dart';
import 'features/splash/views/splash_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  AppBindings.init();
  Get.put(ApiServices(baseUrl: 'http://10.10.7.108:8000/api/v1'));
  // Get.put(ApiServices(baseUrl: 'https://safe.dsrt321.online/api/v1'));
  Get.put(SplashController());


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar icons to white throughout the app
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // White icons on Android
      statusBarBrightness: Brightness.dark, // White icons on iOS
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
         GetMaterialApp(
          debugShowCheckedModeBanner: false,
           navigatorKey: AppNavigation.navigatorKey,
           theme: ThemeData(
            // Ensure status bar styling is applied to all AppBars
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      }

}