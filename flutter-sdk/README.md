## GazePoint SDK for Flutter

Cross-platform Flutter plugin for eye tracking and gaze point detection on Android and iOS.

[![pub package](https://img.shields.io/pub/v/gazepoint_sdk.svg)](https://pub.dev/packages/gazepoint_sdk)

## Features

- ✅ **Cross-Platform** - Works on both Android and iOS
- ✅ **Real-time Tracking** - Low-latency gaze point detection
- ✅ **Head Pose Compensation** - Accurate tracking regardless of head position
- ✅ **Blink Detection** - Detect when user blinks
- ✅ **Calibration Support** - Multi-point calibration for improved accuracy
- ✅ **Performance Monitoring** - Built-in FPS and latency tracking
- ✅ **Stream API** - Real-time gaze data through Dart streams
- ✅ **Easy Integration** - Simple, intuitive API

## Platform Support

| Platform | Minimum Version | Requirements |
|----------|----------------|--------------|
| Android  | API 24 (Android 7.0) | Front camera, Google Play Services |
| iOS      | iOS 26.6 | Front camera, Face ID capable device (recommended) |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  gazepoint_sdk: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## Platform-Specific Setup

### Android

Add camera permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.front" />
```

### iOS

Add camera usage description to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for eye tracking</string>
```

## Quick Start

### Basic Usage

```dart
import 'package:gazepoint_sdk/gazepoint_sdk.dart';
import 'package:flutter/material.dart';

class GazeTrackingScreen extends StatefulWidget {
  @override
  _GazeTrackingScreenState createState() => _GazeTrackingScreenState();
}

class _GazeTrackingScreenState extends State<GazeTrackingScreen> {
  final GazeTracker _gazeTracker = GazeTracker();
  Offset _gazePoint = Offset.zero;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _initializeGazeTracker();
  }

  Future<void> _initializeGazeTracker() async {
    // Check if supported
    if (!await _gazeTracker.isSupported()) {
      print('Gaze tracking not supported on this device');
      return;
    }

    // Request camera permission
    if (!await _gazeTracker.requestCameraPermission()) {
      print('Camera permission denied');
      return;
    }

    // Initialize tracker
    await _gazeTracker.initialize();

    // Start tracking
    await _gazeTracker.startTracking();
    setState(() => _isTracking = true);

    // Listen to gaze stream
    _gazeTracker.gazeStream.listen((result) {
      setState(() {
        _gazePoint = result.gazePoint;
      });
      
      print('Gaze: ${result.gazePoint}');
      print('Confidence: ${(result.confidence * 100).toInt()}%');
      print('Blinking: ${result.isBlinking}');
      print('Head Pose: ${result.headPose}');
    });
  }

  @override
  void dispose() {
    _gazeTracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gaze Tracking')),
      body: Stack(
        children: [
          // Your content here
          Center(
            child: Text(
              _isTracking ? 'Tracking Active' : 'Initializing...',
              style: TextStyle(fontSize: 24),
            ),
          ),
          
          // Gaze indicator
          if (_isTracking)
            Positioned(
              left: _gazePoint.dx - 10,
              top: _gazePoint.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

### With Calibration

```dart
Future<void> _performCalibration() async {
  final screenSize = MediaQuery.of(context).size;
  
  // Define calibration points (corners + center)
  final points = [
    Offset(50, 50),                                    // Top-left
    Offset(screenSize.width - 50, 50),                 // Top-right
    Offset(50, screenSize.height - 50),                // Bottom-left
    Offset(screenSize.width - 50, screenSize.height - 50), // Bottom-right
    Offset(screenSize.width / 2, screenSize.height / 2),   // Center
  ];

  // Show each point and collect user gaze
  for (final point in points) {
    // Show calibration target at point
    await _showCalibrationTarget(point);
    
    // Wait for user to look at it
    await Future.delayed(Duration(seconds: 2));
  }

  // Perform calibration
  await _gazeTracker.calibrate(points);
  
  print('Calibration complete!');
}

Future<void> _showCalibrationTarget(Offset point) async {
  // Show a visual indicator at the point
  // Implementation depends on your UI
}
```

### Performance Monitoring

```dart
Future<void> _checkPerformance() async {
  final metrics = await _gazeTracker.getPerformanceMetrics();
  
  print('Performance Metrics:');
  print('FPS: ${metrics.fps.toStringAsFixed(1)}');
  print('Avg Processing: ${metrics.avgProcessingTimeMs.toStringAsFixed(1)} ms');
  print('Max Processing: ${metrics.maxProcessingTimeMs.toStringAsFixed(1)} ms');
  print('Dropped Frames: ${metrics.droppedFrames}');
  print('Total Frames: ${metrics.totalFrames}');
  
  if (metrics.isPerformanceDegraded) {
    print('Warning: Performance degradation detected!');
  }
}
```

### Handling Permissions

```dart
Future<bool> _ensurePermissions() async {
  // Check if already granted
  if (await _gazeTracker.hasCameraPermission()) {
    return true;
  }

  // Request permission
  final granted = await _gazeTracker.requestCameraPermission();
  
  if (!granted) {
    // Show dialog explaining why permission is needed
    _showPermissionDialog();
    return false;
  }

  return true;
}
```

## API Reference

### GazeTracker

Main class for gaze tracking functionality.

#### Methods

- `Future<void> initialize()` - Initialize the tracker
- `Future<void> startTracking()` - Start gaze tracking
- `Future<void> stopTracking()` - Stop gaze tracking
- `Future<GazeResult?> getLatestGaze()` - Get latest gaze result
- `Future<void> calibrate(List<Offset> points)` - Calibrate with points (min 3)
- `Future<void> resetCalibration()` - Reset calibration to default
- `Future<PerformanceMetrics> getPerformanceMetrics()` - Get performance stats
- `Future<bool> isSupported()` - Check if device is supported
- `Future<bool> hasCameraPermission()` - Check camera permission status
- `Future<bool> requestCameraPermission()` - Request camera permission
- `Future<void> dispose()` - Dispose resources

#### Properties

- `Stream<GazeResult> gazeStream` - Real-time gaze results
- `bool isInitialized` - Whether tracker is initialized
- `bool isTracking` - Whether tracking is active

### GazeResult

Result of gaze point calculation.

```dart
class GazeResult {
  final Offset gazePoint;      // Screen coordinates
  final double confidence;     // 0.0 to 1.0
  final bool isBlinking;       // Blink detection
  final HeadPose headPose;     // Head orientation
  final int timestamp;         // Milliseconds since epoch
}
```

### HeadPose

Head orientation information.

```dart
class HeadPose {
  final double pitch;  // Nodding up/down (degrees)
  final double yaw;    // Turning left/right (degrees)
  final double roll;   // Tilting left/right (degrees)
}
```

### PerformanceMetrics

Performance statistics.

```dart
class PerformanceMetrics {
  final double fps;
  final double avgProcessingTimeMs;
  final double maxProcessingTimeMs;
  final int droppedFrames;
  final int totalFrames;
  
  bool get isPerformanceDegraded;
}
```

## Advanced Topics

### Custom UI Integration

```dart
class GazeOverlay extends StatelessWidget {
  final Offset gazePoint;
  final bool isBlinking;

  const GazeOverlay({
    required this.gazePoint,
    required this.isBlinking,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GazePainter(
        gazePoint: gazePoint,
        isBlinking: isBlinking,
      ),
      child: Container(),
    );
  }
}

class GazePainter extends CustomPainter {
  final Offset gazePoint;
  final bool isBlinking;

  GazePainter({required this.gazePoint, required this.isBlinking});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBlinking ? Colors.orange : Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(gazePoint, 10, paint);
  }

  @override
  bool shouldRepaint(GazePainter oldDelegate) {
    return oldDelegate.gazePoint != gazePoint ||
           oldDelegate.isBlinking != isBlinking;
  }
}
```

### State Management Integration

#### With Provider

```dart
class GazeProvider extends ChangeNotifier {
  final GazeTracker _tracker = GazeTracker();
  GazeResult? _latestResult;

  GazeResult? get latestResult => _latestResult;

  Future<void> initialize() async {
    await _tracker.initialize();
    await _tracker.startTracking();
    
    _tracker.gazeStream.listen((result) {
      _latestResult = result;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }
}
```

#### With Riverpod

```dart
final gazeTrackerProvider = Provider((ref) => GazeTracker());

final gazeStreamProvider = StreamProvider.autoDispose<GazeResult>((ref) {
  final tracker = ref.watch(gazeTrackerProvider);
  return tracker.gazeStream;
});
```

## Use Cases

- 📊 **UX Research** - Heatmaps and attention tracking in apps
- ♿ **Accessibility** - Eye-controlled interfaces for users with disabilities
- 📚 **EdTech** - Student engagement and focus tracking
- 🎮 **Gaming** - Gaze-based game controls and interactions
- 🚗 **Automotive** - Driver attention monitoring apps
- 🏥 **Healthcare** - Medical diagnostics and therapy applications

## Troubleshooting

### Low Accuracy

- Ensure good lighting conditions
- Keep face 30-60 cm from device
- Perform calibration
- Check that camera lens is clean

### Low FPS / Performance Issues

- Close other apps using camera
- Reduce screen resolution if possible
- Check `PerformanceMetrics` for bottlenecks
- Ensure device is not in low power mode

### Tracking Stops Working

- Check camera permission status
- Verify app has foreground access
- Check logs for error messages
- Restart tracking: `stopTracking()` then `startTracking()`

### Permission Issues

- Ensure manifest/Info.plist is configured correctly
- Request permissions before starting tracking
- Handle permission denial gracefully in UI

## Performance Considerations

- **Target FPS**: 30 FPS for smooth tracking
- **Processing Time**: < 33ms per frame
- **Memory Usage**: ~20-30 MB
- **Battery Impact**: Moderate (camera + ML processing)

### Best Practices

1. Stop tracking when app goes to background
2. Dispose tracker when no longer needed
3. Use calibration for better accuracy
4. Monitor performance metrics regularly
5. Handle errors and edge cases gracefully

## Example App

Check the [example](example/) directory for a complete working app demonstrating all features.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## License

MIT License - See [LICENSE](LICENSE) file for details

## Support

- 📧 Email: support@gazepoint.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/GazePointSDK-Flutter/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/GazePointSDK-Flutter/discussions)

## Changelog

### 2.0.0 (2026-07-29)

- Initial release
- Cross-platform support (Android & iOS)
- Real-time gaze tracking
- Head pose compensation
- Blink detection
- Calibration support
- Performance monitoring
- Stream API
