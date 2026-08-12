# GazePoint SDK

<div align="center">

![Version](https://img.shields.io/badge/version-3.0.3-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20windows%20%7C%20macos%20%7C%20linux-blue)](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
[![pub package](https://img.shields.io/pub/v/gazepoint_sdk.svg)](https://pub.dev/packages/gazepoint_sdk)

**Universal Eye Tracking and Gaze Point Detection**

*Real-time gaze tracking across all major platforms with native performance*

[Features](#-features) •
[Platforms](#-platform-support) •
[Quick Start](#-quick-start) •
[Examples](#-examples) •
[Documentation](#-documentation) •
[Architecture](#-architecture)

</div>

---

## 🌟 What is GazePoint SDK?

GazePoint SDK is a comprehensive, **universal eye tracking solution** that works seamlessly across Android, iOS, Web, Windows, macOS, and Linux. It enables developers to understand where users are looking on their screens in real-time, opening up possibilities for:

- 📊 **UX Research** - Understand user attention and interaction patterns
- ♿ **Accessibility** - Enable gaze-based interfaces for users with mobility limitations
- 🎮 **Gaming** - Create immersive gaming experiences with gaze controls
- 📈 **Engagement Analytics** - Measure content engagement and attention
- 🔬 **Research** - Conduct eye tracking studies across platforms
- 🎯 **Productivity** - Hands-free computer control

### What is a Gaze Point?

A **gaze point** represents where a user is looking at a specific moment in time. The SDK calculates these points by:

1. **Detecting the face** using advanced ML models
2. **Identifying eye landmarks** for precise pupil tracking
3. **Computing head pose** (pitch, yaw, roll angles)
4. **Calculating gaze vectors** with head pose compensation
5. **Mapping to screen coordinates** with Kalman filtering for smoothness

<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/57a5b78c-5f7c-4e56-8200-eda9ce83f79b" alt="Gaze Point Detection" height="250"/>

---

## ✨ Features

### Core Capabilities

- 🎯 **Real-time Gaze Tracking** - 30 FPS tracking with sub-100ms latency
- 🧠 **Head Pose Compensation** - Accurate tracking regardless of head position
- 👁️ **Blink Detection** - Real-time eye state monitoring using Eye Aspect Ratio
- 📐 **Kalman Filtering** - Smooth, natural gaze point movement
- 🎨 **Adaptive Smoothing** - Velocity-based smoothing for optimal precision
- 🎲 **Multi-Point Calibration** - Improve accuracy with 3-9 calibration points
- 📊 **Performance Monitoring** - Built-in FPS, latency, and dropped frame tracking
- 👥 **Multi-Face Support** - Detect and track multiple faces simultaneously

### Platform-Specific Technologies

- **Android** - CameraX + ML Kit Face Detection
- **iOS** - AVFoundation + Vision Framework
- **Web** - MediaPipe Face Mesh + TensorFlow.js
- **Windows** - Windows.Media.FaceAnalysis + ML.NET
- **macOS** - AVFoundation + Vision Framework
- **Linux** - OpenCV + dlib + Video4Linux2

---

## 📱 Platform Support

| Platform | Min Version | Technologies | Package | Status |
|----------|-------------|--------------|---------|--------|
| 🤖 **Android** | API 24+ | Kotlin, CameraX, ML Kit | [JitPack](https://jitpack.io/#Tareq-Ghassan/GazePointSDK-Android) | ✅ Stable |
| 🍎 **iOS** | 16.0+ | Swift, Vision, AVFoundation | [SPM](https://github.com/Tareq-Ghassan/GazePointSDK-iOS) / [CocoaPods](https://cocoapods.org) | ✅ Stable |
| 🌐 **Web** | Modern Browsers | TypeScript, MediaPipe, TF.js | [NPM](https://www.npmjs.com/) | ✅ Stable |
| 🪟 **Windows** | 10 (1903+) | C#, ML.NET, .NET 6+ | [NuGet](https://www.nuget.org/) | ✅ Stable |
| 🖥️ **macOS** | 12.0+ | Swift, Vision, AVFoundation | [SPM](https://github.com/Tareq-Ghassan/GazePointSDK-macOS) | ✅ Stable |
| 🐧 **Linux** | Ubuntu 20.04+ | C++, OpenCV, dlib | Source | ✅ Stable |
| 🎯 **Flutter** | 3.38.4+ | Dart 3.5+, Platform Channels | [pub.dev](https://pub.dev/packages/gazepoint_sdk) | ✅ Stable |

---

## 🚀 Quick Start

### Flutter (Recommended)

Get started with our Flutter plugin for cross-platform development:

```yaml
dependencies:
  gazepoint_sdk: ^3.0.3
```

```dart
import 'package:gazepoint_sdk/gazepoint_sdk.dart';

final tracker = GazeTracker();
await tracker.initialize();

if (await tracker.requestCameraPermission()) {
  await tracker.startTracking();
  
  tracker.gazeStream.listen((result) {
    print('Gaze: ${result.gazePoint}');
    print('Confidence: ${result.confidence}');
  });
}
```

👉 **[Full Flutter Documentation →](flutter/README.md)**

### Native Platforms

Each platform has its own native SDK implementation:

- 🤖 **Android** - [GazePointSDK-Android](https://github.com/Tareq-Ghassan/GazePointSDK-Android)
- 🍎 **iOS** - [GazePointSDK-iOS](https://github.com/Tareq-Ghassan/GazePointSDK-iOS)
- 🌐 **Web** - [GazePointSDK-Web](https://github.com/Tareq-Ghassan/GazePointSDK-Web)
- 🪟 **Windows** - [GazePointSDK-Windows](https://github.com/Tareq-Ghassan/GazePointSDK-Windows)
- 🖥️ **macOS** - [GazePointSDK-macOS](https://github.com/Tareq-Ghassan/GazePointSDK-macOS)
- 🐧 **Linux** - [GazePointSDK-Linux](https://github.com/Tareq-Ghassan/GazePointSDK-Linux)

---

## 📚 Examples

Each platform ships its example **inside that SDK repo** (clone one repo, run the demo):

- **[Flutter](https://github.com/Tareq-Ghassan/GazePointSDK-Flutter/tree/main/example)**
- **[Android](https://github.com/Tareq-Ghassan/GazePointSDK-Android/tree/main/example)**
- **[iOS](https://github.com/Tareq-Ghassan/GazePointSDK-iOS/tree/main/Example)**
- **[Web](https://github.com/Tareq-Ghassan/GazePointSDK-Web/tree/main/example)**
- **[Windows](https://github.com/Tareq-Ghassan/GazePointSDK-Windows/tree/main/example)**
- **[macOS](https://github.com/Tareq-Ghassan/GazePointSDK-macOS/tree/main/example)**
- **[Linux](https://github.com/Tareq-Ghassan/GazePointSDK-Linux/tree/main/example)**

👉 **[Examples catalog →](EXAMPLES.md)** · **[How to test every SDK →](TESTING.md)**

---

## 🏗️ Architecture

GazePoint SDK uses **one GitHub repository per platform**. This umbrella only pins submodule SHAs for people who want everything in one checkout.

```
FaceDetection-GazePoint/          # optional umbrella (lockfile + docs)
├── android/   → GazePointSDK-Android   (example/ inside that repo)
├── ios/       → GazePointSDK-iOS       (Example/ inside that repo)
├── flutter/   → GazePointSDK-Flutter   (example/ inside that repo)
├── web/       → GazePointSDK-Web
├── windows/   → GazePointSDK-Windows
├── macos/     → GazePointSDK-macOS
└── linux/     → GazePointSDK-Linux
```

Changing Android (or any other SDK) is a commit + tag **in that repository only**. Do not create matching branches across repos. See [`.agents/WORKFLOW_RULES.md`](.agents/WORKFLOW_RULES.md).

---

## 📖 Documentation

### Getting Started

- 📦 **Installation** - Platform-specific setup guides in each SDK repository
- 🎯 **Quick Start** - See examples above and in the [Examples Guide](EXAMPLES.md)
- 🔧 **API Reference** - Full API documentation in [Flutter README](flutter/README.md)

### Advanced Topics

- 📊 **Performance Optimization** - Tips for achieving best performance
- 🎨 **Calibration** - Multi-point calibration guide
- 🐛 **Troubleshooting** - Common issues and solutions
- 🔌 **Platform Integration** - Platform-specific integration guides

### For Contributors

- 🛠️ **[Publishing Guide](PUBLISHING_GUIDE.md)** - How to publish packages
- 📝 **[Examples Guide](EXAMPLES.md)** - Overview of all examples
- 🤖 **[Agent Files](.agents/)** - Setup scripts and internal documentation

---

## 📊 Performance

Expected performance across platforms:

| Metric | Target | Notes |
|--------|--------|-------|
| **Frame Rate** | 30 FPS | Consistent across platforms |
| **Latency** | 50-100ms | Lower on desktop platforms |
| **Accuracy** | 1-2° visual | After calibration |
| **CPU Usage** | 5-15% | Varies by device |
| **Memory** | 100-200 MB | Depends on resolution |

### Optimization Tips

1. **Run Calibration** - Improves accuracy by 50-80%
2. **Good Lighting** - Ensure face is well-lit
3. **Optimal Distance** - 50-80cm from camera
4. **Center Face** - Keep face in camera view
5. **High-End Hardware** - Better performance on newer devices

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. 🐛 **Report Bugs** - [Open an issue](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/issues)
2. 💡 **Suggest Features** - Share your ideas
3. 📝 **Improve Documentation** - Help make docs clearer
4. 🔧 **Submit Pull Requests** - Fix bugs or add features

### Development Setup

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/Tareq-Ghassan/FaceDetection-GazePoint.git

# Or if already cloned
cd FaceDetection-GazePoint
git submodule update --init --recursive
```

---

## 📝 License

MIT License - Copyright (c) 2024-2026 Tareq Abu Saleh

See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Google ML Kit** team for Android face detection
- **Apple Vision** framework team for iOS/macOS support
- **MediaPipe** team for web face tracking
- **OpenCV** community for computer vision tools
- **Flutter** team for amazing cross-platform framework
- All **contributors** who have helped improve this project

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/discussions)
- **Flutter Package**: [pub.dev/packages/gazepoint_sdk](https://pub.dev/packages/gazepoint_sdk)

---

## 🌟 Star History

If you find this project useful, please consider giving it a star ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=Tareq-Ghassan/FaceDetection-GazePoint&type=Date)](https://star-history.com/#Tareq-Ghassan/FaceDetection-GazePoint&Date)

---

<div align="center">

**Made with ❤️ by [Tareq Ghassan](https://github.com/Tareq-Ghassan)**

[⬆ Back to Top](#gazepoint-sdk)

</div>
