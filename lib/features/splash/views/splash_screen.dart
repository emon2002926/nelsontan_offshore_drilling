import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body:  Center(
        child: Image.asset(
          AppAssertImage.instance.splashImage,
          width: context.responsiveSize(MediaQuery.sizeOf(context).width),
          height: context.responsiveSize(250),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
