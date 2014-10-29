package com.kaikeba.mitv.Listener;

import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import com.kaikeba.common.entity.Course;
import com.kaikeba.mitv.CourseActivity;

public class MyCourseOnKeyListener implements OnKeyListener {

    Course course;
    Context c;

    public MyCourseOnKeyListener(Course course, Context c) {
        this.course = course;
        this.c = c;
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
            Intent intent = new Intent(c, CourseActivity.class);
            intent.putExtra("course", course);
            c.startActivity(intent);
        }
        return false;
    }
}
