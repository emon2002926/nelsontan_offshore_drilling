import '../../features/auth/bindings/others_bindings.dart';


class AppBindings {
  AppBindings._();
  static void init() {
    AuthBindings.signInDependencies();
    AuthBindings.signUpDependencies();
    // BaseBinding.dependencies();
    // HomeBinding.dependencies();
    // NotificationBinding.dependencies();
    // UnitsBinding.dependencies();
    AuthBindings.forgotPassDependencies();
    AuthBindings.otpVerificationDependencies();
    // OtherAuthBindings.otpDependencies();
    // OtherAuthBindings.resetPassDependencies();
  }

}