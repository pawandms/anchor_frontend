import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/lang/translation_service.dart';
import 'nav/main_scaffold.dart';
import 'nav/nav_controller.dart';
import 'core/network/auth_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/user_service.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/auth_controller.dart';
import 'features/profile/controllers/user_controller.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const AnchorApp());
}

class AnchorApp extends StatelessWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Anchor',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to Light
      // Localization
      translations: TranslationService(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      // DI
      initialBinding: BindingsBuilder(() {
        Get.put(AuthClient());
        Get.put(AuthService());
        Get.put(UserService());
        Get.put(UserController());
        Get.put(NavController());
        Get.put(AuthController());
      }),

      // Routes
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/forgot_password', page: () => ForgotPasswordScreen()),
        GetPage(name: '/home', page: () => const MainScaffold()),
      ],
    );
  }
}
