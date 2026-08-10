# GazePoint SDK for Web

Native Web implementation of GazePoint SDK using MediaPipe Face Mesh and TensorFlow.js for real-time eye tracking and gaze point detection in web browsers.

## Features

- 🎯 Real-time gaze tracking using WebGL acceleration
- 👁️ Face mesh detection with 468 facial landmarks
- 📹 WebRTC camera access with optimized frame processing
- 🚀 WebAssembly-accelerated calculations
- 📊 Head pose estimation (pitch, yaw, roll)
- 👓 Blink detection using Eye Aspect Ratio (EAR)
- 🎨 TypeScript with full type definitions
- 📱 Responsive and works on mobile browsers

## Browser Support

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 15+ (iOS 15+)
- ✅ Opera 76+

## Installation

### NPM

```bash
npm install @gazepoint/sdk-web
```

### CDN

```html
<script src="https://cdn.jsdelivr.net/npm/@gazepoint/sdk-web@2.0.0/dist/gazepoint.min.js"></script>
```

## Quick Start

```typescript
import { GazeTracker } from '@gazepoint/sdk-web';

// Initialize tracker
const tracker = new GazeTracker({
  videoElement: document.getElementById('video'),
  onGazeUpdate: (result) => {
    console.log('Gaze Point:', result.gazePoint);
    console.log('Confidence:', result.confidence);
    console.log('Blinking:', result.isBlinking);
  }
});

// Start tracking
await tracker.initialize();
await tracker.start();

// Stop tracking
tracker.stop();
```

## API Reference

### `GazeTracker`

Main class for eye tracking operations.

#### Constructor

```typescript
new GazeTracker(options: GazeTrackerOptions)
```

**Options:**
- `videoElement?: HTMLVideoElement` - Video element for camera feed
- `canvasElement?: HTMLCanvasElement` - Canvas for visualization
- `onGazeUpdate?: (result: GazeResult) => void` - Callback for gaze updates
- `modelPath?: string` - Custom path to ML models
- `targetFPS?: number` - Target frame rate (default: 30)

#### Methods

##### `initialize(): Promise<void>`

Initialize the tracker and load ML models.

##### `start(): Promise<void>`

Start camera and begin tracking.

##### `stop(): void`

Stop tracking and release camera.

##### `calibrate(points: CalibrationPoint[]): Promise<void>`

Calibrate tracker with custom points.

##### `getPerformanceMetrics(): PerformanceMetrics`

Get current performance statistics.

### Types

#### `GazeResult`

```typescript
interface GazeResult {
  gazePoint: { x: number; y: number };
  confidence: number;
  isBlinking: boolean;
  headPose: {
    pitch: number;
    yaw: number;
    roll: number;
  };
  timestamp: number;
}
```

## Architecture

```
GazePointSDK-Web/
├── src/
│   ├── core/
│   │   ├── GazeTracker.ts       # Main tracker class
│   │   ├── FaceDetector.ts      # MediaPipe face detection
│   │   ├── GazeEstimator.ts     # Gaze calculation
│   │   └── HeadPoseEstimator.ts # Head pose calculation
│   ├── utils/
│   │   ├── KalmanFilter.ts      # Smoothing filter
│   │   ├── CameraManager.ts     # WebRTC camera handling
│   │   └── MathUtils.ts         # Vector math
│   ├── models/
│   │   └── mediapipe/           # MediaPipe models
│   ├── types/
│   │   └── index.ts             # TypeScript definitions
│   └── index.ts                 # Main export
├── examples/
│   ├── basic/                   # Basic example
│   ├── calibration/             # Calibration example
│   └── heatmap/                 # Heatmap visualization
├── dist/                        # Built files
├── tests/                       # Unit tests
├── package.json
├── tsconfig.json
├── webpack.config.js
└── README.md
```

## Performance

- **Latency**: <50ms on desktop, <100ms on mobile
- **Frame Rate**: 30 FPS on modern hardware
- **CPU Usage**: ~15-25% (one core)
- **Memory**: ~100-150 MB

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run tests
npm test

# Run example
npm run example
```

## Examples

See the [examples/](examples/) directory for:
- Basic tracking
- Multi-point calibration
- Heatmap generation
- Attention analytics

## License

MIT License - see [LICENSE](LICENSE) file

## Links

- [Main Repository](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
- [Documentation](https://github.com/Tareq-Ghassan/GazePointSDK-Web)
- [NPM Package](https://www.npmjs.com/package/@gazepoint/sdk-web)
