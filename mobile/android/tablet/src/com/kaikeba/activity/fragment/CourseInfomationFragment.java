package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.activity.dialog.WebViewDialog;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.api.EnrollCourseAPI;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.widget.AllCoursesGridView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.view.annotation.ViewInject;

import java.util.ArrayList;
import java.util.List;

/**
 * 课程详情
 *
 * @author Super Man
 */
public class CourseInfomationFragment extends Fragment {

    public BitmapUtils bitmapUtils;
    @ViewInject(R.id.tv_course_price)
    private TextView tvCoursePrice;
    @ViewInject(R.id.tv_course_old_price)
    private TextView tvCourseOldPrice;
    @ViewInject(R.id.tv_go_pay)
    private TextView tvGoPay;
    @ViewInject(R.id.tv_course_type)
    private TextView tvCourseType;
    @ViewInject(R.id.tv_course_name)
    private TextView tvCourseName;
    @ViewInject(R.id.tv_school_name)
    private TextView tvSchoolName;
    @ViewInject(R.id.tv_instructor_name)
    private TextView tvInstructorName;
    @ViewInject(R.id.tv_course_time)
    private TextView tvCourseTime;
    @ViewInject(R.id.tv_course_time_about)
    private TextView tvCourseTimeAbout;
    @ViewInject(R.id.tv_course_number)
    private TextView tvCourseNumber;
    @ViewInject(R.id.tv_course_key)
    private TextView tvCourseKey;
    @ViewInject(R.id.tv_course_key_info)
    private TextView tvCourseKeyInfo;
    @ViewInject(R.id.gridview)
    private AllCoursesGridView gridView;
    private Course mCourse;
    private LayoutInflater inflater;
    private List<Badge> badges;
    private List<Badge> newBadges;
    private Handler handler = new Handler() {

    };

    @SuppressWarnings("unchecked")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.course_info_base, container, false);
        ViewUtils.inject(this, v);
        bitmapUtils = BitmapHelp.getBitmapUtils(getActivity()
                .getApplicationContext());
        mCourse = (Course) getArguments().getSerializable("course");
        badges = (ArrayList<Badge>) getArguments().getSerializable("badge");
        tvCourseOldPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
        setText();
        return v;
    }

    private void setText() {
        if (mCourse.getPrice().equals("0")) {
            tvCoursePrice.setText("￥" + "免费");
        } else {
            tvCoursePrice.setText("￥" + mCourse.getPrice());
        }
        if (mCourse.getPrice4Phone().equals("0")) {
            tvCourseOldPrice.setVisibility(View.GONE);
        } else {
            tvCourseOldPrice.setText("￥" + mCourse.getPrice4Phone());
        }
        if (mCourse.getCourseType().equals("guide")) {
            tvCourseType.setText("导学课");
        } else {
            tvCourseType.setText("公开课");
        }
        tvSchoolName.setText(mCourse.getSchoolName());
        tvCourseName.setText(mCourse.getCourseName());
        tvInstructorName.setText(mCourse.getInstructorName());
        tvCourseTime.setText(mCourse.getStartDate());
        tvCourseTimeAbout.setText(mCourse.getEstimate());
        tvCourseNumber.setText(mCourse.getCourseNum());
        tvCourseKey.setText("课程关键字：  " + mCourse.getCourseKeywords());
        tvCourseKeyInfo.setText(mCourse.getCourseIntro());
        tvGoPay.setText("学习此课程");

    }

    @Override
    public void onResume() {
        super.onResume();
        if (API.getAPI().alreadySignin()) {
            ArrayList<Long> ids = LocalStorage.sharedInstance().getIds();
            for (Long id : ids) {
                if (mCourse.getId().equals(id)) {
                    tvGoPay.setText("继续学习");
                    break;
                }
            }
            if ("已结束".equals(DateUtils.getDate(mCourse.getCourseType(), mCourse.getEstimate(), mCourse.getStartDate()))) {
                tvGoPay.setBackgroundColor(getResources().getColor(R.color.color_zuiqianhui));
                tvGoPay.setText("即将开课");
            }
        }
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        tvGoPay.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
//				Toast.makeText(getActivity(), "正在进入课程", Toast.LENGTH_SHORT).show();
                if (!API.getAPI().alreadySignin()) {
                    goRegist();
                    return;
                } else {
                    if ("已结束".equals(DateUtils.getDate(mCourse.getCourseType(), mCourse.getEstimate(), mCourse.getStartDate()))) {
                        return;
                    }
                    if (tvGoPay.getText().toString().equals("继续学习")) {
                        goUnit();
                    } else {
                        Toast.makeText(getActivity(), "正在进入课程", Toast.LENGTH_SHORT).show();
                        new Thread() {
                            public void run() {
                                Constants.isFreshMyCourse = true;
                                try {
                                    if (null != EnrollCourseAPI.entrollCourse(mCourse.getId())) {
                                        ArrayList<Long> ids = CoursesAPI.getMyCoursesId(false);
                                        LocalStorage.sharedInstance().setIds(ids);
                                    }
                                } catch (DibitsExceptionC e) {
                                    // TODO Auto-generated catch block
                                    e.printStackTrace();
                                }
                                handler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        goUnit();
                                    }
                                });
                            }

                            ;
                        }.start();
                    }
                }
            }
        });
        new Thread(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                try {
                    badges = CoursesAPI.getBadge(false);
                    newBadges = new ArrayList<Badge>();
                    List<Long> ids = mCourse.getCourseBadges();
                    for (Long id : ids) {
                        for (Badge b : badges) {
                            if (id.equals(b.getId())) {
                                newBadges.add(b);
                            }
                        }
                    }
                    handler.post(new Runnable() {

                        @Override
                        public void run() {
                            // TODO Auto-generated method stub
                            gridView.setAdapter(new BadgeAdapter());
                        }

                    });
                } catch (DibitsExceptionC e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

        }).start();
    }

    private void goRegist() {
        Constants.LOGIN_FROM = Constants.FROM_PAY;
        Intent intent = new Intent(getActivity(), WebViewDialog.class);
        intent.putExtra("course", mCourse);
        startActivity(intent);
    }

    private void goUnit() {
        Constants.DOWNLOAD_VIEW = 1;
        if (mCourse.getStartDate().equals("2020-01-01")) {
            Toast.makeText(getActivity(), "此课程为精彩预告，敬请期待！", Toast.LENGTH_SHORT).show();
            return;
        }
        Intent mIntent = new Intent();
        mIntent.putExtra("course", mCourse);
        mIntent.setClass(getActivity(), ModuleActivity.class);
        startActivity(mIntent);
    }

    class BadgeAdapter extends BaseAdapter {

        @Override
        public int getCount() {
            // TODO Auto-generated method stub
            return newBadges.size();
        }

        @Override
        public Object getItem(int position) {
            // TODO Auto-generated method stub
            return newBadges.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // TODO Auto-generated method stub
            final ViewHolder holder;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.badge_child, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            holder.tv.setText(newBadges.get(position).getBadgeTitle());
            bitmapUtils.display(holder.iv, newBadges.get(position)
                    .getImage4big());
            return convertView;
        }

        class ViewHolder {
            ImageView iv;
            TextView tv;

            public ViewHolder(View v) {
                iv = (ImageView) v.findViewById(R.id.iv_courseinfo_badge);
                tv = (TextView) v.findViewById(R.id.tv_courseinfo_badge);
            }
        }

    }

}
