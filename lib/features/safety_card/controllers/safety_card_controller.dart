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
import '../models/safety_card_model.dart';

class SafetyCardController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final descriptionController = TextEditingController();

  // Focus Nodes
  final descriptionFocus = FocusNode();

  // ── API-driven dropdown data ─────────────────────────────────────────────
  final RxList<CardTypeModel> cardTypes = <CardTypeModel>[].obs;
  final RxList<AreaModel> areas         = <AreaModel>[].obs;
  final RxList<HazardModel> hazards     = <HazardModel>[].obs;
  final RxBool isLoadingDropdowns       = false.obs;

  // ── Selected values (hold the model, not just a string) ─────────────────
  final Rx<CardTypeModel?> selectedCardType  = Rx<CardTypeModel?>(null);
  final Rx<AreaModel?>     selectedArea      = Rx<AreaModel?>(null);
  final RxList<HazardModel> selectedHazards  = <HazardModel>[].obs;

  // ── Other fields ─────────────────────────────────────────────────────────
  final Rx<String?>  selectedRiskSeverity  = Rx<String?>('Medium');
  final Rx<String?>  uploadedPhotoPath     = Rx<String?>(null);
  final RxBool actionTaken                 = false.obs;
  final RxBool immediateActionRequired     = false.obs;
  final RxBool submitAnonymously           = false.obs;
  final RxBool isSubmitting                = false.obs;

  final List<String> riskSeverities = ['Low', 'Medium', 'High'];

  // ── Speech-to-Text ────────────────────────────────────────────────────────
  final SpeechToText _speech           = SpeechToText();
  final RxBool       isListening       = false.obs;
  final RxBool       isSpeechAvailable = false.obs;
  bool               _speechInitialized = false; // prevents re-init on every tap

  // Snapshot of text before a listening session starts — so new words
  // are appended rather than overwriting what the user already typed.
  String _textBeforeListening = '';

  // ── Helpers ───────────────────────────────────────────────────────────────

  String hazardIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fall'))     return '🪜';
    if (lower.contains('chemical')) return '🧪';
    if (lower.contains('struck'))   return '💥';
    if (lower.contains('electric')) return '⚡';
    if (lower.contains('fire'))     return '🔥';
    return '⚠️';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // ✅ No _initSpeech() here — permission is requested only on first mic tap
    fetchDropdowns();
  }

  @override
  void onClose() {
    _speech.stop();
    descriptionController.dispose();
    descriptionFocus.dispose();
    super.onClose();
  }

  // ── Speech: lazy init (called only when user taps the mic) ───────────────

  /// Initializes speech recognition the first time it's needed.
  /// Returns true if available. Subsequent calls return the cached result.
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

  /// Toggles listening on/off. Permission prompt fires here on first call.
  Future<void> toggleListening() async {
    // ── Stop if already listening ─────────────────────────────────────────
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    // ── Init + permission on first tap only ───────────────────────────────
    final available = await _ensureSpeechInitialized();
    if (!available) {
      CustomSnackBar.error('Speech recognition not available on this device');
      return;
    }

    // ── Start listening ───────────────────────────────────────────────────
    _textBeforeListening = descriptionController.text;
    isListening.value    = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        final newWords = result.recognizedWords;
        if (newWords.isNotEmpty) {
          descriptionController.text = _textBeforeListening.isEmpty
              ? newWords
              : '$_textBeforeListening $newWords';

          // Keep cursor at end while transcribing
          descriptionController.selection = TextSelection.fromPosition(
            TextPosition(offset: descriptionController.text.length),
          );
        }
        // Lock in the transcribed text as the new baseline on final result
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

  // ── GET /card-submission/type-hazard-area ─────────────────────────────────

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
        '/card-submission/type-hazard-area',
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = CardTypeHazardAreaModel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      cardTypes.assignAll(data.cardTypes);
      areas.assignAll(data.areas);
      hazards.assignAll(data.hazards);

      // Default first card type selected
      if (cardTypes.isNotEmpty) selectedCardType.value = cardTypes.first;
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load form data. Please try again.');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  // ── POST /card-submission/create (multipart/form-data) ───────────────────

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
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isSubmitting.value = true;
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
      CustomSnackBar.error('Failed to submit safety card. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe what you observed';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
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

  // ── Reset ─────────────────────────────────────────────────────────────────

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