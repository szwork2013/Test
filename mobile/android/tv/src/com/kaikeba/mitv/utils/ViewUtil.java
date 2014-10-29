package com.kaikeba.mitv.utils;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import com.kaikeba.mitv.ViewCourseActivity;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.LargeCourseCardItem;

/**
 * Created by sjyin on 14-8-18.
 */
public class ViewUtil {

    private static ViewUtil instance;
    private int courseCardHeight;
    private int courseItemMarginTop;
    private ViewUtil() {
    }

    public static ViewUtil getInstance() {
        if (instance == null) {
            instance = new ViewUtil();
        }
        return instance;
    }

    public LinearLayout.LayoutParams getLLParams(Integer width, Integer height, Integer weight) {
        int mwidth = LinearLayout.LayoutParams.WRAP_CONTENT;
        int mheight = LinearLayout.LayoutParams.WRAP_CONTENT;
        if (width != null && height != null) {
            mwidth = width;
            mheight = height;
        }
        if (weight != null) {
            return new LinearLayout.LayoutParams(mwidth, mheight, weight);
        }
        return new LinearLayout.LayoutParams(mwidth, mheight);
    }


    public LargeCourseCardItem initLargeCourseCard(final Context context, CourseCardItem courseItem, int from) {

        final LargeCourseCardItem itemView = new LargeCourseCardItem(context, courseItem, from);
        itemView.setTag(courseItem);
        itemView.setFocusable(true);
//        itemView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
//            @Override
//            public void onFocusChange(View v, boolean hasFocus) {
//                itemView.setBottomViewContainerHidden(!hasFocus);
//            }
//        });
        itemView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {

                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                        Intent intent = new Intent(context, ViewCourseActivity.class);
                        CourseCardItem c = (CourseCardItem) itemView.getTag();
                        intent.putExtra("cardItem", c);
                        context.startActivity(intent);
                    }
                }

                return false;
            }
        });
        return itemView;
    }

    public void scrollToTop(final ScrollView scrollView) {

        Handler handler = new Handler();
        handler.post(new Runnable() {
            @Override
            public void run() {
                scrollView.smoothScrollTo(0, 0);
            }
        });
    }

    public void scrollToBottom(final ScrollView scrollView) {

        Handler handler = new Handler();
        handler.post(new Runnable() {
            @Override
            public void run() {
                int scrollAmount = scrollView.getBottom();
                Log.i("ViewUtil", "scrollAmount == " + scrollAmount);
                scrollView.smoothScrollTo(0, scrollAmount);
            }
        });
    }

    public int getCourseCardHeight() {
        return courseCardHeight;
    }

    public void setCourseCardHeight(int courseCardHeight) {
        this.courseCardHeight = courseCardHeight;
    }

    public int getCourseItemMarginTop() {
        return courseItemMarginTop;
    }

    public void setCourseItemMarginTop(int courseItemMarginTop) {
        this.courseItemMarginTop = courseItemMarginTop;
    }
}
