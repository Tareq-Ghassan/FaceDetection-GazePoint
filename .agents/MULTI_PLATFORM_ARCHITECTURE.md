# GazePoint SDK Multi-Platform Architecture

This document explains the architecture of the GazePoint SDK across all supported platforms.

## 🏗️ Architecture Overview

GazePoint SDK follows a **native-first architecture** where each platform has its own **native SDK implementation**, and **Flutter acts as a unified wrapper** that provides a consistent API across all platforms.

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Application                        │
│                  (Cross-Platform API)                        │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │   Flutter Plugin    │
        │   (gazepoint_sdk)   │
        └──────────┬──────────┘
                   │
     ┌─────────────┴─────────────┐
     │   Platform Channels       │
     └──┬────┬────┬────┬────┬───┘
        │    │    │    │    │
   ┌────▼┐ ┌─▼──┐ ┌▼───┐ ┌▼──┐ ┌▼────┐ ┌▼─────┐
   │ iOS │ │And │ │Web │ │Win│ │macOS│ │Linux │
   │ SDK │ │ SDK│ │SDK │ │SDK│ │ SDK │ │ SDK  │
   └─────┘ └────┘ └────┘ └───┘ └─────┘ └──────┘
     ▲       ▲      ▲      ▲      ▲        ▲
     │       │      │      │      │        │
  Native  Native Native Native Native  Native
  Vision  ML Kit Media  WinRT Vision  OpenCV
  Frame   Face   Pipe   Face  Frame   dlib
  work    Det.   Mesh   API   work
```

## 📁 Repository Structure

```
FaceDetection-GazePoint/                 # Main umbrella repository
├── android/            →  [SUBMODULE]   # GazePointSDK-Android (+ example/)
│   └── gazepoint-sdk/
│       ├── src/main/kotlin/
│       └── build.gradle
├── ios/                →  [SUBMODULE]   # GazePointSDK-iOS
│   ├── Sources/GazePointSDK/
│   ├── Package.swift
│   └── GazePointSDK.podspec
├── web/                →  [WILL BE SUBMODULE] # GazePointSDK-Web
│   ├── src/
│   │   ├── core/
│   │   ├── utils/
│   │   └── types/
│   ├── package.json
│   └── tsconfig.json
├── windows/            →  [WILL BE SUBMODULE] # GazePointSDK-Windows
│   └── GazePoint.SDK.Windows/
│       ├── Core/
│       ├── Models/
│       └── GazePoint.SDK.Windows.csproj
├── macos/              →  [WILL BE SUBMODULE] # GazePointSDK-macOS
│   ├── Sources/GazePointSDK/
│   ├── Package.swift
│   └── GazePointSDK.podspec
├── linux/              →  [WILL BE SUBMODULE] # GazePointSDK-Linux
│   ├── src/
│   ├── include/gazepoint/
│   └── CMakeLists.txt
├── flutter/            →  [SUBMODULE]   # GazePointSDK-Flutter (+ example/)
│   ├── lib/
│   │   ├── gazepoint_sdk.dart
│   │   ├── gazepoint_sdk_web.dart
│   │   └── src/
│   ├── android/        (JitPack: GazePointSDK-Android)
│   ├── ios/            (source snapshot of GazePointSDK-iOS)
│   ├── lib/gazepoint_sdk_web.dart  (Dart + MediaPipe CDN; does not wrap GazePointSDK-Web)
│   ├── windows/        (wraps windows/)
│   ├── macos/          (Vision + AVFoundation under macos/gazepoint_sdk/Sources)
│   ├── linux/          (wraps linux/)
│   ├── example/
│   └── pubspec.yaml
├── README.md
└── .gitmodules
```

## 🎯 Platform SDK Details

### 1. Android SDK (Kotlin + ML Kit)

**Location**: `android/` (submodule: GazePointSDK-Android)

**Technology Stack**:
- Language: Kotlin
- Face Detection: Google ML Kit Face Detection
- Camera: CameraX 1.6.x
- Build: Gradle with Maven publishing

**Key Features**:
- 30 FPS tracking
- 468 facial landmarks
- ProGuard/R8 optimizations
- JitPack publishing ready

**Publishing**: JitPack (automatic from GitHub releases)

---

### 2. iOS SDK (Swift + Vision)

**Location**: `ios/` (submodule: GazePointSDK-iOS)

**Technology Stack**:
- Language: Swift 6.0
- Face Detection: Apple Vision framework
- Camera: AVFoundation
- Build: Swift Package Manager + CocoaPods

**Key Features**:
- 30 FPS tracking
- Native Vision landmarks
- Metal acceleration
- ARKit integration (future)

**Publishing**: 
- Swift Package Manager (GitHub releases)
- CocoaPods Trunk

---

### 3. Web SDK (TypeScript + MediaPipe)

**Location**: `web/` (will be submodule: GazePointSDK-Web)

**Technology Stack**:
- Language: TypeScript
- Face Detection: MediaPipe Face Mesh
- ML: TensorFlow.js
- Build: Webpack + TypeScript compiler

**Key Features**:
- WebGL acceleration
- 468 facial landmarks from MediaPipe
- WebRTC camera access
- WebAssembly for performance-critical code
- Works on mobile browsers

**Browser Support**:
- Chrome/Edge 90+
- Firefox 88+
- Safari 15+
- Opera 76+

**Publishing**: NPM (`@gazepoint/sdk-web`)

---

### 4. Windows SDK (C# + Windows Media)

**Location**: `windows/` (will be submodule: GazePointSDK-Windows)

**Technology Stack**:
- Language: C# / .NET 6.0
- Face Detection: Windows.Media.FaceAnalysis + ML.NET
- Camera: DirectShow / Media Foundation
- Build: MSBuild / .NET SDK

**Key Features**:
- DirectX acceleration
- Windows Hello face API integration
- UWP, WPF, WinUI 3 support
- Native Windows performance

**Target Platforms**:
- Windows 10 1809+
- Windows 11

**Publishing**: NuGet (`GazePoint.SDK.Windows`)

---

### 5. macOS SDK (Swift + Vision)

**Location**: `macos/` (will be submodule: GazePointSDK-macOS)

**Technology Stack**:
- Language: Swift 6.0
- Face Detection: Apple Vision framework (same as iOS)
- Camera: AVFoundation
- Build: Swift Package Manager + CocoaPods

**Key Features**:
- Metal acceleration
- AppKit and SwiftUI support
- Native macOS performance
- Catalyst app support

**Target Platforms**:
- macOS 13.0+ (Ventura)

**Publishing**:
- Swift Package Manager (GitHub releases)
- CocoaPods Trunk

---

### 6. Linux SDK (C++ + OpenCV)

**Location**: `linux/` (will be submodule: GazePointSDK-Linux)

**Technology Stack**:
- Language: C++17
- Face Detection: dlib (68 landmarks) + OpenCV
- Camera: Video4Linux2 (V4L2)
- Build: CMake

**Key Features**:
- OpenCV-accelerated processing
- dlib face detection
- Python bindings (optional)
- GTK and Qt support
- X11 and Wayland support

**Target Platforms**:
- Ubuntu 20.04+
- Debian 11+
- Fedora 35+
- Arch Linux

**Publishing**: Source (CMake install)

---

### 7. Flutter Plugin (Dart)

**Location**: `flutter/` (submodule: GazePointSDK-Flutter)

**Technology Stack**:
- Language: Dart 3.5+
- Platform Channels: MethodChannel + EventChannel
- Build: Flutter plugin architecture

**Purpose**: 
- Wraps all native SDKs
- Provides unified Dart API
- Handles platform-specific implementations
- Stream-based reactive API

**Publishing**: pub.dev (`gazepoint_sdk`)

---

## 🔄 Data Flow

### Initialization Flow

```
Flutter App
    │
    ├─> gazeTracker.initialize()
    │       │
    │       └─> Platform Channel
    │               │
    │               ├─> Android: Initialize ML Kit
    │               ├─> iOS: Initialize Vision
    │               ├─> Web: Load MediaPipe
    │               ├─> Windows: Initialize Media Foundation
    │               ├─> macOS: Initialize Vision
    │               └─> Linux: Initialize OpenCV + dlib
    │
    └─> gazeTracker.startTracking()
            │
            └─> Start platform-specific camera
```

### Gaze Update Flow

```
Native Platform SDK
    │
    ├─> Camera Frame
    │       │
    │       ├─> Face Detection
    │       │       │
    │       │       └─> Facial Landmarks
    │       │
    │       ├─> Head Pose Estimation
    │       │
    │       ├─> Gaze Calculation
    │       │
    │       └─> Kalman Filtering
    │
    └─> GazeResult {
            gazePoint: (x, y),
            confidence: 0.0-1.0,
            isBlinking: bool,
            headPose: {pitch, yaw, roll},
            timestamp: ms
        }
            │
            └─> Platform Channel (Event Stream)
                    │
                    └─> Flutter: gazeTracker.gazeStream
                            │
                            └─> App UI Update
```

## 📦 Creating GitHub Submodules

To set up the complete multi-platform architecture, each platform SDK should be in its own GitHub repository and added as a submodule:

### Step 1: Create Separate Repositories

Create these GitHub repositories:
1. `GazePointSDK-Web`
2. `GazePointSDK-Windows`
3. `GazePointSDK-macOS`
4. `GazePointSDK-Linux`

### Step 2: Move Code to Repositories

```bash
# For each platform, create a new repo and push:

# Web
cd web/
git init
git add .
git commit -m "Initial commit: Web SDK"
git remote add origin https://github.com/Tareq-Ghassan/GazePointSDK-Web.git
git push -u origin main

# Windows
cd windows/
git init
git add .
git commit -m "Initial commit: Windows SDK"
git remote add origin https://github.com/Tareq-Ghassan/GazePointSDK-Windows.git
git push -u origin main

# macOS
cd macos/
git init
git add .
git commit -m "Initial commit: macOS SDK"
git remote add origin https://github.com/Tareq-Ghassan/GazePointSDK-macOS.git
git push -u origin main

# Linux
cd linux/
git init
git add .
git commit -m "Initial commit: Linux SDK"
git remote add origin https://github.com/Tareq-Ghassan/GazePointSDK-Linux.git
git push -u origin main
```

### Step 3: Add as Submodules

```bash
cd FaceDetection-GazePoint/

# Remove directories (save changes first!)
rm -rf web/ windows/ macos/ linux/

# Add as submodules
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Web.git web
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Windows.git windows
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-macOS.git macos
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Linux.git linux

# Commit submodule additions
git add .gitmodules web windows macos linux
git commit -m "feat: add Web, Windows, macOS, and Linux SDKs as submodules"
git push
```

### Step 4: Update Flutter Plugin

The Flutter plugin in `flutter/` has Android (JitPack), iOS (source snapshot), macOS (Vision + AVFoundation under `macos/gazepoint_sdk/Sources`), and Web (`lib/gazepoint_sdk_web.dart`, MediaPipe CDN). Windows / Linux plugin implementations are still missing.

```
flutter/
├── android/            # References ../android/gazepoint-sdk
├── ios/                # References ../ios
├── web/                # Web platform channel
├── windows/            # References ../windows
├── macos/              # References ../macos  
└── linux/              # References ../linux
```

## 🚀 Usage Examples

### Flutter (Cross-Platform)

```dart
import 'package:gazepoint_sdk/gazepoint_sdk.dart';

final gazeTracker = GazeTracker();

await gazeTracker.initialize();
await gazeTracker.startTracking();

gazeTracker.gazeStream.listen((result) {
  print('Gaze: ${result.gazePoint}');
  print('Platform: ${Platform.operatingSystem}');
});
```

This same code works on **all 6 platforms** (Android, iOS, Web, Windows, macOS, Linux)!

### Native Android

```kotlin
import com.gazepoint.sdk.GazeTracker

val gazeTracker = GazeTracker(context)
val result = gazeTracker.calculateGazePoint(face)
```

### Native iOS/macOS

```swift
import GazePointSDK

let gazeTracker = GazeTracker()
try await gazeTracker.startTracking()
```

### Native Web

```typescript
import { GazeTracker } from '@gazepoint/sdk-web';

const tracker = new GazeTracker({ onGazeUpdate: (result) => {
    console.log(result.gazePoint);
}});
await tracker.start();
```

### Native Windows

```csharp
using GazePoint.SDK.Windows;

var tracker = new GazeTracker();
await tracker.InitializeAsync();
await tracker.StartTrackingAsync();
```

### Native Linux

```cpp
#include <gazepoint/GazeTracker.hpp>

gazepoint::GazeTracker tracker;
tracker.initialize();
tracker.startTracking();
```

## 🔧 Development Workflow

### Working on a Native SDK

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/Tareq-Ghassan/FaceDetection-GazePoint.git

# Work on specific platform
cd android/
# Make changes
git add .
git commit -m "feat: improve Android tracking"
git push

# Update main repo to point to new commit
cd ..
git add android
git commit -m "chore: update Android SDK submodule"
git push
```

### Working on Flutter Plugin

```bash
cd flutter/
# Make changes to Dart code or platform channels
git add .
git commit -m "feat: add new Flutter API"
git push

# Update main repo
cd ..
git add flutter
git commit -m "chore: update Flutter plugin submodule"
git push
```

## 📊 Platform Comparison

| Feature | Android | iOS | Web | Windows | macOS | Linux |
|---------|---------|-----|-----|---------|-------|-------|
| **Language** | Kotlin | Swift | TypeScript | C# | Swift | C++ |
| **Face Detection** | ML Kit | Vision | MediaPipe | ML.NET | Vision | dlib |
| **Landmarks** | 468 | Vision | 468 | Custom | Vision | 68 |
| **FPS** | 30 | 30 | 30 | 30 | 30 | 30 |
| **Min Version** | API 24 | iOS 16 | - | Win 10 | macOS 13 | Ubuntu 20.04 |
| **Publishing** | JitPack | SPM/Pods | NPM | NuGet | SPM/Pods | Source |

## 🎓 Benefits of This Architecture

1. **Native Performance**: Each platform uses its best-available APIs
2. **Platform Optimization**: Leverage platform-specific features
3. **Independent Development**: Each SDK can evolve independently
4. **Easy Maintenance**: Clear separation of concerns
5. **Flexible Integration**: Use native SDKs directly or via Flutter
6. **Consistent API**: Flutter provides unified interface
7. **Version Control**: Each SDK has its own versioning
8. **Parallel Development**: Teams can work on different platforms simultaneously

## 📝 Next Steps

1. ✅ Create native SDK implementations for each platform
2. ✅ Set up Flutter platform channels
3. 🔄 Create separate GitHub repositories for each platform
4. 🔄 Convert directories to Git submodules
5. 🔄 Publish each SDK to its respective package manager
6. 🔄 Create comprehensive examples for each platform
7. 🔄 Set up CI/CD for all platforms

---

**Last Updated**: August 10, 2026
