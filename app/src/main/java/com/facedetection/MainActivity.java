package com.facedetection;

import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.facedetection.camerax.CameraManager;

/**
 * The main activity of the face detection application.
 */
public class MainActivity extends AppCompatActivity {
    private TextView gazePointTextView;

    private CameraManager cameraManager;
    private GazeViewModel viewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        gazePointTextView = findViewById(R.id.gazePointTextView);

        // Initialize the ViewModel
        viewModel = new ViewModelProvider(this).get(GazeViewModel.class);

        // Initialize the ViewModel
        createCameraManager(viewModel);

        // Check for camera permission and start the camera if granted
        checkForPermission();

        // Setup click listener for camera switch button
        onClicks();

        // Observe changes in the gaze point and update the UI accordingly
        viewModel.getGazePoint().observe(this, new Observer<String>() {
            @Override
            public void onChanged(String gazePoint) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        gazePointTextView.setText(gazePoint);
                    }
                });

            }
        });
    }

    // Check for camera permission and start the camera if granted
    private void checkForPermission() {
        if (allPermissionsGranted()) {
            cameraManager.startCamera();
        } else {
            ActivityCompat.requestPermissions(
                    this,
                    REQUIRED_PERMISSIONS,
                    REQUEST_CODE_PERMISSIONS
            );
        }
    }

    // Set up click listener for the camera switch button
    private void onClicks() {
        findViewById(R.id.btnSwitch).setOnClickListener(view -> cameraManager.changeCameraSelector());
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (allPermissionsGranted()) {
                cameraManager.startCamera();
            } else {
                Toast.makeText(this, "Permissions not granted by the user.", Toast.LENGTH_SHORT)
                        .show();
                finish();
            }
        }
    }

    // Create and initialize the CameraManager with the ViewModel
    private void createCameraManager(GazeViewModel viewModel) {
        cameraManager = new CameraManager(
                this,
                findViewById(R.id.previewView_finder),
                this,
                findViewById(R.id.graphicOverlay_finder),
                viewModel
        );
    }

    // Check if all required permissions are granted
    private boolean allPermissionsGranted() {
        for (String permission : REQUIRED_PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    private static final int REQUEST_CODE_PERMISSIONS = 10;
    private static final String[] REQUIRED_PERMISSIONS = new String[]{android.Manifest.permission.CAMERA};


}