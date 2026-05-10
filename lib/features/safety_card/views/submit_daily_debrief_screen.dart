import 'package:flutter/material.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/constants/app_colors.dart';
import 'package:get/get.dart';
import '../../../core/dropdown/searchable_multi_select_dropdown.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/progress_bar/app_progress_bar.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../notification/views/notifications_screen.dart';
import '../controllers/daily_debrief_controller.dart';
import '../widgets/submit_not_available.dart';

class SubmitDailyDebriefScreen extends StatelessWidget {
  SubmitDailyDebriefScreen({super.key});

  final appAssets = AppAssertImage.instance;
  final appColor = AppColors.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyDebriefController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body:RefreshIndicator(
        onRefresh: () {
          return controller.refreshCard();
        },
        child: SafeArea(child: Obx(() => controller.isCheckingSubmission.value
            ? Center(
          child: AppProgressBar(
            value: 0.0,
            style: ProgressBarStyle.circular,
            indeterminate: true,
          ),
        )
            : submitNotAvailable(controller,context),
        ),),
      ) ,
    );
  }

  Widget submitNotAvailable(DailyDebriefController controller, BuildContext context) {
    return Obx(() => controller.canSubmitToday.value
        ? cardUi(context, controller)
        : Center(child: SubmitNotAvailable()),);
  }
  Widget cardUi (BuildContext context,DailyDebriefController controller){
    return Stack(
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
                  Row(
                    children: [
                      Image.asset(
                        appAssets.submitDailyDebrief,
                        width: context.responsiveSize(36),
                        height: context.responsiveSize(36),
                      ),
                      SizedBox(width: context.responsiveSize(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              data: 'Submit Daily Debrief',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                              useResponsiveFontSize: true,
                            ),
                            AppText(
                              data: 'Capture insights instantly',
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
                          context: context,
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                          size: context.responsiveSize(30),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.responsiveSize(24)),

                  _buildLabel(context, 'Activity Name'),
                  SizedBox(height: context.responsiveSize(8)),
                  Obx(() {
                    if (controller.isLoadingDropdowns.value) {
                      return _buildDropdownSkeleton(context);
                    }
                    return SearchableMultiSelectDropdown(
                      hint: 'Select activity',
                      icon: '🛢️',
                      items: controller.activities.map((e) => e.name).toList(),
                      selectedItems: controller.selectedActivity.value != null
                          ? [controller.selectedActivity.value!.name]
                          : [],
                      multiSelect: false,
                      onChanged: (items) {
                        controller.selectedActivity.value = items.isNotEmpty
                            ? controller.activities
                            .firstWhere((e) => e.name == items.first)
                            : null;
                      },
                    );
                  }),

                  SizedBox(height: context.responsiveSize(20)),

                  _buildLabel(context, 'Type of Debrief'),
                  SizedBox(height: context.responsiveSize(8)),
                  Obx(() {
                    if (controller.isLoadingDropdowns.value) {
                      return _buildDropdownSkeleton(context);
                    }
                    return SearchableMultiSelectDropdown(
                      hint: 'Select type of debrief',
                      icon: '⚙️',
                      items: controller.debriefTypes.map((e) => e.name).toList(),
                      selectedItems: controller.selectedDebriefType.value != null
                          ? [controller.selectedDebriefType.value!.name]
                          : [],
                      multiSelect: false,
                      onChanged: (items) {
                        controller.selectedDebriefType.value = items.isNotEmpty
                            ? controller.debriefTypes
                            .firstWhere((e) => e.name == items.first)
                            : null;
                      },
                    );
                  }),

                  SizedBox(height: context.responsiveSize(20)),

                  _buildLabel(context, 'What Happened?'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextArea(
                    context,
                    controller: controller.whatHappenedController,
                    focusNode: controller.whatHappenedFocus,
                    hint: 'Short description of the event or observation...',
                    validator: controller.validateField,
                  ),

                  SizedBox(height: context.responsiveSize(20)),

                  _buildLabel(context, 'What Worked Well?'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextArea(
                    context,
                    controller: controller.whatWorkedWellController,
                    focusNode: controller.whatWorkedWellFocus,
                    hint: 'Capture positive practices or successful actions...',
                    validator: controller.validateField,
                  ),

                  SizedBox(height: context.responsiveSize(20)),

                  _buildLabel(context, 'What Could Be Improved?'),
                  SizedBox(height: context.responsiveSize(8)),
                  _buildTextArea(
                    context,
                    controller: controller.whatImprovedController,
                    focusNode: controller.whatImprovedFocus,
                    hint: 'Identify gaps or areas for improvement...',
                    validator: controller.validateField,
                  ),

                  SizedBox(height: context.responsiveSize(20)),

                  _buildToggleOptions(context, controller),

                  SizedBox(height: context.responsiveSize(24)),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          buttonText: 'Reset',
                          onPressed: controller.resetForm,
                          fillColor: const Color(0xffE6ECF5),
                          textColor: const Color(0xFF0047AB),
                          borderColor: const Color(0xFF0047AB),
                          borderWidth: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          buttonHeight: context.heightPercentage(6),
                          borderRadius: 25,
                        ),
                      ),
                      SizedBox(width: context.responsiveSize(12)),
                      Expanded(
                        child: Obx(
                              () => AppButton(
                            buttonText: 'Submit Card',
                            onPressed: () =>
                                controller.submitDebrief(context),
                            fillColor: const Color(0xFF0047AB),
                            textColor: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            buttonHeight: context.heightPercentage(6),
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

          Obx(
                () => controller.isSubmitting.value
                ? AppButton.buildLoadingOverlay(
              isLoading: controller.isSubmitting,
              loadingMessage: 'Submitting debrief...',
              backgroundColor: Colors.black,
            )
                : const SizedBox.shrink(),
          ),
        ],
      );

  }

  Widget _buildLabel(BuildContext context, String text) {
    return AppText(
      data: text,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: appColor.normalTextColor,
      useResponsiveFontSize: true,
    );
  }

  Widget _buildDropdownSkeleton(BuildContext context) {
    return Container(
      height: context.responsiveSize(52),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(context.responsiveSize(8)),
      ),
    );
  }

  Widget _buildTextArea(
      BuildContext context, {
        required TextEditingController controller,
        required FocusNode focusNode,
        required String hint,
        required String? Function(String?) validator,
      }) {
    return Container(
      height: context.responsiveSize(120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(8)),
        border: Border.all(color: const Color(0xffCBD5E1), width: 1.5),
      ),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            validator: validator,
            style: TextStyle(
              fontSize: context.responsiveFontSize(14),
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: hint,
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
              onTap: () => CustomSnackBar.info('Voice input coming soon!'),
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

  Widget _buildToggleOptions(
      BuildContext context, DailyDebriefController controller) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF5),
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
      ),
      child: _buildToggleRow(
        context,
        title: 'Submit Anonymously',
        subtitle: 'Your identity will be hidden from reports',
        value: controller.submitAnonymously,
        activeColor: const Color(0xFF0047AB),
      ),
    );
  }

  Widget _buildToggleRow(
      BuildContext context, {
        required String title,
        required String subtitle,
        required RxBool value,
        required Color activeColor,
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
            onTap: () => value.value = !value.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: context.responsiveSize(56),
              height: context.responsiveSize(32),
              decoration: BoxDecoration(
                color: value.value ? activeColor : inactiveColor,
                borderRadius:
                BorderRadius.circular(context.responsiveSize(16)),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: value.value ? null : context.responsiveSize(32),
                    right: value.value ? context.responsiveSize(32) : null,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: AppText(
                        data: value.value ? 'Yes' : 'No',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        useResponsiveFontSize: false,
                      ),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: value.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: context.responsiveSize(28),
                      height: context.responsiveSize(28),
                      margin: EdgeInsets.symmetric(
                          horizontal: context.responsiveSize(2)),
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