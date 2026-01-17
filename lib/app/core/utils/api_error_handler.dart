import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';

/// Validation error model from backend
class ValidationError {
  final String errorCode;
  final String? fieldValue;
  final String fieldName;

  ValidationError({
    required this.errorCode,
    this.fieldValue,
    required this.fieldName,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      errorCode: json['errorCode'] ?? '',
      fieldValue: json['fieldValue'],
      fieldName: json['filedName'] ?? json['fieldName'] ?? 'general',
    );
  }
}

/// Generic API error response handler
class ApiErrorHandler {
  /// Handle validation errors from backend (400 status)
  /// Returns a map of field names to error messages
  static Map<String, String> handleValidationErrors(
    Map<String, dynamic>? responseBody,
  ) {
    final fieldErrors = <String, String>{};

    if (responseBody == null) return fieldErrors;

    if (responseBody['errors'] != null && responseBody['errors'] is List) {
      final errors = (responseBody['errors'] as List)
          .map((e) => ValidationError.fromJson(e))
          .toList();

      for (var error in errors) {
        final errorMessage = _getErrorMessage(
          error.errorCode,
          error.fieldValue,
        );
        fieldErrors[error.fieldName.toLowerCase()] = errorMessage;
      }

      AppLogger.debug('Validation errors mapped: $fieldErrors');
    }

    return fieldErrors;
  }

  /// Show appropriate error snackbar based on status code
  static void showErrorSnackbar({
    required int statusCode,
    required Map<String, dynamic>? responseBody,
    String defaultMessage = 'An error occurred',
  }) {
    String title = 'Error';
    String message = defaultMessage;
    Color backgroundColor = Colors.red;

    if (statusCode == 400) {
      // Validation error
      title = 'Validation Error';
      backgroundColor = Colors.orange;

      // Check for general error
      final errors = handleValidationErrors(responseBody);
      if (errors.containsKey('general')) {
        message = errors['general']!;
      } else {
        message = responseBody?['message'] ?? 'Please fix the errors below';
      }
    } else if (statusCode == 401) {
      title = 'Unauthorized';
      message = 'Invalid credentials or session expired';
    } else if (statusCode == 403) {
      title = 'Forbidden';
      message = 'You do not have permission to perform this action';
    } else if (statusCode == 404) {
      title = 'Not Found';
      message = 'The requested resource was not found';
    } else if (statusCode == 409) {
      title = 'Conflict';
      message = responseBody?['message'] ?? 'Resource already exists';
    } else if (statusCode >= 500) {
      title = 'Server Error';
      message = 'Server error. Please try again later';
      backgroundColor = Colors.red.shade900;
    } else {
      message =
          responseBody?['message'] ?? responseBody?['error'] ?? defaultMessage;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Convert error codes to user-friendly messages
  static String _getErrorMessage(String errorCode, dynamic fieldValue) {
    switch (errorCode.toUpperCase()) {
      // General errors
      case 'INVALID_REQUEST':
        return 'Invalid request. Please check your input';
      case 'INTERNAL_ERROR':
        return 'An internal error occurred. Please try again';

      // Email errors
      case 'EMAIL_ALREADY_PRESENT':
      case 'EMAIL_EXISTS':
        return 'This email is already registered';
      case 'INVALID_EMAIL':
      case 'EMAIL_INVALID':
        return 'Invalid email format';

      // Mobile errors
      case 'MOBILE_EXISTS':
      case 'PHONE_EXISTS':
        return 'This mobile number is already in use';
      case 'INVALID_MOBILE':
      case 'INVALID_PHONE':
        return 'Invalid mobile number';

      // Username errors
      case 'USERNAME_EXISTS':
      case 'USER_NAME_EXISTS':
        return 'This username is already taken';
      case 'USERNAME_INVALID':
        return 'Invalid username format';

      // Password errors
      case 'PASSWORD_TOO_WEAK':
      case 'WEAK_PASSWORD':
        return 'Password is too weak';
      case 'PASSWORD_TOO_SHORT':
        return 'Password is too short';
      case 'PASSWORD_MISMATCH':
        return 'Passwords do not match';

      // Field validation errors
      case 'FIELD_REQUIRED':
      case 'REQUIRED_FIELD':
        return 'This field is required';
      case 'FIELD_TOO_SHORT':
        return 'Value is too short';
      case 'FIELD_TOO_LONG':
        return 'Value is too long';
      case 'INVALID_FORMAT':
        return 'Invalid format';

      // Date errors
      case 'INVALID_DATE':
      case 'DATE_INVALID':
        return 'Invalid date';
      case 'DATE_IN_FUTURE':
        return 'Date cannot be in the future';
      case 'DATE_IN_PAST':
        return 'Date cannot be in the past';

      default:
        // Convert snake_case to readable format
        return errorCode
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
    }
  }
}
