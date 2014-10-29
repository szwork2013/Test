package com.kaikeba.common.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.HorizontalScrollView;

public class MyhorizaScrollView extends HorizontalScrollView {

    private OnScrollListener1 onScrollListener;

    public MyhorizaScrollView(Context context) {
        super(context);
    }

    public MyhorizaScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);

    }

    public MyhorizaScrollView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        View view = (View) getChildAt(getChildCount() - 1);
        // 如果为0，证明滑动到最左边
        if (view.getLeft() - getScrollX() == 0) {
            onScrollListener.onLeft();
            // 如果为0证明滑动到最右边
        } else if ((view.getRight() - (getWidth() + getScrollX())) == 0) {
            onScrollListener.onRight();
            // 说明在中间
        } else {
            onScrollListener.onScroll();
        }
        super.onScrollChanged(l, t, oldl, oldt);
    }

    public void setOnScrollListener(OnScrollListener1 onScrollListener) {
        this.onScrollListener = onScrollListener;
    }

    /**
     * 定义接口
     *
     * @author admin
     */
    public interface OnScrollListener1 {
        void onRight();

        void onLeft();

        void onScroll();
    }

}
