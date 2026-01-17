# Internationalization (i18n) Guide

This project uses **GetX's built-in internationalization system** for managing translations.

## How It Works

1. **Translation Keys** (`translation_keys.dart`): Contains all the string keys used in the app
2. **Language Files** (e.g., `en_us_translations.dart`): Contains translations for each language
3. **App Translations** (`app_translations.dart`): Combines all language translations
4. **Usage**: Use `.tr` extension on translation keys to get the translated text

## Using Translations in Your Code

### Basic Usage

```dart
import '../../../core/i18n/translation_keys.dart';

// In your widget
Text(TranslationKeys.createAccount.tr)
```

### With Variables

```dart
// Define in translation file:
'welcome_user': 'Welcome, @name!',

// Use in code:
Text(TranslationKeys.welcomeUser.trParams({'name': 'John'}))
```

### With Plural Forms

```dart
// Define in translation file:
'message_count': 'You have @count message',
'message_count_plural': 'You have @count messages',

// Use in code:
Text(TranslationKeys.messageCount.trPlural('message_count', count))
```

## Adding a New Language

### Step 1: Create a new translation file

Create `lib/app/core/i18n/[language_code]_translations.dart`:

```dart
import 'package:get/get.dart';

class FrenchTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'fr_FR': {
          'app_name': 'Anchor',
          'sign_in': 'Se Connecter',
          'sign_up': "S'inscrire",
          // ... add all translations
        },
      };
}
```

### Step 2: Add to app_translations.dart

```dart
import 'en_us_translations.dart';
import 'es_es_translations.dart';
import 'fr_fr_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        ...EnglishTranslations().keys,
        ...SpanishTranslations().keys,
        ...FrenchTranslations().keys,
      };
}
```

## Changing Language at Runtime

```dart
// In your settings or language selector
Get.updateLocale(const Locale('es', 'ES')); // Spanish
Get.updateLocale(const Locale('fr', 'FR')); // French
Get.updateLocale(const Locale('en', 'US')); // English
```

## Example: Language Selector Widget

```dart
class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Get.locale,
      items: const [
        DropdownMenuItem(
          value: Locale('en', 'US'),
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: Locale('es', 'ES'),
          child: Text('Español'),
        ),
      ],
      onChanged: (locale) {
        if (locale != null) {
          Get.updateLocale(locale);
        }
      },
    );
  }
}
```

## Adding New Translation Keys

### Step 1: Add key to translation_keys.dart

```dart
static const String newFeature = 'new_feature';
```

### Step 2: Add translations to all language files

```dart
// en_us_translations.dart
'new_feature': 'New Feature',

// es_es_translations.dart
'new_feature': 'Nueva Función',
```

### Step 3: Use in your code

```dart
Text(TranslationKeys.newFeature.tr)
```

## Best Practices

1. **Always use TranslationKeys**: Never use hardcoded strings
2. **Keep keys descriptive**: Use clear, descriptive names like `enterYourEmail` not `hint1`
3. **Group related keys**: Organize by feature (auth, home, settings, etc.)
4. **Test all languages**: When adding new text, update ALL language files
5. **Use fallback locale**: Default language (en_US) is used if translation is missing

## Current Supported Languages

- English (en_US) - Default ✅
- Spanish (es_ES) - Example provided

## Translation Status

| Key | English | Spanish |
|-----|---------|---------|
| All keys | ✅ | Example |

## Resources

- [GetX Internationalization Documentation](https://github.com/jonataslaw/getx#internationalization)
- [Flutter Intl Documentation](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
