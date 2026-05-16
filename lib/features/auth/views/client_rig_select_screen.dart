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

  void _showBottomSheet(BuildContext context) {
    if (onChanged == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DropdownSheet<T>(
        items: items,
        itemLabel: itemLabel,
        selectedValue: value,
        onSelected: (selected) {
          Navigator.pop(context);
          onChanged?.call(selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    final hasValue = value != null;

    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFFF9F9F9) : Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveSize(14)),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF0047AB).withOpacity(0.4)
                : const Color(0xFFE8E8E8),
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: isDisabled
              ? []
              : [
            BoxShadow(
              color: const Color(0xFF0047AB).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(18),
          vertical: context.responsiveSize(16),
        ),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: context.responsiveSize(36),
              height: context.responsiveSize(36),
              decoration: BoxDecoration(
                color: isDisabled
                    ? const Color(0xFFF0F0F0)
                    : const Color(0xFF0047AB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(context.responsiveSize(10)),
              ),
              child: Icon(
                hasValue ? Icons.check_circle_outline_rounded : Icons.list_alt_rounded,
                size: context.responsiveSize(18),
                color: isDisabled
                    ? const Color(0xFFBDBDBD)
                    : hasValue
                    ? const Color(0xFF0047AB)
                    : const Color(0xFF0047AB).withOpacity(0.5),
              ),
            ),

            SizedBox(width: context.responsiveSize(12)),

            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasValue)
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(11),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0047AB).withOpacity(0.7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  if (hasValue) SizedBox(height: context.responsiveSize(2)),
                  Text(
                    hasValue ? itemLabel(value as T) : hint,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),

            // Trailing chevron
            Container(
              width: context.responsiveSize(28),
              height: context.responsiveSize(28),
              decoration: BoxDecoration(
                color: isDisabled
                    ? const Color(0xFFF0F0F0)
                    : const Color(0xFF0047AB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(context.responsiveSize(8)),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: context.responsiveSize(18),
                color: isDisabled
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF0047AB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────

class _DropdownSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _DropdownSheet({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_DropdownSheet<T>> createState() => _DropdownSheetState<T>();
}

class _DropdownSheetState<T> extends State<_DropdownSheet<T>> {
  late List<T> _filtered;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _search.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((i) => widget.itemLabel(i).toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0047AB).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.list_alt_rounded,
                    size: 18,
                    color: Color(0xFF0047AB),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select an option',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          if (widget.items.length > 5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EEFF)),
                ),
                child: TextField(
                  controller: _search,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF0047AB),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
            ),

          if (widget.items.length > 5) const SizedBox(height: 12),

          // Divider
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // Items list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: _filtered.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'No results found',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: Color(0xFFF5F5F5),
              ),
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final isSelected = item == widget.selectedValue;
                return GestureDetector(
                  onTap: () => widget.onSelected(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    color: isSelected
                        ? const Color(0xFF0047AB).withOpacity(0.05)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Color dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF0047AB)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.itemLabel(item),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF0047AB)
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Color(0xFF0047AB),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}