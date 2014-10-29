package com.example.myapp.scroll;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Display;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Scroller;

//自定义ViewGroup ， 包含了三个LinearLayout控件，存放在不同的布局位置，通过scrollBy或者scrollTo方法切换
public class MultiViewGroup extends ViewGroup {
    private static final String TAG = "sjyin";
    private int curScreen;


    public MultiViewGroup(Context context) {
        super(context);
        initViewGroup(context);
    }

    public MultiViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        initViewGroup(context);
    }

    public MultiViewGroup(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        initViewGroup(context);
    }

    private void initViewGroup(Context context) {
        mScroller = new Scroller(getContext());
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        curScreen = wm.getDefaultDisplay().getWidth();

    }

    private Scroller mScroller;

    //startScroll开始移至下一屏
    public void startMove() {
        curScreen++;
        Log.i(TAG, "----startMove---- curScreen " + curScreen);

        //使用动画控制偏移过程 , 3s内到位
        mScroller.startScroll((curScreen - 1) * getWidth(), 0, getWidth(), 0, 3000);
        //其实点击按钮的时候，系统会自动重新绘制View，我们还是手动加上吧。
        invalidate();
        //使用scrollTo一步到位
        //scrollTo(curScreen * MultiScreenActivity.screenWidth, 0);
    }

    // 由父视图调用用来请求子视图根据偏移值 mScrollX,mScrollY重新绘制
    @Override
    public void computeScroll() {
        // TODO Auto-generated method stub
        Log.e(TAG, "computeScroll");
        // 如果返回true，表示动画还没有结束
        // 因为前面startScroll，所以只有在startScroll完成时 才会为false
        if (mScroller.computeScrollOffset()) {
            Log.e(TAG, mScroller.getCurrX() + "======" + mScroller.getCurrY());
            // 产生了动画效果，根据当前值 每次滚动一点
            scrollTo(mScroller.getCurrX(), mScroller.getCurrY());

            Log.e(TAG, "### getleft is " + getLeft() + " ### getRight is " + getRight());
            //此时同样也需要刷新View ，否则效果可能有误差
            postInvalidate();
        } else
            Log.i(TAG, "have done the scoller -----");
    }

    //马上停止移动，如果已经超过了下一屏的一半，我们强制滑到下一个屏幕
    public void stopMove() {

        Log.v(TAG, "----stopMove ----");

        if (mScroller != null) {
            //如果动画还没结束，我们就按下了结束的按钮，那我们就结束该动画，即马上滑动指定位置
            if (!mScroller.isFinished()) {

                int scrollCurX = mScroller.getCurrX();
                //判断是否超过下一屏的中间位置，如果达到就抵达下一屏，否则保持在原屏幕
                // 这样的一个简单公式意思是：假设当前滑屏偏移值即 scrollCurX 加上每个屏幕一半的宽度，除以每个屏幕的宽度就是
                //  我们目标屏所在位置了。 假如每个屏幕宽度为320dip, 我们滑到了500dip处，很显然我们应该到达第二屏,索引值为1
                //即(500 + 320/2)/320 = 1
                int descScreen = (scrollCurX + getWidth() / 2) / getWidth();

                Log.i(TAG, "-mScroller.is not finished scrollCurX +" + scrollCurX);
                Log.i(TAG, "-mScroller.is not finished descScreen +" + descScreen);
                mScroller.abortAnimation();

                //停止了动画，我们马上滑倒目标位置
                scrollTo(descScreen * getWidth(), 0);
                curScreen = descScreen; //纠正目标屏位置
            } else
                Log.i(TAG, "----OK mScroller.is  finished ---- ");
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {

    }

}