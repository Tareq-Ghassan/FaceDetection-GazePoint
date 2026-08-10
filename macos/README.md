# GazePoint SDK for macOS

Native macOS implementation using Vision framework for real-time eye tracking and gaze point detection on macOS desktop applications.

## Features

- 🎯 Real-time gaze tracking at 30 FPS
- 👁️ Apple Vision framework face detection
- 📹 AVFoundation camera integration
- 🚀 Metal-accelerated processing
- 📊 Head pose estimation
- 👓 Blink detection
- 💻 AppKit and SwiftUI support
- 🎨 Swift 6.0 with async/await

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 6.0 or later

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Tareq-Ghassan/GazePointSDK-macOS.git", from: "2.0.0")
]
```

### CocoaPods

```ruby
pod 'GazePointSDK-macOS', '~> 2.0'
```

## Quick Start

```swift
import GazePointSDK

class ViewController: NSViewController {
    let gazeTracker = GazeTracker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            try await gazeTracker.initialize()
            
            gazeTracker.onGazeUpdate = { result in
                print("Gaze: \\(result.gazePoint)")
                print("Confidence: \\(result.confidence)")
            }
            
            try await gazeTracker.startTracking()
        }
    }
    
    deinit {
        gazeTracker.stopTracking()
    }
}
```

## Platform Support

- ✅ macOS 13.0+ (Ventura)
- ✅ AppKit applications
- ✅ SwiftUI applications
- ✅ Catalyst applications

## License

MIT License

## Links

- [Main Repository](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
- [Documentation](https://github.com/Tareq-Ghassan/GazePointSDK-macOS)
