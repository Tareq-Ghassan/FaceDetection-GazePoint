# GazePoint SDK - Linux Example

This example demonstrates how to use the GazePoint SDK for Linux applications with real-time eye tracking using OpenCV and dlib.

## Features

- 👁️ Real-time eye tracking and gaze detection
- 📊 Performance statistics (FPS, latency, dropped frames)
- 🎯 9-point calibration system
- 👀 Blink detection using Eye Aspect Ratio (EAR)
- 🎭 Head pose estimation (pitch, yaw, roll)
- ⚡ Low-latency processing with OpenCV

## Prerequisites

- Linux (Ubuntu 20.04+ / Debian 11+ / Fedora 35+ / Arch Linux)
- C++17 compatible compiler (GCC 9+ or Clang 10+)
- CMake 3.16 or later
- OpenCV 4.x
- Video4Linux2 (v4l2)
- Webcam

## Installing Dependencies

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    libopencv-dev \
    v4l-utils \
    pkg-config
```

### Fedora

```bash
sudo dnf install -y \
    gcc-c++ \
    cmake \
    opencv-devel \
    v4l-utils \
    pkgconfig
```

### Arch Linux

```bash
sudo pacman -S \
    base-devel \
    cmake \
    opencv \
    v4l-utils
```

## Building the Example

```bash
cd linux_example
mkdir build
cd build
cmake ..
make
```

## Running the Example

```bash
./bin/gazepoint_example
```

Or from the project root:

```bash
cd linux_example/build
./bin/gazepoint_example
```

## Usage

When you run the example, it will:

1. Initialize the GazePoint tracker
2. Open the webcam
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
   GazePoint SDK - Linux Example
═══════════════════════════════════════

Initializing GazePoint tracker...
✓ Tracker initialized successfully

Starting eye tracking...
✓ Tracking started

Running 9-point calibration...
✓ Calibration completed
  Average error: 38.45px
  Max error: 65.12px

👁️  Gaze: (1280, 720) | Confidence: 95.8% | Head: P1.2° Y-0.8° R0.3°
```

## Architecture

The example demonstrates:

1. **Initialization**
   ```cpp
   GazeTracker tracker;
   tracker.initialize();
   ```

2. **Event Handling**
   ```cpp
   tracker.setGazeCallback(onGazeDetected);
   tracker.setBlinkCallback(onBlinkDetected);
   tracker.setTrackingLostCallback(onTrackingLost);
   ```

3. **Starting Tracking**
   ```cpp
   tracker.startTracking();
   ```

4. **Calibration**
   ```cpp
   auto result = tracker.calibrate(9);
   ```

5. **Cleanup**
   ```cpp
   tracker.stopTracking();
   ```

## Performance

Expected performance on modern hardware:

- **Frame Rate**: 30 FPS
- **Latency**: 35-50ms
- **CPU Usage**: 8-15%
- **Memory**: ~200MB

## Troubleshooting

### Camera Not Detected

Check available cameras:
```bash
v4l2-ctl --list-devices
```

Test camera:
```bash
ffplay /dev/video0
```

Ensure permissions:
```bash
sudo usermod -a -G video $USER
# Log out and back in
```

### Build Errors

Check OpenCV installation:
```bash
pkg-config --modversion opencv4
```

If not found, install development files:
```bash
# Ubuntu/Debian
sudo apt install libopencv-dev

# Fedora
sudo dnf install opencv-devel
```

### Low Accuracy
- Ensure good lighting conditions
- Position face 50-80cm from the screen
- Run calibration again
- Check camera focus

### Runtime Errors

**Symbol not found:**
```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

**Permission denied:**
```bash
sudo chmod 666 /dev/video0
```

## Advanced Usage

### Custom Camera Configuration

```cpp
TrackerConfig config;
config.cameraIndex = 0;  // /dev/video0
config.targetFPS = 30;
config.resolution = {1280, 720};
config.smoothingFactor = 0.7;

GazeTracker tracker(config);
```

### Saving Calibration

```cpp
auto calibration = tracker.calibrate(9);
calibration.saveToFile("calibration.json");

// Load later
tracker.loadCalibration("calibration.json");
```

### Integration with GTK+

```cpp
#include <gtk/gtk.h>
#include <gazepoint/GazeTracker.hpp>

static void on_gaze_detected(const GazeResult& result, gpointer user_data) {
    GtkWidget* overlay = GTK_WIDGET(user_data);
    // Update overlay position
    gtk_widget_queue_draw(overlay);
}

int main(int argc, char* argv[]) {
    gtk_init(&argc, &argv);
    
    GazeTracker tracker;
    tracker.initialize();
    tracker.setGazeCallback([](const GazeResult& r) {
        // Handle gaze
    });
    tracker.startTracking();
    
    // ... GTK+ setup ...
    
    gtk_main();
    return 0;
}
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Ubuntu 20.04 | Ubuntu 22.04+ |
| CPU | Dual-core 2.0 GHz | Quad-core 2.5+ GHz |
| RAM | 4 GB | 8 GB+ |
| Camera | 720p @ 30fps | 1080p @ 30fps |

## Learn More

- [Linux SDK Documentation](../linux/README.md)
- [OpenCV Documentation](https://docs.opencv.org/)
- [Video4Linux2 API](https://www.kernel.org/doc/html/latest/userspace-api/media/v4l/v4l2.html)
- [Multi-Platform Architecture](../MULTI_PLATFORM_ARCHITECTURE.md)

## License

MIT License - see [LICENSE](../LICENSE) for details
