
// class LanguageController extends GetxController {
//   final RxString currentLanguage = 'en'.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadLanguage();
//   }
//
//   void loadLanguage() {
//     currentLanguage.value = StorageService.language;
//   }
//
//   Future<void> changeLanguage(String languageCode) async {
//     currentLanguage.value = languageCode;
//     await StorageService.saveLanguage(languageCode);
//     update();
//   }
//
//   bool get isEnglish => currentLanguage.value == 'en';
//   bool get isSpanish => currentLanguage.value == 'es';
// }