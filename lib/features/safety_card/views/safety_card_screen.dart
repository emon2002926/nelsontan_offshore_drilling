import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/features/notification/views/notifications_screen.dart';
import 'package:nelsontan_offshore_drilling/features/safety_card/widgets/submit_not_available.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/dropdown/searchable_multi_select_dropdown.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/dashed_border_painter.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/progress_bar/app_progress_bar.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/safety_card_controller.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class SafetyCardScreen extends StatelessWidget {
  SafetyCardScreen({super.key});

  final appAssets = AppAssertImage.instance;
  final appColor  = AppColors.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SafetyCardController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() => controller.isCheckingSubmission.value
            ? Center(
              child: AppProgressBar(
                        value: 0.0, // ignored
                        style: ProgressBarStyle.circular,
                        indeterminate: true,
                      ),
            )
            : submitNotAvailable(controller,context),
        ),
      ),
    );
  }

  Widget submitNotAvailable(SafetyCardController controller , BuildContext context) {
    return Obx(()=> controller.canSubmitToday.value
        ?cardUi(context, controller)
        :Center(child: SubmitNotAvailable()),
    );
  }

  Widget cardUi(BuildContext context,SafetyCardController controller ){
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left:   context.widthPercentage(5),
            right:  context.widthPercentage(5),
            top:    context.heightPercentage(4),
            bottom: context.heightPercentage(3),
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      appAssets.topHeaderIcon,
                      width:  context.responsiveSize(36),
                      height: context.responsiveSize(36),
                      colorBlendMode: BlendMode.srcIn,
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
                    GestureDetector(
                      onTap: () => AppNavigation.push(
                          NotificationsScreen(),
                          context: context),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                        size: context.responsiveSize(30),
                      ),
                    ),
                  ],
                ),


                Obx(() {
                  final connectivity = Get.find<ConnectivityService>();
                  final sync         = Get.find<SyncService>();

                  if (sync.isSyncing.value) {
                    return _buildBanner(
                      context,
                      color:   const Color(0xFF0047AB),
                      icon:    Icons.sync,
                      message: 'Syncing ${sync.pendingCount.value} pending card(s)…',
                    );
                  }
                  if (!connectivity.isOnline.value && sync.pendingCount.value > 0) {
                    return _buildBanner(
                      context,
                      color:   const Color(0xFFF59E0B),
                      icon:    Icons.cloud_off,
                      message: 'Offline — ${sync.pendingCount.value} card(s) queued to sync',
                    );
                  }
                  if (!connectivity.isOnline.value) {
                    return _buildBanner(
                      context,
                      color:   const Color(0xFFF59E0B),
                      icon:    Icons.cloud_off,
                      message: 'You\'re offline. Submissions will be saved locally.',
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(height: context.responsiveSize(12)),

                SizedBox(height: context.responsiveSize(24)),

                _buildLabel(context, 'Card Type'),
                SizedBox(height: context.responsiveSize(8)),
                Obx(() {
                  if (controller.isLoadingDropdowns.value) {
                    return _buildDropdownSkeleton(context);
                  }
                  return SearchableMultiSelectDropdown(
                    hint: 'Select card type',
                    icon: '✋',
                    items: controller.cardTypes.map((e) => e.name).toList(),
                    selectedItems: controller.selectedCardType.value != null
                        ? [controller.selectedCardType.value!.name]
                        : [],
                    multiSelect: false,
                    onChanged: (items) {
                      controller.selectedCardType.value = items.isNotEmpty
                          ? controller.cardTypes
                          .firstWhere((e) => e.name == items.first)
                          : null;
                    },
                  );
                }),

                SizedBox(height: context.responsiveSize(20)),

                _buildLabel(context, 'Area of Observation'),
                SizedBox(height: context.responsiveSize(8)),
                Obx(() {
                  if (controller.isLoadingDropdowns.value) {
                    return _buildDropdownSkeleton(context);
                  }
                  return SearchableMultiSelectDropdown(
                    hint: 'Select area',
                    icon: '📍',
                    items: controller.areas.map((e) => e.name).toList(),
                    selectedItems: controller.selectedArea.value != null
                        ? [controller.selectedArea.value!.name]
                        : [],
                    multiSelect: false,
                    onChanged: (items) {
                      controller.selectedArea.value = items.isNotEmpty
                          ? controller.areas
                          .firstWhere((e) => e.name == items.first)
                          : null;
                    },
                  );
                }),

                SizedBox(height: context.responsiveSize(20)),


                _buildLabel(context, 'Hazard Categories'),
                SizedBox(height: context.responsiveSize(12)),
                Obx(() => _buildHazardCategories(context, controller)),

                SizedBox(height: context.responsiveSize(20)),

                _buildLabel(context, 'Description'),
                SizedBox(height: context.responsiveSize(8)),
                _buildDescriptionField(context, controller),

                SizedBox(height: context.responsiveSize(20)),

                _buildLabel(context, 'Risk Severity'),
                SizedBox(height: context.responsiveSize(12)),
                Obx(() => _buildRiskSeverity(context, controller)),

                SizedBox(height: context.responsiveSize(20)),

                _buildLabel(context, 'Photo / Video Evidence'),
                SizedBox(height: context.responsiveSize(12)),
                Obx(() => _buildPhotoUpload(context, controller)),

                SizedBox(height: context.responsiveSize(20)),

                _buildToggleOptions(context, controller),

                SizedBox(height: context.responsiveSize(24)),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        buttonText: 'Reset',
                        onPressed:  controller.resetForm,
                        fillColor:  const Color(0xffE6ECF5),
                        textColor:  const Color(0xFF0047AB),
                        borderColor: const Color(0xFF0047AB),
                        borderWidth: 1.5,
                        fontSize:   16,
                        fontWeight: FontWeight.w600,
                        buttonHeight: context.heightPercentage(6),
                        borderRadius: 25,
                      ),
                    ),
                    SizedBox(width: context.responsiveSize(12)),
                    Expanded(
                      flex: 2,
                      child: Obx(
                            () => AppButton(
                          buttonText:   'Submit Card',
                          onPressed:    () => controller.submitSafetyCard(context),
                          fillColor:    const Color(0xFF0047AB),
                          textColor:    Colors.white,
                          fontSize:     16,
                          fontWeight:   FontWeight.w600,
                          buttonHeight: context.heightPercentage(6),
                          isLoading:    controller.isSubmitting.value,
                          loadingText:  'Submitting...',
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

        Obx(
              () => controller.isSubmitting.value
              ? AppButton.buildLoadingOverlay(
            isLoading:       controller.isSubmitting,
            loadingMessage:  'Submitting safety card...',
            backgroundColor: Colors.black,
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }


  Widget _buildBanner(
      BuildContext context, {
        required Color  color,
        required IconData icon,
        required String message,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(12),
        vertical:   context.responsiveSize(10),
      ),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.responsiveSize(8)),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: context.responsiveSize(18)),
          SizedBox(width: context.responsiveSize(8)),
          Expanded(
            child: AppText(
              data:                message,
              fontSize:            13,
              fontWeight:          FontWeight.w500,
              color:               color,
              useResponsiveFontSize: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return AppText(
      data:                text,
      fontSize:            16,
      fontWeight:          FontWeight.w600,
      color:               AppColors.instance.normalTextColor,
      useResponsiveFontSize: true,
    );
  }

  Widget _buildDropdownSkeleton(BuildContext context) {
    return Container(
      height: context.responsiveSize(52),
      decoration: BoxDecoration(
        color:        Colors.grey.shade200,
        borderRadius: BorderRadius.circular(context.responsiveSize(8)),
      ),
    );
  }

  Widget _buildHazardCategories(
      BuildContext context, SafetyCardController controller) {
    if (controller.isLoadingDropdowns.value) {
      return _buildDropdownSkeleton(context);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.hazards.map((hazard) {
          final isSelected = controller.selectedHazards.contains(hazard);
          return Padding(
            padding: EdgeInsets.only(right: context.responsiveSize(12)),
            child: GestureDetector(
              onTap: () {
                if (isSelected) {
                  controller.selectedHazards.remove(hazard);
                } else {
                  controller.selectedHazards.add(hazard);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(16),
                  vertical:   context.responsiveSize(4),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0047AB)
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(context.responsiveSize(25)),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0047AB)
                        : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      controller.hazardIcon(hazard.name),
                      style:
                      TextStyle(fontSize: context.responsiveFontSize(18)),
                    ),
                    SizedBox(width: context.responsiveSize(8)),
                    AppText(
                      data:                hazard.name,
                      fontSize:            14,
                      fontWeight:          FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
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

  Widget _buildDescriptionField(
      BuildContext context, SafetyCardController controller) {
    return Obx(() {
      final isListening = controller.isListening.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text area
          Container(
            height: context.responsiveSize(120),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(context.responsiveSize(8)),
              border: Border.all(
                // Border turns blue while recording
                color: isListening
                    ? const Color(0xFF0047AB)
                    : const Color(0xffCBD5E1),
                width: isListening ? 2.0 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                TextFormField(
                  controller:       controller.descriptionController,
                  focusNode:        controller.descriptionFocus,
                  maxLines:         null,
                  expands:          true,
                  textAlignVertical: TextAlignVertical.top,
                  validator:        controller.validateDescription,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                    color:    const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: isListening
                        ? 'Listening…'
                        : 'Describe what you observed in detail...',
                    hintStyle: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      color: isListening
                          ? const Color(0xFF0047AB)
                          : appColor.hintTextColor,
                    ),
                    contentPadding:
                    EdgeInsets.all(context.responsiveSize(16)),
                    border: InputBorder.none,
                  ),
                ),

                Positioned(
                  bottom: context.responsiveSize(10),
                  right:  context.responsiveSize(10),
                  child: GestureDetector(
                    onTap: controller.toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width:  context.responsiveSize(36),
                      height: context.responsiveSize(36),
                      decoration: BoxDecoration(
                        // Red while recording, brand-blue otherwise
                        color: isListening
                            ? Colors.red
                            : const Color(0xFF0047AB),
                        shape: BoxShape.circle,
                        boxShadow: isListening
                            ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius:   8,
                            spreadRadius: 2,
                          ),
                        ]
                            : [],
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size:  context.responsiveSize(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isListening) ...[
            SizedBox(height: context.responsiveSize(6)),
            Row(
              children: [
                _PulsingDot(size: context.responsiveSize(8)),
                SizedBox(width: context.responsiveSize(6)),
                AppText(
                  data:                'Listening… tap mic to stop',
                  fontSize:            12,
                  fontWeight:          FontWeight.w400,
                  color:               const Color(0xFF0047AB),
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildRiskSeverity(
      BuildContext context, SafetyCardController controller) {
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
              onTap: () =>
              controller.selectedRiskSeverity.value = severity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                    vertical: context.responsiveSize(8)),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(context.responsiveSize(6)),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0047AB)
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width:  context.responsiveSize(20),
                      height: context.responsiveSize(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0047AB)
                              : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Container(
                          width:  context.responsiveSize(10),
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
                      data:       severity,
                      fontSize:   15,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0047AB)
                          : const Color(0xFF6B6B6B),
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

  Widget _buildPhotoUpload(
      BuildContext context, SafetyCardController controller) {
    return GestureDetector(
      onTap: () => controller.showPhotoOptions(context),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color:        const Color(0xffCBD5E1),
          strokeWidth:  1.5,
          dashWidth:    context.responsiveSize(5),
          dashSpace:    context.responsiveSize(3),
          borderRadius: context.responsiveSize(12),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.responsiveSize(32)),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveSize(12)),
          ),
          child: controller.uploadedPhotoPath.value != null
              ? Column(
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.circular(context.responsiveSize(8)),
                child: Image.file(
                  File(controller.uploadedPhotoPath.value!),
                  height: context.responsiveSize(150),
                  width:  double.infinity,
                  fit:    BoxFit.cover,
                ),
              ),
              SizedBox(height: context.responsiveSize(12)),
              AppText(
                data:                'Tap to change photo',
                fontSize:            13,
                fontWeight:          FontWeight.w400,
                color:               const Color(0xFF6B6B6B),
                useResponsiveFontSize: true,
              ),
            ],
          )
              : Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size:  context.responsiveSize(48),
                  color: const Color(0xFF0047AB)),
              SizedBox(height: context.responsiveSize(12)),
              AppText(
                data:                'Tap to capture or upload',
                fontSize:            15,
                fontWeight:          FontWeight.w500,
                color:               const Color(0xFF1A1A1A),
                useResponsiveFontSize: true,
              ),
              SizedBox(height: context.responsiveSize(4)),
              AppText(
                data:                'JPG, PNG, MP4 (max 10MB)',
                fontSize:            13,
                fontWeight:          FontWeight.w400,
                color:               const Color(0xFF9E9E9E),
                useResponsiveFontSize: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOptions(
      BuildContext context, SafetyCardController controller) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      decoration: BoxDecoration(
        color:        const Color(0xFFE6ECF5),
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            context,
            title:         'Action Taken',
            subtitle:      'Was corrective action taken on the spot?',
            value:         controller.actionTaken,
            activeColor:   const Color(0xFF0047AB),
            inactiveColor: Colors.red,
          ),
          Divider(
              height: context.responsiveSize(24),
              color:  const Color(0xFFE0E0E0)),
          _buildToggleRow(
            context,
            title:       'Immediate Action Required',
            subtitle:    'Does this require urgent attention from HSE?',
            value:       controller.immediateActionRequired,
            activeColor: const Color(0xFF0047AB),
          ),
          Divider(
              height: context.responsiveSize(24),
              color:  const Color(0xFFE0E0E0)),
          _buildToggleRow(
            context,
            title:       'Submit Anonymously',
            subtitle:    'Your identity will be hidden from reports',
            value:       controller.submitAnonymously,
            activeColor: const Color(0xFF0047AB),
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
        required Color  activeColor,
        Color inactiveColor = const Color(0xFFB0C4DE),
      }) {
    return Obx(
          () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  data:                title,
                  fontSize:            15,
                  fontWeight:          FontWeight.w600,
                  color:               const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(4)),
                AppText(
                  data:                subtitle,
                  fontSize:            13,
                  fontWeight:          FontWeight.w400,
                  color:               const Color(0xFF6B6B6B),
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          ),
          SizedBox(width: context.responsiveSize(12)),
          GestureDetector(
            onTap: () => value.value = !value.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  context.responsiveSize(56),
              height: context.responsiveSize(32),
              decoration: BoxDecoration(
                color:        value.value ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(context.responsiveSize(16)),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left:   value.value ? null : context.responsiveSize(32),
                    right:  value.value ? context.responsiveSize(32) : null,
                    top:    0,
                    bottom: 0,
                    child: Center(
                      child: AppText(
                        data:                 value.value ? 'Yes' : 'No',
                        fontSize:             10,
                        fontWeight:           FontWeight.w600,
                        color:                Colors.white,
                        useResponsiveFontSize: false,
                      ),
                    ),
                  ),
                  AnimatedAlign(
                    duration:  const Duration(milliseconds: 200),
                    curve:     Curves.easeInOut,
                    alignment: value.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width:  context.responsiveSize(28),
                      height: context.responsiveSize(28),
                      margin: EdgeInsets.symmetric(
                          horizontal: context.responsiveSize(2)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset:     const Offset(0, 2),
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

class _PulsingDot extends StatefulWidget {
  final double size;
  const _PulsingDot({required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>    _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width:  widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}