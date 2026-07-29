import Foundation

/// GazePointSDK - iOS Eye Tracking and Gaze Point Detection
///
/// This SDK provides real-time eye tracking and gaze point detection for iOS applications.
/// It uses Apple's Vision framework for face and landmark detection, with advanced algorithms
/// for accurate gaze estimation.
///
/// Features:
/// - Real-time gaze point tracking
/// - Head pose compensation
/// - Blink detection
/// - Kalman filtering for smooth tracking
/// - Performance monitoring
/// - Calibration support
///
/// Example usage:
/// ```swift
/// let gazeTracker = GazeTracker()
///
/// // From camera frame (CVPixelBuffer)
/// if let result = gazeTracker.calculateGazePoint(from: pixelBuffer) {
///     print("Gaze point: \(result.gazePoint)")
///     print("Confidence: \(result.confidence)")
///     print("Blinking: \(result.isBlinking)")
/// }
///
/// // Calibration
/// let calibrationPoints = [
///     (expected: CGPoint(x: 100, y: 100), actual: CGPoint(x: 95, y: 102)),
///     (expected: CGPoint(x: 200, y: 200), actual: CGPoint(x: 198, y: 205)),
///     (expected: CGPoint(x: 300, y: 300), actual: CGPoint(x: 305, y: 295))
/// ]
/// gazeTracker.calibrate(calibrationPoints: calibrationPoints)
/// ```
@available(iOS 16.0, *)
public struct GazePointSDK {
    
    /// Current version of the SDK
    public static let version = "2.0.0"
    
    /// Build number
    public static let build = "1"
    
    /// Full version string
    public static var fullVersion: String {
        return "\(version) (\(build))"
    }
    
    /// SDK information
    public static func printInfo() {
        print("""
        ╔═══════════════════════════════════════╗
        ║      GazePoint SDK for iOS            ║
        ║      Version: \(version)                  ║
        ║      Build: \(build)                      ║
        ╚═══════════════════════════════════════╝
        
        Features:
        ✓ Real-time gaze tracking
        ✓ Head pose compensation
        ✓ Blink detection
        ✓ Kalman filtering
        ✓ Performance monitoring
        ✓ Calibration support
        
        Requirements:
        • iOS 16.0+
        • Camera access permission
        """)
    }
}
