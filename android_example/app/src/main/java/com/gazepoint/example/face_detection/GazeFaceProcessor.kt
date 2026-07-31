package com.gazepoint.example.face_detection

import android.content.Context
import android.graphics.Rect
import android.util.Log
import com.gazepoint.example.GazeViewModel
import com.gazepoint.example.camerax.BaseImageAnalyzer
import com.gazepoint.example.camerax.GraphicOverlay
import com.gazepoint.sdk.GazeTracker
import com.gazepoint.sdk.PerformanceMonitor
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.google.mlkit.vision.face.FaceDetectorOptions

/**
 * Demo face processor: ML Kit detection + GazePointSDK gaze estimation.
 */
class GazeFaceProcessor(
    context: Context,
    private val graphicOverlay: GraphicOverlay,
    private val viewModel: GazeViewModel
) : BaseImageAnalyzer<List<Face>>() {

    companion object {
        private const val TAG = "GazeFaceProcessor"
        private const val PERFORMANCE_LOG_INTERVAL = 60
    }

    private val gazeTracker = GazeTracker(context)
    private val performanceMonitor = PerformanceMonitor()
    private var framesSinceLastLog = 0

    private val faceDetector: FaceDetector = FaceDetection.getClient(
        FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
            .setMinFaceSize(0.15f)
            .enableTracking()
            .build()
    )

    override fun getGraphicOverlay(): GraphicOverlay = graphicOverlay

    override fun detectInImage(image: InputImage): Task<List<Face>> = faceDetector.process(image)

    override fun onSuccess(results: List<Face>, graphicOverlay: GraphicOverlay, rect: Rect) {
        val startTime = performanceMonitor.startFrame()
        graphicOverlay.clear()

        when {
            results.isEmpty() -> viewModel.applyResult(null)
            else -> {
                val primary = selectPrimaryFace(results)
                results.forEach { face ->
                    graphicOverlay.add(FaceContourGraphic(graphicOverlay, face, rect))
                }
                viewModel.applyResult(primary?.let { gazeTracker.calculateGazePoint(it) })
            }
        }

        graphicOverlay.postInvalidate()
        performanceMonitor.endFrame(startTime)

        framesSinceLastLog++
        if (framesSinceLastLog >= PERFORMANCE_LOG_INTERVAL) {
            performanceMonitor.logMetrics()
            framesSinceLastLog = 0
            if (performanceMonitor.isPerformanceDegraded()) {
                Log.w(TAG, "Performance degradation detected")
            }
        }
    }

    private fun selectPrimaryFace(faces: List<Face>): Face? {
        return faces.maxByOrNull { face ->
            val box = face.boundingBox
            val area = box.width() * box.height()
            val trackingScore = if (face.trackingId != null) 1000 else 0
            area + trackingScore
        }
    }

    override fun onFailure(e: Exception) {
        viewModel.setStatus("Face detection failed: ${e.message}")
        Log.e(TAG, "Face detection failed", e)
    }

    override fun stop() {
        try {
            faceDetector.close()
            performanceMonitor.logMetrics()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping face detector", e)
        }
    }
}
