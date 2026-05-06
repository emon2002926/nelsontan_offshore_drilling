import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/services/api_services.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import '../models/cached_dropdown_model.dart';
import '../models/pending_submission_model.dart';
import '../models/safety_card_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../services/connectivity_service.dart';
import '../services/hive_boxes.dart';
import '../services/sync_service.dart';

class SafetyCardController extends GetxController {
  final ApiServices         _api          = Get.find<ApiServices>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncService         _syncService  = Get.find<SyncService>();

  final formKey               = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final descriptionFocus      = FocusNode();

  final RxList<CardTypeModel>  cardTypes        = <CardTypeModel>[].obs;
  final RxList<AreaModel>      areas            = <AreaModel>[].obs;
  final RxList<HazardModel>    hazards          = <HazardModel>[].obs;
  final RxBool                 isLoadingDropdowns = false.obs;
  final Rx<DateTime?>          dropdownCachedAt = Rx<DateTime?>(null);


  final Rx<CardTypeModel?>   selectedCardType    = Rx<CardTypeModel?>(null);
  final Rx<AreaModel?>       selectedArea        = Rx<AreaModel?>(null);
  final RxList<HazardModel>  selectedHazards     = <HazardModel>[].obs;
  final Rx<String?>          selectedRiskSeverity = Rx<String?>('Medium');
  final Rx<String?>          uploadedPhotoPath    = Rx<String?>(null);


  final RxBool actionTaken             = false.obs;
  final RxBool immediateActionRequired = false.obs;
  final RxBool submitAnonymously       = false.obs;
  final RxBool isSubmitting            = false.obs;

  final List<String> riskSeverities = ['Low', 'Medium', 'High'];

  final SpeechToText _speech           = SpeechToText();
  final RxBool       isListening       = false.obs;
  final RxBool       isSpeechAvailable = false.obs;
  bool               _speechInitialized = false;
  String             _textBeforeListening = '';


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
    _speech.stop();
    descriptionController.dispose();
    descriptionFocus.dispose();
    super.onClose();
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
        '/card-submission/check',
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
      isLoadingDropdowns.value = true;
      try {
        final raw = await _api.get(
          '/card-submission/type-hazard-area',
          headers: {'Authorization': 'Bearer $token'},
        );

        final data = CardTypeHazardAreaModel.fromJson(
          raw['data'] as Map<String, dynamic>,
        );

        cardTypes.assignAll(data.cardTypes);
        areas.assignAll(data.areas);
        hazards.assignAll(data.hazards);

        if (cardTypes.isNotEmpty) selectedCardType.value = cardTypes.first;

        // Silently cache for offline use
        await _saveDropdownsToCache(data);

      } on HttpException catch (e) {
        CustomSnackBar.error(e.message);
      } catch (e) {
        CustomSnackBar.error('Failed to load form data. Please try again.');
      } finally {
        isLoadingDropdowns.value = false;
      }

    } else {
      _loadDropdownsFromCache();
    }
  }



  void _loadDropdownsFromCache() {
    final cached = HiveBoxes.dropdownBox.get(HiveBoxes.dropdownCacheKey);
    if (cached == null) return;

    cardTypes.assignAll(
      cached.cardTypes.map((e) => CardTypeModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
    areas.assignAll(
      cached.areas.map((e) => AreaModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
    hazards.assignAll(
      cached.hazards.map((e) => HazardModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );

    if (cardTypes.isNotEmpty) selectedCardType.value = cardTypes.first;
    dropdownCachedAt.value = cached.cachedAt;
  }

  Future<void> _saveDropdownsToCache(CardTypeHazardAreaModel data) async {
    final entry = CachedDropdownModel(
      areas:      data.areas.map((e) => {'id': e.id, 'name': e.name, 'color': e.color}).toList(),
      cardTypes:  data.cardTypes.map((e) => {'id': e.id, 'name': e.name}).toList(),
      hazards:    data.hazards.map((e) => {'id': e.id, 'name': e.name}).toList(),
      cachedAt:   DateTime.now(),
    );
    await HiveBoxes.dropdownBox.put(HiveBoxes.dropdownCacheKey, entry);
    dropdownCachedAt.value = entry.cachedAt;
  }


  Future<void> submitSafetyCard(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedCardType.value == null) {
      CustomSnackBar.warning('Please select a card type');
      return;
    }
    if (selectedArea.value == null) {
      CustomSnackBar.warning('Please select an area of observation');
      return;
    }
    if (selectedHazards.isEmpty) {
      CustomSnackBar.warning('Please select at least one hazard category');
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
        _drainPendingQueue(token); // fire and forget, no await
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
      final fields = <String, String>{
        'cardTypeId':        selectedCardType.value!.id.toString(),
        'areaId':            selectedArea.value!.id.toString(),
        'hazardId':          selectedHazards.first.id.toString(),
        'description':       descriptionController.text.trim(),
        'riskSeverity':      (selectedRiskSeverity.value ?? 'Medium').toUpperCase(),
        'actionTaken':       actionTaken.value.toString(),
        'immediateAction':   immediateActionRequired.value.toString(),
        'submitAnonymously': submitAnonymously.value.toString(),
      };

      final imageFile = uploadedPhotoPath.value != null
          ? File(uploadedPhotoPath.value!)
          : null;

      await _api.postFormData(
        '/card-submission/create',
        headers: {'Authorization': 'Bearer $token'},
        fields: fields,
        imageFile: imageFile,
        imageFieldName: 'media',
      );

      CustomSnackBar.success('Safety card submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      resetForm();

    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to submit. Please try again.');
    }
  }


  Future<void> _saveToHive() async {
    try {
      String? savedImagePath;
      if (uploadedPhotoPath.value != null) {
        savedImagePath = await _copyImageToDocuments(uploadedPhotoPath.value!);
      }

      final submission = PendingSubmissionModel(
        localId:           const Uuid().v4(),
        cardTypeId:        selectedCardType.value!.id,
        areaId:            selectedArea.value!.id,
        hazardIds:         selectedHazards.map((h) => h.id).toList(),
        description:       descriptionController.text.trim(),
        riskSeverity:      (selectedRiskSeverity.value ?? 'Medium').toUpperCase(),
        actionTaken:       actionTaken.value,
        immediateAction:   immediateActionRequired.value,
        submitAnonymously: submitAnonymously.value,
        localImagePath:    savedImagePath,
        createdAt:         DateTime.now(),
      );

      await HiveBoxes.pendingBox.put(submission.localId, submission);

      CustomSnackBar.success('Safety card submitted successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      resetForm();

    } catch (e) {
      CustomSnackBar.error('Failed to save. Please try again.');
    }
  }


  Future<void> _drainPendingQueue(String token) async {
    final pending = HiveBoxes.pendingBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final submission in pending) {
      try {
        final fields = <String, String>{
          'cardTypeId':        submission.cardTypeId.toString(),
          'areaId':            submission.areaId.toString(),
          'hazardId':          submission.hazardIds.first.toString(),
          'description':       submission.description,
          'riskSeverity':      submission.riskSeverity,
          'actionTaken':       submission.actionTaken.toString(),
          'immediateAction':   submission.immediateAction.toString(),
          'submitAnonymously': submission.submitAnonymously.toString(),
        };

        final imageFile = submission.localImagePath != null
            ? File(submission.localImagePath!)
            : null;

        await _api.postFormData(
          '/card-submission/create',
          headers: {'Authorization': 'Bearer $token'},
          fields: fields,
          imageFile: imageFile,
          imageFieldName: 'media',
        );

        await submission.delete(); // success → remove from Hive

      } catch (_) {
      }
    }
  }







  /// Copies picked image from temp cache → app documents so it survives
  /// cache clears and long offline periods on the rig.
  Future<String> _copyImageToDocuments(String tempPath) async {
    final docsDir  = await getApplicationDocumentsDirectory();
    final fileName = 'safety_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${docsDir.path}/$fileName';
    await File(tempPath).copy(destPath);
    return destPath;
  }


  Future<bool> _ensureSpeechInitialized() async {
    if (_speechInitialized) return isSpeechAvailable.value;

    isSpeechAvailable.value = await _speech.initialize(
      onError: (error) {
        isListening.value = false;
        CustomSnackBar.error('Speech error: ${error.errorMsg}');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
    );

    _speechInitialized = true;
    return isSpeechAvailable.value;
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    final available = await _ensureSpeechInitialized();
    if (!available) {
      CustomSnackBar.error('Speech recognition not available on this device');
      return;
    }

    _textBeforeListening = descriptionController.text;
    isListening.value    = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        final newWords = result.recognizedWords;
        if (newWords.isNotEmpty) {
          descriptionController.text = _textBeforeListening.isEmpty
              ? newWords
              : '$_textBeforeListening $newWords';

          descriptionController.selection = TextSelection.fromPosition(
            TextPosition(offset: descriptionController.text.length),
          );
        }
        if (result.finalResult) {
          _textBeforeListening = descriptionController.text;
        }
      },
      listenFor:      const Duration(seconds: 60),
      pauseFor:       const Duration(seconds: 4),
      partialResults: true,
      localeId:       'en_US',
      cancelOnError:  true,
      listenMode:     ListenMode.confirmation,
    );
  }



  String hazardIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fall'))     return '🪜';
    if (lower.contains('chemical')) return '🧪';
    if (lower.contains('struck'))   return '💥';
    if (lower.contains('electric')) return '⚡';
    if (lower.contains('fire'))     return '🔥';
    return '⚠️';
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe what you observed';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source:       source,
        maxWidth:     1920,
        maxHeight:    1080,
        imageQuality: 85,
      );
      if (image != null) {
        uploadedPhotoPath.value = image.path;
        CustomSnackBar.success('Photo uploaded successfully');
      }
    } catch (e) {
      CustomSnackBar.error('Failed to pick image');
    }
  }

  void showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.responsiveSize(20)),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.responsiveSize(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0047AB)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF0047AB)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(context, ImageSource.gallery);
                },
              ),
              if (uploadedPhotoPath.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    uploadedPhotoPath.value = null;
                    Navigator.pop(context);
                    CustomSnackBar.info('Photo removed');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void resetForm() {
    descriptionController.clear();
    selectedCardType.value        = cardTypes.isNotEmpty ? cardTypes.first : null;
    selectedArea.value            = null;
    selectedHazards.clear();
    selectedRiskSeverity.value    = 'Medium';
    uploadedPhotoPath.value       = null;
    actionTaken.value             = false;
    immediateActionRequired.value = false;
    submitAnonymously.value       = false;
  }
}