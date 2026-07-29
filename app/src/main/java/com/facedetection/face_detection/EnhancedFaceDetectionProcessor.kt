package com.facedetection.face_detection

import android.content.Context
import android.graphics.Rect
import android.util.Log
import androidx.camera.core.ImageProxy
import com.facedetection.GazeViewModel
import com.facedetection.camerax.BaseImageAnalyzer
import com.facedetection.camerax.GraphicOverlay
import com.facedetection.gaze.GazeTracker
import com.facedetection.gaze.PerformanceMonitor
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.google.mlkit.vision.face.FaceDetectorOptions

/**
 * Enhanced face detection processor with improved accuracy and performance.
 * 
 * Features:
 * - Improved gaze tracking with Kalman filtering
 * - Performance monitoring
 * - Better error handling
 * - Multi-face support with primary face selection
 * - Calibration support
 */
class EnhancedFaceDetectionProcessor(
    private val context: Context,
    private val graphicOverlay: GraphicOverlay,
    private val viewModel: GazeViewModel?
) : BaseImageAnalyzer<List<Face>>() {
    
    companion object {
        private const val TAG = "EnhancedFaceDetector"
        private const val PERFORMANCE_LOG_INTERVAL = 60 // Log every 60 frames
    }
    
    private val gazeTracker = GazeTracker(context)
    private val performanceMonitor = PerformanceMonitor()
    private var framesSinceLastLog = 0
    
    // Optimized face detector options
    private val highAccuracyOptions = FaceDetectorOptions.Builder()
        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
        .setMinFaceSize(0.15f)
        .enableTracking()
        .build()
    
    private val faceDetector: FaceDetector = FaceDetection.getClient(highAccuracyOptions)
    
    override fun getGraphicOverlay(): GraphicOverlay = graphicOverlay
    
    override fun detectInImage(image: InputImage): Task<List<Face>> {
        return faceDetector.process(image)
    }
    
    override fun onSuccess(
        results: List<Face>,
        graphicOverlay: GraphicOverlay,
        rect: Rect
    ) {
        val startTime = performanceMonitor.startFrame()
        
        graphicOverlay.clear()
        
        when {
            results.isEmpty() -> {
                updateViewModel("No Face Detected")
                Log.d(TAG, "No faces detected")
            }
            results.size == 1 -> {
                processSingleFace(results[0], graphicOverlay, rect)
            }
            else -> {
                processMultipleFaces(results, graphicOverlay, rect)
            }
        }
        
        graphicOverlay.postInvalidate()
        performanceMonitor.endFrame(startTime)
        
        // Periodic performance logging
        framesSinceLastLog++
        if (framesSinceLastLog >= PERFORMANCE_LOG_INTERVAL) {
            performanceMonitor.logMetrics()
            framesSinceLastLog = 0
            
            // Warn if performance is degraded
            if (performanceMonitor.isPerformanceDegraded()) {
                Log.w(TAG, "Performance degradation detected!")
            }
        }
    }
    
    private fun processSingleFace(face: Face, graphicOverlay: GraphicOverlay, rect: Rect) {
        // Draw face contours
        val faceGraphic = FaceContourGraphic(graphicOverlay, face, rect)
        graphicOverlay.add(faceGraphic)
        
        // Calculate gaze point
        val gazeResult = gazeTracker.calculateGazePoint(face)
        
        if (gazeResult != null) {
            val formattedGaze = formatGazeResult(gazeResult)
            updateViewModel(formattedGaze)
            
            Log.d(TAG, """
                Gaze: (${gazeResult.gazePoint.x.toInt()}, ${gazeResult.gazePoint.y.toInt()})
                Confidence: ${"%.2f".format(gazeResult.confidence)}
                Blinking: ${gazeResult.isBlinking}
                Head Pose: Pitch=${gazeResult.headPose.pitch.toInt()}° 
                          Yaw=${gazeResult.headPose.yaw.toInt()}° 
                          Roll=${gazeResult.headPose.roll.toInt()}°
            """.trimIndent())
        } else {
            updateViewModel("Eyes Not Detected")
            Log.w(TAG, "Could not calculate gaze point")
        }
    }
    
    private fun processMultipleFaces(
        faces: List<Face>,
        graphicOverlay: GraphicOverlay,
        rect: Rect
    ) {
        Log.d(TAG, "${faces.size} faces detected")
        
        // Select primary face (largest or closest to center)
        val primaryFace = selectPrimaryFace(faces, rect)
        
        // Draw all faces
        faces.forEach { face ->
            val faceGraphic = FaceContourGraphic(graphicOverlay, face, rect)
            graphicOverlay.add(faceGraphic)
        }
        
        // Process gaze for primary face only
        if (primaryFace != null) {
            val gazeResult = gazeTracker.calculateGazePoint(primaryFace)
            if (gazeResult != null) {
                val formattedGaze = formatGazeResult(gazeResult)
                updateViewModel("Multiple Faces: $formattedGaze")
            } else {
                updateViewModel("Multiple Faces Detected - Eyes Not Clear")
            }
        } else {
            updateViewModel("${faces.size} Faces Detected")
        }
    }
    
    private fun selectPrimaryFace(faces: List<Face>, rect: Rect): Face? {
        if (faces.isEmpty()) return null
        
        // Select face with highest confidence and largest size
        return faces.maxByOrNull { face ->
            val boundingBox = face.boundingBox
            val area = boundingBox.width() * boundingBox.height()
            val trackingScore = if (face.trackingId != null) 1000 else 0
            area + trackingScore
        }
    }
    
    private fun formatGazeResult(result: GazeTracker.GazeResult): String {
        return buildString {
            append("Gaze: (${result.gazePoint.x.toInt()}, ${result.gazePoint.y.toInt()})")
            append(" | Confidence: ${"%.0f".format(result.confidence * 100)}%")
            if (result.isBlinking) {
                append(" | BLINKING")
            }
        }
    }
    
    private fun updateViewModel(message: String) {
        viewModel?.setGazePoint(message)
    }
    
    override fun onFailure(e: Exception) {
        val errorMsg = "Face Detection Failed: ${e.message}"
        updateViewModel(errorMsg)
        Log.e(TAG, errorMsg, e)
    }
    
    override fun stop() {
        try {
            faceDetector.close()
            performanceMonitor.logMetrics()
            Log.i(TAG, "Face detector stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping face detector", e)
        }
    }
    
    /**
     * Start calibration mode.
     */
    fun startCalibration(calibrationPoints: List<Pair<android.graphics.PointF, android.graphics.PointF>>) {
        gazeTracker.calibrate(calibrationPoints)
    }
    
    /**
     * Reset calibration.
     */
    fun resetCalibration() {
        gazeTracker.resetCalibration()
    }
    
    /**
     * Get current performance metrics.
     */
    fun getPerformanceMetrics(): PerformanceMonitor.PerformanceMetrics {
        return performanceMonitor.getMetrics()
    }
}
