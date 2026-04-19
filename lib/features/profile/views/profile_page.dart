import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/buttons/app_button.dart';
import 'package:nelsontan_offshore_drilling/features/onboarding/views/onboarding_screen.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/profile_controller.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.responsiveSize(35)),

                  // ── Avatar ──────────────────────────────────────────
                  Center(child: _buildProfileAvatar(context, controller)),

                  SizedBox(height: context.responsiveSize(12)),

                  // ── Name ────────────────────────────────────────────
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.nameController,
                    builder: (_, value, __) => Center(
                      child: AppText(
                        data: value.text.isEmpty ? '—' : value.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        useResponsiveFontSize: true,
                      ),
                    ),
                  ),


                  SizedBox(height: context.responsiveSize(4)),

                  // ── Position ─────────────────────────────────────────
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.positionController,
                    builder: (_, value, __) => Center(
                      child: AppText(
                        data: value.text.isEmpty ? '—' : value.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFBEBDBD),
                        useResponsiveFontSize: true,
                      ),
                    ),
                  ),

                  SizedBox(height: context.responsiveSize(20)),

                  // ── Fields ────────────────────────────────────────────
                  _label(context, 'Name'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextField(context, controller: controller.nameController),

                  SizedBox(height: context.responsiveSize(12)),

                  _label(context, 'Email'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextField(
                    context,
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true, // email is not editable
                  ),

                  SizedBox(height: context.responsiveSize(12)),

                  _label(context, 'Company Name'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextField(context, controller: controller.companyController),

                  SizedBox(height: context.responsiveSize(12)),

                  _label(context, 'Position'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextField(context, controller: controller.positionController),

                  SizedBox(height: context.responsiveSize(12)),

                  _label(context, 'Phone'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextField(
                    context,
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  SizedBox(height: context.responsiveSize(35)),

                  // ── Save Button ───────────────────────────────────────
                  Obx(() => AppButton(
                    buttonText: 'Save',
                    onPressed: controller.saveProfile,
                    fillColor: const Color(0xFF0047AB),
                    textColor: Colors.white,
                    isLoading: controller.isUpdating.value,
                    loadingText: 'Saving...',
                  )),

                  SizedBox(height: context.responsiveSize(12)),

                  // ── Logout Button ─────────────────────────────────────
                  AppButton(
                    buttonText: 'Log out',
                    onPressed: controller.logout,
                    fillColor: Colors.red,
                    textColor: Colors.white,
                  ),

                  SizedBox(height: context.responsiveSize(40)),
                ],
              ),
            ),

            // ── Full-screen loader on initial fetch ───────────────────
            Obx(() {
              if (!controller.isLoadingProfile.value) return const SizedBox.shrink();
              return Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0047AB)),
                ),
              );
            }),

            // ── Save overlay ──────────────────────────────────────────
            AppButton.buildLoadingOverlay(
              isLoading: controller.isUpdating,
              loadingMessage: 'Updating your profile...',
              backgroundColor: Colors.black,
              cardColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => AppText(
    data: text,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1A1A1A),
    useResponsiveFontSize: true,
  );

  Widget _buildProfileAvatar(BuildContext context, ProfileController controller) {
    return Stack(
      children: [
        Obx(() {
          // Priority: newly picked image → remote URL → placeholder
          if (controller.pickedImage.value != null) {
            return CircleAvatar(
              radius: context.responsiveSize(44),
              backgroundImage: FileImage(controller.pickedImage.value!),
            );
          }
          if (controller.profileImageUrl.value != null &&
              controller.profileImageUrl.value!.isNotEmpty) {
            return CircleAvatar(
              radius: context.responsiveSize(44),
              backgroundImage: NetworkImage(controller.profileImageUrl.value!),
            );
          }
          return CircleAvatar(
            radius: context.responsiveSize(44),
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.changeProfilePhoto,
            child: Container(
              padding: EdgeInsets.all(context.responsiveSize(2)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
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
        bool readOnly = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(6)),
        border: Border.all(color: const Color(0xFFBEBDBD)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: context.responsiveFontSize(14),
          color: readOnly
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsiveSize(16),
            vertical: context.responsiveSize(14),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}