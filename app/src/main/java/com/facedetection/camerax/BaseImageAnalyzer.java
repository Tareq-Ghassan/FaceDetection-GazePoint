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

public abstract class BaseImageAnalyzer<T> implements ImageAnalysis.Analyzer {

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


    public abstract Task<List<Face>> detectInImage(InputImage image);

    public abstract void stop();

    protected abstract void onSuccess(
            T results,
            GraphicOverlay graphicOverlay,
            Rect rect
    );

    protected abstract void onFailure(Exception e);

}