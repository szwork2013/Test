package com.kaikeba.common.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import com.kaikeba.common.R;

/**
 * Created by sjyin on 14-8-9.
 */
public class MyRatingBar extends RelativeLayout {

    private int numStars;
    private float rating;
    private Drawable progressDrawable;
    private Drawable secondaryProgress;
    private Drawable progress;
    private float starInterval;
    private float starWidth;
    private float starHeight;
    private Context context;
    public MyRatingBar(Context context) {
        super(context);
    }
    public MyRatingBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
        initAttr(attrs);
        addBg();
    }
    public MyRatingBar(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.context = context;
        initAttr(attrs);
        addBg();
    }

    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    public static int dip2px2(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    private void initAttr(AttributeSet attrs) {
        this.context = context;
        TypedArray mTypedArray = context.obtainStyledAttributes(attrs, R.styleable.MyRatingBar);

        //获取自定义属性和默认值
        numStars = mTypedArray.getInt(R.styleable.MyRatingBar_numStars, 5);
        rating = mTypedArray.getFloat(R.styleable.MyRatingBar_rating, 1.5f);
        progressDrawable = mTypedArray.getDrawable(R.styleable.MyRatingBar_progressDrawable);
        secondaryProgress = mTypedArray.getDrawable(R.styleable.MyRatingBar_secondaryProgress);
        progress = mTypedArray.getDrawable(R.styleable.MyRatingBar_progress);
        starInterval = mTypedArray.getDimension(R.styleable.MyRatingBar_starInterval, 5.0f);
        starWidth = mTypedArray.getDimension(R.styleable.MyRatingBar_starWidth, 11.0f);
        starHeight = mTypedArray.getDimension(R.styleable.MyRatingBar_starHeight, 10.0f);
    }

    private void addBg() {
        LinearLayout bg = new LinearLayout(context);
        for (int i = 0; i < numStars; i++) {
            ImageView bgStar = new ImageView(context);
            bgStar.setImageDrawable(progress);
            LinearLayout.LayoutParams mBgStarParams = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            if (i != numStars - 1) {
                mBgStarParams.rightMargin = (int) starInterval;
            }
            setDimension(mBgStarParams);
            bg.addView(bgStar, mBgStarParams);
        }
        addView(bg);
        addStar();
    }

    private void addStar() {

        LinearLayout star = new LinearLayout(context);
        for (int i = 0; i < rating; i++) {
            ImageView bgStar = new ImageView(context);
            bgStar.setImageDrawable(progressDrawable);
            LinearLayout.LayoutParams mBgStarParams = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            if (i != numStars - 1) {
                mBgStarParams.rightMargin = (int) starInterval;
            }
            setDimension(mBgStarParams);
            star.addView(bgStar, i, mBgStarParams);
        }
        if (rating - (int) rating > 0) {
            star.removeViewAt((int) rating);
            ImageView halfStar = new ImageView(context);
            LinearLayout.LayoutParams mBgStarParams = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            setDimension(mBgStarParams);
            halfStar.setLayoutParams(mBgStarParams);

            halfStar.setImageDrawable(secondaryProgress);
            star.addView(halfStar);
        }
        addView(star);
    }

    private void setDimension(LinearLayout.LayoutParams mBgStarParams) {
        mBgStarParams.width = (int) starWidth;
        mBgStarParams.height = (int) starHeight;
    }

    public void setRating(float rating) {
        this.rating = rating;
        removeViewAt(1);
        addStar();
    }

    public void setFullStar(Drawable star) {
        this.progressDrawable = star;
        removeViewAt(1);
        addStar();
    }

    public void setHalfStar(Drawable halfStar) {
        this.secondaryProgress = halfStar;
        removeViewAt(1);
        addStar();
    }

}
