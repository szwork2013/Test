package com.kaikeba.activity;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import com.kaikeba.activity.fragment.ModuleNavFragment;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;

/**
 * 单元Activity
 *
 * @author Allen
 */
public class ModuleActivity extends Activity {

    private FragmentManager fm;
    private FragmentTransaction ft;
    private ModuleNavFragment moduleNavFmt;
    private Course course;
    private String url = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.my_course);
        if (Constants.DOWNLOAD_VIEW == 2) url = getIntent().getStringExtra("url");
        course = (Course) getIntent().getSerializableExtra("course");
        fm = getFragmentManager();
        //加载右侧全部课程Fragment
        moduleNavFmt = new ModuleNavFragment();
        ft = fm.beginTransaction();
        ft.add(R.id.module_nav_container, moduleNavFmt, "ModuleNavFragment");
        ft.show(moduleNavFmt);
        ft.commit();
    }

    public Course getCourse() {
        return this.course;
    }

    public String getString() {
        return url;
    }
}
