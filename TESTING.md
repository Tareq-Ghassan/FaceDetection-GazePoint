# How to test every GazePoint SDK

Two layers, tested separately:

1. **Native SDK** — the platform library + its in-repo example.
2. **Flutter plugin** (`gazepoint_sdk` **3.0.4** on pub.dev) — Dart API with **Android, iOS, Web, and macOS** implementations. Windows / Linux are still declared in `pubspec.yaml` without plugin files; test those via the **native** examples.

Camera + a real face in frame is required for a meaningful pass. Simulators/emulators without a camera only prove the app **launches**.

## Pass criteria (every demo)

After Start / allow camera (the Flutter example now prompts; if you already denied, enable Camera in app settings):

- [ ] Preview or tracker starts without a crash
- [ ] Native Android / iOS / Web / macOS: white outline on **every** face (tight to the face, not floating in empty space); status **Multiple faces detected** when two people are in frame; **no gaze point** until only one face remains
- [ ] Flip camera switches front / back (or the next Mac camera)
- [ ] A gaze indicator moves when you look around (if the console floods `Map<Object?, Object?> is not a subtype of Map<String, dynamic>`, the native tracker is working and Dart is dropping events — use gazepoint_sdk 3.0.4+)
- [ ] Confidence is > 0 when your face is visible
- [ ] Blink flag flips when you blink
- [ ] Stop / quit cleans up (camera light goes off)

## This Mac (darwin)

Connected today: **macOS desktop**, **Chrome**, wireless **iPhone** (unlock + Developer Mode). Emulators: **Pixel 10 Pro XL**, **iOS Simulator**.

Windows and Linux native (and Flutter Windows/Linux) need those operating systems. This Mac cannot `flutter run -d windows` or `flutter run -d linux`.

---

## 1. Flutter plugin — all platforms

The example is `flutter/example`. Host apps (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`) are in the repo. Camera permission is already set on Android, iOS, and macOS.

```bash
cd flutter/example
flutter pub get
```

`example/pubspec.yaml` uses `gazepoint_sdk: path: ../` so you are testing the submodule, not pub.dev.

**Published 3.0.4:** `gazepoint_sdk: ^3.0.4`. Do not test Android against 3.0.3 — it depends on JitPack `2.1.0`, which never built.

| Command | What it tests | Expectation today |
|---------|----------------|-------------------|
| `flutter emulators --launch Pixel_10_Pro_XL` then `flutter run -d android` | Flutter → JitPack Android `2.2.0`; example `compileSdk 37` and JVM 17 for Java+Kotlin | Should work on a device/emulator with a camera |
| Unlock iPhone, then `flutter run -d ios` | Flutter → iOS snapshot via SwiftPM (`ios/gazepoint_sdk`) | Prefer **USB**. Example Runner target and `ios/Flutter/*.xcconfig` must be 16.0 (not only the project). If you see “requires 16.0 but this target supports 13.0”, run `flutter clean && flutter build ios --config-only` then run again. Wireless debug on iOS 26 often stays on a white launch screen until the Dart VM Service attaches. |
| `flutter emulators --launch apple_ios_simulator` then `flutter run -d iPhone` | Flutter iOS compile | Launch only unless you inject a camera |
| `flutter run -d macos` | Flutter macOS plugin (`macos/gazepoint_sdk` snapshot of `GazeCamera`) | Allow Camera in System Settings. Example `MACOSX_DEPLOYMENT_TARGET` must be 13.0. |
| `flutter run -d chrome` | Flutter web plugin (`gazepoint_sdk_web.dart`, MediaPipe Face Mesh CDN) | Allow camera in Chrome. Needs localhost or HTTPS. Live preview is an `HtmlElementView` registered as `gazepoint_sdk/preview`. |
| `flutter run -d windows` | Flutter Windows plugin | Needs a Windows PC **and** a plugin implementation (`flutter/windows/` is empty). Native Windows SDK is still a TODO stub. |
| `flutter run -d linux` | Flutter Linux plugin | Needs a Linux PC **and** a plugin implementation (`flutter/linux/` is empty). Native Linux SDK has a header but no `src/*.cpp`. |

```bash
# compile-only checks (no camera)
cd flutter && dart format --output=none --set-exit-if-changed lib
cd flutter/example && flutter analyze
```

---

## 2. Native SDKs (independent of Flutter)

From the umbrella checkout (submodules already present):

### Android `2.2.0` — JitPack + local example

```bash
cd android/example
./gradlew :app:assembleDebug
# Android Studio: File → Open → android/example  → Run on Pixel 10 Pro XL or a phone
```

### iOS `2.2.1` — SPM example

```bash
open ios/Example/ios_example.xcodeproj
# Run on a physical iPhone (camera)
```

CI `swift build` is the wrong default (macOS, no UIKit). The example is the real test.

### Web `2.1.0`

```bash
cd web/example && npm start
# Chrome → http://localhost:8080  → Start → allow camera
```

`GazeCamera` draws the preview and white face boxes. Run from `example/` like the other SDKs; webpack in the parent folder serves this page and `/dist`.

### macOS `2.2.1`

```bash
cd macos/example
swift build
swift run
# System Settings → Privacy & Security → Camera → allow Terminal/Xcode
```

AppKit window hosts `GazePreviewView`. White face boxes sit on each face. A green gaze indicator appears when exactly one face is in frame. The title bar shows `statusText` (`Multiple faces detected` when two faces are in frame).

### Windows `v1.0.0` (Windows machine)

**Not a gaze test yet.** `GazeTracker.cs` is placeholders (`TODO: Initialize face detection and camera`). The example calls APIs the library does not define (`GazeDetected`, `CalibrateAsync(9)`, …), so `dotnet build` is expected to fail until that SDK is implemented.

```bash
cd windows/example
dotnet restore && dotnet build && dotnet run
```

### Linux `v1.0.0` (Linux machine)

**Not a gaze test yet.** `include/gazepoint/GazeTracker.hpp` has no matching `src/*.cpp` in the repo. Root `CMakeLists.txt` lists those sources; `example/` does not link the library and calls methods that are not on the header.

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
6. Flutter **Chrome** (`flutter run -d chrome`) and Flutter **macOS** (`flutter run -d macos`) — allow camera.
7. Windows + Linux — **not on this Mac.** See [No Windows or Linux PC](#no-windows-or-linux-pc).

Do not treat a green Gradle/Xcode **build** as a gaze-tracking pass. The checklist at the top is the product test.

---

## No Windows or Linux PC

`flutter run -d windows` and `flutter run -d linux` only work **on that OS**. Flutter does not cross-compile a runnable Windows/Linux app from macOS. The Flutter plugin also has **no Windows or Linux implementation yet** (`pubspec.yaml` declares them; the plugin folders are empty). The **native** Windows and Linux SDKs are stubs too (TODOs / missing `.cpp`), so a VM would not give a gaze pass today.

| Goal | What to use | Camera / gaze pass? |
|------|-------------|---------------------|
| Skip for now | Finish Android, iOS, macOS, Chrome on this Mac | — |
| Compile-only | GitHub Actions (or a cloud VM) running `dotnet build` / `cmake` | No |
| Linux GUI + webcam | [UTM](https://mac.getutm.app/) Ubuntu VM (Apple Silicon: Ubuntu ARM). Pass through a **USB** webcam | Maybe |
| Windows GUI + webcam | UTM **Windows 11 ARM** (Apple Silicon) or a cheap Windows PC | Maybe; ARM + camera is flaky |
| Reliable product test | A real Windows 10/11 PC and an Ubuntu machine with a webcam | Yes |

UTM: install Ubuntu or Windows 11 ARM, clone the matching SDK repo (or this umbrella with submodules), then run the native example from [§2](#2-native-sdks-independent-of-flutter). The Mac’s built-in camera usually does **not** appear in the VM; use a USB webcam and enable USB forwarding.

GitHub Actions can prove the native example **builds**. It cannot prove gaze tracking.
