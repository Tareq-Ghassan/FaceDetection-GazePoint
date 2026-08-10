import Foundation
import Vision
import AVFoundation
import AppKit

/// Main GazeTracker class for macOS
public class GazeTracker {
    public var onGazeUpdate: ((GazeResult) -> Void)?
    public var onError: ((Error) -> Void)?
    
    private var isInitialized = false
    private var isTracking = false
    
    public init() {}
    
    /// Initialize the tracker
    public func initialize() async throws {
        // TODO: Initialize Vision and camera
        isInitialized = true
    }
    
    /// Start gaze tracking
    public func startTracking() async throws {
        guard isInitialized else {
            throw GazeTrackerError.notInitialized
        }
        
        isTracking = true
        // TODO: Start camera and processing loop
    }
    
    /// Stop gaze tracking
    public func stopTracking() {
        isTracking = false
        // TODO: Stop camera
    }
    
    /// Calibrate the tracker
    public func calibrate(points: [CalibrationPoint]) async throws {
        // TODO: Implement calibration
    }
}

/// Gaze tracking result
public struct GazeResult {
    public let gazePoint: NSPoint
    public let confidence: Double
    public let isBlinking: Bool
    public let headPose: HeadPose
    public let timestamp: Date
    
    public init(gazePoint: NSPoint, confidence: Double, isBlinking: Bool, headPose: HeadPose) {
        self.gazePoint = gazePoint
        self.confidence = confidence
        self.isBlinking = isBlinking
        self.headPose = headPose
        self.timestamp = Date()
    }
}

/// Head pose angles
public struct HeadPose {
    public let pitch: Double
    public let yaw: Double
    public let roll: Double
    
    public init(pitch: Double, yaw: Double, roll: Double) {
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
    }
}

/// Calibration point
public struct CalibrationPoint {
    public let expected: NSPoint
    public let actual: NSPoint
    
    public init(expected: NSPoint, actual: NSPoint) {
        self.expected = expected
        self.actual = actual
    }
}

/// Errors
public enum GazeTrackerError: Error {
    case notInitialized
    case cameraUnavailable
    case trackingFailed
}
