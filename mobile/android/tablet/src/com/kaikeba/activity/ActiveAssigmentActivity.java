package com.kaikeba.activity;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.view.View;
import com.kaikeba.activity.fragment.AssignmentItemFragment;
import com.kaikeba.activity.fragment.ModuleNavFragment;
import com.kaikeba.common.entity.Assignment;
import com.kaikeba.common.entity.Course;
import com.kaikeba.phone.R;

import java.util.ArrayList;

/**
 * 从最近活动进入的测验界面
 *
 * @author Super Man
 */
public class ActiveAssigmentActivity extends Activity {

    private static final String TAG = "";
    ArrayList<Assignment> mAssList;
    private FragmentManager fm;
    private FragmentTransaction ft;
    private ModuleNavFragment moduleNavFmt;
    private AssignmentItemFragment disFragment;
    private Course course;

    @SuppressWarnings("unchecked")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.my_course);
        course = (Course) getIntent().getSerializableExtra(getResources().getString(R.string.value_course));
        mAssList = (ArrayList<Assignment>) getIntent().getSerializableExtra("assignments");
        fm = getFragmentManager();
        //加载右侧全部课程Fragment
        moduleNavFmt = new ModuleNavFragment();
        disFragment = new AssignmentItemFragment();
        Bundle b = new Bundle();
        b.putInt("index", getIntent().getIntExtra("index", 0));
        b.putSerializable("assignments", mAssList);
        b.putString("courseID", course.getId() + "");
        findViewById(R.id.moduleAssignment_container).setVisibility(View.VISIBLE);
        disFragment.setArguments(b);
        ft = fm.beginTransaction();
        ft.replace(R.id.module_nav_container, moduleNavFmt, "ModuleNavFragment");
        ft.replace(R.id.moduleAssignment_container, disFragment);
        ft.show(moduleNavFmt);
        ft.commit();
    }

    public Course getCourse() {
        return this.course;
    }

    public void clickAssignment() {
        moduleNavFmt.clickAssignment();
    }
}

