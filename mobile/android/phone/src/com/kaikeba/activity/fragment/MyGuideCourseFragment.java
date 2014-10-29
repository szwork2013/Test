package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.GuideCourseLearnActivity;
import com.kaikeba.activity.OpenCourseActivity;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;
import com.kaikeba.viewholder.GuideCourseViewHolder;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.Date;

public class MyGuideCourseFragment extends Fragment {

    private PullToRefreshListView lv_my_open_course;
    private MyGuideCourseAdapter adapter;
    private ArrayList<CourseModel> courses = new ArrayList<CourseModel>();
    private ArrayList<CourseModel> showCourses = new ArrayList<CourseModel>();
    private ArrayList<CourseModel> refrehCourses = new ArrayList<CourseModel>();
    private ArrayList<CourseModel> tempCourses;
    private boolean flag;
    private Drawable loadingDraw;
    private BitmapUtils bitmapUtils;
    private FragmentActivity mContext;
    private LinearLayout ll_no_courses;
    private int tag;
    private String TAG = "MyGuideCourseActivity1";

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        mContext = getActivity();
        View v = inflater.inflate(R.layout.activity_my_open_course, container, false);
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext);

        lv_my_open_course = (PullToRefreshListView) v.findViewById(R.id.lv_my_open_course);
        ll_no_courses = (LinearLayout) v.findViewById(R.id.ll_no_courses);
        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        lv_my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
        lv_my_open_course.setReleaseLabel("放手刷新");
        lv_my_open_course.setRefreshingLabel("正在刷新...");
        lv_my_open_course.setPullLabel("上拉加载更多");
        lv_my_open_course.setLoadingDrawable(loadingDraw);
        lv_my_open_course.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener<ListView>() {
                                                   @Override
                                                   public void onRefresh(PullToRefreshBase<ListView> refreshView) {
                                                       // Do work to refresh the list here.
                                                       new AsyncTask<Void, Void, String[]>() {

                                                           @Override
                                                           protected String[] doInBackground(Void... params) {
                                                               // Simulates a background job.
                                                               try {
                                                                   Thread.sleep(500);
                                                               } catch (InterruptedException e) {
                                                               }

                                                               return null;
                                                           }

                                                           @Override
                                                           protected void onPostExecute(String[] result) {
                                                               // Call onRefreshComplete when the list has been refreshed.
                                                               super.onPostExecute(result);
                                                               lv_my_open_course.onRefreshComplete();
                                                               refrehCourses.clear();
                                                               if (courses.size() > 10) {
                                                                   refrehCourses.addAll(courses.subList(0, 10));
                                                                   flag = false;
                                                               } else {
                                                                   refrehCourses.addAll(courses);
                                                                   flag = true;
                                                               }
                                                               showCourses.addAll(refrehCourses);
                                                               courses.removeAll(refrehCourses);
                                                               adapter.notifyDataSetChanged();

                                                               if (flag) {
                                                                   lv_my_open_course.setLoadingDrawable(null);
                                                                   lv_my_open_course.setReleaseLabel("共" + showCourses.size() + "门课程");
                                                                   lv_my_open_course.setRefreshingLabel("共" + showCourses.size() + "门课程");
                                                                   lv_my_open_course.setPullLabel("共" + showCourses.size() + "门课程");
                                                               } else {
                                                                   lv_my_open_course.setLoadingDrawable(loadingDraw);
                                                                   lv_my_open_course.setReleaseLabel("放手刷新");
                                                                   lv_my_open_course.setRefreshingLabel("正在刷新...");
                                                                   lv_my_open_course.setPullLabel("上拉加载更多");
                                                               }
                                                           }
                                                       }.execute();
                                                   }
                                               }
        );

        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
        adapter = new MyGuideCourseAdapter();
        lv_my_open_course.setAdapter(adapter);
        lv_my_open_course.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent it = new Intent();
                Bundle b = new Bundle();
                if (showCourses.get(position - 1).getType().equals("OpenCourse")) {
                    it.setClass(mContext, OpenCourseActivity.class);
                } else {
                    it.setClass(mContext, GuideCourseLearnActivity.class);
                    b.putInt("lms_course_id", showCourses.get(position - 1).getCourses_lms().getId());
                    b.putInt("number", showCourses.get(position - 1).getNumber());
                }
                b.putSerializable(ContextUtil.CATEGORY_COURSE, showCourses.get(position - 1));
                it.putExtras(b);
                startActivity(it);
            }
        });
    }

    public void initData() {

        Bundle bundle = getArguments();
        tempCourses = (ArrayList<CourseModel>) bundle.getSerializable("courses");
        tag = bundle.getInt("flag");
        if (tempCourses == null) {
            return;
        }
        courses.clear();
        showCourses.clear();
        switch (tag) {
            case 11:
                for (CourseModel course : tempCourses) {
                    if (-1 != course.getNumber() && -2 != course.getNumber()) {
                        courses.add(course);
                    }
                }
                if (courses.size() > 3) {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                } else {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
                }

                break;
            case 22:
                for (CourseModel course : tempCourses) {
                    if (-1 == course.getNumber()) {
                        courses.add(course);
                    }
                }
                if (courses.size() > 3) {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                } else {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
                }

                break;
            case 33:
                for (CourseModel course : tempCourses) {
                    if (-2 == course.getNumber()) {
                        courses.add(course);
                    }
                }
                if (courses.size() > 3) {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                } else {
                    lv_my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
                }

                break;
            default:
                break;
        }
        if (courses.size() > 10) {
            showCourses.addAll(courses.subList(0, 10));
            ll_no_courses.setVisibility(View.GONE);
        } else if (courses.size() > 0) {
            showCourses.addAll(courses);
            ll_no_courses.setVisibility(View.GONE);
        } else {
            ll_no_courses.setVisibility(View.VISIBLE);
        }
        courses.removeAll(showCourses);

    }

    class MyGuideCourseAdapter extends BaseAdapter {

        @Override
        public int getCount() {
            return showCourses.size();
        }

        @Override
        public Object getItem(int position) {
            return showCourses.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            GuideCourseViewHolder holder;
            CourseModel course = showCourses.get(position);
            if (convertView == null) {
                convertView = View.inflate(mContext, R.layout.activity_my_guide_course_item, null);
                holder = new GuideCourseViewHolder(convertView, tag);
                convertView.setTag(holder);
            } else {
                holder = (GuideCourseViewHolder) convertView.getTag();
            }

//            bitmapUtils.display(holder.courseImg, course.getCover_image());
            bitmapUtils.display(holder.courseImg, course.getCover_image(),BitmapHelp.getBitMapConfig(getActivity(),R.drawable.default_224_140));
            Log.i(TAG, "cover_image url = " + course.getCover_image());
            holder.courseName.setText(course.getName());
            switch (tag) {
                case 11:
                    holder.totalAmount.setText(course.getWeeks() + "周");
                    holder.updateAmount.setText("已更新至第" + course.getNumber() + "周");
                    break;
                case 22:
//                    holder.grade.setText(course.);
                    break;
                case 33:
                    holder.totalAmount.setText(course.getTotal_amount() + "周");
                    holder.duration.setText("每周" + course.getMin_duration() + "-" + showCourses.get(position).getMax_duration());

                    if ("online".equals(course.getStatus())) {
                        String startTime = DateUtils.getCourseStartTime(new Date(Long.parseLong(course.getCourses_lms().getStart_at())));
                        holder.startCourse.setText(startTime + "开课");
                        holder.startCourse.setVisibility(View.VISIBLE);
                        holder.ll_will_begin.setVisibility(View.GONE);
                    } else {
                        holder.startCourse.setVisibility(View.GONE);
                        holder.ll_will_begin.setVisibility(View.VISIBLE);
                    }
                    break;
            }
            return convertView;
        }
    }
}

