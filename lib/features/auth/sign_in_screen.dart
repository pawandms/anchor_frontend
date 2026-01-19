import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: context.isPhone ? double.infinity : 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.anchor, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 32),
              Text(
                'welcome_back'.tr,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'email_hint'.tr,
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'password_hint'.tr,
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => authController.login(
                  emailController.text,
                  passwordController.text,
                ),
                child: Text('sign_in'.tr),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.toNamed('/forgot_password'),
                child: Text('forgot_password'.tr),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/signup'),
                child: Text('create_account'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
