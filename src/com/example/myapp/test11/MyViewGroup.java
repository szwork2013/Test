package com.example.myapp.test11;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Scroller;
import android.widget.ViewFlipper;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-28.
 */
public class MyViewGroup extends ViewGroup {
    private Context mContext;
    private String tag = "sjyin";

    public MyViewGroup(Context context) {
        super(context);
        this.mContext = context;
        init();
    }

    public MyViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mContext = context;
        init();
    }

    public MyViewGroup(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.mContext = context;
        init();
    }

    private double lastMotionX;
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        double motionX = event.getX();
        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                break;
            case MotionEvent.ACTION_MOVE:
                break;
            case MotionEvent.ACTION_UP:
                break;
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return super.onInterceptTouchEvent(ev);
    }

    private Scroller mScroller;

    private void init(){
        LinearLayout l1 = new LinearLayout(mContext);
        l1.setBackgroundColor(mContext.getResources().getColor(R.color.red));
        LinearLayout l2 = new LinearLayout(mContext);
        l2.setBackgroundColor(mContext.getResources().getColor(R.color.gray));
        LinearLayout l3 = new LinearLayout(mContext);
        l3.setBackgroundColor(mContext.getResources().getColor(R.color.blue));
        addView(l1);
        addView(l2);
        addView(l3);

        mScroller = new Scroller(mContext);
        mScroller.getCurrVelocity();
        ViewConfiguration viewConfiguration = ViewConfiguration.get(mContext);
        float scaledMinimumFlingVelocity = viewConfiguration.getScaledMinimumFlingVelocity();
        float scaledTouchSlop = viewConfiguration.getScaledTouchSlop();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        Log.i(tag,"widthMode = " + widthMode +"  heightMode = "+heightMode);
        int measureWidth = MeasureSpec.getSize(widthMeasureSpec);
        int measureHeight = MeasureSpec.getSize(heightMeasureSpec);
        Log.i(tag, "view group getWidth = " + getWidth());
        Log.i(tag, "view group getHeight = " + getHeight());
        setMeasuredDimension(measureWidth,measureHeight);
        for(int i = 0; i< getChildCount();i++){
            getChildAt(i).measure(getWidth(),getHeight());
        }
    }

    private int startLeft = 0;
    private int startRight = 0;
    private int startTop = 0;
    private int startBottom = 0;

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for(int i = 0;i < getChildCount();i++){
            startLeft = getWidth() * i;
            startRight = getWidth() *(i + 1);
            getChildAt(i).layout(startLeft,startTop,startRight,startBottom);
        }
    }
}
