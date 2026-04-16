import 'package:flutter/cupertino.dart';

import '../widgets/snakbar/custom_snackbar.dart';

class FormValidator {
  FormValidator._();

  /// Validates a single field — shows snackbar and requests focus if invalid
  static bool validateField({
    required String value,
    required String errorMessage,
    FocusNode? focusNode,
  }) {
    if (value.isEmpty) {
      CustomSnackBar.error(errorMessage);
      focusNode?.requestFocus();
      return false;
    }
    return true;
  }

  /// Validates multiple fields in order — stops at first invalid field
  static bool validateAll(List<FormFieldEntry> fields) {
    for (final field in fields) {
      if (!validateField(
        value: field.value,
        errorMessage: field.errorMessage,
        focusNode: field.focusNode,
      )) {
        return false;
      }
    }
    return true;
  }

  /// Email format check
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Password length check
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    return true;
  }

/** Example usage:
 * if (!FormValidator.isValidPassword(password)) {
    final msg = password.length < 8
    ? 'Password must be at least 8 characters'
    : 'Password must contain at least one uppercase letter';
    CustomSnackBar.warning(msg);
    passwordFocusNode.requestFocus();
    return;
    }
 */
}

class FormFieldEntry {
  final String value;
  final String errorMessage;
  final FocusNode? focusNode;

  FormFieldEntry({
    required this.value,
    required this.errorMessage,
    this.focusNode,
  });
}