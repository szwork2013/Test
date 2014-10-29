package com.kaikeba.common.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ScrollView;

/**
 * 带浮动条的ScrollView
 */
public class XDScrollView extends ScrollView {
    private OnScrollListener onScrollListener = null;

    private View viewInScroll, viewOutScroll;

    public XDScrollView(Context context, AttributeSet attrs,
                        int defStyle) {
        super(context, attrs, defStyle);
    }

    public XDScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public XDScrollView(Context context) {
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

    /**
     * 设置需要浮动的View
     *
     * @param viewInScroll ScollView内的view
     * @param viewFloat    ScollView外的view，真正需要浮动的view
     */
    public void setFloatView(View viewInScroll, View viewOutScroll) {
        this.viewInScroll = viewInScroll;
        this.viewOutScroll = viewOutScroll;
    }

    private void computeFloatIfNecessary() {
        if (viewInScroll == null && viewOutScroll == null) {
            return;
        }

        int[] location = new int[2];
        this.getLocationInWindow(location);

        int[] loc = new int[2];
        viewInScroll.getLocationOnScreen(loc);

        if (loc[1] <= location[1]) {
            viewOutScroll.setVisibility(View.VISIBLE);
            viewInScroll.setVisibility(View.INVISIBLE);
        } else {
            viewOutScroll.setVisibility(View.GONE);
            viewInScroll.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 监听ScrollView滚动接口
     *
     * @author reyo
     */
    public interface OnScrollListener {

        public void onScrollChanged(XDScrollView scrollView, int x,
                                    int y, int oldx, int oldy);

    }
}

