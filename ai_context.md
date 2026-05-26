# Qubah Learning App - AI Context

## Overview
**Qubah Learning App** is a Flutter-based educational platform designed primarily for children. The application provides structured learning through a hierarchy of educational stages, grades, subjects, sections, units, lessons, and specific lesson files. It includes support for rich media playback, document viewing, and interactive content like SCORM/HTML5 modules. The primary language of the application is Arabic.

## Tech Stack
*   **Framework**: Flutter (SDK: `^3.11.5`)
*   **Language**: Dart
*   **State Management**: `flutter_bloc` & `equatable`
*   **Networking**: `dio`, `internet_connection_checker_plus`
*   **Dependency Injection (DI)**: `get_it`, `injectable`
*   **Routing**: `go_router`
*   **Storage**: `flutter_secure_storage`, `shared_preferences`
*   **Code Generation**: `json_annotation`, `freezed_annotation`, `json_serializable`, `freezed`, `build_runner`
*   **Media & Interactive**:
    *   `video_player`, `chewie`, `just_audio` (Audio/Video playback)
    *   `syncfusion_flutter_pdfviewer` (Document viewer)
    *   `flutter_inappwebview` (SCORM and HTML5 interactive content)
*   **UI Enhancements**: `cached_network_image`, `flutter_animate`, `shimmer`, `google_fonts`, `flutter_svg`

## Architecture
The application follows a **Clean Architecture** or **Feature-First Architecture** approach, neatly separated into `core` and `features` directories under the `lib/` folder.

### 1. `lib/core`
Contains shared, application-wide utilities, configurations, and generic implementations:
*   **`constants/`**: App-wide constants (colors, strings, API endpoints).
*   **`errors/`**: Error handling, exceptions, and failure classes.
*   **`network/`**: Network interceptors, HTTP client configurations (`dio` setup).
*   **`routing/`**: Navigation configurations using `go_router` (`AppRouter`).
*   **`services/`**: Services like `LoggerService` and `DependencyInjection` setup.
*   **`storage/`**: Local storage management (`SharedPreferences` and `FlutterSecureStorage`).
*   **`theme/`**: Theming definitions (`LightTheme` and `DarkTheme`).
*   **`utils/`**: Helper functions and generic utilities (e.g., `AppBlocObserver`).
*   **`widgets/`**: Reusable generic UI components.

### 2. `lib/features`
Contains distinct business features, each likely encapsulating its own presentation (UI/Blocs), domain (Entities/UseCases), and data (Repositories/DataSources) layers.
Current features include:
*   `authentication`: Login, registration, and session management.
*   `educational_stages`: Top-level educational categorization.
*   `grades`: Grade levels within stages.
*   `subjects`: Subjects within grades.
*   `sections`: Sub-divisions within subjects.
*   `units`: Learning units.
*   `lessons`: Individual lessons within units.
*   `lesson_files`: Materials associated with lessons (PDFs, Videos, etc.).
*   `home`: Main dashboard/landing screen.
*   `interactive_viewer`: General viewer for interactive content.
*   `media_player`: Custom implementation for audio/video playback.
*   `notifications`: Handling app notifications.
*   `parent_lock`: Security feature to restrict child access.
*   `scorm_player`: Specific player for SCORM-compliant educational packages.
*   `settings`: App settings and configuration.
*   `splash`: Application launch screen.
*   `subscription`: Premium content access and billing.
*   `theme`: Dynamic theme switching (Light/Dark mode).
*   `user_profile`: User account details and progress tracking.

## Application Flow & Navigation
The application's routing is managed by `go_router`. The core user journey follows this hierarchy:

### 1. App Entry
*   `/` **Splash Screen**: The initial entry point. Determines authentication status.
*   `/login` **Login Screen**: Handles user authentication (if not authenticated).
*   `/home` **Home Screen**: The main dashboard after successful login.

### 2. Main Educational Path (Drill-down)
The core learning flow is a nested drill-down, passing parent IDs in the path:
*   `/stages` -> Lists all Educational Stages
*   `/grades/:stageId` -> Grades within the selected Stage
*   `/sections/:gradeId` -> Sections within the selected Grade
*   `/subjects/:sectionId` -> Subjects within the selected Subject (Note: route says `/subjects/:sectionId` indicating subjects belong to sections)
*   `/units/:subjectId` -> Units within the selected Subject
*   `/lessons/:unitId` -> Lessons within the selected Unit
*   `/lesson-files/:lessonId` -> Specific content/files for the selected Lesson

### 3. Media & Content Consumption
From `lesson-files`, users navigate to specialized players based on the content type:
*   `/player/video`: Video Player
*   `/player/audio`: Audio Player
*   `/player/pdf`: Document Viewer
*   `/player/interactive`: HTML5 / SCORM interactive content viewer

### 4. Secondary & Settings Flows
*   `/profile`: User Profile
*   `/subscription`: Subscription and billing
*   `/settings`: General app settings
*   `/notifications`: In-app notifications
*   **Parental Controls**: 
    *   `/parent-lock`: PIN validation screen (used for app entry, exit, or accessing settings)
    *   `/parent-settings`: Parental dashboard
    *   `/change-pin`: PIN management

## Global App Behavior
*   **Localization**: Explicitly configured for Arabic (`'ar'`).
*   **Error Handling**: Global exception capture via `FlutterError.onError` and `PlatformDispatcher.instance.onError`, logged using a custom `LoggerService`.
*   **Orientation**: Locked primarily to portrait modes, though landscape is supported structurally depending on the content (like video playback).
*   **Global Blocs**: The application initializes numerous Blocs globally at the root (`QubahLearningApp`), including `ThemeCubit`, `StagesCubit`, `GradesCubit`, `SectionsCubit`, `SubjectsCubit`, `UnitsCubit`, `LessonsCubit`, and `LessonFilesCubit`. This suggests a pre-loading or globally accessible state for core educational content navigation.

## Common Tasks for AI
When assisting with this project, consider the following structural patterns:
*   **Adding a new feature**: Create a new folder in `lib/features/`. Include `data`, `domain`, and `presentation` layers.
*   **Creating UI**: Ensure you use `flutter_bloc` for state handling and avoid placing business logic in UI widgets. Use the predefined `core/theme` for styling.
*   **Routing**: New screens must be registered in `core/routing/app_router.dart` using `go_router` paths.
*   **API Calls**: Add endpoints to `core/network` and use `get_it` injected repositories to fetch data. Use `freezed` and `json_serializable` for model definitions.
