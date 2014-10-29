package com.kaikeba.common.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ScrollView;

public class VerticalScrollview extends ScrollView {

    private OnScrollListener onScrollListener = null;

    private View viewInScroll;

    public VerticalScrollview(Context context, AttributeSet attrs,
                              int defStyle) {
        super(context, attrs, defStyle);
    }

    public VerticalScrollview(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public VerticalScrollview(Context context) {
        super(context);
    }

    public void setOnScrollListener(OnScrollListener onScrollListener) {
        this.onScrollListener = onScrollListener;
    }

    @Override
    protected void onScrollChanged(int x, int y, int oldx, int oldy) {
        super.onScrollChanged(x, y, oldx, oldy);
        if (onScrollListener != null) {
            onScrollListener.onScrollChanged(this, x, y, oldx, oldy);
        }
        computeFloatIfNecessary();
    }

    public void setFlagView(View viewInScroll) {
        this.viewInScroll = viewInScroll;
    }

    private void computeFloatIfNecessary() {
        if (viewInScroll == null) {
            return;
        }
        int[] location = new int[2];
        this.getLocationInWindow(location);

        int[] loc = new int[2];
        viewInScroll.getLocationOnScreen(loc);

        if (loc[1] <= location[1]) {
            requestDisallowInterceptTouchEvent(false);
        } else {
            requestDisallowInterceptTouchEvent(true);
        }
    }

    /**
     * 监听ScrollView滚动接口
     *
     * @author reyo
     */
    public interface OnScrollListener {

        public void onScrollChanged(VerticalScrollview scrollView, int x,
                                    int y, int oldx, int oldy);

    }
}
