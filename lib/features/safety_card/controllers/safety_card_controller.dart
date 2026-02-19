// features/safety_card/presentation/controllers/safety_card_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../models/safety_card_model.dart';

class SafetyCardController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final descriptionController = TextEditingController();

  // Focus Nodes
  final descriptionFocus = FocusNode();

  // Observable values
  final Rx<String?> selectedCardType = Rx<String?>(null);
  final Rx<String?> selectedArea = Rx<String?>(null);
  final RxList<String> selectedHazardCategories = <String>[].obs; // Changed to list for multiple selection
  final Rx<String?> selectedRiskSeverity = Rx<String?>('Medium');
  final Rx<String?> uploadedPhotoPath = Rx<String?>(null);

  final RxBool actionTaken = false.obs;
  final RxBool immediateActionRequired = false.obs;
  final RxBool submitAnonymously = false.obs;
  final RxBool isSubmitting = false.obs;

  // Dropdown options
  final List<String> cardTypes = ['Unsafe Act', 'Unsafe Condition', 'Near Miss', 'Good Practice'];
  final List<String> areas = ['Drilling', 'Production', 'Maintenance', 'Logistics', 'HSE'];

  final List<Map<String, dynamic>> hazardCategories = [
    {'icon': '🪜', 'label': 'Fall Hazard'},
    {'icon': '🧪', 'label': 'Chemical Exposure'},
    {'icon': '💥', 'label': 'Struck By'},
    {'icon': '⚡', 'label': 'Electrical'},
    {'icon': '🔥', 'label': 'Fire'},
  ];

  final List<String> riskSeverities = ['Low', 'Medium', 'High'];

  @override
  void onInit() {
    super.onInit();
    selectedCardType.value = cardTypes[0]; // Default to first option
  }

  // Validators
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe what you observed';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  // Pick image
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        uploadedPhotoPath.value = image.path;
        CustomSnackBar.success('Photo uploaded successfully');
      }
    } catch (e) {
      CustomSnackBar.error('Failed to pick image');
      print('Error picking image: $e');
    }
  }

  // Show photo options
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

  // Submit safety card
  Future<void> submitSafetyCard(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCardType.value == null) {
      CustomSnackBar.warning('Please select a card type');
      return;
    }

    if (selectedArea.value == null) {
      CustomSnackBar.warning('Please select an area of observation');
      return;
    }

    if (selectedHazardCategories.isEmpty) {
      CustomSnackBar.warning('Please select at least one hazard category');
      return;
    }

    isSubmitting.value = true;

    try {
      final card = SafetyCardModel(
        cardType: selectedCardType.value,
        areaOfObservation: selectedArea.value,
        hazardCategories: selectedHazardCategories.toList(), // Changed to list
        description: descriptionController.text.trim(),
        riskSeverity: selectedRiskSeverity.value,
        photoPath: uploadedPhotoPath.value,
        actionTaken: actionTaken.value,
        immediateActionRequired: immediateActionRequired.value,
        submitAnonymously: submitAnonymously.value,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      print('Submitting safety card: ${card.toJson()}');

      isSubmitting.value = false;

      CustomSnackBar.success('Safety card submitted successfully!');

      // Navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      AppNavigation.pop(context);

    } catch (e) {
      isSubmitting.value = false;
      CustomSnackBar.error('Failed to submit safety card');
      print('Error: $e');
    }
  }

  // Reset form
  void resetForm() {
    descriptionController.clear();
    selectedCardType.value = cardTypes[0];
    selectedArea.value = null;
    selectedHazardCategories.clear(); // Clear the list
    selectedRiskSeverity.value = 'Medium';
    uploadedPhotoPath.value = null;
    actionTaken.value = false;
    immediateActionRequired.value = false;
    submitAnonymously.value = false;
  }

  @override
  void onClose() {
    descriptionController.dispose();
    descriptionFocus.dispose();
    super.onClose();
  }
}