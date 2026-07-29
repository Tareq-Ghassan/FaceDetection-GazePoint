import Foundation
import CoreGraphics

/// Kalman Filter for smoothing gaze point tracking
public class KalmanFilter {
    
    private var estimateX: CGFloat = 0
    private var estimateY: CGFloat = 0
    private var errorCovarianceX: CGFloat = 1
    private var errorCovarianceY: CGFloat = 1
    
    private let processNoise: CGFloat = 0.01
    private let measurementNoise: CGFloat = 0.1
    
    public init() {}
    
    /// Update the filter with a new measurement
    public func update(measurement: CGPoint) -> CGPoint {
        // Prediction step (assume no change in position)
        let predictedErrorCovX = errorCovarianceX + processNoise
        let predictedErrorCovY = errorCovarianceY + processNoise
        
        // Update step
        let kalmanGainX = predictedErrorCovX / (predictedErrorCovX + measurementNoise)
        let kalmanGainY = predictedErrorCovY / (predictedErrorCovY + measurementNoise)
        
        estimateX += kalmanGainX * (measurement.x - estimateX)
        estimateY += kalmanGainY * (measurement.y - estimateY)
        
        errorCovarianceX = (1 - kalmanGainX) * predictedErrorCovX
        errorCovarianceY = (1 - kalmanGainY) * predictedErrorCovY
        
        return CGPoint(x: estimateX, y: estimateY)
    }
    
    /// Reset the filter to initial state
    public func reset() {
        estimateX = 0
        estimateY = 0
        errorCovarianceX = 1
        errorCovarianceY = 1
    }
}
