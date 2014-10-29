package com.kaikeba.common.widget;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.widget.ListView;

/**
 * Created by mjliu on 14-8-6.
 */
public class MyListVIew extends ListView {

    public MyListVIew(Context context) {
        super(context);
    }

    public MyListVIew(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public MyListVIew(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
                MeasureSpec.AT_MOST);
        super.onMeasure(widthMeasureSpec, expandSpec);
    }

    @Override
    public boolean requestFocus(int direction, Rect previouslyFocusedRect) {
        return false;
    }
}
