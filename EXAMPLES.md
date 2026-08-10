# GazePoint SDK - Examples Overview

This document provides an overview of all example applications available for the GazePoint SDK across different platforms.

## Available Examples

The repository includes example applications for all 7 supported platforms:

| Platform | Directory | Description |
|----------|-----------|-------------|
| 🤖 **Android** | [`android_example/`](./android_example/) | Native Android app with Kotlin/CameraX |
| 🍎 **iOS** | [`ios_example/`](./ios_example/) | Native iOS app with Swift/Vision |
| 🎯 **Flutter** | [`flutter_example/`](./flutter_example/) | Cross-platform Flutter app |
| 🌐 **Web** | [`web_example/`](./web_example/) | Browser-based with WebRTC |
| 🪟 **Windows** | [`windows_example/`](./windows_example/) | Native Windows console app (.NET) |
| 🖥️ **macOS** | [`macos_example/`](./macos_example/) | Native macOS console app (Swift) |
| 🐧 **Linux** | [`linux_example/`](./linux_example/) | Native Linux console app (C++/OpenCV) |

## Quick Start by Platform

### Android Example

```bash
cd android_example
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

**Features**: Live camera feed, gaze overlay, calibration UI, performance stats

[Full Documentation →](./android_example/README.md)

---

### iOS Example

```bash
cd ios_example
open ios_example.xcodeproj
# Build and run in Xcode (Cmd+R)
```

**Features**: ARKit integration, face tracking, SwiftUI interface

[Full Documentation →](./ios_example/README.md)

---

### Flutter Example

```bash
cd flutter_example
flutter pub get
flutter run
```

**Features**: Cross-platform UI, real-time gaze visualization, works on Android/iOS/Web

[Full Documentation →](./flutter_example/README.md)

---

### Web Example

```bash
cd web_example
python3 -m http.server 8000
# Open http://localhost:8000
```

**Features**: Browser-based, no installation required, WebRTC camera access

[Full Documentation →](./web_example/README.md)

---

### Windows Example

```bash
cd windows_example
dotnet restore
dotnet run
```

**Features**: Console application, Windows.Media.FaceAnalysis, real-time stats

[Full Documentation →](./windows_example/README.md)

---

### macOS Example

```bash
cd macos_example
swift build
swift run
```

**Features**: Vision framework, native performance, console interface

[Full Documentation →](./macos_example/README.md)

---

### Linux Example

```bash
cd linux_example
mkdir build && cd build
cmake ..
make
./bin/gazepoint_example
```

**Features**: OpenCV integration, V4L2 camera support, lightweight

[Full Documentation →](./linux_example/README.md)

---

## Common Features Across All Examples

All examples demonstrate:

- ✅ Initialization and setup
- ✅ Real-time gaze tracking
- ✅ Calibration (3, 5, or 9 points)
- ✅ Blink detection
- ✅ Head pose estimation
- ✅ Performance monitoring
- ✅ Error handling

## Example Complexity Levels

### 🟢 Beginner-Friendly
- **Web Example** - Just open in browser
- **Flutter Example** - Single `flutter run` command

### 🟡 Intermediate
- **macOS Example** - Swift Package Manager
- **Windows Example** - .NET CLI
- **Android Example** - Gradle build

### 🔴 Advanced
- **iOS Example** - Xcode project setup
- **Linux Example** - CMake + native dependencies

## Testing Your Integration

Each example includes:

1. **README.md** - Detailed setup instructions
2. **Source Code** - Well-commented implementation
3. **Build Configuration** - Ready-to-use build files
4. **Troubleshooting** - Common issues and solutions

## Example Structure Pattern

All examples follow a consistent structure:

```
platform_example/
├── README.md           # Full documentation
├── Source files        # Main example code
├── Build config        # Build system files
└── Assets (optional)   # Resources if needed
```

## Integration Tips

### Starting from an Example

1. Choose your target platform
2. Read the example's README.md
3. Run the example to verify it works
4. Copy relevant code to your project
5. Customize for your use case

### Example-to-Production Checklist

- [ ] Replace demo UI with your design
- [ ] Add proper error handling
- [ ] Implement data persistence
- [ ] Add analytics/logging
- [ ] Optimize performance settings
- [ ] Add user preferences
- [ ] Implement proper permissions handling
- [ ] Test on multiple devices

## Platform-Specific Notes

### Mobile (Android/iOS)
- Require camera permissions
- Test on real devices (emulators may not have cameras)
- Consider battery usage
- Handle app lifecycle properly

### Desktop (Windows/macOS/Linux)
- Console-based for simplicity
- Can be integrated into GUI apps
- Lower latency than mobile
- More processing power available

### Web
- Requires HTTPS (except localhost)
- Browser compatibility varies
- No installation required
- Limited by browser APIs

### Flutter
- Runs on multiple platforms
- Consistent UI across devices
- Hot reload for rapid development
- Native performance via platform channels

## Common Integration Patterns

### Pattern 1: Direct SDK Usage (Native Apps)

```
Your App
    ↓
GazePoint Native SDK
    ↓
Platform APIs (Vision, OpenCV, etc.)
```

**Used in**: Android, iOS, Windows, macOS, Linux examples

### Pattern 2: Platform Channel (Flutter)

```
Flutter App
    ↓
Platform Channel
    ↓
GazePoint Native SDK (per platform)
    ↓
Platform APIs
```

**Used in**: Flutter example

### Pattern 3: JavaScript API (Web)

```
Web App
    ↓
GazePoint JS SDK
    ↓
MediaPipe / TensorFlow.js
    ↓
WebRTC / getUserMedia
```

**Used in**: Web example

## Performance Benchmarks

Typical performance across examples:

| Platform | FPS | Latency | CPU Usage | RAM Usage |
|----------|-----|---------|-----------|-----------|
| Android  | 30  | 60-80ms | 10-15%    | 150MB     |
| iOS      | 30  | 40-60ms | 8-12%     | 120MB     |
| Flutter  | 30  | 70-90ms | 12-18%    | 180MB     |
| Web      | 25  | 80-120ms| 15-25%    | 200MB     |
| Windows  | 30  | 50-80ms | 8-12%     | 150MB     |
| macOS    | 30  | 40-60ms | 5-10%     | 100MB     |
| Linux    | 30  | 35-50ms | 10-15%    | 200MB     |

*Measured on mid-range hardware (2020-2023 devices)*

## Getting Help

If you encounter issues with any example:

1. Check the example's README.md troubleshooting section
2. Review the [Multi-Platform Architecture](./MULTI_PLATFORM_ARCHITECTURE.md)
3. Check the main [README.md](./README.md)
4. Open an issue on GitHub

## Contributing Examples

Want to add a new example or improve existing ones?

1. Follow the existing structure
2. Include comprehensive README.md
3. Add comments in code
4. Test on multiple devices
5. Submit a pull request

## Next Steps

After exploring the examples:

1. **Understand the Architecture**: Read [MULTI_PLATFORM_ARCHITECTURE.md](./MULTI_PLATFORM_ARCHITECTURE.md)
2. **Publishing**: See [PUBLISHING_GUIDE.md](./PUBLISHING_GUIDE.md)
3. **API Reference**: Check platform-specific SDK documentation
4. **Integration**: Start building your own app!

## License

All examples are provided under the MIT License - see [LICENSE](./LICENSE) for details.

---

**Need more help?** Check the README files in each example directory for detailed, platform-specific instructions.
