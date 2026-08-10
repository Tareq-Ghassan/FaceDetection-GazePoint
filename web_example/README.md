# GazePoint SDK - Web Example

This example demonstrates how to use the GazePoint SDK for web applications with real-time eye tracking and gaze detection in the browser.

## Features

- 📹 Real-time camera feed processing
- 👁️ Eye tracking and gaze point detection
- 📊 Live statistics (FPS, confidence, blink detection)
- 🎯 Visual gaze point overlay
- 🔧 Calibration support

## Prerequisites

- Modern web browser with WebRTC support (Chrome, Firefox, Edge, Safari)
- Webcam access
- HTTPS connection (required for camera access)

## Running the Example

### Option 1: Local Development Server

```bash
cd web_example
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

### Option 2: Using Node.js

```bash
npx serve web_example
```

### Option 3: Direct File Access

Some browsers allow opening the HTML file directly:

```bash
open index.html
```

**Note:** Camera access requires HTTPS in production. Use a local development server for testing.

## Usage

1. Click "Start Tracking" to begin eye tracking
2. Allow camera permissions when prompted
3. The green circle shows your estimated gaze point
4. Click "Calibrate" to improve accuracy
5. Click "Stop Tracking" to end the session

## Integration with Web SDK

To use the actual GazePoint Web SDK (instead of the demo):

1. Build the Web SDK:
   ```bash
   cd ../web
   npm install
   npm run build
   ```

2. Update the import in `index.html`:
   ```javascript
   import { GazeTracker } from '../web/dist/gazepoint-sdk.js';
   ```

3. Replace `DemoGazeTracker` with the actual `GazeTracker` class

## Browser Compatibility

| Browser | Version | Status |
|---------|---------|--------|
| Chrome  | 90+     | ✅ Full Support |
| Firefox | 88+     | ✅ Full Support |
| Safari  | 14+     | ✅ Full Support |
| Edge    | 90+     | ✅ Full Support |

## Troubleshooting

### Camera Not Working
- Ensure HTTPS connection (or localhost)
- Check browser permissions
- Try a different browser

### Poor Tracking Accuracy
- Ensure good lighting
- Position face centered in frame
- Run calibration
- Avoid glasses with reflections

### Low FPS
- Close other camera applications
- Reduce video resolution
- Use a more powerful device

## Learn More

- [Web SDK Documentation](../web/README.md)
- [GazePoint Main Repository](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)
- [Multi-Platform Architecture](../MULTI_PLATFORM_ARCHITECTURE.md)
