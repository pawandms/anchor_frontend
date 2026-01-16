# Logging Configuration

## Simple Configuration with LOG_LEVEL

Control all logging with a single parameter in your `.env` file:

```bash
LOG_LEVEL=debug
```

## Available Log Levels

| Level     | What Gets Logged |
|-----------|------------------|
| `trace`   | Everything (most verbose) |
| `debug`   | Debug, Info, Warning, Error |
| `info`    | Info, Warning, Error |
| `warning` | Warning, Error |
| `error`   | Only Errors |
| `none`    | Nothing (all logs disabled) |

## Configuration Examples

### Development (Recommended)
```bash
LOG_LEVEL=debug
```
Shows debug logs and above. Good for active development.

### Production
```bash
LOG_LEVEL=warning
```
Only shows warnings and errors. Recommended for production.

### Debugging Issues
```bash
LOG_LEVEL=trace
```
Shows everything including detailed trace logs.

### Errors Only
```bash
LOG_LEVEL=error
```
Only shows error messages.

### Disable All Logs
```bash
LOG_LEVEL=none
```
Completely disables all logging.

## Default Behavior (if not set)

- **Development** (`flutter run`): `LOG_LEVEL=trace`
- **Production** (`flutter build --release`): `LOG_LEVEL=warning`

### Usage Examples

```dart
import 'package:flutter_demo_1/app/core/utils/app_logger.dart';

// These will be hidden in production
AppLogger.trace('Detailed trace information');
AppLogger.debug('Debugging variable: $value');

// These will always show
AppLogger.info('User logged in successfully');
AppLogger.warning('API response took longer than expected');
AppLogger.error('Failed to load data', error);
```

### Testing Production Mode Locally

```bash
# Run in release mode to test
flutter run --release

# Or build and install
flutter build apk --release
flutter install
```

### Advanced Configuration

If you need custom log level control, modify [app_logger.dart](lib/app/core/utils/app_logger.dart):

```dart
// Option 1: Environment variable
static bool get _isProduction => 
  dotenv.env['ENVIRONMENT'] == 'production';

// Option 2: Custom flag
static bool enableDebugLogs = true;

// Option 3: Multiple log levels per environment
static Level get _logLevel {
  if (kReleaseMode) return Level.warning;
  if (kProfileMode) return Level.info;
  return Level.trace;
}
```

## No Configuration Needed!

The current implementation works automatically:
- **Development** (`flutter run`) → All logs enabled
- **Production** (`flutter build`) → Only warnings and errors

Just use the logger and it handles everything! 🎉
