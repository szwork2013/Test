package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.common.BaseClass.BaseFragmentActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.widget.MyListVIew;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by chris on 14-8-4.
 */
public class MyMicroActivity extends BaseFragmentActivity {

    private ArrayList<CourseInfo.MicroSpecialties> microSpecialties = new ArrayList<CourseInfo.MicroSpecialties>();
    private ArrayList<CourseInfo.MicroSpecialties> joinedMicroSpecialties = new ArrayList<CourseInfo.MicroSpecialties>();
    private User user;
    private ListView lv_my_micro;
    private MicroAdapter adapter;
    private CourseAdapter courseAdapter;
    private Context mContext;
    private BitmapUtils bitmapUtils;

    private LinearLayout view_loading_fail;
    private LinearLayout ll_no_courses;
    private ImageView loading_fail;
    private RelativeLayout view_loading;

    private String TAG = "MyMicroActivity";
    private List<CourseModel> courseModels = new ArrayList<CourseModel>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_micro);
        mContext = this;
        Intent intent = getIntent();
        user = (User) intent.getSerializableExtra("user");
        Log.i(TAG, "user id = " + user.getId());
        initView();
        loadAllCourseData();
    }

    protected void loadAllCourseData() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    courseModels.addAll((ArrayList<CourseModel>) data);
                    initData(true);
                    initData(false);
                } else {
                    showNoData();
                }
            }
        });
    }

    private void initData(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        PretreatDataCache.loadMicroCourseFromChche(MyMicroActivity.this, false, new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    microSpecialties.clear();
                    joinedMicroSpecialties.clear();
                    microSpecialties.addAll((ArrayList<CourseInfo.MicroSpecialties>) data);

                    for (int i = 0; i < microSpecialties.size(); i++) {
                        if (microSpecialties.get(i).getJoin_status() == 1) {
                            joinedMicroSpecialties.add(microSpecialties.get(i));
                        }
                    }

                    if (adapter != null) {
                        adapter.notifyDataSetChanged();
                    }
                    if (fromCache) {
                        showData();
                    }
                    if (joinedMicroSpecialties.size() == 0) {
                        ll_no_courses.setVisibility(View.VISIBLE);
                    } else {
                        ll_no_courses.setVisibility(View.GONE);
                    }
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });

        ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
            @Override
            public void onAuthenticationFail() {
                Intent i = new Intent(mContext, AllCourseActivity.class);
                mContext.startActivity(i);
                ((Activity) mContext).finish();
            }
        });
    }

    private void initView() {
        bitmapUtils = BitmapHelp.getBitmapUtils(this);
        lv_my_micro = (ListView) findViewById(R.id.lv_my_micro);
        adapter = new MicroAdapter();
        lv_my_micro.setAdapter(adapter);

        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        ll_no_courses = (LinearLayout) findViewById(R.id.ll_no_courses);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);

        findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                appointSkip();
            }
        });
        TextView tv_text = (TextView) findViewById(R.id.tv_text);
        tv_text.setText("我的微专业");
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loadAllCourseData();
                showLoading();
            }
        });
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("MyMicroCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MyMicroCourse");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }

    public void appointSkip() {
        Intent intent = new Intent(MyMicroActivity.this, TabCourseActivity.class);
        intent.putExtra("TabTag", "UserCenter");
        intent.putExtra("TabNum", 3);
        startActivity(intent);
        finish();
    }

    private class MicroAdapter extends BaseAdapter {
        @Override
        public Object getItem(int position) {
            return joinedMicroSpecialties.get(position);
        }

        @Override
        public int getCount() {
            return joinedMicroSpecialties.size();
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = View.inflate(mContext, R.layout.my_micro_item, null);
                holder = new ViewHolder();
                holder.microName = (TextView) convertView.findViewById(R.id.tv_my_micro_name);
                holder.myMicroRate = (TextView) convertView.findViewById(R.id.tv_my_micro_rate);
                holder.microCoursesList = (MyListVIew) convertView.findViewById(R.id.lv_my_micro_courses);
                holder.finalCheckImg = (ImageView) convertView.findViewById(R.id.iv_final_check);
                holder.finalCheckStatus = (ImageView) convertView.findViewById(R.id.iv_final_check_status);
                holder.ll_tv_my_micro = (RelativeLayout) convertView.findViewById(R.id.ll_tv_my_micro);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.microName.setText(joinedMicroSpecialties.get(position).getName());
            holder.myMicroRate.setText(joinedMicroSpecialties.get(position).getLearn_progress());
            courseAdapter = new CourseAdapter();

            courseAdapter.setCourseses(joinedMicroSpecialties.get(position));
            holder.microCoursesList.setAdapter(courseAdapter);
            holder.microCoursesList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int childPosition, long id) {
                    Intent it = new Intent();
                    Bundle b = new Bundle();
                    if (joinedMicroSpecialties.get(position).getCourses().get(childPosition).getType().equals("OpenCourse")) {
                        it.setClass(mContext, OpenCourseActivity.class);
                    } else {
                        it.setClass(mContext, GuideCourseAcitvity.class);
                    }
                    CourseModel courseInfo = null;
                    for (CourseModel detail_course : courseModels) {
                        if (detail_course.getId() == joinedMicroSpecialties.get(position).getCourses().get(childPosition).getId()) {
                            courseInfo = detail_course;
                        }
                    }
                    b.putSerializable(ContextUtil.CATEGORY_COURSE, courseInfo);
                    it.putExtras(b);
                    startActivity(it);
                }
            });

            holder.ll_tv_my_micro.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Constants.LOGIN_FROM = Constants.FROM_MYMICRO_COURSE;
                    Intent intent = new Intent(MyMicroActivity.this, MicroCourseActivity.class);
                    Bundle b = new Bundle();
                    CourseInfo.MicroSpecialties micro = joinedMicroSpecialties.get(position);
                    b.putSerializable("microcourseinfo", micro);
                    intent.putExtras(b);
                    startActivity(intent);
                }
            });
            return convertView;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }
    }

    class ViewHolder {
        TextView microName;
        MyListVIew microCoursesList;
        ImageView finalCheckImg;
        ImageView finalCheckStatus;
        TextView myMicroRate;
        RelativeLayout ll_tv_my_micro;
    }

    class CourseAdapter extends BaseAdapter {

        private ArrayList<CourseInfo.MicroSpecialties.Courses> courseses = new ArrayList<CourseInfo.MicroSpecialties.Courses>();
        private int mposition;
        private CourseInfo.MicroSpecialties microSpecialtie;
        private boolean flag = true;

        public void setCourseses(CourseInfo.MicroSpecialties microSpecialties) {
            if (this.courseses != null) {
                this.courseses.clear();
            }
            microSpecialtie = microSpecialties;
            this.courseses.addAll(microSpecialties.getCourses());
        }

        @Override
        public int getCount() {
            if (this.courseses != null) {
                return courseses.size();
            }
            return 0;
        }

        @Override
        public Object getItem(int position) {
            if (courseses != null) {
                return courseses.get(position);
            }
            return null;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public boolean isEnabled(int position) {
            return flag;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            this.mposition = position;
            CourseInfo.MicroSpecialties.Courses courses = courseses.get(position);
            CourseViewHolder holder = null;
            if (convertView == null) {
                convertView = View.inflate(mContext, R.layout.my_micro_course_item, null);
                holder = new CourseViewHolder();
                holder.courseName = (TextView) convertView.findViewById(R.id.my_micro_course_name);
                holder.courseStatus = (ImageView) convertView.findViewById(R.id.my_micro_course_status);
                holder.divider = (View) convertView.findViewById(R.id.my_micro_course_divider);
                convertView.setTag(holder);
            } else {
                holder = (CourseViewHolder) convertView.getTag();
            }
            holder.courseName.setText(courses.getName());
            if (microSpecialtie != null && microSpecialtie.getLearn_status() != null) {
                Map<String, Integer> learnStatus = microSpecialtie.getLearn_status();
                if (learnStatus != null) {
                    Iterator iterator = learnStatus.entrySet().iterator();
                    while (iterator.hasNext()) {
                        Map.Entry entry = (Map.Entry) iterator.next();
                        String key = (String) entry.getKey();
                        Integer val = (Integer) entry.getValue();
                        if (key.equals(courses.getId() + "")) {
                            if (val == 0) {
                                flag = true;
                                holder.courseStatus.setImageResource(R.drawable.task_button_finish_def);
                            } else if (val == 1) {
                                flag = true;
                                holder.courseStatus.setImageResource(R.drawable.task_button_unfinished2_def);
                            } else if (val == 2) {
                                flag = false;
                                holder.courseStatus.setImageResource(R.drawable.mic_pro_button_willbegin);
                                holder.courseName.setTextColor(R.color.text_color_willbegin);
                            }
                            break;
                        }
                    }
                }
            }
            /*if(courses.getNumber() == -2){
                holder.courseStatus.setVisibility(View.VISIBLE);
                holder.courseStatus.setBackgroundColor(R.drawable.mic_pro_button_willbegin);
                holder.courseName.setTextColor(R.color.text_color_willbegin);
            }else{
                holder.courseStatus.setVisibility(View.INVISIBLE);
                holder.courseName.setTextColor(R.color.text_color_no_willbegin);
            }*/
            if (position == courseses.size() - 1) {
                holder.divider.setVisibility(View.GONE);
            } else {
                holder.divider.setVisibility(View.VISIBLE);
            }

            return convertView;
        }
    }

    class CourseViewHolder {
        TextView courseName;
        ImageView courseStatus;
        View divider;
    }
}
