package com.kaikeba.activity;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.view.View;
import com.kaikeba.activity.fragment.AnnouncementDetailFragment;
import com.kaikeba.activity.fragment.ModuleNavFragment;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.entity.Course;
import com.kaikeba.phone.R;

import java.util.ArrayList;

public class ActiveDisscussActivity extends Activity {

    private FragmentManager fm;
    private FragmentTransaction ft;
    private ModuleNavFragment moduleNavFmt;
    private AnnouncementDetailFragment disFragment;
    private Course course;
    private Announcement discussion;
    private ArrayList<Announcement> annList;

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.my_course);
        course = (Course) getIntent().getSerializableExtra("course");
        discussion = (Announcement) getIntent().getSerializableExtra(getResources().getString(R.string.announcement));
        annList = (ArrayList<Announcement>) getIntent().getSerializableExtra("announcements");
        fm = getFragmentManager();
        //加载右侧全部课程Fragment
        moduleNavFmt = new ModuleNavFragment();
        disFragment = new AnnouncementDetailFragment();
        Bundle b = new Bundle();
        b.putSerializable("announcement", discussion);
        b.putSerializable("announcements", annList);
        b.putString("courseId", course.getId() + "");
        findViewById(R.id.moduleDiscusion_container).setVisibility(View.VISIBLE);
        disFragment.setArguments(b);
        ft = fm.beginTransaction();
        ft.replace(R.id.module_nav_container, moduleNavFmt, "ModuleNavFragment");
        ft.replace(R.id.moduleDiscusion_container, disFragment);
        ft.show(moduleNavFmt);
        ft.commit();
    }

    public Course getCourse() {
        return this.course;
    }

    public void clickDisscuss() {
        moduleNavFmt.clickDisscuss();
    }
}

