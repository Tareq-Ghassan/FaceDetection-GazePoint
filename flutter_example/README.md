# GazePoint Flutter Example

Demo host app for the Flutter GazePoint plugin — mirrors `android_example/` and `ios_example/`.

**Umbrella repo:** [Tareq-Ghassan/FaceDetection-GazePoint](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)

## Architecture

```text
flutter_example/     → this app (UI + permissions)
       ↓ path dep
flutter/             → Flutter plugin (GazePointSDK-Flutter)
       ↓ native deps
android/gazepoint-sdk
ios/ (GazePointSDK)
```

The plugin owns the camera / face-detection pipeline and calls into the native SDKs for gaze math. This app only drives the Dart `GazeTracker` API and renders results.

## Run

```bash
cd flutter_example
flutter pub get
flutter run          # physical device recommended (camera required)
```

### Android

- Min SDK 24
- Camera permission is requested at runtime
- Local SDK module is wired in `android/settings.gradle.kts` → `../../android/gazepoint-sdk`

### iOS

- Deployment target iOS 16+
- `NSCameraUsageDescription` is set in `ios/Runner/Info.plist`
- Local SDK pod is wired in `ios/Podfile` → `../../ios`

```bash
cd ios && pod install && cd ..
flutter run
```

## Requirements

- Flutter 3.38.4+
- Physical device with a front camera recommended
