import 'package:flutter/material.dart';

import '../../../core/util/app_navigation.dart';
import '../../../home_page.dart';
import '../controllers/account_status_controller.dart';
import '../views/account_status_screen.dart';
import '../views/client_rig_select_screen.dart';

class StatusChecker {
  static void navigate(String status) {
    final page = _getPage(status);

    if (page != null) {
      AppNavigation.pushAndClear(page);
    }
  }

  static Widget? _getPage(String status) {
    switch (status) {
      case "PENDING":
        return AccountStatusScreen(
          status: AccountStatus.pending,
        );

      case "ACTIVE":
        return BasePage();

      case "REJECTED":
        return AccountStatusScreen(
          status: AccountStatus.suspended,
        );

      case "INACTIVE":
        return AccountStatusScreen(
          status: AccountStatus.inactive,
        );

      case "DELETED":
        return AccountStatusScreen(
          status: AccountStatus.deleted,
        );

      case "NOT_SUBMITTED":
        return ClientRigSelectScreen();

      default:
        return null;
    }
  }
}