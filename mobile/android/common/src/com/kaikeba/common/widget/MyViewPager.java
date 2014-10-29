package com.kaikeba.common.widget;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.KeyEvent;

public class MyViewPager extends ViewPager {

    /**
     * ViewPager 是否可滚动
     */
    private boolean isCanScroll = true;

    /**
     * 是否是Gallery
     */
    private boolean isGallery = false;

    public MyViewPager(Context context) {
        super(context);
    }

    public MyViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public boolean isCanScroll() {
        return isCanScroll;
    }

    public void setCanScroll(boolean isCanScroll) {
        this.isCanScroll = isCanScroll;
    }

    public boolean isGallery() {
        return isGallery;
    }

    public void setGallery(boolean isGallery) {
        this.isGallery = isGallery;
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // TODO Auto-generated method stub

        if (event.getAction() == KeyEvent.ACTION_UP) {
            int keyCode = event.getKeyCode();
            // 第一行的时候，Activity自己处理
            switch (keyCode) {
                case KeyEvent.KEYCODE_DPAD_LEFT:
                    if (!isCanScroll) {
                        return true;
                    } else {
                        return false;
                    }
                case KeyEvent.KEYCODE_DPAD_RIGHT:
                    if (!isCanScroll) {
                        return true;
                    } else {
                        return false;
                    }
                default:
                    break;
            }
        }
//		else if (event.getAction() == KeyEvent.ACTION_DOWN) {
//			return false;
//      }
        return super.dispatchKeyEvent(event);
    }
}
