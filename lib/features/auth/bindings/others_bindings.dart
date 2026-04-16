import 'package:get/get.dart';
import '../controllers/forget_password_controller.dart';
import '../controllers/reset_password_controller.dart';
import '../controllers/signin_controller.dart';
import '../controllers/signup_controller.dart';
class AuthBindings {
  static void signInDependencies(){
    Get.lazyPut<SignInController>(
          ()=> SignInController(),
      fenix: true,
    );
  }

  static void signUpDependencies(){
    Get.lazyPut<SignUpController>(
          ()=> SignUpController(),
      fenix: true,
    );
  }
  // static void otpDependencies(){
  //   Get.lazyPut<EnterOtpController>(
  //         ()=> EnterOtpController(),
  //     fenix: true,
  //   );
  // }
  static void forgotPassDependencies(){
    Get.lazyPut<ForgetPasswordController>(
          ()=> ForgetPasswordController(),
      fenix: true,
    );
  }


  // static void accountCreatedSuccess(){
  //   Get.lazyPut<ResetPasswordController>(
  //         ()=> ResetPasswordController(),
  //     fenix: true,
  //   );
  // }
//
// static void resetPassDependencies(){
  //   Get.lazyPut<ResetPasswordController>(
  //         ()=> ResetPasswordController(),
  //     fenix: true,
  //   );
  // }
}