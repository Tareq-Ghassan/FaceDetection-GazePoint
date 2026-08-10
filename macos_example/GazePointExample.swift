import Foundation
import GazePointSDK
import AVFoundation

/// macOS console example for GazePoint SDK
/// Demonstrates real-time eye tracking using Vision framework
@main
struct GazePointExample {
    static func main() async {
        print("═══════════════════════════════════════")
        print("   GazePoint SDK - macOS Example")
        print("═══════════════════════════════════════\n")
        
        do {
            let example = GazePointExample()
            try await example.run()
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    func run() async throws {
        // Check camera permissions
        print("Checking camera permissions...")
        let authorized = await checkCameraPermissions()
        guard authorized else {
            print("❌ Camera access denied. Please grant permissions in System Preferences.")
            return
        }
        print("✓ Camera access granted\n")
        
        // Initialize tracker
        print("Initializing GazePoint tracker...")
        let tracker = GazeTracker()
        try await tracker.initialize()
        print("✓ Tracker initialized successfully\n")
        
        // Set up event handlers
        setupEventHandlers(tracker: tracker)
        
        // Start tracking
        print("Starting eye tracking...")
        try await tracker.startTracking()
        print("✓ Tracking started\n")
        
        // Display instructions
        displayInstructions()
        
        // Run calibration
        print("\nRunning 9-point calibration...")
        let calibrationResult = try await tracker.calibrate(points: 9)
        print("✓ Calibration completed")
        print(String(format: "  Average error: %.2fpx", calibrationResult.averageError))
        print(String(format: "  Max error: %.2fpx", calibrationResult.maxError))
        print()
        
        // Main loop
        print("Real-time tracking active...")
        print("(Press 'q' to quit)\n")
        
        var isRunning = true
        while isRunning {
            if let input = readLine()?.lowercased() {
                switch input {
                case "c":
                    try await runCalibration(tracker: tracker)
                case "s":
                    try await showStats(tracker: tracker)
                case "r":
                    try await restartTracking(tracker: tracker)
                case "q":
                    isRunning = false
                default:
                    print("Unknown command. Press 'h' for help.")
                }
            }
        }
        
        // Cleanup
        print("\n\nStopping tracker...")
        try await tracker.stopTracking()
        print("✓ Tracker stopped successfully")
        
        print("\nGoodbye! 👋")
    }
    
    func checkCameraPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func setupEventHandlers(tracker: GazeTracker) {
        tracker.onGazeDetected = { result in
            // Clear line and display gaze data
            print("\r", terminator: "")
            print(String(format: "👁️  Gaze: (%.0f, %.0f) | Confidence: %.1f%% | Head: P%.1f° Y%.1f° R%.1f°",
                        result.gazePoint.x,
                        result.gazePoint.y,
                        result.confidence * 100,
                        result.headPose.pitch,
                        result.headPose.yaw,
                        result.headPose.roll),
                 terminator: "")
            fflush(stdout)
        }
        
        tracker.onBlinkDetected = {
            print("\n👁️ Blink detected!")
        }
        
        tracker.onTrackingLost = {
            print("\n⚠️  Tracking lost - please position your face in the camera view")
        }
    }
    
    func displayInstructions() {
        print("═══════════════════════════════════════")
        print("Commands:")
        print("  [c] Calibrate")
        print("  [s] Show Statistics")
        print("  [r] Restart Tracking")
        print("  [q] Quit")
        print("═══════════════════════════════════════")
    }
    
    func runCalibration(tracker: GazeTracker) async throws {
        print("\n\nStarting calibration...")
        print("Look at each point that appears on the screen.")
        
        let result = try await tracker.calibrate(points: 9)
        print("✓ Calibration completed successfully")
        print(String(format: "  Average error: %.2fpx", result.averageError))
        print(String(format: "  Max error: %.2fpx", result.maxError))
    }
    
    func showStats(tracker: GazeTracker) async throws {
        print("\n\n═══════════════════════════════════════")
        print("Performance Statistics")
        print("═══════════════════════════════════════")
        
        let stats = try await tracker.getPerformanceStats()
        
        print(String(format: "Frame Rate: %.1f FPS", stats.fps))
        print(String(format: "Average Latency: %.1fms", stats.averageLatency))
        print(String(format: "Dropped Frames: %d", stats.droppedFrames))
        print(String(format: "Tracking Time: %@", formatDuration(stats.totalTrackingTime)))
        print(String(format: "Blinks Detected: %d", stats.totalBlinks))
        print("═══════════════════════════════════════\n")
    }
    
    func restartTracking(tracker: GazeTracker) async throws {
        print("\n\nRestarting tracking...")
        try await tracker.stopTracking()
        try await Task.sleep(nanoseconds: 500_000_000) // 500ms
        try await tracker.startTracking()
        print("✓ Tracking restarted successfully")
    }
    
    func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
