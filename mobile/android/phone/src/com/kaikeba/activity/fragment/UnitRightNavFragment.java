package com.kaikeba.activity.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.TextView;
import com.kaikeba.activity.UnitActivity;
import com.kaikeba.phone.R;

public class UnitRightNavFragment extends Fragment {

    private String courseName;
    private TextView tvCourseName;
    private TextView back;
    private TextView courseIntro;
    private TextView instrustorIntro;
    private TextView unitArrange;
    private UnitActivity activity;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            activity.mSlidingMenu.toggle();
            int id = v.getId();
            switch (id) {
                case R.id.tv_back_my_course:
                    activity.finish();
                    break;
                case R.id.tv_unit_course_intro:
                    changeBg(v);
                    activity.showCourseInfo();
                    break;
                case R.id.tv_unit_instrustor_intro:
                    changeBg(v);
                    activity.showInstrustorInfo();
                    break;
                case R.id.tv_unit_arrange:
                    changeBg(v);
                    activity.showUnitInfo();
                    break;
                default:
                    break;
            }
        }
    };

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.unit_right_nav, container, false);
        courseName = getArguments().getString("courseName");
        initView(v);
        setListener();
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        activity = (UnitActivity) getActivity();
        initFirstTab();
    }

    public void onResume() {
        super.onResume();
    }

    public void onPause() {
        super.onPause();
    }

    private void initView(View v) {
        tvCourseName = (TextView) v.findViewById(R.id.tv_unit_course_name);
        tvCourseName.setText(courseName);
        back = (TextView) v.findViewById(R.id.tv_back_my_course);
        courseIntro = (TextView) v.findViewById(R.id.tv_unit_course_intro);
        instrustorIntro = (TextView) v.findViewById(R.id.tv_unit_instrustor_intro);
        unitArrange = (TextView) v.findViewById(R.id.tv_unit_arrange);
    }

    private void setListener() {
        back.setOnClickListener(listener);
        courseIntro.setOnClickListener(listener);
        instrustorIntro.setOnClickListener(listener);
        unitArrange.setOnClickListener(listener);
    }

    private void changeBg(View v) {
        TextView[] vs = {courseIntro, instrustorIntro, unitArrange};
        for (TextView view : vs) {
            view.setBackgroundDrawable(getResources().getDrawable(R.drawable.sidebar_button_gray));
            if (v == view) {
                v.setBackgroundDrawable(getResources().getDrawable(R.drawable.sidebar_button_normal));
            }
        }
    }

    private void initFirstTab() {
        unitArrange.performClick();
    }
}
