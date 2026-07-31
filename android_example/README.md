# GazePoint SDK — Android Example

Demo host app for the Android GazePoint SDK. Mirrors [`ios_example`](../ios_example) consuming [`ios`](../ios).

**Umbrella repo:** [Tareq-Ghassan/FaceDetection-GazePoint](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)

```
FaceDetection-GazePoint/
├── android/                 # GazePoint SDK (submodule)
│   └── gazepoint-sdk/
└── android_example/         # This demo app
    └── app/                 # depends on ../android/gazepoint-sdk
```

## Open in Android Studio

1. **File → Open** → select `android_example/`
2. Wait for Gradle sync (it pulls in `../android/gazepoint-sdk`)
3. Run the `app` configuration on a device/emulator with a camera

## What it shows

- Live front-camera preview (CameraX)
- Face bounding box overlay
- Green gaze indicator from `GazeTracker`
- Status panel: confidence, blink, head pose (pitch / yaw / roll)

## Requirements

- Android Studio / AGP 9.2+
- Android device or emulator, API 24+
- Camera permission (requested at runtime)
