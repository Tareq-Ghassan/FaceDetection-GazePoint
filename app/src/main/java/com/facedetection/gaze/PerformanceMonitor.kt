package com.facedetection.gaze

import android.util.Log
import java.util.concurrent.ConcurrentLinkedQueue
import kotlin.math.roundToInt

/**
 * Performance monitor for tracking FPS, processing time, and other metrics.
 */
class PerformanceMonitor {
    
    companion object {
        private const val TAG = "PerformanceMonitor"
        private const val WINDOW_SIZE = 30 // Rolling window for averages
    }
    
    private val frameTimestamps = ConcurrentLinkedQueue<Long>()
    private val processingTimes = ConcurrentLinkedQueue<Long>()
    private var lastFrameTime = 0L
    private var frameCount = 0L
    private var totalProcessingTime = 0L
    
    data class PerformanceMetrics(
        val fps: Float,
        val avgProcessingTimeMs: Float,
        val maxProcessingTimeMs: Long,
        val droppedFrames: Int,
        val totalFrames: Long
    )
    
    /**
     * Record start of frame processing.
     */
    fun startFrame(): Long {
        return System.nanoTime()
    }
    
    /**
     * Record end of frame processing.
     */
    fun endFrame(startTime: Long) {
        val currentTime = System.nanoTime()
        val processingTime = (currentTime - startTime) / 1_000_000 // Convert to ms
        
        frameCount++
        totalProcessingTime += processingTime
        
        // Add to rolling window
        frameTimestamps.offer(currentTime)
        processingTimes.offer(processingTime)
        
        // Keep only recent data
        while (frameTimestamps.size > WINDOW_SIZE) {
            frameTimestamps.poll()
            processingTimes.poll()
        }
        
        lastFrameTime = currentTime
    }
    
    /**
     * Get current performance metrics.
     */
    fun getMetrics(): PerformanceMetrics {
        if (frameTimestamps.isEmpty()) {
            return PerformanceMetrics(0f, 0f, 0L, 0, frameCount)
        }
        
        // Calculate FPS
        val timestamps = frameTimestamps.toList()
        val fps = if (timestamps.size > 1) {
            val timeSpan = (timestamps.last() - timestamps.first()) / 1_000_000_000.0 // Convert to seconds
            if (timeSpan > 0) (timestamps.size / timeSpan).toFloat() else 0f
        } else {
            0f
        }
        
        // Calculate average processing time
        val times = processingTimes.toList()
        val avgProcessingTime = if (times.isNotEmpty()) {
            times.average().toFloat()
        } else {
            0f
        }
        
        // Find max processing time
        val maxProcessingTime = times.maxOrNull() ?: 0L
        
        // Estimate dropped frames (processing time > frame time)
        val targetFrameTime = 1000f / 30f // Assuming 30 FPS target
        val droppedFrames = times.count { it > targetFrameTime }
        
        return PerformanceMetrics(
            fps = fps,
            avgProcessingTimeMs = avgProcessingTime,
            maxProcessingTimeMs = maxProcessingTime,
            droppedFrames = droppedFrames,
            totalFrames = frameCount
        )
    }
    
    /**
     * Log current performance metrics.
     */
    fun logMetrics() {
        val metrics = getMetrics()
        Log.d(TAG, """
            Performance Metrics:
            FPS: ${metrics.fps.roundToInt()}
            Avg Processing Time: ${metrics.avgProcessingTimeMs.roundToInt()} ms
            Max Processing Time: ${metrics.maxProcessingTimeMs} ms
            Dropped Frames: ${metrics.droppedFrames}
            Total Frames: ${metrics.totalFrames}
        """.trimIndent())
    }
    
    /**
     * Reset all metrics.
     */
    fun reset() {
        frameTimestamps.clear()
        processingTimes.clear()
        lastFrameTime = 0L
        frameCount = 0L
        totalProcessingTime = 0L
    }
    
    /**
     * Check if performance is degraded.
     */
    fun isPerformanceDegraded(): Boolean {
        val metrics = getMetrics()
        return metrics.fps < 15f || metrics.avgProcessingTimeMs > 100f
    }
}
