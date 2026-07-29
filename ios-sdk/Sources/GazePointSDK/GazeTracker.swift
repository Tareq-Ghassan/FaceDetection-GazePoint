import Foundation
import Vision
import ARKit
import CoreML
import UIKit
import Accelerate

/// Enhanced Gaze Tracker for iOS with Vision and ARKit support
@available(iOS 16.0, *)
public class GazeTracker {
    
    // MARK: - Types
    
    public struct GazeResult {
        public let gazePoint: CGPoint
        public let confidence: Float
        public let isBlinking: Bool
        public let headPose: HeadPose
        public let timestamp: TimeInterval
        
        public init(gazePoint: CGPoint, confidence: Float, isBlinking: Bool, headPose: HeadPose, timestamp: TimeInterval) {
            self.gazePoint = gazePoint
            self.confidence = confidence
            self.isBlinking = isBlinking
            self.headPose = headPose
            self.timestamp = timestamp
        }
    }
    
    public struct HeadPose {
        public let pitch: Float // Nodding up/down
        public let yaw: Float   // Turning left/right
        public let roll: Float  // Tilting left/right
        
        public init(pitch: Float, yaw: Float, roll: Float) {
            self.pitch = pitch
            self.yaw = yaw
            self.roll = roll
        }
    }
    
    public struct CalibrationData: Codable {
        public var offsetX: Float
        public var offsetY: Float
        public var scaleX: Float
        public var scaleY: Float
        public var rotationCompensation: Float
        
        public init(offsetX: Float = 0, offsetY: Float = 0, scaleX: Float = 1, scaleY: Float = 1, rotationCompensation: Float = 0) {
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.scaleX = scaleX
            self.scaleY = scaleY
            self.rotationCompensation = rotationCompensation
        }
    }
    
    // MARK: - Properties
    
    private let smoothingFactor: Float = 0.3
    private let minConfidenceThreshold: Float = 0.5
    private let blinkThreshold: Float = 0.3
    private let velocityThreshold: Float = 100.0
    
    private var lastGazePoint: CGPoint?
    private var calibrationData: CalibrationData?
    private var isCalibrated: Bool = false
    private var kalmanFilter: KalmanFilter
    private let performanceMonitor: PerformanceMonitor
    
    private lazy var faceDetectionRequest: VNDetectFaceLandmarksRequest = {
        let request = VNDetectFaceLandmarksRequest()
        request.revision = VNDetectFaceLandmarksRequestRevision3
        return request
    }()
    
    // MARK: - Initialization
    
    public init() {
        self.kalmanFilter = KalmanFilter()
        self.performanceMonitor = PerformanceMonitor()
    }
    
    // MARK: - Public Methods
    
    /// Calculate gaze point from a CVPixelBuffer
    public func calculateGazePoint(from pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up) -> GazeResult? {
        let startTime = performanceMonitor.startFrame()
        defer {
            performanceMonitor.endFrame(startTime: startTime)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        
        do {
            try handler.perform([faceDetectionRequest])
            
            guard let observations = faceDetectionRequest.results,
                  let faceObservation = observations.first else {
                return nil
            }
            
            let result = processGaze(from: faceObservation)
            return result
            
        } catch {
            print("Error performing face detection: \(error)")
            return nil
        }
    }
    
    /// Calculate gaze point from a UIImage
    public func calculateGazePoint(from image: UIImage) -> GazeResult? {
        guard let cgImage = image.cgImage else { return nil }
        
        let startTime = performanceMonitor.startFrame()
        defer {
            performanceMonitor.endFrame(startTime: startTime)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([faceDetectionRequest])
            
            guard let observations = faceDetectionRequest.results,
                  let faceObservation = observations.first else {
                return nil
            }
            
            return processGaze(from: faceObservation)
            
        } catch {
            print("Error performing face detection: \(error)")
            return nil
        }
    }
    
    /// Calibrate the gaze tracker with known screen points
    public func calibrate(calibrationPoints: [(expected: CGPoint, actual: CGPoint)]) {
        guard calibrationPoints.count >= 3 else {
            print("Need at least 3 calibration points")
            return
        }
        
        var sumOffsetX: Float = 0
        var sumOffsetY: Float = 0
        var sumScaleX: Float = 0
        var sumScaleY: Float = 0
        
        for (expected, actual) in calibrationPoints {
            sumOffsetX += Float(expected.x - actual.x)
            sumOffsetY += Float(expected.y - actual.y)
            
            if actual.x != 0 {
                sumScaleX += Float(expected.x / actual.x)
            }
            if actual.y != 0 {
                sumScaleY += Float(expected.y / actual.y)
            }
        }
        
        let count = Float(calibrationPoints.count)
        calibrationData = CalibrationData(
            offsetX: sumOffsetX / count,
            offsetY: sumOffsetY / count,
            scaleX: sumScaleX / count,
            scaleY: sumScaleY / count
        )
        
        isCalibrated = true
        print("Calibration completed: \(String(describing: calibrationData))")
    }
    
    /// Reset calibration
    public func resetCalibration() {
        calibrationData = nil
        isCalibrated = false
        lastGazePoint = nil
        kalmanFilter.reset()
    }
    
    /// Get current performance metrics
    public func getPerformanceMetrics() -> PerformanceMonitor.PerformanceMetrics {
        return performanceMonitor.getMetrics()
    }
    
    // MARK: - Private Methods
    
    private func processGaze(from faceObservation: VNFaceObservation) -> GazeResult? {
        guard let landmarks = faceObservation.landmarks else {
            return nil
        }
        
        // Get eye landmarks
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return nil
        }
        
        // Detect blink
        let isBlinking = detectBlink(leftEye: leftEye, rightEye: rightEye, faceObservation: faceObservation)
        
        // Calculate head pose
        let headPose = calculateHeadPose(from: faceObservation)
        
        // Calculate gaze vector
        let gazeVector = calculateGazeVector(leftEye: leftEye, rightEye: rightEye, headPose: headPose)
        
        // Apply calibration if available
        let calibratedVector = applyCalibration(to: gazeVector)
        
        // Map to screen coordinates
        let screenSize = UIScreen.main.bounds.size
        let screenPoint = mapGazeVectorToScreen(gazeVector: calibratedVector, headPose: headPose, screenSize: screenSize)
        
        // Apply Kalman filter
        let filteredPoint = kalmanFilter.update(measurement: screenPoint)
        
        // Apply adaptive smoothing
        let smoothedPoint = applyAdaptiveSmoothing(currentPoint: filteredPoint)
        
        // Calculate confidence
        let confidence = calculateConfidence(faceObservation: faceObservation, isBlinking: isBlinking)
        
        lastGazePoint = smoothedPoint
        
        return GazeResult(
            gazePoint: smoothedPoint,
            confidence: confidence,
            isBlinking: isBlinking,
            headPose: headPose,
            timestamp: Date().timeIntervalSince1970
        )
    }
    
    private func calculateGazeVector(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, headPose: HeadPose) -> CGPoint {
        let leftPoints = leftEye.normalizedPoints
        let rightPoints = rightEye.normalizedPoints
        
        guard !leftPoints.isEmpty, !rightPoints.isEmpty else {
            return .zero
        }
        
        // Calculate eye centers
        let leftCenter = averagePoint(points: leftPoints)
        let rightCenter = averagePoint(points: rightPoints)
        
        // Calculate eye midpoint
        let eyeMidX = (leftCenter.x + rightCenter.x) / 2
        let eyeMidY = (leftCenter.y + rightCenter.y) / 2
        
        // Calculate base gaze vector
        var gazeX = rightCenter.x - leftCenter.x
        var gazeY = rightCenter.y - leftCenter.y
        
        // Compensate for head rotation
        gazeX += CGFloat(headPose.yaw) * 0.005
        gazeY += CGFloat(headPose.pitch) * 0.005
        
        // Normalize
        let magnitude = sqrt(gazeX * gazeX + gazeY * gazeY)
        if magnitude > 0 {
            gazeX /= magnitude
            gazeY /= magnitude
        }
        
        return CGPoint(x: gazeX, y: gazeY)
    }
    
    private func calculateHeadPose(from faceObservation: VNFaceObservation) -> HeadPose {
        let pitch = faceObservation.pitch?.floatValue ?? 0
        let yaw = faceObservation.yaw?.floatValue ?? 0
        let roll = faceObservation.roll?.floatValue ?? 0
        
        return HeadPose(
            pitch: pitch,
            yaw: yaw,
            roll: roll
        )
    }
    
    private func detectBlink(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, faceObservation: VNFaceObservation) -> Bool {
        // Calculate eye aspect ratios
        let leftEAR = calculateEyeAspectRatio(eye: leftEye)
        let rightEAR = calculateEyeAspectRatio(eye: rightEye)
        
        let avgEAR = (leftEAR + rightEAR) / 2
        
        return avgEAR < blinkThreshold
    }
    
    private func calculateEyeAspectRatio(eye: VNFaceLandmarkRegion2D) -> Float {
        let points = eye.normalizedPoints
        guard points.count >= 6 else { return 1.0 }
        
        // Simplified EAR calculation
        // EAR = (vertical distance) / (horizontal distance)
        let vertical1 = distance(from: points[1], to: points[5])
        let vertical2 = distance(from: points[2], to: points[4])
        let horizontal = distance(from: points[0], to: points[3])
        
        if horizontal == 0 { return 1.0 }
        
        let ear = Float((vertical1 + vertical2) / (2.0 * horizontal))
        return ear
    }
    
    private func mapGazeVectorToScreen(gazeVector: CGPoint, headPose: HeadPose, screenSize: CGSize) -> CGPoint {
        // Apply head pose compensation
        let yawFactor: CGFloat = 1.0 + (CGFloat(abs(headPose.yaw)) / 30.0) * 0.2
        let pitchFactor: CGFloat = 1.0 + (CGFloat(abs(headPose.pitch)) / 30.0) * 0.2
        
        // Map to screen coordinates
        var screenX = (screenSize.width / 2) + (gazeVector.x * (screenSize.width / 2) * yawFactor)
        var screenY = (screenSize.height / 2) - (gazeVector.y * (screenSize.height / 2) * pitchFactor)
        
        // Clamp to screen bounds
        screenX = max(0, min(screenSize.width, screenX))
        screenY = max(0, min(screenSize.height, screenY))
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    private func applyCalibration(to gazeVector: CGPoint) -> CGPoint {
        guard isCalibrated, let calibration = calibrationData else {
            return gazeVector
        }
        
        return CGPoint(
            x: CGFloat(gazeVector.x * CGFloat(calibration.scaleX) + CGFloat(calibration.offsetX)),
            y: CGFloat(gazeVector.y * CGFloat(calibration.scaleY) + CGFloat(calibration.offsetY))
        )
    }
    
    private func applyAdaptiveSmoothing(currentPoint: CGPoint) -> CGPoint {
        guard let lastPoint = lastGazePoint else {
            return currentPoint
        }
        
        // Calculate velocity
        let dx = currentPoint.x - lastPoint.x
        let dy = currentPoint.y - lastPoint.y
        let velocity = sqrt(dx * dx + dy * dy)
        
        // Adaptive smoothing factor
        let adaptiveFactor: CGFloat
        if velocity > CGFloat(velocityThreshold) {
            adaptiveFactor = CGFloat(smoothingFactor) * 0.5
        } else {
            adaptiveFactor = CGFloat(smoothingFactor)
        }
        
        return CGPoint(
            x: lastPoint.x + (currentPoint.x - lastPoint.x) * adaptiveFactor,
            y: lastPoint.y + (currentPoint.y - lastPoint.y) * adaptiveFactor
        )
    }
    
    private func calculateConfidence(faceObservation: VNFaceObservation, isBlinking: Bool) -> Float {
        var confidence = faceObservation.confidence
        
        // Reduce confidence if blinking
        if isBlinking {
            confidence *= 0.3
        }
        
        // Check face quality
        if let boundingBox = Optional(faceObservation.boundingBox) {
            let faceArea = boundingBox.width * boundingBox.height
            if faceArea < 0.05 { // Face too small
                confidence *= 0.7
            }
        }
        
        return max(0, min(1, confidence))
    }
    
    // MARK: - Helper Methods
    
    private func averagePoint(points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        
        var sumX: CGFloat = 0
        var sumY: CGFloat = 0
        
        for point in points {
            sumX += point.x
            sumY += point.y
        }
        
        return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
}
