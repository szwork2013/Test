package com.kaikeba.mitv.Listener;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.StaticDate;
import com.kaikeba.mitv.CourseActivity;
import com.kaikeba.mitv.MainActivity;

import java.util.List;

public class CustomOnKeyListener implements OnKeyListener {

    CourseModel course;
    Context c;

    // ImageButton button;
    public CustomOnKeyListener(CourseModel course, Context c) {
        this.course = course;
        this.c = c;
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER
                || keyCode == KeyEvent.KEYCODE_ENTER) {
            Log.i("test", "按钮被点击了" + v.getId());
            if (course.getType().equals("open")) {
                setCourse(StaticDate.openCourseList);
            } else {
                setCourse(StaticDate.guideCourseList);
            }
            Intent intent = new Intent(c, CourseActivity.class);
            intent.putExtra("course", course);
            c.startActivity(intent);
        }

        return false;
    }

    private void setCourse(List<CourseModel> courses) {
        boolean flag = false;
        for (CourseModel mCourse : courses) {
            if (course.getId() == mCourse.getId()) {
                flag = true;
                break;
            }
        }
        if (!flag) {
            courses.add(0, course);
            MainActivity.getMainActivity().refreshView();
        }
    }
}
