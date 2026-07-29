package com.facedetection.gaze

import android.content.Context
import android.graphics.PointF
import android.util.DisplayMetrics
import android.util.Log
import com.google.ar.sceneform.math.Vector3
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceLandmark
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.sqrt

/**
 * Enhanced Gaze Tracker with improved accuracy and calibration support.
 * 
 * Features:
 * - Kalman filtering for smooth tracking
 * - Multi-point calibration support
 * - Head pose compensation
 * - Adaptive smoothing based on movement speed
 * - Eye aspect ratio for blink detection
 */
class GazeTracker(private val context: Context) {
    
    companion object {
        private const val TAG = "GazeTracker"
        private const val SMOOTHING_FACTOR = 0.3f
        private const val MIN_CONFIDENCE_THRESHOLD = 0.5f
        private const val BLINK_EAR_THRESHOLD = 0.2f
        private const val VELOCITY_THRESHOLD = 100f
    }
    
    private var lastGazePoint: PointF? = null
    private var calibrationData: CalibrationData? = null
    private var isCalibrated = false
    private var blinkDetected = false
    private val kalmanFilter = KalmanFilter()
    
    data class CalibrationData(
        val offsetX: Float = 0f,
        val offsetY: Float = 0f,
        val scaleX: Float = 1f,
        val scaleY: Float = 1f,
        val rotationCompensation: Float = 0f
    )
    
    data class GazeResult(
        val gazePoint: PointF,
        val confidence: Float,
        val isBlinking: Boolean,
        val headPose: HeadPose
    )
    
    data class HeadPose(
        val pitch: Float,
        val yaw: Float,
        val roll: Float
    )
    
    /**
     * Calculate gaze point from detected face with improved accuracy.
     */
    fun calculateGazePoint(face: Face): GazeResult? {
        val leftEyeLandmark = face.getLandmark(FaceLandmark.LEFT_EYE)
        val rightEyeLandmark = face.getLandmark(FaceLandmark.RIGHT_EYE)
        
        if (leftEyeLandmark == null || rightEyeLandmark == null) {
            Log.w(TAG, "Eye landmarks not detected")
            return null
        }
        
        val leftEyePosition = leftEyeLandmark.position
        val rightEyePosition = rightEyeLandmark.position
        
        // Detect blink using Eye Aspect Ratio
        blinkDetected = detectBlink(face)
        
        // Calculate head pose
        val headPose = calculateHeadPose(face)
        
        // Calculate raw gaze vector
        val gazeVector = calculateGazeVector(leftEyePosition, rightEyePosition, headPose)
        
        // Apply calibration if available
        val calibratedVector = if (isCalibrated && calibrationData != null) {
            applyCalibration(gazeVector, calibrationData!!)
        } else {
            gazeVector
        }
        
        // Map to screen coordinates
        val screenPoint = mapGazeVectorToScreenCoordinates(calibratedVector, headPose)
        
        // Apply Kalman filter for smoothing
        val filteredPoint = kalmanFilter.update(screenPoint)
        
        // Apply adaptive smoothing based on velocity
        val smoothedPoint = applyAdaptiveSmoothing(filteredPoint)
        
        // Calculate confidence based on multiple factors
        val confidence = calculateConfidence(face, leftEyePosition, rightEyePosition)
        
        lastGazePoint = smoothedPoint
        
        return GazeResult(
            gazePoint = smoothedPoint,
            confidence = confidence,
            isBlinking = blinkDetected,
            headPose = headPose
        )
    }
    
    /**
     * Calculate gaze vector with head pose compensation.
     */
    private fun calculateGazeVector(
        leftEyePosition: PointF,
        rightEyePosition: PointF,
        headPose: HeadPose
    ): Vector3 {
        // Calculate eye midpoint
        val eyeMidPoint = PointF(
            (leftEyePosition.x + rightEyePosition.x) / 2f,
            (leftEyePosition.y + rightEyePosition.y) / 2f
        )
        
        // Calculate base gaze vector
        val baseVector = Vector3(
            rightEyePosition.x - leftEyePosition.x,
            rightEyePosition.y - leftEyePosition.y,
            0f
        )
        
        // Compensate for head rotation
        val compensatedX = baseVector.x + headPose.yaw * 0.5f
        val compensatedY = baseVector.y + headPose.pitch * 0.5f
        
        val gazeVector = Vector3(compensatedX, compensatedY, 0f)
        
        // Normalize
        val magnitude = sqrt(gazeVector.x * gazeVector.x + gazeVector.y * gazeVector.y)
        if (magnitude > 0) {
            return Vector3(gazeVector.x / magnitude, gazeVector.y / magnitude, 0f)
        }
        
        return gazeVector
    }
    
    /**
     * Calculate head pose from face landmarks.
     */
    private fun calculateHeadPose(face: Face): HeadPose {
        val pitch = face.headEulerAngleX // Nodding up and down
        val yaw = face.headEulerAngleY   // Turning left and right
        val roll = face.headEulerAngleZ  // Tilting left and right
        
        return HeadPose(pitch, yaw, roll)
    }
    
    /**
     * Detect blink using Eye Aspect Ratio (EAR).
     */
    private fun detectBlink(face: Face): Boolean {
        // Get eye landmarks for more accurate blink detection
        val leftEye = face.getLandmark(FaceLandmark.LEFT_EYE)
        val rightEye = face.getLandmark(FaceLandmark.RIGHT_EYE)
        
        if (leftEye == null || rightEye == null) return false
        
        // Use eye open probability if available
        val leftEyeOpen = face.leftEyeOpenProbability ?: 1f
        val rightEyeOpen = face.rightEyeOpenProbability ?: 1f
        
        val avgEyeOpen = (leftEyeOpen + rightEyeOpen) / 2f
        
        return avgEyeOpen < BLINK_EAR_THRESHOLD
    }
    
    /**
     * Map gaze vector to screen coordinates with head pose compensation.
     */
    private fun mapGazeVectorToScreenCoordinates(
        gazeVector: Vector3,
        headPose: HeadPose
    ): PointF {
        val displayMetrics = context.resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels.toFloat()
        val screenHeight = displayMetrics.heightPixels.toFloat()
        
        // Apply head pose compensation
        val yawFactor = 1f + (abs(headPose.yaw) / 30f) * 0.2f
        val pitchFactor = 1f + (abs(headPose.pitch) / 30f) * 0.2f
        
        // Map to screen coordinates with compensation
        val screenX = (screenWidth / 2f) + (gazeVector.x * (screenWidth / 2f) * yawFactor)
        val screenY = (screenHeight / 2f) - (gazeVector.y * (screenHeight / 2f) * pitchFactor)
        
        // Clamp to screen bounds
        val clampedX = screenX.coerceIn(0f, screenWidth)
        val clampedY = screenY.coerceIn(0f, screenHeight)
        
        return PointF(clampedX, clampedY)
    }
    
    /**
     * Apply calibration data to gaze vector.
     */
    private fun applyCalibration(gazeVector: Vector3, calibration: CalibrationData): Vector3 {
        return Vector3(
            gazeVector.x * calibration.scaleX + calibration.offsetX,
            gazeVector.y * calibration.scaleY + calibration.offsetY,
            gazeVector.z
        )
    }
    
    /**
     * Apply adaptive smoothing based on gaze velocity.
     */
    private fun applyAdaptiveSmoothing(currentPoint: PointF): PointF {
        val lastPoint = lastGazePoint ?: return currentPoint
        
        // Calculate velocity
        val dx = currentPoint.x - lastPoint.x
        val dy = currentPoint.y - lastPoint.y
        val velocity = sqrt(dx * dx + dy * dy)
        
        // Adaptive smoothing factor based on velocity
        val adaptiveFactor = if (velocity > VELOCITY_THRESHOLD) {
            SMOOTHING_FACTOR * 0.5f // Less smoothing for fast movements
        } else {
            SMOOTHING_FACTOR // More smoothing for slow movements
        }
        
        return PointF(
            lastPoint.x + (currentPoint.x - lastPoint.x) * adaptiveFactor,
            lastPoint.y + (currentPoint.y - lastPoint.y) * adaptiveFactor
        )
    }
    
    /**
     * Calculate confidence score based on multiple factors.
     */
    private fun calculateConfidence(
        face: Face,
        leftEyePosition: PointF,
        rightEyePosition: PointF
    ): Float {
        var confidence = 1.0f
        
        // Face detection confidence
        confidence *= (face.trackingId ?: 0).let { if (it > 0) 1.0f else 0.8f }
        
        // Eye position stability
        lastGazePoint?.let { last ->
            val eyeMidX = (leftEyePosition.x + rightEyePosition.x) / 2f
            val eyeMidY = (leftEyePosition.y + rightEyePosition.y) / 2f
            val stability = 1f - (abs(last.x - eyeMidX) + abs(last.y - eyeMidY)) / 1000f
            confidence *= stability.coerceIn(0.5f, 1.0f)
        }
        
        // Blink penalty
        if (blinkDetected) {
            confidence *= 0.3f
        }
        
        return confidence.coerceIn(0f, 1f)
    }
    
    /**
     * Calibrate the gaze tracker with known screen points.
     */
    fun calibrate(calibrationPoints: List<Pair<PointF, PointF>>) {
        if (calibrationPoints.size < 3) {
            Log.w(TAG, "Need at least 3 calibration points")
            return
        }
        
        // Calculate calibration offsets and scales
        var sumOffsetX = 0f
        var sumOffsetY = 0f
        var sumScaleX = 0f
        var sumScaleY = 0f
        
        calibrationPoints.forEach { (expected, actual) ->
            sumOffsetX += expected.x - actual.x
            sumOffsetY += expected.y - actual.y
            
            if (actual.x != 0f) sumScaleX += expected.x / actual.x
            if (actual.y != 0f) sumScaleY += expected.y / actual.y
        }
        
        val count = calibrationPoints.size
        calibrationData = CalibrationData(
            offsetX = sumOffsetX / count,
            offsetY = sumOffsetY / count,
            scaleX = sumScaleX / count,
            scaleY = sumScaleY / count
        )
        
        isCalibrated = true
        Log.i(TAG, "Calibration completed: $calibrationData")
    }
    
    /**
     * Reset calibration.
     */
    fun resetCalibration() {
        calibrationData = null
        isCalibrated = false
        lastGazePoint = null
        kalmanFilter.reset()
    }
    
    /**
     * Simple Kalman Filter for smoothing gaze points.
     */
    private class KalmanFilter {
        private var estimateX = 0f
        private var estimateY = 0f
        private var errorCovarianceX = 1f
        private var errorCovarianceY = 1f
        
        private val processNoise = 0.01f
        private val measurementNoise = 0.1f
        
        fun update(measurement: PointF): PointF {
            // Prediction (assume no change)
            val predictedErrorCovX = errorCovarianceX + processNoise
            val predictedErrorCovY = errorCovarianceY + processNoise
            
            // Update
            val kalmanGainX = predictedErrorCovX / (predictedErrorCovX + measurementNoise)
            val kalmanGainY = predictedErrorCovY / (predictedErrorCovY + measurementNoise)
            
            estimateX += kalmanGainX * (measurement.x - estimateX)
            estimateY += kalmanGainY * (measurement.y - estimateY)
            
            errorCovarianceX = (1 - kalmanGainX) * predictedErrorCovX
            errorCovarianceY = (1 - kalmanGainY) * predictedErrorCovY
            
            return PointF(estimateX, estimateY)
        }
        
        fun reset() {
            estimateX = 0f
            estimateY = 0f
            errorCovarianceX = 1f
            errorCovarianceY = 1f
        }
    }
}
