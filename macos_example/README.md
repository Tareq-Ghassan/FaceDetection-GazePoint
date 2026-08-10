# GazePoint SDK - macOS Example

This example demonstrates how to use the GazePoint SDK for macOS applications with real-time eye tracking using the Vision framework.

## Features

- 👁️ Real-time eye tracking and gaze detection
- 📊 Performance statistics (FPS, latency, dropped frames)
- 🎯 9-point calibration system
- 👀 Blink detection using Eye Aspect Ratio (EAR)
- 🎭 Head pose estimation (pitch, yaw, roll)
- ⚡ Low-latency processing with Vision framework

## Prerequisites

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- Swift 5.7 or later
- FaceTime HD camera or compatible webcam
- Camera permissions enabled

## Building the Example

### Using Swift Package Manager

```bash
cd macos_example
swift build
swift run
```

### Using Xcode

1. Open Package.swift in Xcode
2. Build and run (Cmd+R)

## Usage

When you run the example, it will:

1. Request camera permissions (if needed)
2. Initialize the GazePoint tracker
3. Start eye tracking
4. Run a 9-point calibration
5. Display real-time gaze data

### Interactive Commands

While the example is running, you can type these commands:

- **c** - Run calibration
- **s** - Show performance statistics
- **r** - Restart tracking
- **q** - Quit

### Output Example

```
═══════════════════════════════════════
   GazePoint SDK - macOS Example
═══════════════════════════════════════

Checking camera permissions...
✓ Camera access granted

Initializing GazePoint tracker...
✓ Tracker initialized successfully

Starting eye tracking...
✓ Tracking started

Running 9-point calibration...
✓ Calibration completed
  Average error: 42.15px
  Max error: 73.28px

👁️  Gaze: (1024, 768) | Confidence: 94.2% | Head: P3.2° Y-2.1° R0.8°
```

## Architecture

The example demonstrates:

1. **Permission Handling**
   ```swift
   let authorized = await checkCameraPermissions()
   ```

2. **Initialization**
   ```swift
   let tracker = GazeTracker()
   try await tracker.initialize()
   ```

3. **Event Handling**
   ```swift
   tracker.onGazeDetected = { result in
       // Handle gaze data
   }
   tracker.onBlinkDetected = {
       // Handle blink
   }
   ```

4. **Starting Tracking**
   ```swift
   try await tracker.startTracking()
   ```

5. **Calibration**
   ```swift
   let result = try await tracker.calibrate(points: 9)
   ```

6. **Cleanup**
   ```swift
   try await tracker.stopTracking()
   ```

## Performance

Expected performance on modern Macs:

- **Frame Rate**: 30 FPS
- **Latency**: 40-60ms
- **CPU Usage**: 3-8%
- **Memory**: ~100MB

## Troubleshooting

### Camera Permissions Denied
1. Open System Preferences → Security & Privacy → Privacy → Camera
2. Enable camera access for Terminal or your app
3. Restart the example

### Camera Not Detected
- Check if webcam is connected
- Ensure no other application is using the camera
- Try `killall VDCAssistant` to restart camera service

### Low Accuracy
- Ensure good lighting conditions
- Position face 50-80cm from the screen
- Run calibration again
- Avoid wearing glasses with strong reflections

### Build Errors
- Ensure Xcode Command Line Tools are installed:
  ```bash
  xcode-select --install
  ```
- Update Swift: `swift --version` (should be 5.7+)
- Clean build folder: `swift package clean`

## Advanced Usage

### Custom Configuration

```swift
let config = TrackerConfig(
    targetFPS: 30,
    smoothingFactor: 0.7,
    minConfidence: 0.6,
    enableBlinkDetection: true
)

let tracker = GazeTracker(config: config)
```

### Saving Calibration

```swift
let calibration = try await tracker.calibrate(points: 9)
try calibration.save(to: URL(fileURLWithPath: "calibration.json"))

// Load later
try await tracker.loadCalibration(from: URL(fileURLWithPath: "calibration.json"))
```

### Integration with SwiftUI

```swift
import SwiftUI
import GazePointSDK

struct ContentView: View {
    @StateObject private var tracker = GazeTracker()
    @State private var gazePoint: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // Your content here
            
            Circle()
                .fill(Color.green)
                .frame(width: 20, height: 20)
                .position(gazePoint)
        }
        .onAppear {
            Task {
                try await tracker.initialize()
                tracker.onGazeDetected = { result in
                    gazePoint = result.gazePoint
                }
                try await tracker.startTracking()
            }
        }
    }
}
```

## Learn More

- [macOS SDK Documentation](../macos/README.md)
- [Apple Vision Framework](https://developer.apple.com/documentation/vision)
- [AVFoundation Guide](https://developer.apple.com/documentation/avfoundation)
- [Multi-Platform Architecture](../MULTI_PLATFORM_ARCHITECTURE.md)

## License

MIT License - see [LICENSE](../LICENSE) for details
