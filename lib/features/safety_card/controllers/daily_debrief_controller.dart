import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import '../models/activity_model.dart';
import 'package:uuid/uuid.dart';
import '../models/cached_debrief_dropdown_model.dart';
import '../models/pending_debrief_model.dart';
import '../services/connectivity_service.dart';
import '../services/hive_boxes.dart';

class DailyDebriefController extends GetxController {
  final ApiServices   _api  = Get.find<ApiServices>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  final formKey = GlobalKey<FormState>();

  // Dropdown data
  final RxList<ActivityModel>    activities   = <ActivityModel>[].obs;
  final RxList<DebriefTypeModel> debriefTypes = <DebriefTypeModel>[].obs;
  final RxBool isLoadingDropdowns = false.obs;

  // Dynamic questions from API
  final RxList<DebriefQuestionModel> questions = <DebriefQuestionModel>[].obs;
  final Map<int, TextEditingController> questionControllers = {};
  final Map<int, FocusNode> questionFocusNodes = {};

  final Rx<ActivityModel?>    selectedActivity    = Rx<ActivityModel?>(null);
  final Rx<DebriefTypeModel?> selectedDebriefType = Rx<DebriefTypeModel?>(null);

  final RxBool submitAnonymously = false.obs;
  final RxBool isSubmitting      = false.obs;

  final RxBool canSubmitToday = true.obs;
  final RxBool isCheckingSubmission = true.obs;


  @override
  void onInit() {
    super.onInit();
    checkSubmissionStatus();
    fetchDropdowns();
  }

  @override
  void onClose() {
    _disposeQuestionFields();
    super.onClose();
  }

  TextEditingController controllerFor(DebriefQuestionModel q) =>
      questionControllers.putIfAbsent(q.id, () => TextEditingController());

  FocusNode focusNodeFor(DebriefQuestionModel q) =>
      questionFocusNodes.putIfAbsent(q.id, () => FocusNode());

  void _setQuestions(List<DebriefQuestionModel> newQuestions) {
    // Drop controllers for questions that no longer exist; keep text of
    // ones that survive a refresh.
    final newIds = newQuestions.map((q) => q.id).toSet();
    final removedIds =
        questionControllers.keys.where((id) => !newIds.contains(id)).toList();
    for (final id in removedIds) {
      questionControllers.remove(id)?.dispose();
      questionFocusNodes.remove(id)?.dispose();
    }
    questions.assignAll(newQuestions);
  }

  void _disposeQuestionFields() {
    for (final c in questionControllers.values) {
      c.dispose();
    }
    for (final f in questionFocusNodes.values) {
      f.dispose();
    }
    questionControllers.clear();
    questionFocusNodes.clear();
  }

  Future<void> refreshCard() async {
    await Future.wait([
      checkSubmissionStatus(),
      fetchDropdowns(),
    ]);
  }

  Future<void> checkSubmissionStatus() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    try {
      isCheckingSubmission.value = true;
      final raw = await _api.get(
        '/daily-debrief/check',
        headers: {'Authorization': 'Bearer $token'},
      );
      canSubmitToday.value = raw['success'] == true;
    } catch (e) {
      canSubmitToday.value = true; // fail open — don't block on network error
    } finally {
      isCheckingSubmission.value = false;
    }
  }


  Future<void> fetchDropdowns() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    if (_connectivity.isOnline.value) {
      // Online: fetch from API then cache silently
      isLoadingDropdowns.value = true;
      try {
        final raw = await _api.get(
          '/daily-debrief/get-active-debrief',
          headers: {'Authorization': 'Bearer $token'},
        );

        final data = raw['data'] as Map<String, dynamic>;

        activities.assignAll(
          (data['activity'] as List)
              .map((e) => ActivityModel.fromJson(e))
              .toList(),
        );
        debriefTypes.assignAll(
          (data['typeOfDevrief'] as List)
              .map((e) => DebriefTypeModel.fromJson(e))
              .toList(),
        );
        _setQuestions(
          ((data['debriefQuestion'] as List?) ?? [])
              .map((e) => DebriefQuestionModel.fromJson(e))
              .toList(),
        );

        if (activities.isNotEmpty)   selectedActivity.value   = activities.first;
        if (debriefTypes.isNotEmpty) selectedDebriefType.value = debriefTypes.first;

        // Silently save to Hive for offline use
        await _saveDropdownsToCache();

      } on HttpException catch (e) {
        CustomSnackBar.error(e.message);
      } catch (e) {
        CustomSnackBar.error('Failed to load form data. Please try again.');
      } finally {
        isLoadingDropdowns.value = false;
      }

    } else {
      // Offline: load from Hive silently, no banners
      _loadDropdownsFromCache();
    }
  }

  void _loadDropdownsFromCache() {
    final cached = HiveBoxes.debriefDropdownBox
        .get(HiveBoxes.debriefDropdownCacheKey);
    if (cached == null) return;

    activities.assignAll(
      cached.activities.map((e) =>
          ActivityModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
    debriefTypes.assignAll(
      cached.debriefTypes.map((e) =>
          DebriefTypeModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
    _setQuestions(
      cached.questions.map((e) =>
          DebriefQuestionModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );

    if (activities.isNotEmpty)   selectedActivity.value   = activities.first;
    if (debriefTypes.isNotEmpty) selectedDebriefType.value = debriefTypes.first;
  }

  Future<void> _saveDropdownsToCache() async {
    final entry = CachedDebriefDropdownModel(
      activities:  activities.map((e) => {'id': e.id, 'name': e.name}).toList(),
      debriefTypes: debriefTypes.map((e) => {'id': e.id, 'name': e.name}).toList(),
      questions:   questions.map((q) => {
        'id':          q.id,
        'question':    q.question,
        'placeholder': q.placeholder,
      }).toList(),
      cachedAt:    DateTime.now(),
    );
    await HiveBoxes.debriefDropdownBox
        .put(HiveBoxes.debriefDropdownCacheKey, entry);
  }


  List<Map<String, String>> _buildQuestionAnswers() {
    return questions.map((q) => {
      'question': q.question,
      'answer':   controllerFor(q).text.trim(),
    }).toList();
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
    if (questions.isEmpty) {
      CustomSnackBar.warning('No debrief questions available. Pull to refresh.');
      return;
    }

    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isSubmitting.value = true;
    try {
      if (_connectivity.isOnline.value) {
        await _submitOnline(token);
        _drainPendingQueue(token); // fire and forget
        canSubmitToday.value = false;
      } else {
        await _saveToHive();
        canSubmitToday.value = false;
      }
    } finally {
      isSubmitting.value = false;
      canSubmitToday.value = false;
    }
  }

  Future<void> _submitOnline(String token) async {
    try {
      await _api.post(
        '/daily-debrief/create',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'activityId':        selectedActivity.value!.id,
          'typeOfDevriefId':   selectedDebriefType.value!.id,
          'submitAnonymously': submitAnonymously.value,
          'questionAnswer':    _buildQuestionAnswers(),
        },
      );

      CustomSnackBar.success('Daily debrief submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      resetForm();

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to submit debrief. Please try again.');
    }
  }

  Future<void> _saveToHive() async {
    try {
      final debrief = PendingDebriefModel(
        localId:          const Uuid().v4(),
        activityId:       selectedActivity.value!.id,
        typeOfDevriefId:  selectedDebriefType.value!.id,
        questionAnswer:   _buildQuestionAnswers(),
        submitAnonymously: submitAnonymously.value,
        createdAt:        DateTime.now(),
      );

      await HiveBoxes.pendingDebriefBox.put(debrief.localId, debrief);

      CustomSnackBar.success('Daily debrief submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      resetForm();

    } catch (e) {
      CustomSnackBar.error('Failed to save. Please try again.');
    }
  }

  // Silently uploads pending Hive debriefs when back online
  Future<void> _drainPendingQueue(String token) async {
    final pending = HiveBoxes.pendingDebriefBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final debrief in pending) {
      try {
        await _api.post(
          '/daily-debrief/create',
          headers: {'Authorization': 'Bearer $token'},
          body: {
            'activityId':        debrief.activityId,
            'typeOfDevriefId':   debrief.typeOfDevriefId,
            'submitAnonymously': debrief.submitAnonymously,
            'questionAnswer':    debrief.questionAnswer
                .map((qa) => Map<String, dynamic>.from(qa))
                .toList(),
          },
        );
        await debrief.delete(); // success → remove from Hive
      } catch (_) {
        // Silent fail — retry next time online
      }
    }
  }


  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.trim().length < 10) return 'Must be at least 10 characters';
    return null;
  }

  void resetForm() {
    for (final c in questionControllers.values) {
      c.clear();
    }
    selectedActivity.value    = activities.isNotEmpty ? activities.first : null;
    selectedDebriefType.value = debriefTypes.isNotEmpty ? debriefTypes.first : null;
    submitAnonymously.value   = false;
  }
}
