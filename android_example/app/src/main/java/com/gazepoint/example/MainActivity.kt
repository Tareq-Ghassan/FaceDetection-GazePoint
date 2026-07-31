package com.gazepoint.example

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.gazepoint.example.camerax.CameraManager
import com.gazepoint.example.databinding.ActivityMainBinding
import com.gazepoint.sdk.GazePointSDK

/**
 * Demo host app for GazePoint SDK — mirrors ios_example.
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var viewModel: GazeViewModel
    private lateinit var cameraManager: CameraManager

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            cameraManager.startCamera()
        } else {
            Toast.makeText(this, "Camera permission is required", Toast.LENGTH_LONG).show()
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        GazePointSDK.printInfo()

        viewModel = ViewModelProvider(this)[GazeViewModel::class.java]
        cameraManager = CameraManager(
            context = this,
            previewView = binding.previewView,
            lifecycleOwner = this,
            graphicOverlay = binding.graphicOverlay,
            viewModel = viewModel
        )

        binding.btnSwitch.setOnClickListener { cameraManager.changeCameraSelector() }

        viewModel.uiState.observe(this) { state ->
            binding.statusText.text = state.statusText
            binding.statusText.setTextColor(
                ContextCompat.getColor(
                    this,
                    if (state.faceDetected) android.R.color.holo_green_light
                    else android.R.color.holo_orange_light
                )
            )

            if (state.faceDetected && state.gazePoint != null) {
                val point = state.gazePoint
                binding.gazePointText.text = getString(
                    R.string.gaze_detail_format,
                    point.x,
                    point.y,
                    state.confidence * 100f
                )
                binding.headPoseText.text = getString(
                    R.string.head_pose_format,
                    state.pitch,
                    state.yaw,
                    state.roll
                ) + if (state.isBlinking) "\nEyes: blinking" else "\nEyes: open"

                binding.gazeIndicator.visibility = View.VISIBLE
                binding.gazeIndicator.post {
                    val halfW = binding.gazeIndicator.width / 2f
                    val halfH = binding.gazeIndicator.height / 2f
                    binding.gazeIndicator.x = point.x - halfW
                    binding.gazeIndicator.y = point.y - halfH
                }
            } else {
                binding.gazePointText.text = getString(R.string.gaze_point_placeholder)
                binding.headPoseText.text = getString(R.string.point_camera_hint)
                binding.gazeIndicator.visibility = View.GONE
            }
        }

        checkCameraPermission()
    }

    private fun checkCameraPermission() {
        when {
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                    == PackageManager.PERMISSION_GRANTED -> cameraManager.startCamera()
            else -> permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::cameraManager.isInitialized) {
            cameraManager.shutdown()
        }
    }
}
