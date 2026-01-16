import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/values/app_values.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppValues.paddingL),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  AppStrings.createYourAccount,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: AppValues.paddingS),
                Text(
                  'Join us to stay connected',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppValues.paddingXL),
                
                // Name Field
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: controller.validateName,
                ),
                const SizedBox(height: AppValues.paddingM),
                
                // Email Field
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: AppValues.paddingM),
                
                // Password Field
                Obx(() => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: 'Enter your password',
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
                    )),
                const SizedBox(height: AppValues.paddingM),
                
                // Confirm Password Field
                Obx(() => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.obscureConfirmPassword.value,
                      decoration: InputDecoration(
                        labelText: AppStrings.confirmPassword,
                        hintText: 'Confirm your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureConfirmPassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                      validator: controller.validateConfirmPassword,
                    )),
                const SizedBox(height: AppValues.paddingXL),
                
                // Sign Up Button
                Obx(() => SizedBox(
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
                            : const Text(AppStrings.createAccount),
                      ),
                    )),
                const SizedBox(height: AppValues.paddingL),
                
                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: controller.navigateToSignIn,
                      child: Text(
                        AppStrings.signIn,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
