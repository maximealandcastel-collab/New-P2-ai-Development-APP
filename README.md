# redmi.dm

A Flutter-based AI-powered fitness companion app that generates personalized workout plans, connects users with trainers, and provides real-time progress tracking.

---

## Table of Contents


- [Project Overview](#project-overview)
- [App Idea & Core Concept](#app-idea--core-concept)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation & Run Guide](#installation--run-guide)
- [Usage](#usage)
- [Future Improvements](#future-improvements)
- [Contribution](#contribution)
- [License](#license)
- [Author](#author)

---

## Project Overview

**redmi.dm** (internal package: `pler_to_pler_app`) is a cross-platform mobile application built with Flutter. It serves as a dual-role fitness platform connecting fitness enthusiasts with professional trainers, powered by AI-driven workout generation and real-time communication.

- **Version:** 1.0.0+1
- **SDK:** Dart ^3.10.4 / Flutter
- **Platform:** Android & iOS

---

## App Idea & Core Concept

The app addresses a common pain point: **creating personalized workout plans without professional guidance**. Users answer a multi-step questionnaire about their fitness goals, preferences, and constraints, and the AI generates a tailored exercise program. Trainers can manage clients, create exercise plans, schedule sessions, and communicate in real-time.

The platform operates on a **dual-role model**:
- **Fitness Users** browse AI-generated workout plans, track progress, consume video content, find trainers, and interact with an **AI video chatbot** for real-time fitness guidance.
- **Trainers** manage clients, build exercise plans, schedule sessions, track earnings, and publish content.

### AI-Powered Features
- **AI Workout Generator** — personalized plans based on user goals, experience, and preferences
- **AI Video Chatbot** *(planned)* — conversational AI interface for real-time fitness advice, form checks, and motivational support

---

## Key Features


### User (Fitness)
- AI-powered workout plan generator (multi-step onboarding flow)
- AI video chatbot for real-time fitness guidance *(planned)*
- Home dashboard with daily task tracking and progress bars
- Video content feed (Relevant, Shorts, Updates, Tips)
- Exercise summary & progress tracking with stats
- Workout plan management (view assigned plans)
- Find & connect with trainers
- Device connectivity
- Profile, settings, invoices, and payment methods

### Trainer
- Dashboard with mini calendar and session timeline
- Client management (list, details, chat)
- Create & manage exercise plans (add exercises, step sheets)
- Assigned plan management
- Schedule management (reschedule, cancel sessions)
- Content management (create posts, view content details)
- Earnings & invoice tracking

### Shared
- Role-based authentication (Trainer / Fitness User)
- OTP verification & password reset
- Multi-step profile completion (bio, date, gender, document, profile picture, payment)
- Real-time chat via Socket.IO
- Push notifications
- PDF invoice preview
- Onboarding flow with mode selection (Fitness / Facility)

---

## Architecture

The project follows a **Feature-First Clean Architecture** pattern with **GetX** for state management, dependency injection, and routing.

### Layer Structure (per feature)

```
features/<feature_name>/
├── domain/
│   ├── entities/          # Pure Dart business objects
│   ├── repositories/      # Abstract interfaces
│   └── usecases/          # Single-responsibility business logic
├── data/
│   ├── models/            # Data transfer objects + JSON serialization
│   ├── data_sources/      # Remote (API) & Local (Hive/SharedPreferences)
│   └── repositories/      # Concrete implementations of domain interfaces
└── presentation/
    ├── controllers/       # GetX controllers (UI actions, state)
    └── screens/           # UI widgets & pages
```

### Dependency Injection

All dependencies are registered centrally in `ControllerBinder` with the following resolution order:

1. **Data Sources** (Remote `ApiClient`, Local `HiveCacheHelper`, `PrefsHelper`)
2. **Repositories** (concrete implementations)
3. **Use Cases** (domain logic)
4. **Controllers** (presentation layer)

### Navigation

Route definitions are managed via `GetPage` in `routes/app_routes.dart`, with role-based navigation guards. Navigation is performed using `Get.to()`, `Get.offAll()`, and `Get.toNamed()`.

### State Management

- **Reactive state:** `.obs` observables + `Obx` widgets
- **Controller lifecycle:** Managed by GetX dependency injection (`Get.put()`, `Get.find()`)
- **Loading/error states:** Tracked via `.obs` booleans in controllers

### Currently Migrated to Clean Architecture
- ✅ Authentication
- ✅ Trainer Schedule
- 🔄 Other features (home, profile, user workout plans, etc.) use a flatter presentation structure

---

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (Dart ^3.10.4) |
| **State Management / DI / Routing** | GetX ^4.7.3 |
| **HTTP Client** | `http` ^1.6.0 (primary), `dio` ^5.9.0 (available) |
| **Real-Time** | `socket_io_client` ^3.1.4 |
| **Local Storage** | `shared_preferences` ^2.5.4, `hive` ^2.2.3 + `hive_flutter` ^1.1.0 |
| **Responsive UI** | `flutter_screenutil` ^5.9.3 (design size: 390×844) |
| **UI Components** | `flutter_svg`, `shimmer`, `flutter_spinkit`, `dotted_border`, `confetti`, `chat_bubbles`, `cached_network_image`, `pinput` |
| **Media** | `image_picker`, `file_picker` |
| **Utilities** | `intl`, `logger`, `url_launcher`, `mime_type` |
| **Code Generation** | `flutter_gen_runner`, `build_runner`, `flutter_launcher_icons` |
| **Linting** | `flutter_lints` ^6.0.0 |
| **Font** | Figtree |

---

## Project Structure

```
.
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # GetMaterialApp config, theme, routes
│   ├── core/                              # Shared utilities
│   │   ├── bindings/                      # Global DI (ControllerBinder)
│   │   ├── localization/                  # i18n
│   │   ├── models/                        # Shared models
│   │   └── utils/                         # Constants, formatters, helpers, theme, validators
│   ├── features/                          # Feature modules
│   │   ├── authentication/                # Clean Architecture (domain/data/presentation)
│   │   ├── common/                        # Shared features (notifications)
│   │   ├── home/                          # Trainer & User home screens
│   │   ├── nav_bar/                       # Bottom navigation
│   │   ├── onboarding/                    # App intro & mode selection
│   │   ├── profile/                       # Profile management
│   │   ├── settings/                      # Account, earnings, invoices
│   │   ├── splash_screen/                 # App launch screen
│   │   ├── trainer/                       # Trainer-side features
│   │   │   ├── assignedPlan/
│   │   │   ├── clients/                   # List, details, chat
│   │   │   ├── contentPost/
│   │   │   ├── contents/
│   │   │   ├── createExercisePlan/
│   │   │   └── schedule/                  # Clean Architecture
│   │   └── user/                          # User-side features
│   │       ├── connect_device/
│   │       ├── contents/                  # Feed, video details
│   │       ├── find_trainer/
│   │       ├── progress/                  # Exercise summary
│   │       ├── user_profile/
│   │       ├── workout_find/              # AI workout finder
│   │       └── workout_pan/               # Workout plan viewer
│   ├── routes/                            # Route definitions
│   ├── services/                          # Network, socket, FCM
│   │   ├── network/                       # ApiClient, DioApiClient
│   │   ├── api_urls.dart
│   │   └── socket_services.dart
│   └── widgets/                           # Shared reusable widgets
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   └── logos/
├── lib/custom_assets/                     # Generated assets (flutter_gen)
├── pubspec.yaml
└── MIGRATION_SUMMARY.md
```

---

## Installation & Run Guide

### Prerequisites

- **Flutter SDK** ^3.10.4 (managed via FVM — see `.fvmrc`)
- **Dart SDK** ^3.10.4
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd New-P2-ai-Development-
   ```

2. **Install Flutter version** (if using FVM)
   ```bash
   fvm install
   fvm use
   ```

3. **Get dependencies**
   ```bash
   flutter pub get
   ```

4. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Generate app icons** (optional)
   ```bash
   dart run flutter_launcher_icons
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

- API base URL is configured in `services/api_urls.dart`
- Socket.IO endpoint is configured in `services/socket_services.dart`

---

## Usage

### First Launch
1. The app displays an animated splash screen
2. Onboarding selection: choose **Fitness** (user) or **Facility** (trainer) mode
3. Complete onboarding screens

### Authentication
- Sign up or log in with role selection (Trainer / Fitness User)
- OTP verification for account validation
- Complete profile setup (bio, date of birth, gender, document upload, profile picture, payment info)

### As a Fitness User
- Use the **AI Workout Finder** to generate a personalized plan by answering questions about goals, experience, and preferences
- View your **Home Dashboard** for daily tasks and progress tracking
- Browse the **Video Feed** for workout content, tips, and updates
- Track **Exercise Progress** with detailed stats and summaries
- **Find Trainers** and connect with them
- Manage your **Profile, Settings, Invoices, and Payment Methods**

### As a Trainer
- View your **Schedule** with a mini calendar and session timeline
- Manage **Clients** (list, details, chat)
- **Create Exercise Plans** by adding exercises and step sheets
- Manage **Assigned Plans** and reschedule/cancel sessions
- Track **Earnings** and view invoices
- **Create Content** (posts) for your audience

---

## Future Improvements

- [ ] Complete Clean Architecture migration for all features (currently only `authentication` and `trainer/schedule` are migrated)
- [ ] Implement AI video chatbot — real-time conversational AI for fitness advice, form analysis, and motivational support
- [ ] Implement comprehensive unit, widget, and integration tests
- [ ] Add offline-first support with better data synchronization
- [ ] Implement push notifications with FCM integration
- [ ] Add video streaming / live workout sessions
- [ ] Enhance AI workout generation with more granular parameters
- [ ] Add social features (community feed, challenges, leaderboards)
- [ ] Support for wearable device integration (Apple Watch, Wear OS)
- [ ] Multi-language / i18n support
- [ ] Dark mode theme toggle
- [ ] Payment gateway integration for trainer subscriptions

---

## Contribution

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow the existing **Flutter linting rules** (`flutter_lints`)
- Maintain **Clean Architecture** principles for new features
- Register new dependencies in `ControllerBinder`
- Use **GetX** for state management and routing
- Ensure responsive design with `flutter_screenutil`

---

## License

This project is proprietary software. All rights reserved. Unauthorized copying, distribution, or modification of this software is strictly prohibited.

---

## Author

**redmi.dm** is developed and maintained by the FitAI team.

For questions, issues, or feature requests, please open an issue in the repository or contact the development team.
