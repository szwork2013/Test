package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.common.BaseClass.BaseFragmentActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by chris on 14-8-4.
 */
public class MyOpenCourseActivity extends BaseFragmentActivity {

    ArrayList<CourseModel> allCourses = new ArrayList<CourseModel>();
    private PullToRefreshListView my_open_course;
    private ImageView back_normal;
    private TextView tv_course_top_name;
    private ArrayList<CourseModel> courses = new ArrayList<CourseModel>();
    private Drawable loadingDraw;
    private boolean flag;

    private Context mContext;
    private BitmapUtils bitmapUtils;
    private OpenCourseAdapter adapter;

    private LinearLayout view_loading_fail;
    private LinearLayout ll_no_courses;
    private ImageView loading_fail;
    private RelativeLayout view_loading;

    private String TAG = "MyOpenCourseActivity";
    private List<CourseModel> tempCourses = new ArrayList<CourseModel>();
    private List<CourseModel> showCourses = new ArrayList<CourseModel>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_open_course);
        mContext = this;
        initView();
        loadAllCourses();
    }

    private void loadAllCourses() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    allCourses.addAll((ArrayList<CourseModel>) data);
                    initData(true);
                    initData(false);
                } else {
                    showNoData();
                }

            }
        });
    }

    private void initView() {

        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        ll_no_courses = (LinearLayout) findViewById(R.id.ll_no_courses);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initData(true);
            }
        });

        my_open_course = (PullToRefreshListView) findViewById(R.id.lv_my_open_course);
        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
        my_open_course.setReleaseLabel("放手刷新");
        my_open_course.setRefreshingLabel("正在刷新...");
        my_open_course.setPullLabel("上拉加载更多");
        my_open_course.setLoadingDrawable(loadingDraw);
        my_open_course.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener<ListView>() {
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
                                                            my_open_course.onRefreshComplete();
                                                            tempCourses.clear();
                                                            if (courses.size() > 10) {
                                                                tempCourses.addAll(courses.subList(0, 10));
                                                                flag = false;
                                                            } else {
                                                                tempCourses.addAll(courses);
                                                                flag = true;
                                                            }
                                                            showCourses.addAll(tempCourses);
                                                            courses.removeAll(tempCourses);
                                                            adapter.notifyDataSetChanged();

                                                            if (flag) {
                                                                my_open_course.setLoadingDrawable(null);
                                                                my_open_course.setReleaseLabel("共" + showCourses.size() + "门课程");
                                                                my_open_course.setRefreshingLabel("共" + showCourses.size() + "门课程");
                                                                my_open_course.setPullLabel("共" + showCourses.size() + "门课程");
                                                            } else {
                                                                my_open_course.setLoadingDrawable(loadingDraw);
                                                                my_open_course.setReleaseLabel("放手刷新");
                                                                my_open_course.setRefreshingLabel("正在刷新...");
                                                                my_open_course.setPullLabel("上拉加载更多");
                                                            }
                                                        }
                                                    }.execute();
                                                }
                                            }
        );
        back_normal = (ImageView) findViewById(R.id.iv_back);
        tv_course_top_name = (TextView) findViewById(R.id.tv_text);
        tv_course_top_name.setText(getResources().getString(R.string.my_open_course));
        adapter = new OpenCourseAdapter();
        my_open_course.setAdapter(adapter);
        my_open_course.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent it = new Intent();
                Bundle b = new Bundle();
                if (showCourses.get(position - 1).getType().equals("OpenCourse")) {
                    it.setClass(mContext, OpenCourseActivity.class);
                } else {
                    it.setClass(mContext, GuideCourseAcitvity.class);
                }
                b.putSerializable(ContextUtil.CATEGORY_COURSE, showCourses.get(position - 1));
                it.putExtras(b);
                startActivity(it);
            }
        });
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext);
        back_normal.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                appointSkip();
            }
        });

    }

    private void initData(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        String url = HttpUrlUtil.OPEN_COURSES;//"https://api.kaikeba.com/v1/open_courses";
        Type type = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    courses.clear();
                    showCourses.clear();
                    for (CourseModel course : (ArrayList<CourseModel>) data) {
                        for (CourseModel courseFromAll : allCourses) {
                            if (courseFromAll.getId() == course.getId()) {
                                courseFromAll.setNumber(course.getNumber());
                                courses.add(courseFromAll);
                                break;
                            }
                        }
                    }
                    if (courses.size() > 3) {
                        my_open_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                    } else {
                        my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
                    }
                    if (courses.size() > 10) {
                        showCourses.addAll(courses.subList(0, 10));
                        ll_no_courses.setVisibility(View.GONE);
                    } else if (courses.size() > 0) {
                        showCourses.addAll(courses);
                        ll_no_courses.setVisibility(View.GONE);
                    } else {
                        if (fromCache) {
                            ll_no_courses.setVisibility(View.VISIBLE);
                        }
                    }
                    if (fromCache) {
                        initData(false);
                    }
                    courses.removeAll(showCourses);
                    if (adapter != null) {
                        adapter.notifyDataSetChanged();
                    }
                    showData();
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
        MobclickAgent.onPageStart("MyOpenCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MyOpenCourse");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }

    public void appointSkip() {
        Intent intent = new Intent(MyOpenCourseActivity.this, TabCourseActivity.class);
        intent.putExtra("TabTag", "UserCenter");
        intent.putExtra("TabNum", 3);
        startActivity(intent);
        finish();
    }

    class OpenCourseAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            return showCourses.size();
        }

        @Override
        public Object getItem(int position) {
            return showCourses.get(position);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder holder;
            CourseModel course = showCourses.get(position);
            if (convertView == null) {
                convertView = View.inflate(mContext, R.layout.my_open_course_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
//            bitmapUtils.display(holder.courseImg, course.getCover_image());
            bitmapUtils.display(holder.courseImg, course.getCover_image(),BitmapHelp.getBitMapConfig(MyOpenCourseActivity.this,R.drawable.default_224_140));
            holder.courseName.setText(course.getName());
            holder.updateInfo.setText("更新至 第" + course.getUpdated_amount() + "节");
            if (course.getNumber() != 0) {
                holder.lastWatchInfo.setVisibility(View.VISIBLE);
                holder.lastWatchInfo.setText("观看至第" + course.getNumber() + "节");
            } else {
                holder.lastWatchInfo.setVisibility(View.GONE);
            }

            return convertView;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }
    }

    class ViewHolder {
        ImageView courseImg;
        TextView courseName;
        TextView updateInfo;
        TextView lastWatchInfo;

        public ViewHolder(View parView) {
            courseImg = (ImageView) parView.findViewById(R.id.iv_course_img);
            courseName = (TextView) parView.findViewById(R.id.tv_course_name);
            updateInfo = (TextView) parView.findViewById(R.id.tv_update);
            lastWatchInfo = (TextView) parView.findViewById(R.id.tv_last_watch);
        }
    }
}
