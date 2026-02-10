
class AppStrings {
  // Singleton pattern
  static final AppStrings instance = AppStrings._internal();
  factory AppStrings() => instance;
  AppStrings._internal();

  final String baseUrl = 'https://qube.dsrt321.online/api/v1';

}