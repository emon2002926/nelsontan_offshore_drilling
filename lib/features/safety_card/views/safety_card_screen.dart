// features/safety_card/presentation/safety_card_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/widgets/app_bar/build_app_bar.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/dashed_border_painter.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/safety_card_controller.dart';

class SafetyCardScreen extends StatelessWidget {
   SafetyCardScreen({super.key});

  final appAssets = AppAssertImage.instance;
  final appColor = AppColors.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SafetyCardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: context.widthPercentage(5),
                right: context.widthPercentage(5),
                top: context.heightPercentage(4),
                bottom: context.heightPercentage(3),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          child: Image.asset(
                            appAssets.topHeaderIcon,
                            width: context.responsiveSize(36),
                            height: context.responsiveSize(36),
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: context.responsiveSize(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                data: 'Submit UAUC / STOP Card',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                useResponsiveFontSize: true,
                              ),
                              AppText(
                                data: 'Report safety observations quickly',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B6B6B),
                                useResponsiveFontSize: true,
                              ),
                            ],
                          ),
                        ),

                          Icon(
                            Icons.notifications_none,
                            color: Colors.black,
                            size: context.responsiveSize(30),

                        )
                      ],
                    ),

                    SizedBox(height: context.responsiveSize(24)),

                    // Card Type Dropdown
                    _buildLabel(context, 'Card Type'),
                    SizedBox(height: context.responsiveSize(8)),
                    Obx(() => _buildDropdown(
                      context,
                      value: controller.selectedCardType.value,
                      hint: 'Select card type',
                      icon: '✋',
                      items: controller.cardTypes,
                      onChanged: (value) => controller.selectedCardType.value = value,
                    )),

                    SizedBox(height: context.responsiveSize(20)),

                    // Area of Observation Dropdown
                    _buildLabel(context, 'Area of Observation'),
                    SizedBox(height: context.responsiveSize(8)),
                    Obx(() => _buildDropdown(
                      context,
                      value: controller.selectedArea.value,
                      hint: 'Select area',
                      icon: '📍',
                      items: controller.areas,
                      onChanged: (value) => controller.selectedArea.value = value,
                    )),

                    SizedBox(height: context.responsiveSize(20)),

                    // Hazard Categories
                    _buildLabel(context, 'Hazard Categories'),
                    SizedBox(height: context.responsiveSize(12)),
                    Obx(() => _buildHazardCategories(context, controller)),

                    SizedBox(height: context.responsiveSize(20)),

                    // Description
                    _buildLabel(context, 'Description'),
                    SizedBox(height: context.responsiveSize(8)),
                    _buildDescriptionField(context, controller),

                    SizedBox(height: context.responsiveSize(20)),

                    // Risk Severity
                    _buildLabel(context, 'Risk Severity'),
                    SizedBox(height: context.responsiveSize(12)),
                    Obx(() => _buildRiskSeverity(context, controller)),

                    SizedBox(height: context.responsiveSize(20)),

                    // Photo/Video Evidence
                    _buildLabel(context, 'Photo / Video Evidence'),
                    SizedBox(height: context.responsiveSize(12)),
                    Obx(() => _buildPhotoUpload(context, controller)),

                    SizedBox(height: context.responsiveSize(20)),

                    // Toggle Options
                    _buildToggleOptions(context, controller),

                    SizedBox(height: context.responsiveSize(24)),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            buttonText: 'Reset',
                            onPressed: controller.resetForm,
                            fillColor: const Color(0xffE6ECF5),
                            textColor: const Color(0xFF0047AB),
                            borderColor: const Color(0xFF0047AB),
                            borderWidth: 1.5,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            buttonHeight: context.heightPercentage(5),
                            borderRadius: 25,
                          ),
                        ),
                        SizedBox(width: context.responsiveSize(12)),
                        Expanded(
                          flex: 2,
                          child: Obx(
                                () => AppButton(
                              buttonText: 'Submit Card',
                              onPressed: () => controller.submitSafetyCard(context),
                              fillColor: const Color(0xFF0047AB),
                              textColor: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              buttonHeight: context.heightPercentage(5),
                              isLoading: controller.isSubmitting.value,
                              loadingText: 'Submitting...',
                                  borderRadius: 25,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.responsiveSize(40)),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            Obx(
                  () => controller.isSubmitting.value
                  ? AppButton.buildLoadingOverlay(
                isLoading: controller.isSubmitting,
                loadingMessage: 'Submitting safety card...',
                backgroundColor: Colors.black,
                cardColor: Colors.white,
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return AppText(
      data: text,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.instance.normalTextColor,
      useResponsiveFontSize: true,
    );
  }

  Widget _buildDropdown(
      BuildContext context, {
        required String? value,
        required String hint,
        required String icon,
        required List<String> items,
        required Function(String?) onChanged,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16),
        vertical: context.responsiveSize(0),
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(6)),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: context.responsiveFontSize(20)),
              ),
              SizedBox(width: context.responsiveSize(12)),
              AppText(
                data: hint,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9E9E9E),
                useResponsiveFontSize: true,
              ),
            ],
          ),
          icon: const Icon(Icons.arrow_drop_down_outlined,size: 30, color: Color(0xFF6B6B6B)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Text(
                    icon,
                    style: TextStyle(fontSize: context.responsiveFontSize(20)),
                  ),
                  SizedBox(width: context.responsiveSize(12)),
                  AppText(
                    data: item,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1A1A),
                    useResponsiveFontSize: true,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHazardCategories(BuildContext context, SafetyCardController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.hazardCategories.map((category) {
          final isSelected = controller.selectedHazardCategory.value == category['label'];
          return Padding(
            padding: EdgeInsets.only(right: context.responsiveSize(12)),
            child: GestureDetector(
              onTap: () {
                controller.selectedHazardCategory.value = category['label'];
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(16),
                    vertical: context.responsiveSize(4)),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0047AB) : Colors.white,
                  borderRadius:  BorderRadius.circular(context.responsiveSize(25)),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0047AB) : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category['icon'],
                      style: TextStyle(fontSize: context.responsiveFontSize(18)),
                    ),
                    SizedBox(width: context.responsiveSize(8)),
                    AppText(
                      data: category['label'],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                      useResponsiveFontSize: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

   Widget _buildDescriptionField(BuildContext context, SafetyCardController controller) {
     return Container(
       height: context.responsiveSize(120 ), // Fixed height
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(context.responsiveSize(8)),
         border: Border.all(
           color: const Color(0xffCBD5E1),
           width: 1.5,
         ),
       ),
       child: Stack(
         children: [
           TextFormField(
             controller: controller.descriptionController,
             focusNode: controller.descriptionFocus,
             maxLines: null, // Unlimited lines
             expands: true, // Expands to fill the container height
             textAlignVertical: TextAlignVertical.top, // Align text to top
             validator: controller.validateDescription,
             style: TextStyle(
               fontSize: context.responsiveFontSize(14),
               color: const Color(0xFF1A1A1A),
             ),
             decoration: InputDecoration(
               hintText: 'Describe what you observed in detail...',
               hintStyle: TextStyle(
                 fontSize: context.responsiveFontSize(14),
                 color: appColor.hintTextColor,
               ),
               contentPadding: EdgeInsets.all(context.responsiveSize(16)),
               border: InputBorder.none,
             ),
           ),
           Positioned(
             bottom: context.responsiveSize(12),
             right: context.responsiveSize(12),
             child: GestureDetector(
               onTap: () {
                 // TODO: Implement voice input
                 CustomSnackBar.info('Voice input coming soon!');
               },
               child: Container(
                 padding: EdgeInsets.all(context.responsiveSize(8)),
                 decoration: const BoxDecoration(
                   color: Color(0xFF0047AB),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   Icons.mic_none,
                   color: Colors.white,
                   size: context.responsiveSize(20),
                 ),
               ),
             ),
           ),
         ],
       ),
     );
   }
  Widget _buildRiskSeverity(BuildContext context, SafetyCardController controller) {
    return Row(
      children: controller.riskSeverities.map((severity) {
        final isSelected = controller.selectedRiskSeverity.value == severity;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: severity != controller.riskSeverities.last
                  ? context.responsiveSize(12)
                  : 0,
            ),
            child: GestureDetector(
              onTap: () {
                controller.selectedRiskSeverity.value = severity;
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.responsiveSize(6)),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0047AB) : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.responsiveSize(20),
                      height: context.responsiveSize(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0047AB) : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Container(
                          width: context.responsiveSize(10),
                          height: context.responsiveSize(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0047AB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                          : null,
                    ),
                    SizedBox(width: context.responsiveSize(8)),
                    AppText(
                      data: severity,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF0047AB) : const Color(0xFF6B6B6B),
                      useResponsiveFontSize: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

   Widget _buildPhotoUpload(BuildContext context, SafetyCardController controller) {
     return GestureDetector(
       onTap: () => controller.showPhotoOptions(context),
       child: CustomPaint(
         painter: DashedBorderPainter(
           color: const Color(0xffCBD5E1),
           strokeWidth: 1.5,
           dashWidth: context.responsiveSize(5),
           dashSpace: context.responsiveSize(3),
           borderRadius: context.responsiveSize(12),
         ),
         child: Container(
           width: double.infinity,
           padding: EdgeInsets.all(context.responsiveSize(32)),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(context.responsiveSize(12)),
           ),
           child: controller.uploadedPhotoPath.value != null
               ? Column(
             children: [
               ClipRRect(
                 borderRadius: BorderRadius.circular(context.responsiveSize(8)),
                 child: Image.file(
                   File(controller.uploadedPhotoPath.value!),
                   height: context.responsiveSize(150),
                   width: double.infinity,
                   fit: BoxFit.cover,
                 ),
               ),
               SizedBox(height: context.responsiveSize(12)),
               AppText(
                 data: 'Tap to change photo',
                 fontSize: 13,
                 fontWeight: FontWeight.w400,
                 color: const Color(0xFF6B6B6B),
                 useResponsiveFontSize: true,
               ),
             ],
           )
               : Column(
             children: [
               Icon(
                 Icons.cloud_upload_outlined,
                 size: context.responsiveSize(48),
                 color: const Color(0xFF0047AB),
               ),
               SizedBox(height: context.responsiveSize(12)),
               AppText(
                 data: 'Tap to capture or upload',
                 fontSize: 15,
                 fontWeight: FontWeight.w500,
                 color: const Color(0xFF1A1A1A),
                 useResponsiveFontSize: true,
               ),
               SizedBox(height: context.responsiveSize(4)),
               AppText(
                 data: 'JPG, PNG, MP4 (max 10MB)',
                 fontSize: 13,
                 fontWeight: FontWeight.w400,
                 color: const Color(0xFF9E9E9E),
                 useResponsiveFontSize: true,
               ),
             ],
           ),
         ),
       ),
     );
   }
  Widget _buildToggleOptions(BuildContext context, SafetyCardController controller) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF5),
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            context,
            title: 'Action Taken',
            subtitle: 'Was corrective action taken on the spot?',
            value: controller.actionTaken,
            activeColor:  const Color(0xFF0047AB),
            inactiveColor: Colors.red
          ),
          Divider(height: context.responsiveSize(24), color: const Color(0xFFE0E0E0)),
          _buildToggleRow(
            context,
            title: 'Immediate Action Required',
            subtitle: 'Does this require urgent attention from HSE?',
            value: controller.immediateActionRequired,
            activeColor: const Color(0xFF0047AB),
            inactiveColor: Colors.red
          ),
          Divider(height: context.responsiveSize(24), color: const Color(0xFFE0E0E0)),
          _buildToggleRow(
            context,
            title: 'Submit Anonymously',
            subtitle: 'Your identity will be hidden from reports',
            value: controller.submitAnonymously,
            activeColor: Colors.grey,
          ),
        ],
      ),
    );
  }


   Widget _buildToggleRow(
       BuildContext context, {
         required String title,
         required String subtitle,
         required RxBool value,
         required Color activeColor,
         Color inactiveColor = const Color(0xFFB0C4DE), // Light blue-gray like screenshot
       }) {
     return Obx(
           () => Row(
         children: [
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 AppText(
                   data: title,
                   fontSize: 15,
                   fontWeight: FontWeight.w600,
                   color: const Color(0xFF1A1A1A),
                   useResponsiveFontSize: true,
                 ),
                 SizedBox(height: context.responsiveSize(4)),
                 AppText(
                   data: subtitle,
                   fontSize: 13,
                   fontWeight: FontWeight.w400,
                   color: const Color(0xFF6B6B6B),
                   useResponsiveFontSize: true,
                 ),
               ],
             ),
           ),
           SizedBox(width: context.responsiveSize(12)),
           GestureDetector(
             onTap: () {
               value.value = !value.value;
             },
             child: Container(
               width: context.responsiveSize(56), // Slightly wider
               height: context.responsiveSize(32), // Slightly taller
               decoration: BoxDecoration(
                 color: value.value ? activeColor : inactiveColor,
                 borderRadius: BorderRadius.circular(context.responsiveSize(16)), // More rounded
               ),
               child: Stack(
                 children: [
                   // Text label inside toggle
                   AnimatedPositioned(
                     duration: const Duration(milliseconds: 200),
                     left: value.value ? null : context.responsiveSize(32),
                     right: value.value ? context.responsiveSize(32) : null,
                     top: 0,
                     bottom: 0,
                     child: Center(
                       child: AppText(
                         data: value.value ? 'Yes' : 'No',
                         fontSize: 10, // Larger text
                         fontWeight: FontWeight.w600,
                         color: Colors.white,
                         useResponsiveFontSize: false,
                       ),
                     ),
                   ),
                   // Animated thumb (white circle)
                   AnimatedAlign(
                     duration: const Duration(milliseconds: 200),
                     curve: Curves.easeInOut,
                     alignment: value.value ? Alignment.centerRight : Alignment.centerLeft,
                     child: Container(
                       width: context.responsiveSize(28),
                       height: context.responsiveSize(28),
                       margin: EdgeInsets.symmetric(horizontal: context.responsiveSize(2)),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 4,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         ],
       ),
     );
   }


}