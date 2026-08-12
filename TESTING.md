# How to test every GazePoint SDK

Two layers, tested separately:

1. **Native SDK** — the platform library + its in-repo example.
2. **Flutter plugin** (`gazepoint_sdk` 3.0.4 locally; 3.0.3 on pub.dev cannot resolve Android until 3.0.4 is published) — one Dart API that talks to native code. Today the plugin has **Android and iOS implementations**. Web / Windows / macOS / Linux are declared in `pubspec.yaml` but the plugin platform files are not in the Flutter repo yet; those platforms are tested via the **native** examples.

Camera + a real face in frame is required for a meaningful pass. Simulators/emulators without a camera only prove the app **launches**.

## Pass criteria (every demo)

After Start / allow camera:

- [ ] Preview or tracker starts without a crash
- [ ] A gaze indicator moves when you look around
- [ ] Confidence is > 0 when your face is visible
- [ ] Blink flag flips when you blink
- [ ] Stop / quit cleans up (camera light goes off)

## This Mac (darwin)

Connected today: **macOS desktop**, **Chrome**, wireless **iPhone** (unlock + Developer Mode). Emulators: **Pixel 10 Pro XL**, **iOS Simulator**.

Windows and Linux native (and Flutter Windows/Linux) need those operating systems.

---

## 1. Flutter plugin — all platforms

The example is `flutter/example`. Host apps (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`) are in the repo. Camera permission is already set on Android, iOS, and macOS.

```bash
cd flutter/example
flutter pub get
```

`example/pubspec.yaml` uses `gazepoint_sdk: path: ../` so you are testing the submodule, not pub.dev.

**Published 3.0.4** (after the next pub.dev tag): `gazepoint_sdk: ^3.0.4`. Do not test Android against 3.0.3 — it depends on JitPack `2.1.0`, which never built.

| Command | What it tests | Expectation today |
|---------|----------------|-------------------|
| `flutter emulators --launch Pixel_10_Pro_XL` then `flutter run -d android` | Flutter → JitPack Android `2.1.1`; example `compileSdk 37` | Should work on a device/emulator with a camera |
| Unlock iPhone, then `flutter run -d 00008150-00165D9E1169401C` | Flutter → iOS snapshot | Physical device; camera required |
| `flutter emulators --launch apple_ios_simulator` then `flutter run -d iPhone` | Flutter iOS compile | Launch only unless you inject a camera |
| `flutter run -d macos` | Flutter macOS plugin | **Will fail** until `macos/Classes` plugin code exists |
| `flutter run -d chrome` | Flutter web plugin | **Will fail** until `lib/gazepoint_sdk_web.dart` exists |
| `flutter run -d windows` | Flutter Windows plugin | Needs Windows **and** missing `windows/` plugin |
| `flutter run -d linux` | Flutter Linux plugin | Needs Linux **and** missing `linux/` plugin |

```bash
# compile-only checks (no camera)
cd flutter && dart format --output=none --set-exit-if-changed lib
cd flutter/example && flutter analyze
```

---

## 2. Native SDKs (independent of Flutter)

From the umbrella checkout (submodules already present):

### Android `2.1.1` — JitPack + local example

```bash
cd android/example
./gradlew :app:assembleDebug
# Android Studio: File → Open → android/example  → Run on Pixel 10 Pro XL or a phone
```

### iOS `2.1.1` — SPM example

```bash
open ios/Example/ios_example.xcodeproj
# Run on a physical iPhone (camera)
```

CI `swift build` is the wrong default (macOS, no UIKit). The example is the real test.

### Web `v1.0.0`

```bash
cd web && npm install && npm run build
cd example && python3 -m http.server 8000
# Chrome → http://localhost:8000  → allow camera
```

If `index.html` still uses `DemoGazeTracker`, point it at `../dist` as the example README describes.

### macOS `v1.0.0`

```bash
cd macos/example
swift build
swift run
# System Settings → Privacy & Security → Camera → allow Terminal/Xcode
```

### Windows `v1.0.0` (Windows machine)

```bash
cd windows/example
dotnet restore && dotnet build && dotnet run
```

### Linux `v1.0.0` (Linux machine)

```bash
cd linux/example && mkdir -p build && cd build
cmake .. && make
./bin/gazepoint_example
```

---

## Suggested order on this Mac

1. Native **macOS** example (`swift run`) — fastest camera test.
2. Native **Web** example in Chrome.
3. Native **Android** example on Pixel 10 Pro XL (webcam/virtual scene if no phone).
4. Native **iOS** example on the unlocked iPhone.
5. Generate Flutter example hosts, then Flutter **Android** and Flutter **iPhone**.
6. Confirm Flutter **macOS / Chrome** fail as documented until those plugins are implemented.
7. Windows + Linux on those OSes (native examples first).

Do not treat a green Gradle/Xcode **build** as a gaze-tracking pass. The checklist at the top is the product test.
