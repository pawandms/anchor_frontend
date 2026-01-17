import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/i18n/app_translations.dart';
import 'app/core/i18n/translation_keys.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: TranslationKeys.appName.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Internationalization
      translations: AppTranslations(),
      locale: const Locale('en', 'US'), // Default locale
      fallbackLocale: const Locale('en', 'US'), // Fallback locale
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
