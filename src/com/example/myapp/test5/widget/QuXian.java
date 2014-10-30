package com.example.myapp.test5.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.LinearLayout;

/**
 * Created by sjyin on 14-10-8.
 */
public class QuXian extends LinearLayout {

    public QuXian(Context context) {
        super(context);
    }

    public QuXian(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public QuXian(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        Paint pen = new Paint();
        pen.setColor(Color.RED);
        pen.setStrokeWidth(5f);
        canvas.drawLine(20f,20f,100f,100f,pen);
        canvas.drawLine(500f,500f,590f,590f,pen);
    }

    private void init(){

    }
}
