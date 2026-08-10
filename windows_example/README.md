# GazePoint SDK - Windows Example

This example demonstrates how to use the GazePoint SDK for Windows applications with real-time eye tracking using Windows Media Foundation and ML.NET.

## Features

- 👁️ Real-time eye tracking and gaze detection
- 📊 Performance statistics (FPS, latency, dropped frames)
- 🎯 9-point calibration system
- 👀 Blink detection
- 🎭 Head pose estimation (pitch, yaw, roll)
- ⚡ Low-latency processing (<100ms)

## Prerequisites

- Windows 10 (version 1903) or later
- .NET 6.0 SDK or later
- Webcam
- Visual Studio 2022 (recommended) or VS Code with C# extension

## Building the Example

### Using Visual Studio

1. Open `GazePointExample.csproj` in Visual Studio 2022
2. Restore NuGet packages (right-click solution → Restore NuGet Packages)
3. Build the solution (Ctrl+Shift+B)
4. Run the example (F5)

### Using Command Line

```bash
cd windows_example
dotnet restore
dotnet build
dotnet run
```

## Usage

When you run the example, it will:

1. Initialize the GazePoint tracker
2. Start eye tracking
3. Run a 9-point calibration
4. Display real-time gaze data

### Interactive Commands

While the example is running, you can use these keys:

- **C** - Run calibration
- **S** - Show performance statistics
- **R** - Restart tracking
- **Q** - Quit

### Output Example

```
═══════════════════════════════════════
   GazePoint SDK - Windows Example
═══════════════════════════════════════

Initializing GazePoint tracker...
✓ Tracker initialized successfully

Starting eye tracking...
✓ Tracking started

Running 9-point calibration...
✓ Calibration completed
  Average error: 45.23px
  Max error: 78.45px

👁️  Gaze: (856, 432) | Confidence: 92.5% | Head: P2.3° Y-1.8° R0.5°
```

## Architecture

The example demonstrates:

1. **Initialization**
   ```csharp
   var tracker = new GazeTracker();
   await tracker.InitializeAsync();
   ```

2. **Event Handling**
   ```csharp
   tracker.GazeDetected += OnGazeDetected;
   tracker.BlinkDetected += OnBlinkDetected;
   tracker.TrackingLost += OnTrackingLost;
   ```

3. **Starting Tracking**
   ```csharp
   await tracker.StartTrackingAsync();
   ```

4. **Calibration**
   ```csharp
   var result = await tracker.CalibrateAsync(9);
   ```

5. **Cleanup**
   ```csharp
   await tracker.StopTrackingAsync();
   tracker.Dispose();
   ```

## Performance

Expected performance on modern hardware:

- **Frame Rate**: 30 FPS
- **Latency**: 50-80ms
- **CPU Usage**: 5-10%
- **Memory**: ~150MB

## Troubleshooting

### Camera Not Detected
- Check if webcam is connected
- Ensure no other application is using the camera
- Grant camera permissions in Windows Settings

### Low Accuracy
- Ensure good lighting conditions
- Position face 50-80cm from the screen
- Run calibration again
- Avoid wearing glasses with strong reflections

### Build Errors
- Ensure .NET 6.0 SDK is installed: `dotnet --version`
- Restore NuGet packages: `dotnet restore`
- Clean and rebuild: `dotnet clean && dotnet build`

### Runtime Errors
- Check Windows version (requires Windows 10 1903+)
- Ensure Windows.Media.FaceAnalysis API is available
- Try running as Administrator

## Advanced Usage

### Custom Configuration

```csharp
var config = new TrackerConfig
{
    TargetFPS = 30,
    SmoothingFactor = 0.7,
    MinConfidence = 0.6,
    EnableBlinkDetection = true
};

var tracker = new GazeTracker(config);
```

### Saving Calibration

```csharp
var calibration = await tracker.CalibrateAsync(9);
await calibration.SaveToFileAsync("calibration.json");

// Load later
await tracker.LoadCalibrationAsync("calibration.json");
```

## Learn More

- [Windows SDK Documentation](../windows/README.md)
- [.NET API Reference](https://docs.microsoft.com/dotnet/)
- [Windows Media Foundation](https://docs.microsoft.com/windows/win32/medfound/)
- [Multi-Platform Architecture](../MULTI_PLATFORM_ARCHITECTURE.md)

## License

MIT License - see [LICENSE](../LICENSE) for details
