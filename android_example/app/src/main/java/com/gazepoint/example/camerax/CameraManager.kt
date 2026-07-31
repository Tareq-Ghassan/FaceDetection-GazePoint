package com.gazepoint.example.camerax

import android.content.Context
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.gazepoint.example.GazeViewModel
import com.gazepoint.example.face_detection.GazeFaceProcessor
import java.util.concurrent.Executors

/**
 * Binds CameraX preview + analysis to [GazeFaceProcessor].
 */
class CameraManager(
    private val context: Context,
    private val previewView: PreviewView,
    private val lifecycleOwner: LifecycleOwner,
    private val graphicOverlay: GraphicOverlay,
    private val viewModel: GazeViewModel
) {
    companion object {
        private const val TAG = "CameraManager"
    }

    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private var cameraSelectorOption = CameraSelector.LENS_FACING_FRONT
    private var cameraProvider: ProcessCameraProvider? = null
    private var analyzer: GazeFaceProcessor? = null

    fun startCamera() {
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener({
            try {
                cameraProvider = future.get()
                bindUseCases()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start camera", e)
                viewModel.setStatus("Camera unavailable")
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindUseCases() {
        val provider = cameraProvider ?: return

        val preview = Preview.Builder().build().also {
            it.surfaceProvider = previewView.surfaceProvider
        }

        analyzer?.stop()
        val processor = GazeFaceProcessor(context, graphicOverlay, viewModel)
        analyzer = processor

        val imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also { it.setAnalyzer(cameraExecutor, processor) }

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(cameraSelectorOption)
            .build()

        try {
            provider.unbindAll()
            provider.bindToLifecycle(lifecycleOwner, cameraSelector, preview, imageAnalysis)
            viewModel.setStatus("Look at the screen — tracking…")
        } catch (e: Exception) {
            Log.e(TAG, "Use case binding failed", e)
            viewModel.setStatus("Camera bind failed")
        }
    }

    fun changeCameraSelector() {
        cameraProvider?.unbindAll()
        cameraSelectorOption =
            if (cameraSelectorOption == CameraSelector.LENS_FACING_BACK) {
                CameraSelector.LENS_FACING_FRONT
            } else {
                CameraSelector.LENS_FACING_BACK
            }
        graphicOverlay.toggleSelector()
        startCamera()
    }

    fun shutdown() {
        analyzer?.stop()
        cameraExecutor.shutdown()
    }
}
