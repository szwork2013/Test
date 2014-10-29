package com.kaikeba.activity.fragment;

import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 我的课程Fragment
 *
 * @author Super Man
 */
public class MyCourseContentFragment extends Fragment {

    View v;
    MyCourseAdapter myCourseAdapter;
    private MainActivity mainActivity;
    private GridView myCourseListView;
    private TextView layout_go_course;
    private LinearLayout view_loading;
    private ImageButton btn_togo;
    private OnItemClickListener listViewListener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            Constants.isFirst = false;
            Constants.DOWNLOAD_VIEW = 1;
            Course c = (Course) parent.getAdapter().getItem(position);
            if (c.getStartDate().equals("2020-01-01")) {
                Toast.makeText(mainActivity, "此课程为精彩预告，敬请期待！", Toast.LENGTH_SHORT).show();
                return;
            }
            Intent mIntent = new Intent();
            mIntent.putExtra("course", c);
            mIntent.setClass(getActivity(), ModuleActivity.class);
            startActivity(mIntent);
        }
    };
    private Runnable runnable;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    view_loading.setVisibility(View.GONE);
                    myCourseListView.setVisibility(View.GONE);
                    layout_go_course.setVisibility(View.VISIBLE);
                    break;
                case 1:
                    view_loading.setVisibility(View.GONE);
                    break;
                default:
                    break;
            }
        }

        ;
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.my_course_content, container, false);
        myCourseListView = (GridView) v.findViewById(R.id.gridview);
        myCourseListView.setOnItemClickListener(listViewListener);
        layout_go_course = (TextView) v.findViewById(R.id.no_mycourse);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        btn_togo = (ImageButton) v.findViewById(R.id.btn_togo);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mainActivity = (MainActivity) getActivity();
        initAllCourse();
        btn_togo.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                MainActivity.getMainActivity().getSlidingMenu().showMenu();
            }
        });
    }

    public void initAllCourse() {
        ImgLoaderUtil.threadPool.submit(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub

                try {
                    final List<Course> curlist = new ArrayList<Course>();
                    ArrayList<Long> ids = mainActivity.getIds();
                    if (ids == null) {
                        ids = CoursesAPI.getMyCoursesId(false);
                        mainActivity.setIds(ids);
                    }
                    if (ids.isEmpty()) {
                        handler.sendEmptyMessage(0);
                        return;
                    } else {
                        List<Course> allCourses = CoursesAPI.getAllCourses(false);
                        for (Course c : allCourses) {
                            for (Long id : ids) {
                                if (id.equals(c.getId())) {
                                    curlist.add(c);
                                }
                            }
                        }
                    }
                    runnable = new Runnable() {

                        @Override
                        public void run() {
                            // TODO Auto-generated method stub
                            myCourseAdapter = new MyCourseAdapter(curlist,
                                    getActivity());
                            myCourseListView.setAdapter(myCourseAdapter);
                            view_loading.setVisibility(View.GONE);
                        }
                    };
                    handler.post(runnable);
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    handler.sendEmptyMessage(1);
                    return;
                } catch (Exception e) {
                    handler.sendEmptyMessage(1);
                    return;
                }

            }
        });
    }

    public void refreshView() {
        new Thread() {
            @Override
            public void run() {
                try {
                    final List<Course> curlist = new ArrayList<Course>();
                    ArrayList<Long> ids = CoursesAPI.getMyCoursesId(false);
                    mainActivity.setIds(ids);

                    if (ids.isEmpty()) {
                        handler.sendEmptyMessage(0);
                        return;
                    } else {
                        List<Course> list = mainActivity.getAllCourse();
                        for (Course c : list) {
                            for (Long id : ids) {
                                if (id.equals(c.getId())) {
                                    curlist.add(c);
                                }
                            }
                        }
                    }
                    myCourseAdapter.setDate(curlist);
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            myCourseAdapter.notifyDataSetChanged();
                        }
                    });
                } catch (Exception e) {

                }
            }
        }.start();
    }

    @Override
    public void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        handler.removeCallbacks(runnable);
    }

    class MyCourseAdapter extends BaseAdapter {
        boolean[] hasMeasured;
        int width;
        BitmapUtils bitmapUtils;
        private List<Course> courses;
        private LayoutInflater inflater;

        public MyCourseAdapter(List<Course> courses, Context c) {
            this.courses = courses;
            inflater = LayoutInflater.from(c);
            hasMeasured = new boolean[courses.size()];
            for (int i = 0; i < hasMeasured.length; i++) {
                hasMeasured[i] = true;
            }
            bitmapUtils = BitmapHelp.getBitmapUtils(c.getApplicationContext());
        }

        public void setDate(List<Course> mcourses) {
            courses.clear();
            this.courses = mcourses;
        }

        @Override
        public int getCount() {
            return courses.size();
        }

        @Override
        public Object getItem(int position) {
            return courses.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            final ViewHolder holder;
            final Course c = courses.get(position);
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.my_course_content_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            bitmapUtils.display(holder.gridCourseBg, c.getCoverImage());
            holder.colledgeName.setText(c.getSchoolName());
            holder.courseName.setText(c.getCourseName());
            holder.startTime.setText(c.getStartDate());
            String endTime = null;
            if (c.getCourseType().equals("guide")) {
                endTime = DateUtils.StringToString(c.getStartDate(), c.getEstimate());
                holder.endTime.setText(endTime);
            }
            String isEndString = null;
            int colorYes = getResources().getColor(R.color.my_course_is_in_yes);
            int colorNo = getResources().getColor(R.color.my_course_is_in_no);
            if (c.getCourseType().equals("guide") && DateUtils.getDateprice(DateUtils.StringToDate(endTime))) {
                isEndString = "课程已结束";
                holder.courseIsIn.setTextColor(colorNo);
                holder.percent.setTextColor(colorNo);
                holder.tv_percent.setTextColor(colorNo);
                holder.iv_progress.setBackgroundColor(colorNo);
            } else {
                isEndString = "进入课程";
                holder.courseIsIn.setTextColor(colorYes);
                holder.percent.setTextColor(colorYes);
                holder.tv_percent.setTextColor(colorYes);
                holder.iv_progress.setBackgroundColor(colorYes);
            }
            holder.courseIsIn.setText(isEndString);
            if (c.getCourseType().equals("open")) {
                holder.tv_endTime.setVisibility(View.INVISIBLE);
                holder.endTime.setVisibility(View.INVISIBLE);
                holder.courseType.setText("公开课");
                holder.percent.setVisibility(View.INVISIBLE);
                holder.tv_percent.setVisibility(View.INVISIBLE);
                holder.iv_progress.setVisibility(View.INVISIBLE);
            } else {
                holder.courseType.setText("导学课");
                holder.percent.setVisibility(View.VISIBLE);
                holder.tv_percent.setVisibility(View.VISIBLE);
                holder.tv_endTime.setVisibility(View.VISIBLE);
                holder.iv_progress.setVisibility(View.VISIBLE);
                holder.endTime.setVisibility(View.VISIBLE);
                if (c.getStartDate().equals("2020-01-01")) {
                    holder.tv_endTime.setVisibility(View.INVISIBLE);
                    holder.endTime.setVisibility(View.INVISIBLE);
                    holder.percent.setVisibility(View.INVISIBLE);
                    holder.tv_percent.setVisibility(View.INVISIBLE);
                    holder.iv_progress.setVisibility(View.INVISIBLE);
                    holder.startTime.setVisibility(View.INVISIBLE);
                } else {
                    holder.percent.setVisibility(View.VISIBLE);
                    holder.tv_percent.setVisibility(View.VISIBLE);
                    holder.tv_endTime.setVisibility(View.VISIBLE);
                    holder.iv_progress.setVisibility(View.VISIBLE);
                    holder.endTime.setVisibility(View.VISIBLE);
                    holder.startTime.setVisibility(View.VISIBLE);
                }
                int percent = DateUtils.getPercent(c.getStartDate(), endTime);
                if (DateUtils.getDateprice(DateUtils.StringToDate(endTime))) {
                    holder.percent.setText("100");
                    percent = 100;
                    int newWidth = v.getWidth();
                    LayoutParams laParams = holder.iv_progress.getLayoutParams();
                    laParams.width = newWidth;
                    holder.iv_progress.setLayoutParams(laParams);
                } else if (!DateUtils.getDateprice(DateUtils.StringToDate(c.getStartDate()))) {
                    holder.percent.setText("0");
                    percent = 0;
                    holder.iv_progress.setVisibility(View.INVISIBLE);
                    int newWidth = ((v.getWidth()) * percent / 4) / 100;
                    LayoutParams laParams = holder.iv_progress.getLayoutParams();
                    laParams.width = newWidth;
                    holder.iv_progress.setLayoutParams(laParams);
                } else if (DateUtils.getCourseIsComming(c.getStartDate(), endTime)) {
                    holder.percent.setText(percent + "");
                    int newWidth = ((v.getWidth() / 4) * percent) / 100;
                    LayoutParams laParams = holder.iv_progress.getLayoutParams();
                    laParams.width = newWidth;
                    holder.iv_progress.setLayoutParams(laParams);
                }
            }
            return convertView;
        }

        class ViewHolder {
            ImageView gridCourseBg;
            TextView colledgeName;
            TextView courseName;
            TextView startTime;
            TextView endTime;
            TextView courseIsIn;
            TextView tv_endTime;
            TextView percent;
            TextView tv_percent;
            TextView iv_progress;
            TextView courseType;
            RelativeLayout rv;

            public ViewHolder(View v) {
                gridCourseBg = (ImageView) v.findViewById(R.id.gridCourseBg);
                colledgeName = (TextView) v.findViewById(R.id.colledgeName);
                courseName = (TextView) v.findViewById(R.id.courseName);
                startTime = (TextView) v.findViewById(R.id.startTime);
                endTime = (TextView) v.findViewById(R.id.endTime);
                courseIsIn = (TextView) v.findViewById(R.id.courseIsIn);
                tv_endTime = (TextView) v.findViewById(R.id.tv_endTime);
                percent = (TextView) v.findViewById(R.id.percent);
                tv_percent = (TextView) v.findViewById(R.id.tv_percent);
                iv_progress = (TextView) v.findViewById(R.id.iv_progress);
                courseType = (TextView) v.findViewById(R.id.courseType);
                rv = (RelativeLayout) v.findViewById(R.id.rv);
            }
        }

    }
}
