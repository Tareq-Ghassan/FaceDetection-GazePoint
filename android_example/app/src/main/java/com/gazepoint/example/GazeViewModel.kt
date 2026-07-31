package com.gazepoint.example

import android.graphics.PointF
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gazepoint.sdk.GazeTracker

/**
 * Holds the latest gaze tracking result for the demo UI.
 */
class GazeViewModel : ViewModel() {

    data class UiState(
        val faceDetected: Boolean = false,
        val statusText: String = "Starting camera…",
        val gazePoint: PointF? = null,
        val confidence: Float = 0f,
        val isBlinking: Boolean = false,
        val pitch: Float = 0f,
        val yaw: Float = 0f,
        val roll: Float = 0f
    )

    private val _uiState = MutableLiveData(UiState())
    val uiState: LiveData<UiState> = _uiState

    fun applyResult(result: GazeTracker.GazeResult?) {
        if (result == null) {
            _uiState.postValue(
                UiState(
                    faceDetected = false,
                    statusText = "No face detected"
                )
            )
            return
        }

        _uiState.postValue(
            UiState(
                faceDetected = true,
                statusText = if (result.isBlinking) "Blink detected" else "Tracking",
                gazePoint = result.gazePoint,
                confidence = result.confidence,
                isBlinking = result.isBlinking,
                pitch = result.headPose.pitch,
                yaw = result.headPose.yaw,
                roll = result.headPose.roll
            )
        )
    }

    fun setStatus(message: String) {
        val current = _uiState.value ?: UiState()
        _uiState.postValue(current.copy(statusText = message, faceDetected = false))
    }
}
