package com.facedetection.face_detection;

import static androidx.camera.core.CameraX.getContext;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.PointF;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facedetection.GazeViewModel;
import com.facedetection.camerax.BaseImageAnalyzer;
import com.facedetection.camerax.GraphicOverlay;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.ar.sceneform.math.Vector3;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import com.google.mlkit.vision.face.FaceLandmark;

import java.util.List;

public class FaceContourDetectionProcessor extends BaseImageAnalyzer<List<Face>> {
    private Context context;
    private GazeViewModel viewModel;

    private static final String TAG = "FaceDetectorProcessor";
    private final GraphicOverlay view;
    private final FaceDetectorOptions realTimeOpts;
    private final FaceDetector detector;

    public FaceContourDetectionProcessor(GraphicOverlay view, GazeViewModel viewModel) {
        this.view = view;
        this.viewModel = viewModel;
        this.realTimeOpts = new FaceDetectorOptions.Builder()
                .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
                .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
                .build();
        this.detector = FaceDetection.getClient(realTimeOpts);
    }

    @Override
    public GraphicOverlay getGraphicOverlay() {
        return view;
    }

    @Override
    public Task<List<Face>> detectInImage(InputImage image) {
        detectFaces(image);
        return detector.process(image);
    }

    @Override
    public void stop() {
        detector.close();
    }

    @Override
    public void onSuccess(List<Face> results, GraphicOverlay graphicOverlay, Rect rect) {
        graphicOverlay.clear();
        for (Face face : results) {
            FaceContourGraphic faceGraphic = new FaceContourGraphic(graphicOverlay, face, rect);
            graphicOverlay.add(faceGraphic);
        }
        graphicOverlay.postInvalidate();

    }
    private String formatGazePoint(PointF gazePoint) {
        return "Gaze Point: (" + gazePoint.x + ", " + gazePoint.y + ")";
    }

    private void detectFaces(InputImage image) {
        FaceDetectorOptions options =
                new FaceDetectorOptions.Builder()
                        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
                        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
                        .setMinFaceSize(0.15f)
                        .enableTracking()
                        .build();

        FaceDetector detector = FaceDetection.getClient(options);

        Task<List<Face>> result =
                detector.process(image)
                        .addOnSuccessListener(
                                new OnSuccessListener<List<Face>>() {
                                    @Override
                                    public void onSuccess(List<Face> faces) {
                                        for (Face face : faces) {
                                            FaceLandmark leftEyeLandmark = face.getLandmark(FaceLandmark.LEFT_EYE);
                                            FaceLandmark rightEyeLandmark = face.getLandmark(FaceLandmark.RIGHT_EYE);
                                            if (leftEyeLandmark != null && rightEyeLandmark != null) {
                                                PointF leftEyePosition = leftEyeLandmark.getPosition();
                                                Log.d(TAG, "left"+leftEyePosition);
                                                PointF rightEyePosition = rightEyeLandmark.getPosition();
                                                Log.d(TAG, " right"+rightEyePosition);
                                                Vector3 gazeVector = calculateGazeVector(leftEyePosition, rightEyePosition);
                                                PointF mappedGazeVector = mapGazeVectorToScreenCoordinates(gazeVector);
                                                PointF gazePoint = calculateGazePoint(mappedGazeVector);
                                                if(gazePoint.x!=0 && gazePoint.y!=0&&viewModel != null) {
                                                    viewModel.setGazePoint(formatGazePoint(gazePoint));
                                                    Log.d(TAG, "Gaze point :" +formatGazePoint(gazePoint));
                                                }
                                                else{
                                                    viewModel.setGazePoint("No Eye Detected");
                                                    Log.e(TAG,"No Eye Detected");
                                                }
                                            } else {

                                                viewModel.setGazePoint("No Eye Detected");
                                                Log.w(TAG, "No Eye Detected");
                                            }
                                        }
                                    }
                                })
                        .addOnFailureListener(
                                new OnFailureListener() {
                                    @Override
                                    public void onFailure(@NonNull Exception e) {
                                        viewModel.setGazePoint("No Face Detected or Multiple Faces Detected");
                                        Log.w(TAG, "Face Detector failed: " + e);
                                    }
                                });
    }

    @Override
    public void onFailure(Exception e) {
        viewModel.setGazePoint("Face Detector failed");
        Log.w(TAG, "Face Detector failed: " + e);
    }

    public Vector3 calculateGazeVector(PointF leftEyePosition, PointF rightEyePosition) {
        // Calculate the midpoint between the left and right eye positions
        PointF eyeMidPoint = new PointF(
                (leftEyePosition.x + rightEyePosition.x) / 2,
                (leftEyePosition.y + rightEyePosition.y) / 2
        );

        // Calculate the gaze vector by subtracting the left eye position from the right eye position
        Vector3 gazeVector = new Vector3(
                rightEyePosition.x - leftEyePosition.x,
                rightEyePosition.y - leftEyePosition.y,
                0f
        );

        // Normalize the gaze vector
        gazeVector.normalized();

        return gazeVector;
    }

    private PointF mapGazeVectorToScreenCoordinates(Vector3 gazeVector) {

        // Get screen dimensions
        DisplayMetrics displayMetrics = getContext().getResources().getDisplayMetrics();
        int screenWidth = displayMetrics.widthPixels;
        int screenHeight = displayMetrics.heightPixels;

        // Adjust the gaze vector based on the screen orientation
        int screenOrientation = getContext().getResources().getConfiguration().orientation;
        if (screenOrientation == Configuration.ORIENTATION_LANDSCAPE) {
            gazeVector = new Vector3(gazeVector.y, gazeVector.x, -gazeVector.z);
        }

        // Map the gaze vector to screen coordinates
        float screenX = screenWidth / 2 + gazeVector.x * (screenWidth / 2);
        float screenY = screenHeight / 2 - gazeVector.y * (screenHeight / 2);

        return new PointF(screenX, screenY);
    }

    private PointF calculateGazePoint(PointF mappedGazeVector) {
        // Get screen dimensions
        DisplayMetrics displayMetrics = getContext().getResources().getDisplayMetrics();
        int screenWidth = displayMetrics.widthPixels;
        int screenHeight = displayMetrics.heightPixels;

        // Calculate the gaze point
        float gazePointX = mappedGazeVector.x * screenWidth;
        float gazePointY = mappedGazeVector.y * screenHeight;
        if (gazePointX > 0 && gazePointY > 0) {
            return new PointF(gazePointX, gazePointY);
        }
        else return new PointF(0,0);
    }
}