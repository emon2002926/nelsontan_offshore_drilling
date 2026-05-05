import 'package:nelsontan_offshore_drilling/features/games/binding/game_binding.dart';
import 'package:nelsontan_offshore_drilling/features/home/binding/home_binding.dart';
import 'package:nelsontan_offshore_drilling/features/notification/bindings/notification_binding.dart';
import 'package:nelsontan_offshore_drilling/features/profile/bindings/profile_binding.dart';
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
    GameBinding.gameDependencies();
    NotificationBinding.notificationDependencies();
    ProfileBinding.profileDependencies();
  }

}