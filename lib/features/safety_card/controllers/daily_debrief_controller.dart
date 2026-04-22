import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import '../models/activity_model.dart';

class DailyDebriefController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final whatHappenedController    = TextEditingController();
  final whatWorkedWellController  = TextEditingController();
  final whatImprovedController    = TextEditingController();

  // Focus Nodes
  final whatHappenedFocus   = FocusNode();
  final whatWorkedWellFocus = FocusNode();
  final whatImprovedFocus   = FocusNode();

  // Dropdown data
  final RxList<ActivityModel>    activities   = <ActivityModel>[].obs;
  final RxList<DebriefTypeModel> debriefTypes = <DebriefTypeModel>[].obs;
  final RxBool isLoadingDropdowns = false.obs;

  // Selected values
  final Rx<ActivityModel?>    selectedActivity    = Rx<ActivityModel?>(null);
  final Rx<DebriefTypeModel?> selectedDebriefType = Rx<DebriefTypeModel?>(null);

  // Toggles
  final RxBool submitAnonymously = false.obs;
  final RxBool isSubmitting      = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdowns();
  }


  Future<void> fetchDropdowns() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isLoadingDropdowns.value = true;
    try {
      final raw = await _api.get(
        '/daily-debrief/get-active-debrief', // ← exact endpoint
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = raw['data'] as Map<String, dynamic>;

      activities.assignAll(
        (data['activity'] as List)
            .map((e) => ActivityModel.fromJson(e))
            .toList(),
      );
      debriefTypes.assignAll(
        (data['typeOfDevrief'] as List) // ← note the typo from API: "Devrief"
            .map((e) => DebriefTypeModel.fromJson(e))
            .toList(),
      );

      if (activities.isNotEmpty) selectedActivity.value = activities.first;
      if (debriefTypes.isNotEmpty) selectedDebriefType.value = debriefTypes.first;
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load form data. Please try again.');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  Future<void> submitDebrief(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedActivity.value == null) {
      CustomSnackBar.warning('Please select an activity');
      return;
    }
    if (selectedDebriefType.value == null) {
      CustomSnackBar.warning('Please select a type of debrief');
      return;
    }

    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isSubmitting.value = true;
    try {
      await _api.post(
        '/daily-debrief/create', // ← exact endpoint
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'activityId':        selectedActivity.value!.id,       // int, not string
          'typeOfDevriefId':   selectedDebriefType.value!.id,    // ← "Devrief" typo matches API
          'whatHappend':       whatHappenedController.text.trim(), // ← "Happend" typo matches API
          'whatWorkedWell':    whatWorkedWellController.text.trim(),
          'whatImproved':      whatImprovedController.text.trim(),
          'submitAnonymously': submitAnonymously.value,           // bool, not string
        },
      );

      CustomSnackBar.success('Daily debrief submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      resetForm();
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to submit debrief. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }






  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.trim().length < 10) return 'Must be at least 10 characters';
    return null;
  }

  void resetForm() {
    whatHappenedController.clear();
    whatWorkedWellController.clear();
    whatImprovedController.clear();
    selectedActivity.value = activities.isNotEmpty ? activities.first : null;
    selectedDebriefType.value = debriefTypes.isNotEmpty ? debriefTypes.first : null;
    submitAnonymously.value = false;
  }

  @override
  void onClose() {
    whatHappenedController.dispose();
    whatWorkedWellController.dispose();
    whatImprovedController.dispose();
    whatHappenedFocus.dispose();
    whatWorkedWellFocus.dispose();
    whatImprovedFocus.dispose();
    super.onClose();
  }
}