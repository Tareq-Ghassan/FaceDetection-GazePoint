# GazePoint SDK for Windows

Native Windows implementation using Windows.Media.FaceAnalysis and ML.NET for real-time eye tracking and gaze point detection on Windows 10/11 desktop applications.

## Features

- 🎯 Real-time gaze tracking at 30 FPS
- 👁️ Windows Media Foundation face detection
- 📹 DirectShow camera integration
- 🚀 Hardware-accelerated using DirectX
- 📊 Head pose estimation
- 👓 Blink detection
- 💻 UWP and WPF support
- 🎨 C# with async/await patterns

## Requirements

- Windows 10 version 1809 or later
- .NET 6.0 or later
- Camera with Windows Hello face authentication (optional, for best results)

## Installation

### NuGet

```powershell
Install-Package GazePoint.SDK.Windows
```

Or via .NET CLI:

```bash
dotnet add package GazePoint.SDK.Windows
```

## Quick Start

```csharp
using GazePoint.SDK.Windows;

// Create tracker
var tracker = new GazeTracker();

// Subscribe to gaze updates
tracker.GazeUpdated += (sender, result) => {
    Console.WriteLine($"Gaze Point: ({result.GazePoint.X}, {result.GazePoint.Y})");
    Console.WriteLine($"Confidence: {result.Confidence:P0}");
    Console.WriteLine($"Blinking: {result.IsBlinking}");
};

// Initialize and start
await tracker.InitializeAsync();
await tracker.StartTrackingAsync();

// Stop tracking
tracker.StopTracking();
```

## Platform Support

- ✅ Windows 10/11 Desktop
- ✅ UWP (Universal Windows Platform)
- ✅ WPF (Windows Presentation Foundation)
- ✅ WinUI 3
- ✅ Windows Forms

## Architecture

```
GazePointSDK-Windows/
├── GazePoint.SDK.Windows/
│   ├── Core/
│   │   ├── GazeTracker.cs
│   │   ├── FaceDetector.cs
│   │   ├── GazeEstimator.cs
│   │   └── HeadPoseEstimator.cs
│   ├── Utils/
│   │   ├── KalmanFilter.cs
│   │   ├── CameraManager.cs
│   │   └── MathUtils.cs
│   ├── Models/
│   │   ├── GazeResult.cs
│   │   ├── HeadPose.cs
│   │   └── CalibrationPoint.cs
│   └── GazePoint.SDK.Windows.csproj
├── GazePoint.SDK.Windows.Example/
│   ├── MainWindow.xaml
│   ├── MainWindow.xaml.cs
│   └── GazePoint.SDK.Windows.Example.csproj
├── Tests/
└── GazePoint.SDK.Windows.sln
```

## License

MIT License

## Links

- [Main Repository](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
- [Documentation](https://github.com/Tareq-Ghassan/GazePointSDK-Windows)
- [NuGet Package](https://www.nuget.org/packages/GazePoint.SDK.Windows)
