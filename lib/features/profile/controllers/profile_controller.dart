import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/widgets/snakbar/custom_snackbar.dart';
class ProfileController extends GetxController {
  final nameController = TextEditingController(text: 'Eiden Jonson');
  final emailController = TextEditingController(text: 'ltunuoluwa@gmail.com');
  final companyController = TextEditingController(text: 'ONGC');
  final positionController = TextEditingController(text: 'Contractor');

  void changeProfilePhoto() {
    // Implement photo picker logic
    CustomSnackBar.info('Change profile photo');
  }

  void saveProfile() {
    // Implement save logic
    final name = nameController.text;
    final email = emailController.text;
    final company = companyController.text;
    final position = positionController.text;

    // Validate
    if (name.isEmpty || email.isEmpty || company.isEmpty || position.isEmpty) {
      CustomSnackBar.error('Please fill all fields');
      return;
    }

    // Save to backend/local storage
    CustomSnackBar.success('Profile saved successfully');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    positionController.dispose();
    super.onClose();
  }
}