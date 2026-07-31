package com.gazepoint.example.face_detection;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;

import com.gazepoint.example.camerax.GraphicOverlay;
import com.google.mlkit.vision.face.Face;

/**
 * Draws a face bounding box on the graphic overlay.
 */
public class FaceContourGraphic extends GraphicOverlay.Graphic {

    private static final float BOX_STROKE_WIDTH = 5.0f;

    private final Face face;
    private final Rect imageRect;
    private final Paint boxPaint;

    public FaceContourGraphic(GraphicOverlay overlay, Face face, Rect imageRect) {
        super(overlay);
        this.face = face;
        this.imageRect = imageRect;

        boxPaint = new Paint();
        boxPaint.setColor(Color.WHITE);
        boxPaint.setStyle(Paint.Style.STROKE);
        boxPaint.setStrokeWidth(BOX_STROKE_WIDTH);
    }

    @Override
    public void draw(Canvas canvas) throws Exception {
        RectF rect = calculateRect(
                imageRect.height(),
                imageRect.width(),
                face.getBoundingBox()
        );
        canvas.drawRect(rect, boxPaint);
    }
}
