package com.facedetection.camerax;


import android.annotation.SuppressLint;
import android.graphics.Rect;
import android.media.Image;

import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;

import com.google.android.gms.tasks.Task;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;

import java.util.List;


/**
 * An abstract base class for image analyzers used for face detection.
 *
 * @param <T> The type of results returned by the analyzer.
 */
public abstract class BaseImageAnalyzer<T> implements ImageAnalysis.Analyzer {

    /**
     * Get the graphic overlay associated with this image analyzer.
     *
     * @return The GraphicOverlay used for drawing results.
     */
    public abstract GraphicOverlay getGraphicOverlay();

    @SuppressLint("UnsafeExperimentalUsageError")
    @Override
    public void analyze(ImageProxy imageProxy) {
        Image mediaImage = imageProxy.getImage();
        if (mediaImage != null) {
            InputImage inputImage = InputImage.fromMediaImage(mediaImage, imageProxy.getImageInfo().getRotationDegrees());
            detectInImage(inputImage)
                    .addOnSuccessListener(results -> {
                        onSuccess((T) results, getGraphicOverlay(), mediaImage.getCropRect());
                        imageProxy.close();
                    })
                    .addOnFailureListener(e -> {
                        onFailure(e);
                        imageProxy.close();
                    });
        }
    }

    /**
     * Detects objects or features in the input image.
     *
     * @param image The input image.
     * @return A Task containing the detection results.
     */
    public abstract Task<List<Face>> detectInImage(InputImage image);

    /**
     * Stops the image analyzer and releases resources.
     */
    public abstract void stop();

    /**
     * Called when the analysis is successful.
     *
     * @param results        The analysis results.
     * @param graphicOverlay The GraphicOverlay used for drawing results.
     * @param rect           The rectangular region of interest in the input image.
     */
    protected abstract void onSuccess(
            T results,
            GraphicOverlay graphicOverlay,
            Rect rect
    );

    /**
     * Called when the analysis encounters an error.
     *
     * @param e The exception representing the error.
     */
    protected abstract void onFailure(Exception e);

}