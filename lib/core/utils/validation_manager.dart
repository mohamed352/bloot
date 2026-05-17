import 'package:easy_localization/easy_localization.dart';
import 'package:bloot/core/constants/app_constants.dart';
import 'package:bloot/generated/locale_keys.g.dart';

abstract class ValidationManager {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationEmailRequired.tr();
    }
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return LocaleKeys.validationEmailInvalid.tr();
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationPasswordRequired.tr();
    }
    if (value.length < AppConstants.minPasswordLength) {
      return LocaleKeys.validationPasswordMinLength.tr();
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationNameRequired.tr();
    }
    if (value.trim().length < AppConstants.minNameLength) {
      return LocaleKeys.validationNameMinLength.tr();
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationPhoneRequired.tr();
    }
    final String cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final RegExp saudiRegex = RegExp(r'^(\+966|966|05|5)\d{8}$');
    if (!saudiRegex.hasMatch(cleaned)) {
      return LocaleKeys.validationPhoneInvalid.tr();
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationFieldRequired.tr();
    }
    return null;
  }
}
