# StepPulse

**StepPulse** is a cross-platform step tracking and walking activity application built with Flutter for Android and iOS.

The application helps users monitor their daily physical activity, track walking sessions, set personal step goals, and review their progress through a simple and intuitive interface.

StepPulse focuses on providing an accessible walking experience without requiring a smartwatch or additional wearable devices.

## Features

### Step Tracking
- Daily step count monitoring
- Customizable daily step goals
- Visual goal progress indicator
- Estimated calorie and distance information
- Integration with supported device health data

### Walking Activity
- GPS-based walking session tracking
- Walking route visualization on an interactive map
- Start and stop walking sessions
- Walking duration and distance tracking
- Walking activity history

### Activity Statistics
- Daily activity overview
- Weekly activity statistics
- Monthly activity statistics
- Historical step data visualization

### Personal Profile
- Personal information management
- Height, weight, and age information
- Custom daily step targets
- Application preferences

### Notifications
- Daily walking reminders
- Configurable reminder times
- Daily step goal completion notifications
- Notification permission management

### Appearance
- Light and dark theme support
- Custom application icon and splash screen
- Responsive Flutter interface

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter & Dart | Cross-platform mobile development |
| Drift (SQLite) | Local data persistence |
| Health | HealthKit and Health Connect integration |
| Pedometer | Device step sensor integration |
| Geolocator | GPS location tracking |
| Flutter Map | Interactive map visualization |
| GoRouter | Navigation and routing |
| SharedPreferences | User settings and preferences |
| Flutter Local Notifications | Local notifications |
| Timezone | Timezone-aware scheduling |

## Architecture

StepPulse follows a modular Flutter project structure with separated responsibilities.

```text
lib/
├── core/
├── routes/
├── screens/
├── widgets/
├── models/
├── repositories/
├── services/
└── main.dart
```

The application separates user interface components, navigation, data access, and platform-related services to improve maintainability and readability.

### Data Management

StepPulse uses a hybrid approach to step tracking:

- Device sensors provide step information when supported.
- Platform health services provide access to available historical activity data.
- Drift manages local application data.
- SharedPreferences stores lightweight preferences and settings.

Health data availability depends on device support, permissions, and platform restrictions.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Xcode for iOS development
- Android emulator or physical device / iOS simulator or physical iPhone

### Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
cd YOUR_REPOSITORY
```

Install dependencies:

```bash
flutter pub get
```

Generate required files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the application:

```bash
flutter run
```

For a release build on a connected iPhone:

```bash
flutter run --release
```

## Permissions

Depending on the platform and enabled features, StepPulse may request:

- Physical activity or motion permissions
- Location permissions for walking routes
- Health data read permissions
- Notification permissions

Health service integration is optional where supported. Some functionality may depend on permission availability.

## Project Status

StepPulse is currently under active development.

### Planned Improvements

- Personalized step goal recommendations
- More detailed activity insights
- Improved walking habit tracking
- Additional activity progress summaries
- Enhanced background activity handling

## Platform Support

| Platform | Target |
|---|---|
| Android | Supported development target |
| iOS | Supported development target |
| Web | Not targeted |
| macOS | Not targeted for production |

## License

No open-source license has been specified for this project.

---

Developed with Flutter and Dart.
