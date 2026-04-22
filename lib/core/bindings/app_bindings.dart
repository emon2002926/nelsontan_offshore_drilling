import '../../features/auth/bindings/others_bindings.dart';


class AppBindings {
  AppBindings._();
  static void init() {
    AuthBindings.signInDependencies();
    AuthBindings.signUpDependencies();
    AuthBindings.forgotPassDependencies();
    AuthBindings.otpVerificationDependencies();

  }

}