import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/features/onboarding/views/onboarding_screen.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../core/widgets/text/app_text.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.responsiveSize(40)),

                // Profile Avatar
                Center(child: _buildProfileAvatar(context, controller)),

                SizedBox(height: context.responsiveSize(16)),

                // Name
                Center(
                  child: AppText(
                    data: 'Eiden Jonson',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    useResponsiveFontSize: true,
                  ),
                ),

                SizedBox(height: context.responsiveSize(4)),

                // Position
                Center(
                  child: AppText(
                    data: 'Field Technician',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBEBDBD),
                    useResponsiveFontSize: true,
                  ),
                ),

                SizedBox(height: context.responsiveSize(25)),

                // Name Field
                AppText(
                  data: 'Name',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(8)),
                _buildTextField(
                  context,
                  controller: controller.nameController,
                ),

                SizedBox(height: context.responsiveSize(16)),

                // Email Field
                AppText(
                  data: 'Your Emaill',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(8)),
                _buildTextField(
                  context,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: context.responsiveSize(16)),

                // Company Name Field
                AppText(
                  data: 'Company Name',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(8)),
                _buildTextField(
                  context,
                  controller: controller.companyController,
                ),

                SizedBox(height: context.responsiveSize(16)),

                // Position Field
                AppText(
                  data: 'Position',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(8)),
                _buildTextField(
                  context,
                  controller: controller.positionController,
                ),

                SizedBox(height: context.responsiveSize(40)),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: context.responsiveSize(46),
                  child: ElevatedButton(
                    // onPressed: () => controller.saveProfile(),
                    onPressed: () {
                      Get.offAll(OnboardingScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0047AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.responsiveSize(28)),
                      ),
                      elevation: 0,
                    ),
                    child: AppText(
                      data: 'Save',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      useResponsiveFontSize: true,
                    ),
                  ),
                ),

                SizedBox(height: context.responsiveSize(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, ProfileController controller) {
    return Stack(
      children: [
        CircleAvatar(
          radius: context.responsiveSize(44),
          backgroundColor: const Color(0xFFE0E0E0),
          backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => controller.changeProfilePhoto(),
            child: Container(
              padding: EdgeInsets.all(context.responsiveSize(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: context.responsiveSize(20),
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(6)),
        border: Border.all(
          color: const Color(0xFFBEBDBD),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: context.responsiveFontSize(14),
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(16),
            vertical: context.responsiveSize(0),
          ),
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: context.responsiveFontSize(16),
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}

// Controller
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