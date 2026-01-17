import 'package:get/get.dart';
import 'en_us_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    ...EnglishTranslations().keys,
    // Add more languages here
    // ...SpanishTranslations().keys,
    // ...FrenchTranslations().keys,
  };
}
