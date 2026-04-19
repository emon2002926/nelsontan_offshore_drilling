import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/form_validator.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/models/sign_in_response_model.dart';
import '../../onboarding/views/onboarding_screen.dart';
// ── Controller ────────────────────────────────────────────────────────────────

class ProfileController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final companyController  = TextEditingController();
  final positionController = TextEditingController();
  final phoneController    = TextEditingController();

  final isLoadingProfile = true.obs;
  final isUpdating       = false.obs;
  final profileImageUrl  = Rxn<String>();
  final pickedImage      = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ── GET /user/profile ─────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    try {
      final token = StorageService.accessToken;
      final raw   = await _api.get(
        '/user/profile',
        headers: {"Authorization": "Bearer $token"},
      );

      final user = UserModel.fromJson(raw["data"]);

      nameController.text     = user.name;
      emailController.text    = user.email;
      companyController.text  = user.entryCompany;
      positionController.text = user.position;
      phoneController.text    = user.phone;
      profileImageUrl.value   = user.profile;

      // Keep storage in sync with latest profile
      await StorageService.saveUser(user);

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load profile. Please try again.');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<void> changeProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      pickedImage.value = File(picked.path);
    }
  }

  // ── PUT /user/update  (form-data) ─────────────────────────────────────────
  Future<void> saveProfile() async {
    final name     = nameController.text.trim();
    final company  = companyController.text.trim();
    final position = positionController.text.trim();
    final phone    = phoneController.text.trim();

    final isValid = FormValidator.validateAll([
      FormFieldEntry(value: name,     errorMessage: 'Name is required'),
      FormFieldEntry(value: company,  errorMessage: 'Company name is required'),
      FormFieldEntry(value: position, errorMessage: 'Position is required'),
      FormFieldEntry(value: phone,    errorMessage: 'Phone number is required'),
    ]);
    if (!isValid) return;

    isUpdating.value = true;
    try {
      final token  = StorageService.accessToken;
      final fields = {
        "name":          name,
        "entryCompany":  company,
        "position":      position,
        "phone":         phone,
      };

      if (pickedImage.value != null) {
        // Has new image → multipart
        await _api.putFormData(
          '/user/update',
          headers: {"Authorization": "Bearer $token"},
          fields: fields,
          imageFile: pickedImage.value,
          imageFieldName: "image",
        );
      } else {
        // No image change → regular form-data with text fields only
        await _api.putFormData(
          '/user/update',
          headers: {"Authorization": "Bearer $token"},
          fields: fields,
        );
      }

      CustomSnackBar.success('Profile updated successfully!');
      await fetchProfile(); // refresh with latest data

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to update profile. Please try again.');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    await StorageService.logout();
    AppNavigation.pushAndClear(OnboardingScreen());
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
}