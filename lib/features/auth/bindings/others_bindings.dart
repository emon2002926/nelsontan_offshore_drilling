import 'package:get/get.dart';
import '../controllers/client_rig_select_controller.dart';
import '../controllers/forget_password_controller.dart';
import '../controllers/otp_verification_controller.dart';
import '../controllers/signin_controller.dart';
import '../controllers/signup_controller.dart';
class AuthBindings {
  static void signInDependencies(){
    Get.lazyPut<SignInController>(
          ()=> SignInController(),
    );
  }

  static void signUpDependencies(){
    Get.lazyPut<SignUpController>(
          ()=> SignUpController(),
    );
  }
  static void forgotPassDependencies(){
    Get.lazyPut<ForgetPasswordController>(
          ()=> ForgetPasswordController(),
    );
  }
  static void otpVerificationDependencies(){
    Get.lazyPut<OtpVerificationController>(
          ()=> OtpVerificationController(),
    );
  }
  static void clientRigSelectDependencies(){
    Get.lazyPut<ClientRigSelectController>(
          ()=> ClientRigSelectController(),
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