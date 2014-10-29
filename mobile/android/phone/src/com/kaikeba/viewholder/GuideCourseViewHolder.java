package com.kaikeba.viewholder;

import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.kaikeba.phone.R;

/**
 * Created by sjyin on 14-8-5.
 */
public class GuideCourseViewHolder {

    public ImageView courseImg;
    public TextView courseName;
    public TextView courseType;
    public TextView updateAmount;
    public TextView totalAmount;
    public TextView duration;
    public TextView startCourse;
    public TextView grade;
    public TextView certificate;
    public LinearLayout ll_will_begin;


    public GuideCourseViewHolder(View parView, int tag) {

        LinearLayout ll_worked = (LinearLayout) parView.findViewById(R.id.ll_worked);
        LinearLayout ll_go_work = (LinearLayout) parView.findViewById(R.id.ll_go_work);
        LinearLayout ll_working = (LinearLayout) parView.findViewById(R.id.ll_working);
        RelativeLayout cover_image = (RelativeLayout) parView.findViewById(R.id.cover_image);

        ll_will_begin = (LinearLayout) parView.findViewById(R.id.ll_will_begin);
        courseImg = (ImageView) parView.findViewById(R.id.iv_course_img);
        courseName = (TextView) parView.findViewById(R.id.tv_course_name);
        courseType = (TextView) parView.findViewById(R.id.tv_course_type);
        updateAmount = (TextView) parView.findViewById(R.id.tv_update);
        totalAmount = (TextView) parView.findViewById(R.id.tv_total);
        duration = (TextView) parView.findViewById(R.id.tv_duration);
        startCourse = (TextView) parView.findViewById(R.id.tv_start);
        grade = (TextView) parView.findViewById(R.id.tv_grade);
        certificate = (TextView) parView.findViewById(R.id.tv_check_certificate);

        switch (tag) {
            case 11:
                ll_working.setVisibility(View.VISIBLE);
                ll_worked.setVisibility(View.GONE);
                ll_go_work.setVisibility(View.GONE);
                cover_image.setVisibility(View.GONE);
                break;
            case 22:
                ll_working.setVisibility(View.GONE);
                ll_worked.setVisibility(View.VISIBLE);
                ll_go_work.setVisibility(View.GONE);
                cover_image.setVisibility(View.GONE);
                break;
            case 33:
                ll_working.setVisibility(View.GONE);
                ll_worked.setVisibility(View.GONE);
                ll_go_work.setVisibility(View.VISIBLE);
                cover_image.setVisibility(View.VISIBLE);
                break;
        }
    }
}
