# GazePoint SDK examples

Each example lives **in that platform's SDK repository**, so you can clone one repo and run the demo without the umbrella.

| Platform | Repository | Example |
|----------|------------|---------|
| Flutter | [GazePointSDK-Flutter](https://github.com/Tareq-Ghassan/GazePointSDK-Flutter) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-Flutter/tree/main/example) |
| Android | [GazePointSDK-Android](https://github.com/Tareq-Ghassan/GazePointSDK-Android) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-Android/tree/main/example) |
| iOS | [GazePointSDK-iOS](https://github.com/Tareq-Ghassan/GazePointSDK-iOS) | [`Example/`](https://github.com/Tareq-Ghassan/GazePointSDK-iOS/tree/main/Example) |
| Web | [GazePointSDK-Web](https://github.com/Tareq-Ghassan/GazePointSDK-Web) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-Web/tree/main/example) |
| Windows | [GazePointSDK-Windows](https://github.com/Tareq-Ghassan/GazePointSDK-Windows) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-Windows/tree/main/example) |
| macOS | [GazePointSDK-macOS](https://github.com/Tareq-Ghassan/GazePointSDK-macOS) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-macOS/tree/main/example) |
| Linux | [GazePointSDK-Linux](https://github.com/Tareq-Ghassan/GazePointSDK-Linux) | [`example/`](https://github.com/Tareq-Ghassan/GazePointSDK-Linux/tree/main/example) |

If you already cloned this umbrella with `--recurse-submodules`, the same folders are at `flutter/example`, `android/example`, `ios/Example`, and so on.

## Quick start (from the umbrella checkout)

```bash
# Flutter (pub.dev plugin) — Android, iOS, Chrome, or macOS
cd flutter/example && flutter pub get && flutter run
# Chrome: flutter run -d chrome  (allow camera; MediaPipe loads from jsDelivr)
# iOS: prefer USB. Wireless debug can stay on a white launch screen until the Dart VM Service attaches.
# macOS: flutter run -d macos  (allow Camera in System Settings; app target 12.0)

# Android (open repo root of the Android submodule)
cd android/example && ./gradlew :app:assembleDebug

# iOS
open ios/Example/ios_example.xcodeproj
```

Releasing one SDK does not require updating the others. See [`.agents/WORKFLOW_RULES.md`](.agents/WORKFLOW_RULES.md).

## Testing

Full matrix (Flutter on every platform + each native example): **[TESTING.md](TESTING.md)**.

Published Flutter pin: `gazepoint_sdk: ^3.0.4` (3.0.3 cannot resolve Android on JitPack).
