package com.kaikeba.activity.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.*;
import android.graphics.Paint.Style;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.MotionEvent;
import android.view.View;

/**
 * Created by chris on 14-7-14.
 */
public class TimeFilterView extends View implements View.OnClickListener {

    private final int LEFTPADDING = 60;
    private final float ANGLE_MIN = 30;
    private float toAngle = ANGLE_MIN;
    Paint paint;
    private float mRadiusX = 0;//中心点x坐标
    private float mRadiusY = 0;//中心点y坐标
    private float mRadius;  //半径
    private RectF rect;//矩形触摸范围
    private Canvas canvas;// 画布
    private Bitmap bitmap;// 位图
    private float fromAngle = 270;
    private float lastAngle = 0;
    private Context mContext;

    public TimeFilterView(Context context) {
        super(context);
        mContext = context;
        init();
    }

    public TimeFilterView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mContext = context;
        init();
    }

    public TimeFilterView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        init();
    }

    private void init() {
        mRadiusX = getDisplayMetrics().widthPixels / 2;
        mRadiusY = getDisplayMetrics().heightPixels / 2;
        if (mRadiusX > mRadiusY) {
            mRadius = mRadiusY - LEFTPADDING;
        } else {
            mRadius = mRadiusX - LEFTPADDING;
        }
        rect = new RectF();
        rect.set(mRadiusX - mRadius, mRadiusY - mRadius, mRadiusX + mRadius, mRadiusY + mRadius);

        bitmap = Bitmap.createBitmap(getDisplayMetrics().widthPixels, getDisplayMetrics().heightPixels, Bitmap.Config.ARGB_8888); // 设置位图的宽高
        canvas = new Canvas();
        canvas.setBitmap(bitmap);

        paint = new Paint();
        paint.setStyle(Style.STROKE);// 设置非填充
        paint.setStrokeWidth(15);// 笔宽5像素
        paint.setColor(Color.RED);// 设置为红笔
        paint.setAntiAlias(true);// 锯齿不显示

        canvas.drawArc(rect, fromAngle, toAngle, false, paint);
    }

    private DisplayMetrics getDisplayMetrics() {
//        WindowManager dm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) mContext).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float touch_x = 0;
        float touch_y = 0;
        if (event.getAction() == MotionEvent.ACTION_DOWN) { //处理屏幕屏点下事件 手指点击屏幕时触发
            touch_x = event.getX();
            touch_y = event.getY();
            drawCirlce(touch_x, touch_y);
        } else if (event.getAction() == MotionEvent.ACTION_UP) {//处理屏幕屏抬起事件  手指离开屏幕时触发
            lastAngle = 0;
        } else if (event.getAction() == MotionEvent.ACTION_MOVE) {//处理移动事件 手指在屏幕上移动时触发
            touch_x = event.getX();
            touch_y = event.getY();
            drawCirlce(touch_x, touch_y);
        }
        return true;  //此处需要返回true 才可以正常处理move事件 详情见后面的  说明

    }

    private void drawCirlce(float touch_x, float touch_y) {
        if (!rect.contains(touch_x, touch_y)) {
            return;
        }
        canvas.drawColor(Color.WHITE); //清空画布
        float x, y;
        float z; //三角形斜边

        x = touch_x - mRadiusX;
        y = touch_y - mRadiusY;
        if (x != 0) {
            z = (float) Math.sqrt(x * x + y * y);
            toAngle = (float) ((float) Math.asin(x / z) * 180 / Math.PI);
            if (x > 0) {
                if (y > 0) {
                    toAngle = 180 - toAngle;
                }
            } else {
                if (y > 0) {
                    toAngle = 180 - toAngle;
                } else {
                    toAngle = 360 + toAngle;
                    if (toAngle > 356) {
                        toAngle = 360;
                    }
                }
            }
        } else {
            if (y > 0) {
                toAngle = 90;
            } else if (y < 0) {
                toAngle = 270;
            } else {
                //
            }
        }
        if (toAngle - lastAngle < -270) {
            toAngle = 360;
        }
        lastAngle = toAngle;

        if (toAngle < ANGLE_MIN) {
            toAngle = ANGLE_MIN;
        }
//        Log.d("jack","toAngle==" + toAngle);
        canvas.drawArc(rect, fromAngle, toAngle, false, paint);
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        canvas.drawBitmap(bitmap, 0, 0, paint);
    }

    @Override
    public void onClick(View v) {

    }

}
