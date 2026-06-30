import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/bindings/app_bindings.dart';
import 'core/services/api_services.dart';
import 'core/util/app_navigation.dart';
import 'features/safety_card/services/connectivity_service.dart';
import 'features/safety_card/services/hive_boxes.dart';
import 'features/safety_card/services/sync_service.dart';
import 'features/splash/controller/splash_controller.dart';
import 'features/splash/views/splash_screen.dart';
import 'features/videos/controllers/video_manager.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await HiveBoxes.init();

  AppBindings.init();
  Get.put(ApiServices(baseUrl: 'http://10.10.26.235:13500/api/v1'));
  Get.put(ApiServices(baseUrl: 'https://safe.dsrt321.online/api/v1'));
  Get.put(SplashController());
  Get.put(VideoManager());



  // open boxes
  final connectivity = ConnectivityService();
  await connectivity.init();
  Get.put(connectivity, permanent: true);

  Get.put(SyncService(), permanent: true);


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
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