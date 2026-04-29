import 'package:nelsontan_offshore_drilling/features/home/binding/home_binding.dart';
import 'package:nelsontan_offshore_drilling/features/safety_card/binding/card_binding.dart';
import '../../features/auth/bindings/others_bindings.dart';


class AppBindings {
  AppBindings._();
  static void init() {
    AuthBindings.signInDependencies();
    AuthBindings.signUpDependencies();
    AuthBindings.forgotPassDependencies();
    AuthBindings.otpVerificationDependencies();
    HomeBinding.homeDependencies();
    CardBinding.cardDependencies();
  }

}