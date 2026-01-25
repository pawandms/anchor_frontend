import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../../core/enums/gender_type.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController(); // Added
  final TextEditingController mobileController = TextEditingController();

  DateTime? selectedDate;
  GenderType selectedGender = GenderType.other;

  bool isPasswordVisible = false;
  String? confirmPasswordError;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Get.back())),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: context.isPhone ? double.infinity : 400,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'create_account'.tr,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // General Error Message
                Obx(() => authController.loginError.value != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          authController.loginError.value!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Obx(() => TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'first_name'.tr + ' *',
                              prefixIcon: const Icon(Icons.person),
                              errorText:
                                  authController.validationErrors['firstName'],
                            ),
                          )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'last_name'.tr + ' *',
                              prefixIcon: const Icon(Icons.person_outline),
                              errorText:
                                  authController.validationErrors['lastName'],
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Obx(() => TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'email_hint'.tr + ' *',
                        prefixIcon: const Icon(Icons.email),
                        errorText: authController.validationErrors['email'],
                      ),
                    )),
                const SizedBox(height: 16),

                Obx(() => TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'password_hint'.tr + ' *',
                        prefixIcon: const Icon(Icons.lock),
                        errorText: authController.validationErrors['password'],
                      ),
                    )),
                const SizedBox(height: 16),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr + ' *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Obx(() => TextField(
                      controller: mobileController,
                      decoration: InputDecoration(
                        labelText: 'mobile_optional'.tr,
                        prefixIcon: const Icon(Icons.phone),
                        errorText: authController.validationErrors['mobile'],
                      ),
                      keyboardType: TextInputType.phone,
                    )),
                const SizedBox(height: 16),

                // DOB Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'dob_optional'.tr,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(' ')[0]
                          : 'select_date'.tr,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<GenderType>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'gender_optional'.tr,
                    prefixIcon: const Icon(Icons.wc),
                  ),
                  items: GenderType.values.map((GenderType type) {
                    return DropdownMenuItem<GenderType>(
                      value: type,
                      child: Text(type.localizedName),
                    );
                  }).toList(),
                  onChanged: (GenderType? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 32),

                Obx(() => authController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          authController.validationErrors.clear();
                          bool isValid = true;
                          if (firstNameController.text.trim().isEmpty) {
                            authController.validationErrors['firstName'] =
                                'field_required'.tr;
                            isValid = false;
                          }
                          if (lastNameController.text.trim().isEmpty) {
                            authController.validationErrors['lastName'] =
                                'field_required'.tr;
                            isValid = false;
                          }
                          if (emailController.text.trim().isEmpty) {
                            authController.validationErrors['email'] =
                                'field_required'.tr;
                            isValid = false;
                          }
                          if (passwordController.text.isEmpty) {
                            authController.validationErrors['password'] =
                                'field_required'.tr;
                            isValid = false;
                          }

                          if (!isValid) return;

                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            setState(() {
                              confirmPasswordError = 'passwords_not_match'.tr;
                            });
                            return;
                          }
                          // Clear error if valid
                          setState(() {
                            confirmPasswordError = null;
                          });
                          authController.signup(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            mobile: mobileController.text.isNotEmpty
                                ? mobileController.text
                                : null,
                            dob: selectedDate,
                            gender: selectedGender,
                          );
                        },
                        child: Text('sign_up'.tr),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
