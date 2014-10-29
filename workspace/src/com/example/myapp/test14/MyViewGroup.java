package com.example.myapp.test14;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Scroller;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-28.
 */
public class MyViewGroup extends ViewGroup{

    private Context context;
    private String tag = "sjyin";

    public MyViewGroup(Context context) {
        super(context);
        this.context = context;
        init();
    }

    public MyViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
        init();
    }

    public MyViewGroup(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.context = context;
        init();
    }

    private Scroller mScroll;
    private int touchSlop;

    private void init() {
        LinearLayout l1 = new LinearLayout(context);
        LinearLayout l2 = new LinearLayout(context);
        LinearLayout l3 = new LinearLayout(context);
        l1.setBackgroundColor(context.getResources().getColor(R.color.red));
        l2.setBackgroundColor(context.getResources().getColor(R.color.green));
        l3.setBackgroundColor(context.getResources().getColor(R.color.blue));
        addView(l1);
        addView(l2);
        addView(l3);
        mScroll = new Scroller(context);
        touchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        Log.i(tag, "touch slop:" + touchSlop);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int widthMeasure = MeasureSpec.getSize(widthMeasureSpec);
        int heightMeasure = MeasureSpec.getSize(heightMeasureSpec);
        setMeasuredDimension(widthMeasure, heightMeasure);
        for (int i = 0; i < getChildCount(); i++) {
            getChildAt(i).measure(widthMeasure, heightMeasure);
        }
    }

    private int left;
    private int top;
    private int right;
    private int bottom;

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for (int i = 0; i < getChildCount(); i++) {
            getChildAt(i).layout(l, t, r, b);
        }
    }

    private void smoothScroll(int desX,int desY){
        if (mScroll.computeScrollOffset()){//the animation is not finished
            int scrollX = getScrollX();
            int scrollY = getScrollY();
            Log.i(tag,"scrollX:"+scrollX +"  scrollY:"+scrollY);
            int curX = mScroll.getCurrX();
            Log.i(tag,"curX:" + curX);
            int deltaX = curX - scrollX;
            Log.i(tag,"curX:" + curX +" curY:"+mScroll.getCurrY());
            mScroll.startScroll(scrollX, 0, deltaX, 0);
            invalidate();//refresh the view
        }
    }

    private float startX;
    private float startY;
    private float deltaX;
    private float deltaY;

    private float mLastMotionX;

    @Override
    public boolean onTouchEvent(MotionEvent event){
        super.onTouchEvent(event);

        float x = event.getX();
        float y = event.getY();

        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                if(mScroll != null){
                    if(!mScroll.isFinished()){
                        mScroll.abortAnimation();
                    }
                }
                mLastMotionX = x;
                break;
            case MotionEvent.ACTION_MOVE:
                int deltaX = (int) (mLastMotionX - x);
                scrollBy(deltaX,0);

                Log.i(tag,"deltax :" +deltaX);
                mLastMotionX = x;
                break;
            case MotionEvent.ACTION_UP:

                break;
        }

        return false;
    }

    public boolean onTouch(View v, MotionEvent event) {
        Log.i(tag,"touch view :" +v.toString());
        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                startX = event.getRawX();
                startY = event.getRawY();
                break;
            case MotionEvent.ACTION_MOVE:

                deltaX = event.getRawX() - startX;
                deltaY = event.getRawY() - startY;
                Log.i(tag,"action_move getRawX:" + event.getRawX()+" getRawY:"+event.getRawY());
                break;
            case MotionEvent.ACTION_UP:
                if(deltaX > touchSlop){

                }
                break;
        }
        return false;
    }
}
