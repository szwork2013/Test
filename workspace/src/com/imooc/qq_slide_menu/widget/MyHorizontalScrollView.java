package com.imooc.qq_slide_menu.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import com.example.myapp.R;
import com.nineoldandroids.view.ViewHelper;

/**
 * Created by sjyin on 14-11-2.
 */
public class MyHorizontalScrollView extends HorizontalScrollView {

    private int screenWidth;
    private boolean once = false;
    private int LEFT_MENU_PADDING_RIGHT = 50;
    private int menuWidth;
    private String tag = "sjyin";

    public MyHorizontalScrollView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        LEFT_MENU_PADDING_RIGHT = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, LEFT_MENU_PADDING_RIGHT,
                getResources().getDisplayMetrics());

//        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, R.styleable.slidingMenu, defStyle, 0);
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.slidingMenu);
        for (int i = 0; i < a.getIndexCount(); i++) {
            switch (a.getIndex(i)) {
                case R.styleable.slidingMenu_rightPadding:
                    LEFT_MENU_PADDING_RIGHT = a.getDimensionPixelOffset(i,
                            (int) TypedValue.applyDimension(
                                    TypedValue.COMPLEX_UNIT_DIP, LEFT_MENU_PADDING_RIGHT,
                                    context.getResources().getDisplayMetrics()));
                    break;
            }
        }
        a.recycle();


        DisplayMetrics displayMetrics = new DisplayMetrics();
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        windowManager.getDefaultDisplay().getMetrics(displayMetrics);
        screenWidth = displayMetrics.widthPixels;

    }

    /**
     * 没有自定义属性重写的方法
     *
     * @param context
     * @param attrs
     */
    public MyHorizontalScrollView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);

    }

    private ViewGroup mMenu;
    private ViewGroup mContent;

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (!once) {
            once = true;
            LinearLayout mWrapper = (LinearLayout) getChildAt(0);
            mMenu = (ViewGroup) mWrapper.getChildAt(0);
            mContent = (ViewGroup) mWrapper.getChildAt(1);
            menuWidth = mMenu.getLayoutParams().width = screenWidth - LEFT_MENU_PADDING_RIGHT;
            mContent.getLayoutParams().width = screenWidth;
            Log.i(tag, "menu width:" + menuWidth + " content width:" + mContent.getLayoutParams().width);
        }
    }

    /**
     * 通过设置偏移量，隐藏menu
     *
     * @param changed
     * @param l
     * @param t
     * @param r
     * @param b
     */
    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
        if (changed) {
            Log.i(tag, "on layout changed ---");
            scrollTo(menuWidth, 0);
        }
    }

    /**
     * @param ev
     * @return
     */
    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_UP:
                int scrollX = getScrollX();
                Log.i(tag, "on touch event scrollX = " + scrollX);
                if (scrollX > menuWidth / 2) {
                    smoothScrollTo(menuWidth + LEFT_MENU_PADDING_RIGHT, 0);
                } else {
                    smoothScrollTo(0, 0);
                }
                return true;

        }
        return super.onTouchEvent(ev);
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
        float scale = l * 1.0f / menuWidth; // 1 ~ 0
        /*
        1、内容区域缩放 1.0 ~ 0.7
            0.7 + 0.3 * scale
        2、菜单的偏移量
        3、菜单显示缩放  0.7~1.0
            0.7 + 0.3 * (1 - scale)
             菜单透明度变化  0.6 ~1.0
            0.6 + 0.4 * (1 - scale)
        */
        ViewHelper.setTranslationX(mMenu, menuWidth * scale * 0.8f);
        float menuScale = 0.7f + 0.3f * (1 - scale);
        ViewHelper.setPivotX(mMenu,0);
        ViewHelper.setPivotY(mMenu,mMenu.getHeight()/2);
        ViewHelper.setScaleX(mMenu, menuScale);
        ViewHelper.setScaleY(mMenu, menuScale);
        float menuAlpha = 0.6f + 0.4f * (1 - scale);
        ViewHelper.setAlpha(mMenu, menuAlpha);

        float contentScale = 0.7f + 0.3f * scale;
        ViewHelper.setScaleX(mContent, contentScale);
        ViewHelper.setScaleY(mContent, contentScale);

    }
}
