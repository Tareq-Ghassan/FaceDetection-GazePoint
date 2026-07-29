# GazePoint SDK for iOS

Advanced eye tracking and gaze point detection SDK for iOS applications using Apple's Vision framework and advanced computer vision algorithms.

## Features

- ✅ **Real-time Gaze Tracking** - Track user's gaze point on screen in real-time
- ✅ **Head Pose Compensation** - Accurate tracking regardless of head position
- ✅ **Blink Detection** - Detect when user blinks using Eye Aspect Ratio (EAR)
- ✅ **Kalman Filtering** - Smooth gaze point tracking with advanced filtering
- ✅ **Adaptive Smoothing** - Velocity-based smoothing for natural movement
- ✅ **Calibration Support** - Multi-point calibration for improved accuracy
- ✅ **Performance Monitoring** - Built-in FPS and processing time tracking
- ✅ **Thread-Safe** - Concurrent processing with GCD

## Requirements

- iOS 26.6+
- Xcode 27.0+ (beta) or Xcode 26.6 (stable with Swift 6.3.3)
- Swift 6.3.3+
- Device with front-facing camera
- Camera access permission

## Installation

### Swift Package Manager

Add GazePoint SDK to your project through Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version 2.0.0 or later

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GazePointSDK-iOS", from: "2.0.0")
]
```

## Quick Start

### 1. Request Camera Permission

Add to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for eye tracking</string>
```

### 2. Basic Usage

```swift
import GazePointSDK
import AVFoundation

class GazeTrackingViewController: UIViewController {
    
    let gazeTracker = GazeTracker()
    var captureSession: AVCaptureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        captureSession?.addInput(input)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession?.addOutput(videoOutput)
        
        captureSession?.startRunning()
    }
}

extension GazeTrackingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        if let result = gazeTracker.calculateGazePoint(from: pixelBuffer, orientation: .up) {
            DispatchQueue.main.async {
                print("Gaze Point: \(result.gazePoint)")
                print("Confidence: \(Int(result.confidence * 100))%")
                print("Blinking: \(result.isBlinking)")
                print("Head Pose - Pitch: \(result.headPose.pitch)°, Yaw: \(result.headPose.yaw)°")
                
                // Update UI with gaze point
                self.updateGazeIndicator(at: result.gazePoint)
            }
        }
    }
    
    func updateGazeIndicator(at point: CGPoint) {
        // Update your UI to show where user is looking
    }
}
```

### 3. With Calibration

```swift
// Perform calibration for improved accuracy
let calibrationPoints = [
    (expected: CGPoint(x: 100, y: 100), actual: CGPoint(x: 95, y: 102)),
    (expected: CGPoint(x: 375, y: 100), actual: CGPoint(x: 378, y: 98)),
    (expected: CGPoint(x: 100, y: 750), actual: CGPoint(x: 102, y: 755)),
    (expected: CGPoint(x: 375, y: 750), actual: CGPoint(x: 373, y: 748)),
    (expected: CGPoint(x: 187.5, y: 425), actual: CGPoint(x: 190, y: 422))
]

gazeTracker.calibrate(calibrationPoints: calibrationPoints)
```

### 4. Performance Monitoring

```swift
// Get performance metrics
let metrics = gazeTracker.getPerformanceMetrics()
print("FPS: \(metrics.fps)")
print("Avg Processing Time: \(metrics.avgProcessingTimeMs) ms")
print("Dropped Frames: \(metrics.droppedFrames)")

// Check if performance is degraded
if gazeTracker.getPerformanceMetrics().fps < 15 {
    print("Warning: Low FPS detected!")
}
```

## API Reference

### GazeTracker

Main class for gaze point tracking.

#### Methods

- `calculateGazePoint(from: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> GazeResult?`
  - Calculate gaze point from camera frame
  
- `calculateGazePoint(from: UIImage) -> GazeResult?`
  - Calculate gaze point from image

- `calibrate(calibrationPoints: [(expected: CGPoint, actual: CGPoint)])`
  - Calibrate tracker with known points (minimum 3 points)

- `resetCalibration()`
  - Reset calibration to default

- `getPerformanceMetrics() -> PerformanceMetrics`
  - Get current performance statistics

### GazeResult

Result of gaze point calculation.

```swift
public struct GazeResult {
    public let gazePoint: CGPoint        // Screen coordinates
    public let confidence: Float         // 0.0 to 1.0
    public let isBlinking: Bool         // Blink detection
    public let headPose: HeadPose       // Head orientation
    public let timestamp: TimeInterval  // Unix timestamp
}
```

### HeadPose

Head orientation information.

```swift
public struct HeadPose {
    public let pitch: Float  // Nodding up/down (degrees)
    public let yaw: Float    // Turning left/right (degrees)
    public let roll: Float   // Tilting left/right (degrees)
}
```

### PerformanceMetrics

Performance statistics.

```swift
public struct PerformanceMetrics {
    public let fps: Float
    public let avgProcessingTimeMs: Float
    public let maxProcessingTimeMs: Float
    public let droppedFrames: Int
    public let totalFrames: Int64
}
```

## Advanced Usage

### Custom Smoothing

The SDK uses Kalman filtering and adaptive smoothing by default. Parameters are optimized for most use cases but can be tuned if needed.

### SwiftUI Integration

```swift
import SwiftUI
import GazePointSDK

struct GazeTrackingView: View {
    @StateObject private var viewModel = GazeTrackingViewModel()
    
    var body: some View {
        ZStack {
            CameraView(gazeTracker: viewModel.gazeTracker)
            
            Circle()
                .fill(Color.red.opacity(0.5))
                .frame(width: 20, height: 20)
                .position(viewModel.gazePoint)
        }
    }
}

class GazeTrackingViewModel: ObservableObject {
    @Published var gazePoint: CGPoint = .zero
    let gazeTracker = GazeTracker()
    
    func updateGaze(_ result: GazeTracker.GazeResult) {
        DispatchQueue.main.async {
            self.gazePoint = result.gazePoint
        }
    }
}
```

## Performance Considerations

- **Target FPS**: 30 FPS for smooth tracking
- **Processing Time**: < 33ms per frame
- **Memory Usage**: ~10-20 MB
- **Battery Impact**: Moderate (camera + ML processing)

### Optimization Tips

1. Use lower camera resolution (640x480) for better performance
2. Process every 2-3 frames instead of every frame if 30 FPS not required
3. Disable features you don't need (e.g., blink detection)
4. Use background processing queue

## Use Cases

- 📊 **UX Research** - Heatmaps and attention tracking
- ♿ **Accessibility** - Eye-controlled interfaces
- 📚 **EdTech** - Student engagement tracking
- 🎮 **Gaming** - Gaze-based interactions
- 🚗 **Automotive** - Driver attention monitoring
- 🏥 **Healthcare** - Medical diagnostics and therapy

## Troubleshooting

### Low Accuracy
- Ensure good lighting conditions
- Keep face at normal distance from camera (30-60 cm)
- Perform calibration for better results
- Check that camera is not obstructed

### Low FPS
- Reduce camera resolution
- Process fewer frames per second
- Check performance metrics
- Ensure app is not in low power mode

### No Gaze Detection
- Verify camera permission granted
- Check that face is visible to camera
- Ensure eyes are open and visible
- Check logs for error messages

## License

MIT License - See LICENSE file for details

## Support

For issues, questions, or contributions:
- GitHub Issues: [Create an issue](https://github.com/yourusername/GazePointSDK-iOS/issues)
- Email: support@gazepoint.com

## Version History

### 2.0.0 (2026-07-29)
- Initial release with Vision framework
- Kalman filtering and adaptive smoothing
- Head pose compensation
- Blink detection
- Performance monitoring
- Calibration support
