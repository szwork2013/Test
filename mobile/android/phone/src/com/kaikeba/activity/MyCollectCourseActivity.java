package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.adapter.CategoryCourseAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.CommonUtils;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by sjyin on 14-8-5.
 */
public class MyCollectCourseActivity extends BaseActivity implements View.OnClickListener {

    private PullToRefreshListView my_open_course;
    private ImageView back_normal;
    private TextView tv_course_top_name;
    private Context mContext;

    private LinearLayout ll_course_info_title;
    private LinearLayout my_collect_top_tab;
    private LinearLayout view_loading_fail;
    private LinearLayout ll_no_courses;
    private ImageView loading_fail;
    private RelativeLayout view_loading;

    private TextView open_course;
    private TextView guide_course;
    private CategoryCourseAdapter adapter;
    private ArrayList<CourseModel> courses = new ArrayList<CourseModel>();
    private ArrayList<CourseModel> openCourses = new ArrayList<CourseModel>();
    private ArrayList<CourseModel> guideCourses = new ArrayList<CourseModel>();
    private List<CourseModel> tempCourses = new ArrayList<CourseModel>();
    private List<CourseModel> tempAllCourses;
    private List<TextView> tvs = new ArrayList<TextView>();
    private boolean flag;
    private Drawable loadingDraw;
    private List<CourseModel> courseModels = new ArrayList<CourseModel>();
    private Handler handler = new Handler() {
        @Override
        public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
            return super.sendMessageAtTime(msg, uptimeMillis);
        }
    };
    private List<CourseModel> refreshTemp = new ArrayList<CourseModel>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_collect_course);
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
        String url = HttpUrlUtil.ALL_COLLECTIONS;//"https://api.kaikeba.com/v1/collections/user";
        Type type = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    tempAllCourses = (ArrayList<CourseModel>) data;
                    openCourses.clear();
                    guideCourses.clear();
                    courses.clear();
                    for (CourseModel course : tempAllCourses) {
                        for (CourseModel detail_course : courseModels) {
                            if (detail_course.getId() == course.getId()) {
                                if ("OpenCourse".equals(course.getType())) {
                                    openCourses.add(detail_course);
                                } else {
                                    guideCourses.add(detail_course);
                                }
                            }
                        }
                    }
                    tempCourses.addAll(openCourses);
                    if (tempCourses.size() > 10) {
                        courses.addAll(tempCourses);
                        ll_no_courses.setVisibility(View.GONE);
                    } else if (tempCourses.size() > 0) {
                        courses.addAll(tempCourses);
                        ll_no_courses.setVisibility(View.GONE);
                    } else {
                        if (!fromCache)
                            ll_no_courses.setVisibility(View.VISIBLE);
                    }
                    tempCourses.removeAll(courses);
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

    private void initView() {
        mContext = this;

        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        ll_no_courses = (LinearLayout) findViewById(R.id.ll_no_courses);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loadAllCourseData();
                showLoading();
            }
        });
        ll_course_info_title = (LinearLayout) findViewById(R.id.ll_course_info_title);
        my_collect_top_tab = (LinearLayout) findViewById(R.id.my_collect_top_tab);
        my_open_course = (PullToRefreshListView) findViewById(R.id.lv_my_open_course);
        my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
        my_open_course.setReleaseLabel("放手刷新");
        my_open_course.setRefreshingLabel("正在刷新...");
        my_open_course.setPullLabel("上拉加载更多");
        my_open_course.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener<ListView>() {
            @Override
            public void onRefresh(PullToRefreshBase<ListView> refreshView) {
                // Do work to refresh the list here.
                new GetDataTask().execute();
            }
        });
        back_normal = (ImageView) findViewById(R.id.iv_back);
        tv_course_top_name = (TextView) findViewById(R.id.tv_text);
        tv_course_top_name.setText(getResources().getString(R.string.my_collected_course));
        adapter = new CategoryCourseAdapter(mContext, courses, handler);
        my_open_course.setAdapter(adapter);
        my_open_course.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent it = new Intent();
                Bundle b = new Bundle();
                Log.i("MyCollectCourseActivity", "当前点击的位置是 " + position);
                if (courses.get(position - 1).getType().equals("OpenCourse")) {
                    it.setClass(MyCollectCourseActivity.this, OpenCourseActivity.class);
                } else {
                    it.setClass(MyCollectCourseActivity.this, GuideCourseAcitvity.class);
                }
                b.putSerializable(ContextUtil.CATEGORY_COURSE, courses.get(position - 1));
                it.putExtras(b);
                startActivity(it);
            }
        });
        back_normal.setOnClickListener(this);
        open_course = (TextView) findViewById(R.id.open_course);
        guide_course = (TextView) findViewById(R.id.guide_course);
        tvs.add(open_course);
        tvs.add(guide_course);
        open_course.setOnClickListener(this);
        guide_course.setOnClickListener(this);
        open_course.performClick();

        setListViewHeight();
    }

    private void setListViewHeight() {
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        ll_course_info_title.measure(w, h);
        int height = ll_course_info_title.getMeasuredHeight();

        int wid = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int hig = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        my_collect_top_tab.measure(wid, hig);
        int tab_height = my_collect_top_tab.getMeasuredHeight();
        ViewGroup.LayoutParams params = my_open_course.getLayoutParams();
        params.width = CommonUtils.getScreenWidth(mContext);
        params.height = CommonUtils.getScreenHeight(mContext) - CommonUtils.getStatusBarHeight(mContext) - height - tab_height - 24;
        my_open_course.setLayoutParams(params);
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

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.open_course:
            case R.id.guide_course:
                my_open_course.setLoadingDrawable(loadingDraw);
                my_open_course.setReleaseLabel("放手刷新");
                my_open_course.setRefreshingLabel("正在刷新...");
                my_open_course.setPullLabel("上拉加载更多");
                if (v.getId() == R.id.open_course) {
                    resetFocuse(open_course);
                    if (tempCourses != null) {
                        tempCourses.clear();
                        tempCourses.addAll(openCourses);
                    } else {
                        tempCourses = openCourses;
                    }
                } else if (v.getId() == R.id.guide_course) {
                    resetFocuse(guide_course);
                    if (tempCourses != null) {
                        tempCourses.clear();
                        tempCourses.addAll(guideCourses);
                    } else {
                        tempCourses = guideCourses;
                    }
                }
                courses.clear();
                if (tempCourses.size() > 3) {
                    my_open_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                } else {
                    my_open_course.setMode(PullToRefreshBase.Mode.DISABLED);
                }
                if (tempCourses.size() > 10) {
                    courses.addAll(tempCourses.subList(0, 10));
                    ll_no_courses.setVisibility(View.GONE);
                } else if (tempCourses.size() > 0) {
                    courses.addAll(tempCourses);
                    ll_no_courses.setVisibility(View.GONE);
                } else {
                    ll_no_courses.setVisibility(View.VISIBLE);
                }
                tempCourses.removeAll(courses);
                adapter.notifyDataSetChanged();

                break;
            case R.id.iv_back:
                appointSkip();
                break;
        }
    }

    private void resetFocuse(TextView curTv) {
        for (TextView tv : tvs) {
            if (tv.getId() == curTv.getId()) {
                tv.setEnabled(false);
                tv.setTextColor(getResources().getColor(R.color.text_pressed));
            } else {
                tv.setEnabled(true);
                tv.setTextColor(getResources().getColor(R.color.text_normal));
            }
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("MyFavoriteCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MyFavoriteCourse");
        MobclickAgent.onPause(this);
    }

    private class GetDataTask extends AsyncTask<Void, Void, String[]> {

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
            if (tempCourses.size() > 10) {
                courses.addAll(tempCourses.subList(0, 10));
                refreshTemp.addAll(tempCourses.subList(0, 10));
                tempCourses.removeAll(refreshTemp);
                flag = false;
            } else if (tempCourses.size() > 0) {
                courses.addAll(tempCourses);
                refreshTemp.addAll(tempCourses);
                tempCourses.removeAll(refreshTemp);
                flag = false;
            } else {
                flag = true;
            }

            if (flag) {
                my_open_course.setLoadingDrawable(null);
                my_open_course.setReleaseLabel("共" + courses.size() + "门课程");
                my_open_course.setRefreshingLabel("共" + courses.size() + "门课程");
                my_open_course.setPullLabel("共" + courses.size() + "门课程");
            } else {
                my_open_course.setLoadingDrawable(loadingDraw);
                my_open_course.setReleaseLabel("放手刷新");
                my_open_course.setRefreshingLabel("正在刷新...");
                my_open_course.setPullLabel("上拉加载更多");
            }
        }
    }
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }
    public void appointSkip() {
        Intent intent = new Intent(MyCollectCourseActivity.this, TabCourseActivity.class);
        intent.putExtra("TabTag", "UserCenter");
        intent.putExtra("TabNum", 3);
        startActivity(intent);
        finish();
    }
}
