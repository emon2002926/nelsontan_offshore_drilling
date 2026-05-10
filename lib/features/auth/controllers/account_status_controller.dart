import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'client_rig_select_controller.dart';

enum AccountStatus { pending, inactive, suspended, deleted }

class AccountStatusController extends GetxController {
  final AccountStatus status;

  AccountStatusController({required this.status});

  final checkStatus = Get.find<ClientRigSelectController>();


  @override
  void onInit() {
    super.onInit();
    checkStatus.getStatusUpdate();
  }


  StatusConfig get config => switch (status) {
    AccountStatus.pending => StatusConfig(
      icon: Icons.hourglass_top_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Account Pending',
      message:
      'Your account is under review. Our team will approve it shortly. You will be notified once the process is complete.',
    ),
    AccountStatus.inactive => StatusConfig(
      icon: Icons.block_rounded,
      iconColor: const Color(0xFF6B7280),
      title: 'Account Inactive',
      message:
      'Your account is currently inactive. '
          'Please contact support to reactivate your account.',
    ),
    AccountStatus.suspended => StatusConfig(
      icon: Icons.gpp_bad_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Account Suspended',
      message:
      'Your account has been suspended due to a policy violation. '
          'Please contact support for further assistance.',
    ),
    AccountStatus.deleted => StatusConfig(
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Account Deleted',
      message:
      'This account no longer exists. '
          'If you believe this is a mistake, please contact support.',
    ),
  };
}

class StatusConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const StatusConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });
}