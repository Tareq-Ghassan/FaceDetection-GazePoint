package com.facedetection.camerax;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.camera.core.CameraSelector;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;

public class GraphicOverlay extends View {

    private final Object lock = new Object();
    private final List<Graphic> graphics = new ArrayList<>();
    private Float mScale;
    private Float mOffsetX;
    private Float mOffsetY;
    private int cameraSelector = CameraSelector.LENS_FACING_FRONT;

    public GraphicOverlay(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public boolean isFrontMode() {
        return cameraSelector == CameraSelector.LENS_FACING_FRONT;
    }

    public void toggleSelector() {
        cameraSelector = (cameraSelector == CameraSelector.LENS_FACING_BACK)
                ? CameraSelector.LENS_FACING_FRONT
                : CameraSelector.LENS_FACING_BACK;
    }

    public void clear() {
        synchronized (lock) {
            graphics.clear();
        }
        postInvalidate();
    }

    public void add(Graphic graphic) {
        synchronized (lock) {
            graphics.add(graphic);
        }
    }

    public void remove(Graphic graphic) {
        synchronized (lock) {
            graphics.remove(graphic);
        }
        postInvalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        synchronized (lock) {
            for (Graphic graphic : graphics) {
                try {
                    graphic.draw(canvas);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
        }
    }

    public abstract static class Graphic {

        private final GraphicOverlay overlay;

        public Graphic(GraphicOverlay overlay) {
            this.overlay = overlay;
        }

        public abstract void draw(Canvas canvas) throws Exception;


        public RectF calculateRect(float height, float width, Rect boundingBoxT) throws Exception {

            // for landscape
            Callable<Boolean> isLandscapeMode = () -> {
               boolean  v= overlay.getContext().getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE;
                return v;
            };


            Callable<Float> whenLandscapeModeWidth = () -> {
                float v = isLandscapeMode.call() ? width : height;
                return v;
            };

            Callable<Float> whenLandscapeModeHeight = () -> {
                float v = isLandscapeMode.call() ? height : width;
                return v;
            };

            float scaleX = overlay.getWidth() / whenLandscapeModeWidth.call();
            float scaleY = overlay.getHeight() / whenLandscapeModeHeight.call();
            float scale = Math.max(scaleX, scaleY);
            overlay.mScale = scale;

            // Calculate offset (we need to center the overlay on the target)
            float offsetX = (float) ((overlay.getWidth() - Math.ceil(whenLandscapeModeWidth.call() * scale)) / 2.0f);
            float offsetY = (float) ((overlay.getHeight() - Math.ceil(whenLandscapeModeHeight.call() * scale)) / 2.0f);

            overlay.mOffsetX = offsetX;
            overlay.mOffsetY = offsetY;

            RectF mappedBox = new RectF();
            mappedBox.left = boundingBoxT.right * scale + offsetX;
            mappedBox.top = boundingBoxT.top * scale + offsetY;
            mappedBox.right = boundingBoxT.left * scale + offsetX;
            mappedBox.bottom = boundingBoxT.bottom * scale + offsetY;

            // for front mode
            if (overlay.isFrontMode()) {
                float centerX = overlay.getWidth() / 2.0f;
                mappedBox.left = centerX + (centerX - mappedBox.left);
                mappedBox.right = centerX - (mappedBox.right - centerX);
            }
            return mappedBox;
        }
    }
}
