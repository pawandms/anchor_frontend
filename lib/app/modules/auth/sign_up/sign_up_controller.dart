import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_api_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/api_error_handler.dart';
import '../../../core/enums/gender_type.dart';

class SignUpController extends GetxController {
  final _authApiService = AuthApiService();

  // Text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final mobileController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable fields
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final selectedGender = Rxn<GenderType>();
  final selectedDate = Rxn<DateTime>();

  // Field-specific errors from backend
  final generalError = RxnString();
  final firstNameError = RxnString();
  final lastNameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final mobileError = RxnString();
  final genderError = RxnString();
  final dobError = RxnString();

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Clear all backend validation errors
  void clearFieldErrors() {
    generalError.value = null;
    firstNameError.value = null;
    lastNameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    mobileError.value = null;
    genderError.value = null;
    dobError.value = null;
  }

  /// Handle backend validation errors
  void handleValidationErrors(Map<String, dynamic> responseBody) {
    clearFieldErrors();

    final fieldErrors = ApiErrorHandler.handleValidationErrors(responseBody);

    // Map field errors to observables
    for (var entry in fieldErrors.entries) {
      final fieldName = entry.key.toLowerCase();
      final errorMessage = entry.value;

      switch (fieldName) {
        case 'general':
          generalError.value = errorMessage;
          break;
        case 'firstname':
        case 'first_name':
          firstNameError.value = errorMessage;
          break;
        case 'lastname':
        case 'last_name':
          lastNameError.value = errorMessage;
          break;
        case 'email':
          emailError.value = errorMessage;
          break;
        case 'password':
          passwordError.value = errorMessage;
          break;
        case 'mobile':
          mobileError.value = errorMessage;
          break;
        case 'gender':
          genderError.value = errorMessage;
          break;
        case 'dob':
        case 'dateofbirth':
          dobError.value = errorMessage;
          break;
      }
    }
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2 || value.length > 50) {
      return 'First name must be between 2 and 50 characters';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2 || value.length > 50) {
      return 'Last name must be between 2 and 50 characters';
    }
    return null;
  }

  String? validateUserName(String? value) {
    // Optional field
    if (value != null && value.isNotEmpty) {
      if (value.length < 3) {
        return 'Username must be at least 3 characters';
      }
    }
    return null;
  }

  String? validateMobile(String? value) {
    // Optional field
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isPhoneNumber(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      clearFieldErrors(); // Clear previous errors

      AppLogger.info(
        '📝 Attempting signup with email: ${emailController.text}',
      );

      // Prepare request data
      final requestBody = <String, dynamic>{
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };

      // Add optional fields if provided
      if (mobileController.text.isNotEmpty) {
        requestBody['mobile'] = mobileController.text.trim();
      }
      if (selectedGender.value != null) {
        requestBody['gender'] = selectedGender.value!.toApiValue();
      }
      if (selectedDate.value != null) {
        // Format date as yyyy-MM-dd
        final date = selectedDate.value!;
        requestBody['dob'] =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      // Call the signup API
      final response = await _authApiService.signUpWithData(requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ Signup successful');
        clearFieldErrors();

        Get.snackbar(
          'Success',
          'Account created successfully! Please sign in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to sign in page
        navigateToSignIn();
      } else if (response.statusCode == 400 && response.body != null) {
        // Handle validation errors
        AppLogger.error('❌ Validation failed: ${response.body}');

        handleValidationErrors(response.body);
        ApiErrorHandler.showErrorSnackbar(
          statusCode: response.statusCode!,
          responseBody: response.body,
        );
      } else {
        // Handle other errors
        ApiErrorHandler.showErrorSnackbar(
          statusCode: response.statusCode ?? 500,
          responseBody: response.body,
          defaultMessage: 'Failed to create account',
        );
      }
    } catch (e) {
      AppLogger.error('❌ Signup error: $e', e);

      Get.snackbar(
        'Error',
        'Failed to create account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignIn() {
    Get.back();
  }
}
