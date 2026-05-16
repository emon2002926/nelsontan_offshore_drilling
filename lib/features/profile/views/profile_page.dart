import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/buttons/app_button.dart';
import 'package:nelsontan_offshore_drilling/features/auth/views/client_rig_select_screen.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../../core/widgets/text/text_field/AppTextFiled.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () {
          return controller.init();
        },
        child: SafeArea(
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

                    Center(child: _buildProfileAvatar(context, controller)),

                    SizedBox(height: context.responsiveSize(12)),

                    _buildNameDisplay(controller),

                    SizedBox(height: context.responsiveSize(4)),

                    _buildPositionDisplay(controller),

                    SizedBox(height: context.responsiveSize(12)),

                    // Center(child: _buildChangeRigButton(context, controller)),

                    SizedBox(height: context.responsiveSize(20)),

                    ..._buildFormFields(context, controller),

                    SizedBox(height: context.responsiveSize(35)),

                    _buildSaveButton(controller),

                    SizedBox(height: context.responsiveSize(12)),

                    _buildLogoutButton(controller),

                    SizedBox(height: context.responsiveSize(40)),
                  ],
                ),
              ),

              _buildFullScreenLoader(controller),

              AppButton.buildLoadingOverlay(
                isLoading: controller.isUpdating,
                loadingMessage: 'Updating your profile...',
                backgroundColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameDisplay(ProfileController controller) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.nameController,
        builder: (_, value, _) => Center(
          child: AppText(
            data: value.text.isEmpty ? '—' : value.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            useResponsiveFontSize: true,
          ),
        ),
      );

  Widget _buildPositionDisplay(ProfileController controller) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.positionController,
        builder: (_, value, _) => Center(
          child: AppText(
            data: value.text.isEmpty ? '—' : value.text,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFBEBDBD),
            useResponsiveFontSize: true,
          ),
        ),
      );

  // Widget _buildChangeRigButton(
  //     BuildContext context, ProfileController controller) {
  //   return GestureDetector(
  //     onTap: () {
  //       AppNavigation.push(ClientRigSelectScreen());
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: context.responsiveSize(16),
  //         vertical: context.responsiveSize(7),
  //       ),
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [Color(0xFF0047AB), Color(0xFF0063E5)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(context.responsiveSize(20)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF0047AB).withOpacity(0.25),
  //             blurRadius: 8,
  //             offset: const Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.white),
  //           SizedBox(width: context.responsiveSize(6)),
  //           Text(
  //             controller.rigName.isNotEmpty
  //                 ? controller.rigName
  //                 : 'No Rig Assigned',
  //             style: TextStyle(
  //               fontSize: context.responsiveFontSize(12),
  //               fontWeight: FontWeight.w600,
  //               color: Colors.white,
  //               letterSpacing: 0.2,
  //             ),
  //           ),
  //           SizedBox(width: context.responsiveSize(6)),
  //           const Icon(Icons.keyboard_arrow_down_rounded,
  //               size: 14, color: Colors.white),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  List<Widget> _buildFormFields(
      BuildContext context, ProfileController controller) {
    final gap = SizedBox(height: context.responsiveSize(12));

    return [
      AppTextField(
        label: 'Name',
        controller: controller.nameController,
        hintText: 'Enter your name',
        elevation: 0,
        borderColor: const Color(0xFFBEBDBD),
        fillColor: Colors.white,
        inputTextColor: const Color(0xFF1A1A1A),
      ),
      gap,
      AppTextField(
        label: 'Email',
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        hintText: 'Enter your email',
        enabled: false,
        elevation: 0,
        borderColor: const Color(0xFFBEBDBD),
        fillColor: const Color(0xFFF5F5F5),
        inputTextColor: const Color(0xFF9E9E9E),
      ),
      gap,
      AppTextField(
        label: 'Company Name',
        controller: controller.companyController,
        hintText: 'Enter your company name',
        enabled: false,
        elevation: 0,
        borderColor: const Color(0xFFBEBDBD),
        fillColor: const Color(0xFFF5F5F5),
        inputTextColor: const Color(0xFF9E9E9E),
      ),
      gap,
      // AppTextField(
      //   label: 'Position ',
      //   controller: controller.positionController,
      //   hintText: 'Enter your company name',
      //   elevation: 0,
      //   borderColor: const Color(0xFFBEBDBD),
      //   fillColor: Colors.white,
      //   inputTextColor: const Color(0xFF1A1A1A),
      // ),
      gap,
      AppTextField(
        label: 'Position',
        controller: controller.positionController,
        hintText: 'Enter your position',
        elevation: 0,
        borderColor: const Color(0xFFBEBDBD),
        fillColor: Colors.white,
        inputTextColor: const Color(0xFF1A1A1A),
      ),
      gap,
      AppTextField(
        label: 'Phone',
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        hintText: 'Enter your phone number',
        elevation: 0,
        borderColor: const Color(0xFFBEBDBD),
        fillColor: Colors.white,
        inputTextColor: const Color(0xFF1A1A1A),
      ),
    ];
  }

  Widget _buildSaveButton(ProfileController controller) =>
      Obx(() => AppButton(
        buttonText: 'Save',
        onPressed: controller.saveProfile,
        fillColor: const Color(0xFF0047AB),
        textColor: Colors.white,
        isLoading: controller.isUpdating.value,
        loadingText: 'Saving...',
      ));

  Widget _buildLogoutButton(ProfileController controller) => AppButton(
    buttonText: 'Log out',
    onPressed: controller.logout,
    fillColor: Colors.red,
    textColor: Colors.white,
  );

  Widget _buildFullScreenLoader(ProfileController controller) => Obx(() {
    if (!controller.isLoadingProfile.value) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0047AB)),
      ),
    );
  });

  Widget _buildProfileAvatar(
      BuildContext context, ProfileController controller) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Obx(() {
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
              backgroundImage:
              NetworkImage(controller.profileImageUrl.value!),
            );
          }
          return CircleAvatar(
            radius: context.responsiveSize(44),
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage:
            const AssetImage('assets/icons/profile_icon.png'),
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

}