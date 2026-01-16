import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/values/app_values.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppValues.paddingL),
          child: Column(
            children: [
              // Illustration/Image Area
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // You can replace this with actual illustration
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 120,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content Area
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.onboardingTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppValues.paddingM),
                    Text(
                      AppStrings.onboardingSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppValues.paddingXL),
                    
                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.navigateToSignIn,
                        child: const Text(AppStrings.getStarted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
