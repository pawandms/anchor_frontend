import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/i18n/translation_keys.dart';
import '../../../core/values/app_values.dart';
import '../../../core/enums/gender_type.dart';
import 'sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.navigateToSignIn,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppValues.paddingL),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      TranslationKeys.createYourAccount.tr,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppValues.paddingS),
                    Text(
                      TranslationKeys.joinUsToStayConnected.tr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingXL),

                    // General Error Message
                    Obx(
                      () => controller.generalError.value != null
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(
                                bottom: AppValues.paddingM,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.generalError.value!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    color: Colors.red.shade700,
                                    onPressed: () {
                                      controller.generalError.value = null;
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // First Name Field
                    Obx(
                      () => TextFormField(
                        controller: controller.firstNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.firstName.tr,
                          hintText: TranslationKeys.enterYourFirstName.tr,
                          prefixIcon: const Icon(Icons.person_outline),
                          errorText: controller.firstNameError.value,
                        ),
                        validator: controller.validateFirstName,
                        onChanged: (_) =>
                            controller.firstNameError.value = null,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Last Name Field
                    Obx(
                      () => TextFormField(
                        controller: controller.lastNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.lastName.tr,
                          hintText: TranslationKeys.enterYourLastName.tr,
                          prefixIcon: const Icon(Icons.person_outline),
                          errorText: controller.lastNameError.value,
                        ),
                        validator: controller.validateLastName,
                        onChanged: (_) => controller.lastNameError.value = null,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Email Field
                    Obx(
                      () => TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.email.tr,
                          hintText: TranslationKeys.enterYourEmail.tr,
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText: controller.emailError.value,
                        ),
                        validator: controller.validateEmail,
                        onChanged: (_) => controller.emailError.value = null,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Mobile Field (Optional)
                    Obx(
                      () => TextFormField(
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.mobileOptional.tr,
                          hintText: TranslationKeys.enterYourMobileNumber.tr,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          errorText: controller.mobileError.value,
                        ),
                        validator: controller.validateMobile,
                        onChanged: (_) => controller.mobileError.value = null,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Gender Dropdown (Optional)
                    Obx(
                      () => DropdownButtonFormField<GenderType>(
                        initialValue: controller.selectedGender.value,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.genderOptional.tr,
                          prefixIcon: const Icon(Icons.wc_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: GenderType.unknow,
                            child: Text(TranslationKeys.unknown.tr),
                          ),
                          DropdownMenuItem(
                            value: GenderType.male,
                            child: Text(TranslationKeys.male.tr),
                          ),
                          DropdownMenuItem(
                            value: GenderType.female,
                            child: Text(TranslationKeys.female.tr),
                          ),
                          DropdownMenuItem(
                            value: GenderType.other,
                            child: Text(TranslationKeys.other.tr),
                          ),
                        ],
                        onChanged: (value) {
                          controller.selectedGender.value = value;
                        },
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Date of Birth (Optional)
                    Obx(
                      () => InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 18),
                            ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.selectedDate.value = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: TranslationKeys.dateOfBirthOptional.tr,
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            controller.selectedDate.value == null
                                ? TranslationKeys.selectYourDateOfBirth.tr
                                : '${controller.selectedDate.value!.year}-${controller.selectedDate.value!.month.toString().padLeft(2, '0')}-${controller.selectedDate.value!.day.toString().padLeft(2, '0')}',
                            style: controller.selectedDate.value == null
                                ? TextStyle(color: Colors.grey[600])
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Password Field
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.password.tr,
                          hintText: TranslationKeys.enterYourPassword.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: controller.validatePassword,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingM),

                    // Confirm Password Field
                    Obx(
                      () => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        decoration: InputDecoration(
                          labelText: TranslationKeys.confirmPassword.tr,
                          hintText: TranslationKeys.confirmYourPassword.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmPassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        validator: controller.validateConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingXL),

                    // Sign Up Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.signUp,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(TranslationKeys.createAccount.tr),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppValues.paddingL),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          TranslationKeys.alreadyHaveAccount.tr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: controller.navigateToSignIn,
                          child: Text(
                            TranslationKeys.signIn.tr,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
