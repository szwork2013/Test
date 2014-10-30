package com.example.myapp.test14;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.*;
import android.widget.LinearLayout;
import android.widget.Scroller;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-28.
 */
public class MyViewGroup extends ViewGroup {

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
        int widthMeasure = MeasureSpec.getSize(widthMeasureSpec);
        int heightMeasure = MeasureSpec.getSize(heightMeasureSpec);
        Log.i(tag,"view group width = " + widthMeasure +" height = " + heightMeasure);
        setMeasuredDimension(widthMeasure, heightMeasure);

        Log.i(tag,"on measure getWidth:" + getWidth() +" getHeight:" + getHeight());
        for (int i = 0; i < getChildCount(); i++) {
            getChildAt(i).measure(getWidth(), MainActivity.screenHeight);
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        Log.i(tag, "on layout left:" + l + " top:" + t + " right:" + r + " bottom:" + b);
        int startLeft = 0;
        int startTop = 10;
        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);

            if (child.getVisibility() != View.GONE) {
                child.layout(startLeft, startTop, startLeft + getWidth(), startTop + MainActivity.screenHeight);
            }

            startLeft = startLeft + getWidth();
        }
    }

    private void smoothScroll(int desX, int desY) {
        if (mScroll.computeScrollOffset()) {//the animation is not finished
            int scrollX = getScrollX();
            int scrollY = getScrollY();
            Log.i(tag, "scrollX:" + scrollX + "  scrollY:" + scrollY);
            int curX = mScroll.getCurrX();
            Log.i(tag, "curX:" + curX);
            int deltaX = curX - scrollX;
            Log.i(tag, "curX:" + curX + " curY:" + mScroll.getCurrY());
            mScroll.startScroll(scrollX, 0, deltaX, 0);
            invalidate();//refresh the view
        }
    }

    @Override
    public void computeScroll() {
        super.computeScroll();
        // 如果返回true，表示动画还没有结束
        // 因为前面startScroll，所以只有在startScroll完成时 才会为false
        if (mScroll.computeScrollOffset()) {
            Log.e("sjyin", mScroll.getCurrX() + "======" + mScroll.getCurrY());
            // 产生了动画效果 每次滚动一点
            scrollTo(mScroll.getCurrX(), mScroll.getCurrY());

            Log.e("sjyin", "### getleft is " + getLeft() + " ### getRight is " + getRight());

            //刷新View 否则效果可能有误差
            postInvalidate();
        } else
            Log.i("sjyin", "have done the scoller -----");
    }

    private float startX;
    private float startY;
    private float deltaX;
    private float deltaY;

    private float mLastMotionX;
    private VelocityTracker mVelocityTracker;
    private int standardVelocity = 600;
    private int curScreen = 0;

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        super.onTouchEvent(event);

        if (mVelocityTracker == null) {
            mVelocityTracker = VelocityTracker.obtain();
        }
        mVelocityTracker.addMovement(event);

        // the coordinate of the pointer
        float x = event.getX();
        float y = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                //you should abort the animation when the screen is scrolling
                if (mScroll != null) {
                    if (!mScroll.isFinished()) {
                        mScroll.abortAnimation();
                    }
                }
                mLastMotionX = x;
                break;
            case MotionEvent.ACTION_MOVE:
                int deltaX = (int) (mLastMotionX - x);
                scrollBy(deltaX, 0);

                Log.i(tag, "deltaX :" + deltaX);
                mLastMotionX = x;
                break;
            case MotionEvent.ACTION_UP:

                VelocityTracker velocityTracker = mVelocityTracker;
                velocityTracker.computeCurrentVelocity(1000);
                int velocityX = (int) velocityTracker.getXVelocity();
                Log.i(tag, " velocityX:" + velocityX);

                if (velocityX > standardVelocity && curScreen > 0) {
                    snapToScreen(curScreen - 1);
                } else if (velocityX < -standardVelocity && curScreen < (getChildCount() - 1)) {
                    snapToScreen(curScreen + 1);
                } else {
                    snapToDes();
                }

                break;
        }

        return false;
    }

    private void snapToDes() {

        int scrollX = getScrollX();
        int scrollY = getScrollY();
        Log.i(tag, "snap to des scrollX:" + scrollX + " scrollY:" + scrollY);

        int desScreen = (getScrollX() + getWidth() / 2) / getWidth();
        snapToScreen(desScreen);
    }

    public void startMove() {
        curScreen++;
        Log.i(tag, "start move curScreen:" + curScreen + "  getWidth:" + getWidth());
        mScroll.startScroll((curScreen - 1) * getWidth(), 0, getWidth(), 0, 3000);
        invalidate();
    }

    public void stopMove() {
        if (mScroll == null) {
            Log.i(tag, "---scroll is finished");
        } else {
            int scrollX = getScrollX();
            Log.i(tag, "stop move scrollX:" + scrollX);
            int desScreen = (scrollX + getWidth() / 2) / getWidth();
            scrollTo(desScreen * getWidth(), 0);
            curScreen = desScreen;
        }
    }

    private void snapToScreen(int whichScreen) {
        Log.i(tag, "snap to screen curScreen : " + whichScreen);
        curScreen = whichScreen;

        if (curScreen > getChildCount() - 1) {
            curScreen = getChildCount() - 1;
        }
        Log.i("tag", "snap to screen getWidth:" + getWidth() + "  getScrollX:" + getScrollX());
        int dx = curScreen * getWidth() - getScrollX();

        mScroll.startScroll(getScrollX(), 0, dx, 0, Math.abs(dx));

        invalidate();
    }

    public boolean onTouch(View v, MotionEvent event) {
        Log.i(tag, "touch view :" + v.toString());
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                startX = event.getRawX();
                startY = event.getRawY();
                break;
            case MotionEvent.ACTION_MOVE:

                deltaX = event.getRawX() - startX;
                deltaY = event.getRawY() - startY;
                Log.i(tag, "action_move getRawX:" + event.getRawX() + " getRawY:" + event.getRawY());
                break;
            case MotionEvent.ACTION_UP:
                if (deltaX > touchSlop) {

                }
                break;
        }
        return false;
    }
}
