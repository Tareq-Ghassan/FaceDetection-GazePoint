# GazePoint SDK

<div align="center">

![GazePoint SDK](https://img.shields.io/badge/version-2.0.0-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Android](https://img.shields.io/badge/Android-24%2B-green.svg)](https://developer.android.com)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B.svg)](https://flutter.dev)

**Advanced Eye Tracking and Gaze Point Detection for Mobile Applications**

[Features](#-features) •
[Platforms](#-platform-support) •
[Quick Start](#-quick-start) •
[Documentation](#-documentation) •
[Use Cases](#-use-cases) •
[Contributing](#-contributing)

</div>

---

## 🌟 What is GazePoint SDK?

GazePoint SDK is a comprehensive, cross-platform solution for eye tracking and gaze point detection on mobile devices. It enables developers to understand where users are looking on their screens in real-time, opening up possibilities for UX research, accessibility features, engagement tracking, and innovative user interactions.

### What is a Gaze Point?

Gaze points are the fundamental units of measurement in eye tracking. Each gaze point represents an individual record of where a user is looking at a specific moment. The SDK calculates these points by:

1. **Detecting the face** using advanced ML models
2. **Identifying eye landmarks** for both left and right eyes
3. **Computing head pose** (pitch, yaw, roll angles)
4. **Calculating gaze vectors** with head pose compensation
5. **Mapping to screen coordinates** with Kalman filtering for smoothness

<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/57a5b78c-5f7c-4e56-8200-eda9ce83f79b" alt="What is a Gaze Point" height="250"/>

---

## ✨ Features

### Core Capabilities

- ✅ **Real-time Gaze Tracking** - 30 FPS tracking with sub-100ms latency
- ✅ **Head Pose Compensation** - Accurate tracking regardless of head position
- ✅ **Blink Detection** - Real-time eye state monitoring using Eye Aspect Ratio
- ✅ **Kalman Filtering** - Smooth, natural gaze point movement
- ✅ **Adaptive Smoothing** - Velocity-based smoothing for precision vs. smoothness balance
- ✅ **Multi-Point Calibration** - Improve accuracy with 3-9 calibration points
- ✅ **Performance Monitoring** - Built-in FPS, latency, and dropped frame tracking
- ✅ **Multi-Face Support** - Detect and track multiple faces, focus on primary face

### Platform-Specific Enhancements

#### Android
- CameraX 1.4.1 integration for optimized camera handling
- ML Kit face detection with latest models
- Kotlin coroutines for efficient async operations
- ProGuard/R8 optimizations for production builds

#### iOS
- Vision framework integration for native performance
- ARKit support for enhanced accuracy (coming soon)
- Swift 6.3.3 with modern concurrency
- SwiftUI and UIKit compatible

#### Flutter
- Cross-platform API with platform channels
- Stream-based reactive API
- State management friendly (Provider, Riverpod, Bloc)
- Works on both Android and iOS from single codebase

---

## 📱 Platform Support

| Platform | Version | Technologies | Status |
|----------|---------|--------------|--------|
| **Android** | API 24+ (Android 7.0+) | Kotlin, CameraX, ML Kit | ✅ Stable |
| **iOS** | iOS 26.6+ | Swift 6.3.3, Vision, ARKit | ✅ Stable |
| **Flutter** | Flutter 3.44.7+ | Dart 3.5+, Platform Channels | ✅ Stable |

---

## 🚀 Quick Start

### Choose Your Platform

<details>
<summary><b>Android (Kotlin/Java)</b></summary>

#### Installation

Add to your `app/build.gradle`:

```gradle
dependencies {
    implementation 'com.gazepoint:android-sdk:2.0.0'
}
```

#### Basic Usage

```kotlin
import com.facedetection.gaze.GazeTracker

class MainActivity : AppCompatActivity() {
    private val gazeTracker = GazeTracker(this)
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Setup camera and face detection
        val result = gazeTracker.calculateGazePoint(face)
        result?.let {
            Log.d("Gaze", "Point: ${it.gazePoint}")
            Log.d("Gaze", "Confidence: ${it.confidence}")
            Log.d("Gaze", "Blinking: ${it.isBlinking}")
        }
    }
}
```

📖 [Full Android Documentation](android/README.md)

</details>

<details>
<summary><b>iOS (Swift)</b></summary>

#### Installation

**Swift Package Manager:**

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GazePointSDK-iOS", from: "2.0.0")
]
```

#### Basic Usage

```swift
import GazePointSDK

class GazeViewController: UIViewController {
    let gazeTracker = GazeTracker()
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        if let result = gazeTracker.calculateGazePoint(from: pixelBuffer) {
            print("Gaze: \(result.gazePoint)")
            print("Confidence: \(result.confidence)")
            print("Blinking: \(result.isBlinking)")
        }
    }
}
```

📖 [Full iOS Documentation](ios/README.md)

</details>

<details>
<summary><b>Flutter (Cross-Platform)</b></summary>

#### Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  gazepoint_sdk: ^2.0.0
```

#### Basic Usage

```dart
import 'package:gazepoint_sdk/gazepoint_sdk.dart';

class GazeScreen extends StatefulWidget {
  @override
  _GazeScreenState createState() => _GazeScreenState();
}

class _GazeScreenState extends State<GazeScreen> {
  final gazeTracker = GazeTracker();
  Offset gazePoint = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    initGazeTracking();
  }
  
  Future<void> initGazeTracking() async {
    await gazeTracker.initialize();
    await gazeTracker.startTracking();
    
    gazeTracker.gazeStream.listen((result) {
      setState(() {
        gazePoint = result.gazePoint;
      });
      print('Gaze: ${result.gazePoint}');
      print('Confidence: ${(result.confidence * 100).toInt()}%');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your UI here
        Positioned(
          left: gazePoint.dx - 10,
          top: gazePoint.dy - 10,
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
    );
  }
}
```

📖 [Full Flutter Documentation](flutter/README.md)

</details>

---

## 📊 Detection Scenarios

The SDK handles various face detection scenarios:

### 1. ✅ Best Case: Face and Both Eyes Detected
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/f8e2a1e5-157d-4619-b3b9-517b2f72dcee" alt="Best case scenario" height="250"/>

Full tracking with high confidence, head pose compensation, and smooth gaze points.

### 2. ⚠️ No Face Detected
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/dff2b8b9-f1d5-43cd-baf7-83c73051acdc" alt="No face detected" height="250"/>

SDK returns null or error state, allowing graceful handling.

### 3. ⚠️ Face Detected, Eyes Unclear
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/90b7545c-fefb-4198-8aba-ae7702fb1d07" alt="Eyes not clear" height="250"/>

SDK returns low confidence score, app can decide whether to use data or prompt user.

### 4. 👥 Multiple Faces Detected
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/0bf69c13-75cf-42d6-9b0a-202d2f9d966b" alt="Multiple faces" height="250"/>

SDK automatically selects primary face (largest, closest to center, or tracked).

---

## 🎯 Use Cases

### 🔬 UX Research & Analytics
- Generate heatmaps of user attention
- A/B test UI layouts based on visual attention
- Understand user reading patterns
- Optimize content placement

### ♿ Accessibility
- Eye-controlled interfaces for users with motor disabilities
- Hands-free navigation
- Assistive technology integration
- Alternative input methods

### 📚 Education & EdTech
- Student engagement tracking during lessons
- Attention span analysis
- Adaptive learning based on focus
- Reading comprehension assessment

### 🎮 Gaming & Entertainment
- Gaze-based game controls
- Immersive interactive experiences
- Adaptive difficulty based on attention
- Novel gameplay mechanics

### 🛍️ E-Commerce & Retail
- Product attention analytics
- Virtual try-on experiences
- Conversion optimization insights
- User journey analysis

### 🚗 Automotive & Safety
- Driver attention monitoring
- Distraction detection
- Fatigue assessment
- Safety compliance

### 💼 Enterprise & Productivity
- Meeting engagement analytics
- Training effectiveness measurement
- Focus and productivity tracking
- Workplace ergonomics assessment

---

## 📖 Documentation

### Platform-Specific Guides

- 🤖 [Android SDK Documentation](android/README.md)
- 🍎 [iOS SDK Documentation](ios/README.md)
- 🎯 [Flutter Plugin Documentation](flutter/README.md)

### Additional Resources

- 📘 [Submodules Setup Guide](SUBMODULES_SETUP.md) - Working with Git submodules
- 🔧 [API Reference](docs/API.md) - Detailed API documentation (coming soon)
- 📊 [Performance Tuning](docs/PERFORMANCE.md) - Optimization guide (coming soon)
- 🎨 [UI Integration Examples](examples/) - Sample applications (coming soon)
- 🧪 [Testing Guide](docs/TESTING.md) - Unit and integration testing (coming soon)

---

## 🏗️ Repository Structure

This repository uses Git submodules to organize platform-specific SDKs:

```
GazePointSDK/
├── android/          → GazePointSDK-Android (submodule)
│   ├── app/
│   ├── build.gradle
│   └── README.md
├── ios/              → GazePointSDK-iOS (submodule)
│   ├── Sources/
│   ├── Package.swift
│   └── README.md
├── flutter/          → GazePointSDK-Flutter (submodule)
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
├── docs/             → Documentation
├── examples/         → Sample applications
├── .gitignore
├── README.md         → This file
├── LICENSE
└── SUBMODULES_SETUP.md
```

### Cloning with Submodules

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/yourusername/GazePointSDK.git

# Or if already cloned:
git submodule update --init --recursive
```

📖 See [SUBMODULES_SETUP.md](SUBMODULES_SETUP.md) for detailed submodule management.

---

## 🤝 Contributing

We welcome contributions! Whether it's:

- 🐛 Bug reports and fixes
- ✨ New features
- 📚 Documentation improvements
- 🧪 Test coverage
- 🎨 UI/UX enhancements

Please read our [Contributing Guide](CONTRIBUTING.md) (coming soon) for details on our code of conduct and the process for submitting pull requests.

### Development Setup

1. Clone the repository with submodules
2. Choose your platform and navigate to the respective directory
3. Follow platform-specific setup instructions
4. Make your changes
5. Submit a pull request

---

## 📊 Roadmap

### Version 2.1 (Q4 2026)
- [ ] Web support (WebAssembly)
- [ ] ARKit integration for iOS
- [ ] Improved calibration UI components
- [ ] Cloud-based calibration profiles

### Version 2.2 (Q1 2027)
- [ ] React Native wrapper
- [ ] Unity plugin
- [ ] Real-time analytics dashboard
- [ ] Multi-user tracking

### Version 3.0 (Q2 2027)
- [ ] AI-powered attention prediction
- [ ] Emotion detection
- [ ] Fatigue detection
- [ ] Advanced privacy features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author & Contact

**Original Author:** [Tareq Ghassan](https://www.linkedin.com/in/Tareq-ghassan)

**SDK Enhancement & Multi-Platform:** GazePoint Team

### Get in Touch

- 📧 Email: support@gazepoint.com
- 💬 GitHub Issues: [Report a bug](https://github.com/yourusername/GazePointSDK/issues)
- 💡 GitHub Discussions: [Feature requests](https://github.com/yourusername/GazePointSDK/discussions)
- 🐦 Twitter: [@GazePointSDK](https://twitter.com/GazePointSDK)

---

## 🙏 Acknowledgments

- Google ML Kit team for face detection models
- Apple Vision framework team
- CameraX team for Android camera APIs
- Flutter team for cross-platform framework
- All contributors and supporters

---

## 📹 Demo

[View Demo Video](https://drive.google.com/file/d/1gXo4yceQTww4hI5zgYV7oBvWIEw0lSWn/view?usp=sharing)

---

<div align="center">

**Made with ❤️ for developers building the future of human-computer interaction**

[⬆ Back to Top](#gazepoint-sdk)

</div>
