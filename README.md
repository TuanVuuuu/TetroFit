# aa_teris

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Setup

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Fill in the environment variables in `.env`:
- `FIREBASE_CLI_TOKEN`: Your Firebase CLI token
- `GOOGLE_SERVICES_JSON_PATH`: Path to your google-services.json file
- `FIREBASE_API_KEY`: Your Firebase API key

**Note**: Never commit the `.env` file or any sensitive credentials to version control.

├── lib
│   ├── main.dart
│   ├── routes
│   │   ├── app_pages.dart
│   │   ├── app_routes.dart
│   │   ├── controllers
│   │   │   ├── game_controller.dart
│   │   │   ├── start_screen_controller.dart
│   │   ├── models
│   │   │   ├── piece.dart
│   │   │   ├── pixel.dart
│   │   │   ├── teris.dart
│   │   ├── views
│   │   │   ├── start_screen.dart
│   │   │   ├── game_screen.dart
│   │   ├── widgets
│   │   │   ├── aa_button.dart
│   │   │   ├── board_game_header.dart
│   │   ├── utils
│   │   │   ├── extensions
│   │   │   │   ├── debound_ext.dart
│   │   │   │   ├── gesture_detector_extensions.dart
│   │   │   │   ├── status_bar_extension.dart
│   │   ├── services
│   │   │   ├── shared_preference_manager.dart
│   │   ├── values
│   │   │   ├── app_strings.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_images.dart

