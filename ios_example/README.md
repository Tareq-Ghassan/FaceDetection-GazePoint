# GazePoint SDK — iOS Example

Demo host app for the iOS GazePoint SDK. Consumes the local [`ios`](../ios) Swift package (same pattern as `android_example` → `android/gazepoint-sdk`).

**Umbrella repo:** [Tareq-Ghassan/FaceDetection-GazePoint](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)

```
FaceDetection-GazePoint/
├── ios/                     # GazePointSDK (submodule: SPM + podspec)
└── ios_example/             # This demo app
    ├── ios_example/         # SwiftUI sources
    └── ios_example.xcodeproj
```

## Open in Xcode

1. Open `ios_example/ios_example.xcodeproj`
2. Ensure the local `GazePointSDK` package resolves (linked to `../ios`)
3. Run on a **physical iPhone** (camera required)

## What it shows

- Live front-camera preview
- Gaze indicator from `GazeTracker`
- Confidence / blink / head-pose status

## Requirements

- iOS 16.0+ deployment target for the SDK (example project may use a newer device OS)
- Xcode with Swift 6.3 toolchain (tested with Xcode 26.6)
- Camera permission (`NSCameraUsageDescription`)
