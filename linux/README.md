# GazePoint SDK for Linux

Native Linux implementation using OpenCV and dlib for real-time eye tracking and gaze point detection on Linux desktop applications.

## Features

- 🎯 Real-time gaze tracking at 30 FPS
- 👁️ dlib face detection with 68 facial landmarks
- 📹 V4L2 camera support
- 🚀 OpenCV-accelerated processing
- 📊 Head pose estimation
- 👓 Blink detection
- 💻 GTK and Qt support
- 🎨 C++ with Python bindings

## Requirements

- Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- GCC 11+ or Clang 13+
- CMake 3.20+
- OpenCV 4.5+
- dlib 19.24+

## Installation

### From Source

```bash
git clone https://github.com/Tareq-Ghassan/GazePointSDK-Linux.git
cd GazePointSDK-Linux
mkdir build && cd build
cmake ..
make
sudo make install
```

### Python Package

```bash
pip install gazepoint-sdk-linux
```

## Quick Start (C++)

```cpp
#include <gazepoint/GazeTracker.hpp>

int main() {
    gazepoint::GazeTracker tracker;
    
    tracker.onGazeUpdate = [](const gazepoint::GazeResult& result) {
        std::cout << "Gaze: (" << result.gazePoint.x << ", " << result.gazePoint.y << ")" << std::endl;
        std::cout << "Confidence: " << result.confidence << std::endl;
    };
    
    tracker.initialize();
    tracker.startTracking();
    
    // Run tracking loop
    while (tracker.isTracking()) {
        tracker.processFrame();
    }
    
    return 0;
}
```

## Quick Start (Python)

```python
from gazepoint import GazeTracker

tracker = GazeTracker()

@tracker.on_gaze_update
def handle_gaze(result):
    print(f"Gaze: ({result.gaze_point.x}, {result.gaze_point.y})")
    print(f"Confidence: {result.confidence}")

tracker.initialize()
tracker.start_tracking()
```

## Platform Support

- ✅ Ubuntu 20.04+ / Debian 11+
- ✅ Fedora 35+ / RHEL 8+
- ✅ Arch Linux
- ✅ X11 and Wayland

## License

MIT License

## Links

- [Main Repository](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
- [Documentation](https://github.com/Tareq-Ghassan/GazePointSDK-Linux)
