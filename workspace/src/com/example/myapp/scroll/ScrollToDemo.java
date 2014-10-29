package com.example.myapp.scroll;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.ScrollView;

/**
 * Created by sjyin on 14-10-23.
 */
public class ScrollToDemo extends ScrollView{
    public ScrollToDemo(Context context) {
        super(context);
    }

    public ScrollToDemo(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ScrollToDemo(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public void computeScroll() {
        super.computeScroll();
    }

}
