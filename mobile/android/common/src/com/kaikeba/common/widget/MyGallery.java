package com.kaikeba.common.widget;

/**
 * 自己定义的Gallery
 */

import android.content.Context;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.widget.Gallery;

public class MyGallery extends Gallery {

//    int mCoveflowCenter;
//    private int mMaxRotationAngle = 40;
//    private int mMaxZoom = 10;
//
//    private Camera mCamera = new Camera();

    /**
     * 申明键盘监听事件
     */
    private OnKeyListener mOnKeyListener;

    public MyGallery(Context context) {
        super(context);

//        this.setStaticTransformationsEnabled(true);

    }

    public MyGallery(Context context, AttributeSet attrs) {
        super(context, attrs);
//        this.setStaticTransformationsEnabled(true);

    }

    public MyGallery(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
//        this.setStaticTransformationsEnabled(true);
    }

    /**
     * 重写Gallery中的其他方法 可以实现其他功能 比如层叠效果、翻转效果等 这里只关注按键事件的处理
     */

    /**
     * 重写Gallery中的dispatchKeyEvent方法 手动分发按键事件
     */
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (mOnKeyListener != null
                && mOnKeyListener.onKey(this, event.getKeyCode(), event)) {
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    /**
     * 重写Gallery中的setOnKeyListener方法 设置键盘事件监听器
     */
    @Override
    public void setOnKeyListener(OnKeyListener onKeyListener) {
        mOnKeyListener = onKeyListener;
    }


//    private int getCenterOfView(View view) {
//
//        return view.getLeft() + view.getWidth() / 2;
//    }
//
//    private int getCenterOfCoverflow() {
//        return (getWidth() - getPaddingLeft() - getPaddingRight()) / 2 + getPaddingLeft();
//    }
//
//    private void transformImageBitmap(ImageView child, Transformation t, int rotationAngle) {
//
//        mCamera.save();
//        final Matrix imageMatrix = t.getMatrix();
//        final int imageHeight = child.getLayoutParams().height;
//        final int imageWidth = child.getLayoutParams().width;
//        final int rotation = Math.abs(rotationAngle);
//
//        // 在Z轴上正向移动camera的视角，实际效果为放大图片。
//        // 如果在Y轴上移动，则图片上下移动；X轴上对应图片左右移动。
//        mCamera.translate(0.0f, 0.0f, 100.0f);
//
//        // As the angle of the view gets less, zoom in
//        if (rotation < mMaxRotationAngle) {
//            float zoomAmount = (float) (mMaxZoom + (rotation * 1.5));
//            mCamera.translate(0.0f, 0.0f, zoomAmount );
//        }
//        // 在Y轴上旋转，对应图片竖向向里翻转。
//        // 如果在X轴上旋转，则对应图片横向向里翻转。
//        mCamera.rotateY(rotationAngle);
//        mCamera.getMatrix(imageMatrix);
//        imageMatrix.preTranslate(-(imageWidth / 2), -(imageHeight / 2));
//        imageMatrix.postTranslate((imageWidth / 2), (imageHeight / 2));
//        mCamera.restore();
//    }
//
//    @Override
//    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
//
//        mCoveflowCenter = getCenterOfCoverflow();
//        super.onSizeChanged(w, h, oldw, oldh);
//    }
//    private String TAG = "MyGallery";
//    @Override
//    protected boolean getChildStaticTransformation(View child, Transformation t) {
//
//        //取得当前子view的半径值
//        final int childCenter = getCenterOfView(child);
//        final int childWidth = child.getWidth();
//
//        //旋转角度
//        int rotationAngle = 0;
//        //重置转换状态
//        t.clear();
//        //设置转换类型
//        t.setTransformationType(Transformation.TYPE_BOTH);
//        //如果图片位于中心位置不需要进行旋转
//        if (childCenter == mCoveflowCenter) {
//            transformImageBitmap((ImageView) child, t, 0);
//        } else {
//            //根据图片在gallery中的位置来计算图片的旋转角度
//            rotationAngle = (int) (((float) (mCoveflowCenter - childCenter) / childWidth) * mMaxRotationAngle);
//
//            //如果旋转角度绝对值大于最大旋转角度返回（-mMaxRotationAngle或mMaxRotationAngle;）
//            if (Math.abs(rotationAngle) > mMaxRotationAngle) {
//                rotationAngle = (rotationAngle < 0) ? -mMaxRotationAngle : mMaxRotationAngle;
//            }
//
//            transformImageBitmap((ImageView) child, t, rotationAngle);
//        }
//
//        return true;
//    }
}
