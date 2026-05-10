import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/client_rig_select_controller.dart';
import '../models/client_rig_model.dart';

class ClientRigSelectScreen extends StatelessWidget {
  const ClientRigSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<ClientRigSelectController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.responsiveSize(10)),

                    Center(
                      child: Image.asset(
                        AppAssertImage.instance.appLogo,
                        width: context.responsiveSize(280),
                        height: context.responsiveSize(100),
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: context.responsiveSize(60)),

                    AppText(
                      data: 'Client',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(8)),

                    Obx(() => _RigDropdown<ClientModel>(
                      hint: 'Select Client',
                      value: controller.selectedClient.value,
                      items: controller.clients.toList(),
                      itemLabel: (c) => c.name,
                      onChanged: controller.onClientChanged,
                    )),

                    SizedBox(height: context.responsiveSize(24)),

                    AppText(
                      data: 'Rig Name',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                      useResponsiveFontSize: true,
                    ),

                    SizedBox(height: context.responsiveSize(8)),

                    Obx(() => _RigDropdown<RigModel>(
                      hint: controller.selectedClient.value == null
                          ? 'Select a client first'
                          : 'Select Rig',
                      value: controller.selectedRig.value,
                      items: controller.rigs.toList(),
                      itemLabel: (r) => r.name,
                      onChanged: controller.selectedClient.value == null
                          ? null
                          : controller.onRigChanged,
                    )),

                    SizedBox(height: context.responsiveSize(60)),

                    Obx(() => AppButton(
                      buttonText: 'Request',
                      onPressed: controller.submitRequest,
                      fillColor: const Color(0xFF0047AB),
                      textColor: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      buttonHeight: 50,
                      isLoading: controller.isSubmitting.value,
                      loadingText: 'Submitting...',
                    )),

                    SizedBox(height: context.responsiveSize(40)),
                  ],
                ),
              ),

              Obx(() {
                if (!controller.isLoadingData.value) return const SizedBox.shrink();
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0047AB),
                    ),
                  ),
                );
              }),

              AppButton.buildLoadingOverlay(
                isLoading: controller.isSubmitting,
                loadingMessage: 'Submitting your request...',
                backgroundColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RigDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  const _RigDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: AppText(
            data: hint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9E9E9E),
            useResponsiveFontSize: true,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: onChanged == null
                ? const Color(0xFFBDBDBD)
                : const Color(0xFF0047AB),
            size: context.responsiveSize(24),
          ),
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          ))
              .toList(),
        ),
      ),
    );
  }
}