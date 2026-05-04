# SPEC.md — Visionary AI

> **Version:** 1.2.0
> **Platform:** Flutter (iOS & Android)
> **Backend:** Firebase
> **Last Updated:** 2026-05-03
> **Changelog v1.1.0:** Updated Gemini model to `gemini-2.5-flash-lite` (2.0-flash EOL June 1 2026), removed use_cases layer, expanded accessibility requirements.
> **Changelog v1.2.0:** Replaced Riverpod-based DI with `get_it: ^9.2.1` service locator. Riverpod is retained for UI state only. Added dedicated Section 8 — Dependency Injection.

---

## Table of Contents

1. [Product Vision](#1-product-vision)
2. [Target User](#2-target-user)
3. [Tech Stack](#3-tech-stack)
4. [App Theme & Design System](#4-app-theme--design-system)
5. [Architecture — Domain Driven Design](#5-architecture--domain-driven-design)
6. [Folder Structure](#6-folder-structure)
7. [Features & Screens](#7-features--screens)
8. [Dependency Injection — get_it](#8-dependency-injection--get_it)
9. [State Management — Riverpod](#9-state-management--riverpod)
10. [Routing](#10-routing)
11. [AI Integration — Gemini via Firebase AI](#11-ai-integration--gemini-via-firebase-ai)
12. [Text-to-Speech](#12-text-to-speech)
13. [Local Storage — History](#13-local-storage--history)
14. [Non-Functional Requirements](#14-non-functional-requirements)
15. [Open Questions & Future Considerations](#15-open-questions--future-considerations)

---

## 1. Product Vision

**Visionary AI** is an accessibility-first mobile application designed for people with low vision. It empowers users to understand their physical environment by capturing a photo, sending it to the Gemini AI model, and receiving a rich, detailed spoken description of what is visible in the image.

The core loop is:

```
Capture Image → Compress → Send to Gemini → Receive Description → Read Aloud via TTS → Save to History
```

The experience must feel instant, trustworthy, and calm — with zero cognitive overhead for the user.

---

## 2. Target User

- **Primary:** Individuals with low vision or blindness.
- **Phase 1 Scope:** Single user (the developer), designed for personal use with scalability in mind.
- **Accessibility Considerations:**
  - Large tap targets (minimum 80×80dp for primary actions, 48×48dp for secondary)
  - WCAG AAA contrast (7:1) on all text — beyond the minimum, for partial-sight users
  - Screen reader compatibility via explicit `Semantics` widgets throughout
  - `liveRegion: true` on dynamic content so TalkBack/VoiceOver announces updates automatically
  - Voice-first feedback — errors and results are also spoken via TTS, not just displayed
  - Haptic feedback on all key actions (capture, result, error, play)
  - System font scaling supported up to 200%
  - Reduced motion respected via `MediaQuery.disableAnimations`

---

## 3. Tech Stack

| Concern | Package | Version |
|---|---|---|
| UI Framework | Flutter | Latest stable |
| AI / Gemini | `firebase_ai` | ^3.11.0 |
| Image Capture | `image_picker` | ^1.2.2 |
| Text-to-Speech | `flutter_tts` | ^4.2.5 |
| State Management | `flutter_riverpod` | ^3.3.1 |
| Dependency Injection | `get_it` | ^9.2.1 |
| Navigation | `go_router` | ^17.2.3 |
| Local Secure Storage | `simple_secure_storage` | ^0.4.1 |
| Backend | Firebase (Firestore optional later) | — |

### `pubspec.yaml` dependencies block

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase & AI
  firebase_core: latest
  firebase_ai: ^3.11.0

  # Image
  image_picker: ^1.2.2

  # TTS
  flutter_tts: ^4.2.5

  # State
  flutter_riverpod: ^3.3.1

  # Dependency Injection
  get_it: ^9.2.1

  # Routing
  go_router: ^17.2.3

  # Storage
  simple_secure_storage: ^0.4.1
```

---

## 4. App Theme & Design System

### Philosophy
The design follows **Material You** principles with influence from Apple's Human Interface Guidelines. The result is a calm, high-contrast, touch-friendly dark interface that prioritises legibility and usability above decoration.

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primaryColor` | `#0D2B6E` | Dark Blue — brand primary |
| `primaryVariant` | `#1A4BAA` | Buttons, FABs, active states |
| `accentColor` | `#4A9EFF` | Highlights, icons, links |
| `background` | `#0A0F1E` | Scaffold background |
| `surface` | `#131929` | Cards, bottom sheets |
| `surfaceVariant` | `#1E2D4A` | History tiles, input areas |
| `onPrimary` | `#FFFFFF` | Text/icons on primary |
| `onBackground` | `#E8EDF5` | Body text |
| `onSurface` | `#C5CDD8` | Secondary text |
| `error` | `#FF5252` | Error states |
| `success` | `#4CCEA4` | Positive confirmations |

### Typography

- **Font Family:** `Inter` (Google Fonts) — clean, highly legible
- **Display / App Title:** `Inter` SemiBold 24sp
- **Body:** `Inter` Regular 16sp, line-height 1.5
- **Caption / Timestamp:** `Inter` Regular 12sp, `onSurface` color
- **Minimum readable size on-screen:** 16sp

### Component Tokens

```dart
// theme/app_theme.dart
ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF1A4BAA),
    secondary: Color(0xFF4A9EFF),
    background: Color(0xFF0A0F1E),
    surface: Color(0xFF131929),
    error: Color(0xFFFF5252),
    onPrimary: Colors.white,
    onBackground: Color(0xFFE8EDF5),
    onSurface: Color(0xFFC5CDD8),
  ),
  scaffoldBackgroundColor: Color(0xFF0A0F1E),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF0D2B6E),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1A4BAA),
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF131929),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
```

---

## 5. Architecture — Domain Driven Design

The application follows **Domain-Driven Design (DDD)** with a clean separation between domain logic, data access, and presentation.

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| **Domain** | Entities, value objects, repository interfaces |
| **Data** | Repository implementations, data sources (Firebase AI, local storage) |
| **Presentation** | Screens, widgets, Riverpod providers, UI state |

> **Decision — No Use Cases layer:** For this app's scope (single developer, 3 features, no complex business rules), a dedicated use_cases layer adds ceremony without value. Riverpod `Notifier` classes call repositories directly. If business logic grows in v2, use cases can be re-introduced.

### Data Flow

```
UI (Widget)
  ↓ reads state from
Riverpod Notifier (AsyncNotifier / Notifier)
  ↓ resolves dependencies via
get_it Service Locator (sl<VisionRepository>())
  ↓ returns
Repository Interface (domain/repositories/)
  ↓ implemented by
Repository Impl (data/repositories/)
  ↓ uses
Data Source (data/datasources/)
  → Firebase AI SDK / SimpleSecureStorage
```

---

## 6. Folder Structure

```
lib/
├── main.dart
├── firebase_options.dart
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── injection/
│   │   └── injection_container.dart    # get_it service locator setup (sl)
│   ├── constants/
│   │   └── app_constants.dart          # prompt string, storage keys, etc.
│   ├── providers/
│   │   └── core_providers.dart         # Riverpod providers bridging get_it
│   └── utils/
│       ├── image_utils.dart            # image compression utility
│       └── haptic_utils.dart           # haptic feedback helpers
│
└── features/
    ├── vision/
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── vision_result.dart
    │   │   └── repositories/
    │   │       └── vision_repository.dart       # abstract
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── gemini_remote_datasource.dart
    │   │   └── repositories/
    │   │       └── vision_repository_impl.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── vision_provider.dart         # calls repo directly
    │       ├── screens/
    │       │   └── home_screen.dart
    │       └── widgets/
    │           ├── capture_button.dart
    │           └── result_card.dart
    │
    ├── history/
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── history_entry.dart
    │   │   └── repositories/
    │   │       └── history_repository.dart      # abstract
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── history_local_datasource.dart
    │   │   └── repositories/
    │   │       └── history_repository_impl.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── history_provider.dart        # calls repo directly
    │       ├── screens/
    │       │   └── history_screen.dart
    │       └── widgets/
    │           └── history_tile.dart
    │
    └── info/
        └── presentation/
            └── screens/
                └── app_information_screen.dart
```

---

## 7. Features & Screens

### 7.1 Splash Screen

- **Route:** `/splash`
- **Behaviour:** Displayed on app launch. Shows the Visionary AI logo and app name centered on the dark background. Auto-navigates to `/home` after ~2 seconds (or on Firebase init completion, whichever is later).
- **No user interaction required.**
- Uses `Future.delayed` or a `FutureProvider` watching Firebase init state.

---

### 7.2 Home Screen (`home_screen.dart`)

- **Route:** `/`
- **AppBar:**
  - Title: `"Visionary AI"` (centered)
  - Trailing action icon: `Icons.info_outline` → navigates to `/info`
- **Body layout (vertical, centered):**
  1. **Status area** — shows the current state of the AI analysis:
     - Idle: subtle instructional text, e.g., *"Tap the button to describe your environment"*
     - Loading: circular progress indicator + *"Analyzing…"* label
     - Result: a `ResultCard` widget showing the AI-generated description text
     - Error: error message with retry option
  2. **Capture Button** (`CaptureButton` widget):
     - Large circular button (min 80×80dp), icon: `Icons.camera_alt`
     - Primary color background, accessible label: `"Take a photo"`
     - Disabled while loading
  3. **Repeat Audio Button:**
     - Only visible when a result is present
     - Icon: `Icons.volume_up`, label: `"Repeat"`
     - Calls `flutter_tts` to re-speak the last result
  4. **History FAB** (bottom-right):
     - Icon: `Icons.history`
     - Navigates to `/history`

- **Tap flow:**
  1. User taps Capture Button
  2. `image_picker` opens camera
  3. Image is compressed to 50% quality (`image_utils.dart`)
  4. `VisionNotifier` resolves `VisionRepository` via `get_it` and calls `analyzeImage`
  5. Gemini API call is made
  6. On success: result text is displayed + TTS auto-plays + entry is saved to history
  7. On error: error state shown with retry

---

### 7.3 App Information Screen (`app_information_screen.dart`)

- **Route:** `/info`
- **AppBar:** Back button + title `"About Visionary AI"`
- **Content:**
  - App icon + version number
  - Short description of the app's purpose
  - How-to-use guide (3 simple steps with icons)
  - Privacy note: *"Photos are processed by Gemini AI and are not stored on our servers."*
  - Accessibility note about TTS

---

### 7.4 History Screen (`history_screen.dart`)

- **Route:** `/history`
- **AppBar:** Back button + title `"History"`
- **Body:**
  - `ListView` of `HistoryTile` widgets, sorted by most recent first
  - Each tile shows:
    - Timestamp (formatted: `MMM d, yyyy · h:mm a`)
    - First 80 characters of the AI description (truncated with `…`)
    - Play icon button → re-triggers TTS for that entry
  - Empty state: icon + *"No history yet. Take your first photo!"*
  - Swipe-to-delete on each tile (removes from secure storage)

---

## 8. Dependency Injection — get_it

Using **get_it ^9.2.1** as the service locator. All data-layer objects (datasources, repositories, utilities) are registered here. Riverpod `Notifier` classes pull their dependencies from `get_it` via the global `sl` alias — keeping Riverpod focused purely on UI state.

### Responsibility Split

| Concern | Tool |
|---|---|
| Datasources, repositories, utilities | `get_it` (service locator) |
| UI state, async results, TTS state | `flutter_riverpod` (reactive state) |
| Navigation | `go_router` |

### Registration (`core/injection/injection_container.dart`)

```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Infrastructure ──────────────────────────────────────
  sl.registerLazySingleton<SimpleSecureStorage>(() => SimpleSecureStorage());
  sl.registerLazySingleton<FlutterTts>(() => FlutterTts());
  sl.registerLazySingleton<ImageUtils>(() => ImageUtils());

  // ── Firebase AI ─────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAI>(() => FirebaseAI.googleAI());

  // ── Datasources ──────────────────────────────────────────
  sl.registerLazySingleton<GeminiRemoteDatasource>(
    () => GeminiRemoteDatasource(firebaseAI: sl()),
  );
  sl.registerLazySingleton<HistoryLocalDatasource>(
    () => HistoryLocalDatasource(storage: sl()),
  );

  // ── Repositories ─────────────────────────────────────────
  sl.registerLazySingleton<VisionRepository>(
    () => VisionRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(datasource: sl()),
  );
}
```

### Bootstrap (`main.dart`)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();   // register all get_it services
  runApp(const ProviderScope(child: VisionaryApp()));
}
```

### Usage in Riverpod Notifiers

Notifiers resolve dependencies from `get_it` at call time — no `ref.watch` needed for infra objects:

```dart
@riverpod
class VisionNotifier extends _$VisionNotifier {
  @override
  AsyncValue<VisionResult?> build() => const AsyncData(null);

  Future<void> analyzeImage(XFile image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final compressed = await sl<ImageUtils>().compress(image);
      final result     = await sl<VisionRepository>().analyzeImage(compressed);
      await sl<HistoryRepository>().save(
        HistoryEntry(id: uuid(), description: result.description, timestamp: DateTime.now()),
      );
      return result;
    });
  }
}
```

> **Why `LazySingleton` for everything?** All services in this app are stateless or hold shared mutable state (e.g., TTS engine, secure storage). Singletons prevent redundant instances and match the natural lifecycle of these objects. If a service ever needs scoped creation per screen, switch to `registerFactory`.

---

## 9. State Management — Riverpod

Using **Riverpod 3.x** (`flutter_riverpod: ^3.3.1`) with `AsyncNotifier` and `Notifier` patterns. Riverpod is **UI state only** — it does not own repository or datasource instances (those live in `get_it`).

### Key Notifiers

```dart
// Vision — async AI result state
@riverpod
class VisionNotifier extends _$VisionNotifier {
  // AsyncValue<VisionResult?>
  // Methods: analyzeImage(XFile image)
}

// TTS — playback state
@riverpod
class TtsNotifier extends _$TtsNotifier {
  // State: { isSpeaking: bool, lastText: String? }
  // Methods: speak(String text), stop(), repeat()
  // Pulls sl<FlutterTts>() for the engine instance
}

// History — list state
@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  // AsyncValue<List<HistoryEntry>>
  // Methods: load(), deleteEntry(String id)
  // Pulls sl<HistoryRepository>() for persistence
}
```

### Provider Scope

`ProviderScope` wraps the entire app at the root — no scoped overrides needed in v1.

```dart
runApp(const ProviderScope(child: VisionaryApp()));
```

---

## 10. Routing

Using **go_router 17.x**.

```dart
// core/router/app_router.dart

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',  builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/',        builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/info',    builder: (_, __) => const AppInformationScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
  ],
);
```

- Transitions: default Material fade/slide transitions
- No deep linking required in v1
- Splash auto-redirects to `/` using `redirect` callback once Firebase is ready

---

## 11. AI Integration — Gemini via Firebase AI

### Package
`firebase_ai: ^3.11.0` (Vertex AI for Firebase / Gemini Developer API)

### Model
`gemini-2.5-flash-lite` — multimodal, fast, cost-efficient for image + text.

> ⚠️ **Important:** `gemini-2.0-flash` and `gemini-2.0-flash-lite` are **shutting down June 1, 2026**. This spec uses `gemini-2.5-flash-lite` as the direct replacement, which also supports the Gemini 3.1 Flash Image (Nano Banana 2) generation available via Firebase AI Logic.

### Prompt (defined in `core/constants/app_constants.dart`)

```dart
const String kVisionPrompt = '''
You are an accessibility assistant for a person with low vision.
Carefully analyze the image provided and describe in clear, natural language:

1. The overall scene or environment (indoors/outdoors, room type, location type)
2. Key objects visible, their approximate positions (left, right, center, foreground, background)
3. Any text visible in the image (signs, labels, screens)
4. People present (number, general position — do NOT describe personal appearance in detail)
5. Any potential hazards or obstacles (steps, wet floors, objects on the ground)
6. Lighting conditions (bright, dim, natural/artificial light)

Be specific and spatial. Use clear, simple language. 
Prioritize information that would help someone navigate the space safely.
Limit the response to 3–5 sentences maximum.
''';
```

### Data Source Implementation

```dart
// features/vision/data/datasources/gemini_remote_datasource.dart

class GeminiRemoteDatasource {
  final FirebaseAI _firebaseAI;

  Future<String> analyzeImage(Uint8List imageBytes) async {
    final model = _firebaseAI.generativeModel(model: 'gemini-2.5-flash-lite');
    final imagePart = InlineDataPart('image/jpeg', imageBytes);
    final textPart = TextPart(kVisionPrompt);
    final response = await model.generateContent([
      Content.multi([imagePart, textPart])
    ]);
    return response.text ?? 'No description available.';
  }
}
```

---

## 12. Text-to-Speech

Using `flutter_tts: ^4.2.5`.

### Configuration

```dart
// Initialised once via Riverpod provider
await tts.setLanguage("en-US");
await tts.setSpeechRate(0.48);   // Slightly slower for clarity
await tts.setVolume(1.0);
await tts.setPitch(1.0);
```

### Behaviour

- TTS **auto-plays** as soon as a successful Gemini response is received.
- A **"Repeat" button** is shown after first playback, allowing the user to re-listen.
- TTS is **stopped** if the user navigates away or initiates a new capture.
- On History Screen, tapping play on any entry speaks that entry's description.

---

## 13. Local Storage — History

Using `simple_secure_storage: ^0.4.1`.

### Entity

```dart
// features/history/domain/entities/history_entry.dart

class HistoryEntry {
  final String id;           // UUID v4
  final String description;  // Full AI response text
  final DateTime timestamp;
}
```

### Storage Strategy

- Entries are serialised to JSON and stored under a single key: `"vision_history"` as a JSON array string.
- On save: prepend new entry to list, re-serialise, overwrite key.
- On load: read key → parse JSON → return typed list.
- Max entries: **50** (oldest entries are pruned automatically on save to keep storage lean).
- Key: `"vision_history"`

```dart
// Storage key constant
const String kHistoryStorageKey = 'vision_history';
const int kMaxHistoryEntries = 50;
```

---

## 14. Non-Functional Requirements

### Image Compression

Before sending to Gemini, every image is compressed to **50% quality** to reduce payload size and API latency.

```dart
// core/utils/image_utils.dart

Future<Uint8List> compressImage(XFile file) async {
  final bytes = await file.readAsBytes();
  // Decode → re-encode as JPEG at 50% quality
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: 1024, // cap width — preserves aspect ratio
  );
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  // Use flutter's image library or dart:ui to encode at quality 50
  return compressedBytes;
}
```

> **Note:** Consider using the `flutter_image_compress` package if `dart:ui` compression proves insufficient for quality control.

### Performance

- Gemini API calls are made with a timeout of **30 seconds**; a user-friendly error is shown on timeout.
- The app targets **cold start < 2s** on mid-range Android devices.
- History reads are done lazily (on screen open), not on app start.

### Accessibility

Accessibility is a **first-class requirement** for this app, not an afterthought. Every screen and widget must be built with the following rules enforced from day one.

#### Flutter Semantics
- Every interactive widget wraps with `Semantics(label: '...', button: true, ...)` explicitly — never rely solely on Flutter's inferred semantics for custom widgets.
- Use `MergeSemantics` to group related elements (e.g., icon + label on a button) so screen readers announce them as a single unit.
- Use `ExcludeSemantics` on purely decorative elements (background shapes, dividers, shimmer loaders) so they don't pollute the TalkBack/VoiceOver tree.
- `Tooltip` on every `IconButton` — provides both hover text and semantic label.

#### TalkBack (Android) & VoiceOver (iOS)
- Test all screens with TalkBack and VoiceOver enabled before any release.
- Focus order must be logical (top-to-bottom, left-to-right) — use `FocusTraversalGroup` where the natural order breaks.
- Live regions: wrap the result text display in `Semantics(liveRegion: true)` so screen readers announce it automatically when the AI response arrives — without the user having to navigate to it.

```dart
// Result arrives → screen reader announces automatically
Semantics(
  liveRegion: true,
  label: 'AI description ready',
  child: ResultCard(description: result.description),
)
```

#### Touch Targets
- All tap targets: **minimum 80×80dp** for the primary Capture Button, **48×48dp** for secondary actions.
- Use `GestureDetector` with `behavior: HitTestBehavior.opaque` on custom tap areas to prevent missed taps at edges.

#### Visual Accessibility
- Color contrast ratio: **WCAG AAA (7:1)** for body text — exceeds the AA minimum, important for users with partial sight.
- Never convey meaning through color alone — pair color states with icons or labels (e.g., error = red + error icon + text, not just red).
- Support **system text scaling** — all `TextStyle` font sizes use `sp` units, never fixed `px`. Test at 200% system font scale.
- No animations that cannot be disabled — respect `MediaQuery.disableAnimations` and wrap all animated widgets accordingly:

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
// Skip animation if reduceMotion == true
```

#### Haptic Feedback
- On photo capture initiated: `HapticFeedback.mediumImpact()`
- On AI result received successfully: `HapticFeedback.heavyImpact()`
- On error: `HapticFeedback.vibrate()` (distinct pattern)
- On TTS play/repeat: `HapticFeedback.lightImpact()`

```dart
// core/utils/haptic_utils.dart
class HapticUtils {
  static void onCapture() => HapticFeedback.mediumImpact();
  static void onResult()  => HapticFeedback.heavyImpact();
  static void onError()   => HapticFeedback.vibrate();
  static void onPlay()    => HapticFeedback.lightImpact();
}
```

#### Audio Feedback (beyond TTS)
- TTS auto-speaks on result — see Section 11.
- Error states also trigger TTS: `"Something went wrong. Please try again."` — the user must not have to read the screen to understand failure.
- Loading state: after 3 seconds with no response, TTS announces `"Still analyzing, please wait."` to reassure the user.

#### Accessibility Checklist (per screen)

| Check | Home | History | Info |
|---|---|---|---|
| All buttons have semantic labels | ✅ | ✅ | ✅ |
| Live region on dynamic content | ✅ | — | — |
| Focus order is logical | ✅ | ✅ | ✅ |
| Haptics on key actions | ✅ | ✅ | — |
| Error announced via TTS | ✅ | ✅ | — |
| Passes TalkBack end-to-end | required | required | required |
| Passes VoiceOver end-to-end | required | required | required |

### Privacy

- Images are sent to Gemini via Firebase AI and are **not persisted** server-side beyond the API call.
- History is stored **locally** on-device using `simple_secure_storage` (encrypted).
- No user authentication required in v1.

### Error Handling

| Scenario | Behaviour |
|---|---|
| Camera permission denied | Show permission rationale dialog with settings deep-link |
| No internet connection | Show offline error with retry button |
| Gemini API error / timeout | Show error message, offer retry |
| TTS engine unavailable | Silently fail on TTS, display text result only |
| Storage read/write failure | Show warning toast, continue without history |

---

## 15. Open Questions & Future Considerations

| # | Topic | Notes |
|---|---|---|
| 1 | **Real-time mode** | Could add a live camera feed with continuous description using Gemini Live API in v2 |
| 2 | **Multi-language TTS** | Detect device locale and match TTS language |
| 3 | **Cloud history sync** | Firebase Firestore sync for cross-device history in v2 |
| 4 | **Haptic feedback** | Add haptic responses on capture and result received for users who cannot see the screen |
| 5 | **Onboarding flow** | A one-time onboarding for first-time users explaining the app |
| 6 | **Voice trigger** | Allow hands-free capture via voice command ("Describe") |
| 7 | **Image compression lib** | Evaluate `flutter_image_compress` vs custom `dart:ui` approach |
| 8 | **Export history** | Allow user to export history as a plain text file |

---

*End of SPEC.md — Visionary AI v1.2.0*
