import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/form_validator.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../onboarding/views/onboarding_screen.dart';
import '../../safety_card/services/connectivity_service.dart';
import '../../safety_card/services/hive_boxes.dart';
import '../data/models/profile_hive_model.dart';
import '../data/models/profile_model.dart';



class ProfileController extends GetxController {
  final ApiServices         _api          = Get.find<ApiServices>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  // ── Text controllers ────────────────────────────────────────────────────────
  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final companyController  = TextEditingController();
  final positionController = TextEditingController();
  final phoneController    = TextEditingController();

  final isLoadingProfile = false.obs;
  final isUpdating       = false.obs;
  final profileImageUrl  = Rxn<String>();
  final pickedImage      = Rxn<File>();


  Box<ProfileHiveModel> get _box => HiveBoxes.profileBox;
  String? get _token => StorageService.accessToken;
  Map<String, String> get _authHeader => {"Authorization": "Bearer $_token"};


  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    positionController.dispose();
    phoneController.dispose();
    super.onClose();
  }


  Future<void> _init() async {
    final cached = _box.get(HiveBoxes.profileCacheKey);
    if (cached != null) {
      _populateFields(cached.toDomain());
    }
    if (_connectivity.isOnline.value) {
      await fetchProfile();
    }
    _connectivity.onConnected.listen((_) => fetchProfile());
  }



  bool get _hasCachedData => _box.containsKey(HiveBoxes.profileCacheKey);
  Future<void> _saveToCache(ProfileModel model) =>
      _box.put(HiveBoxes.profileCacheKey, ProfileHiveModel.fromDomain(model));
  Future<void> _clearCache() => _box.delete(HiveBoxes.profileCacheKey);



  void _populateFields(ProfileModel model) {
    nameController.text     = model.name;
    emailController.text    = model.email;
    companyController.text  = model.entryCompany;
    positionController.text = model.position;
    phoneController.text    = model.phone;
    profileImageUrl.value   = model.profile;
  }

  bool get _isFormValid => FormValidator.validateAll([
    FormFieldEntry(value: nameController.text.trim(),     errorMessage: 'Name is required'),
    FormFieldEntry(value: companyController.text.trim(),  errorMessage: 'Company name is required'),
    FormFieldEntry(value: positionController.text.trim(), errorMessage: 'Position is required'),
    FormFieldEntry(value: phoneController.text.trim(),    errorMessage: 'Phone number is required'),
  ]);

  Map<String, String> get _formFields => {
    "name":         nameController.text.trim(),
    "entryCompany": companyController.text.trim(),
    "position":     positionController.text.trim(),
    "phone":        phoneController.text.trim(),
  };


  Future<void> fetchProfile() async {
    final hadCache = _hasCachedData;
    if (!hadCache) isLoadingProfile.value = true;
    try {
      final raw      = await _api.get('/user/profile', headers: _authHeader);
      final response = ProfileResponseModel.fromJson(raw);
      if (response.success && response.data != null) {
        final model = response.data!;
        _populateFields(model);
        await _saveToCache(model);
      }
    } on HttpException catch (e) {
      if (!hadCache) CustomSnackBar.error(e.message);
    } catch (e) {
      debugPrint('[ProfileController] fetchProfile error: $e');
      if (!hadCache) CustomSnackBar.error('Failed to load profile. Please try again.');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> changeProfilePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) pickedImage.value = File(picked.path);
  }

  Future<void> saveProfile() async {
    if (!_isFormValid) return;
    isUpdating.value = true;
    try {
      await _api.putFormData(
        '/user/update',
        headers: _authHeader,
        fields: _formFields,
        imageFile: pickedImage.value,
        imageFieldName: "image",
      );

      CustomSnackBar.success('Profile updated successfully!');
      await fetchProfile();
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      debugPrint('[ProfileController] saveProfile error: $e');
      CustomSnackBar.error('Failed to update profile. Please try again.');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    await _clearCache();
    await StorageService.logout();
    AppNavigation.pushAndClear(OnboardingScreen());
  }
}