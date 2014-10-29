package com.kaikeba.activity;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.*;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.adapter.CategoryCourseAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.Category;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by user on 14-7-17.
 */
public class CategoryCourseActivity extends BaseActivity implements View.OnClickListener {

    private Category category;
    private PullToRefreshListView lv_all_course;
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;
    private ImageView iv_back;
    private TextView tv_category_name;
    private TextView nodata_tv;
    private Drawable loadingDraw;
    private CategoryCourseAdapter cateAdapter;
    private List<CourseModel> list;
    private List<CourseModel> allList;
    private List<CourseModel> tempList;
    private String url;
    private List<CourseModel> cs = new ArrayList<CourseModel>(); //全部课程
    private AdapterView.OnItemClickListener listViewListener = new AdapterView.OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            if (!"online".equals(list.get(position - 1).getStatus())) {
                return;
            }
            Intent it = new Intent();
            Bundle b = new Bundle();
            if (list.get(position - 1).getType().equals("OpenCourse")) {
                it.setClass(CategoryCourseActivity.this, OpenCourseActivity.class);
            } else {
                it.setClass(CategoryCourseActivity.this, GuideCourseAcitvity.class);
            }
            b.putSerializable(ContextUtil.CATEGORY_COURSE, list.get(position - 1));
            it.putExtras(b);
            startActivity(it);
        }
    };
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);

        }
    };
    private boolean flag;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.category_courses);
        Bundle b = getIntent().getExtras();
        category = (Category) b.getSerializable("category");
        initView();
        loadAllData();
    }

    private void initView() {
        lv_all_course = (PullToRefreshListView) findViewById(R.id.lv_category_course);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        iv_back = (ImageView) findViewById(R.id.iv_back);
        tv_category_name = (TextView) findViewById(R.id.tv_text);
        nodata_tv = (TextView) findViewById(R.id.nodata);
        tv_category_name.setText(category.getName());
        iv_back.setOnClickListener(this);
        view_loading_fail.setOnClickListener(this);

        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        lv_all_course.setMode(PullToRefreshBase.Mode.DISABLED);
        lv_all_course.setReleaseLabel("放手刷新");
        lv_all_course.setRefreshingLabel("正在刷新...");
        lv_all_course.setPullLabel("上拉加载更多");
        lv_all_course.setLoadingDrawable(loadingDraw);
        lv_all_course.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener<ListView>() {
            @Override
            public void onRefresh(PullToRefreshBase<ListView> refreshView) {
                // Do work to refresh the list here.
                new GetDataTask().execute();
            }
        });
        list = new ArrayList<CourseModel>();
        allList = new ArrayList<CourseModel>();
        tempList = new ArrayList<CourseModel>();
        cateAdapter = new CategoryCourseAdapter(this, list, handler);
        lv_all_course.setAdapter(cateAdapter);
        lv_all_course.setOnItemClickListener(listViewListener);
    }

    @Override
    protected void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("CategoryCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("CategoryCourse");
        MobclickAgent.onPause(this);
    }

    private void loadAllData() {
        showloading();
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    if (cs != null && cs.size() > 0) {
                        cs.clear();
                    }
                    allList.clear();
                    cs.addAll((ArrayList<CourseModel>) data);
                    for (CourseModel info : cs) {
                        if (category.getId() == info.getCategory_id() && info.getStatus().equals("online")) {
                            allList.add(info);
                        }
                    }
                }

                if (allList != null && allList.size() > 0) {
                    list.clear();
                    showSuccessData();
                    if (allList.size() > 3) {
                        lv_all_course.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
                    } else {
                        lv_all_course.setMode(PullToRefreshBase.Mode.DISABLED);
                    }
                } else {
                    showNoData();
                }
                if (allList.size() > 10) {
                    list.addAll(allList.subList(0, 10));
                } else {
                    list.addAll(allList);
                }

                allList.removeAll(list);

                cateAdapter.notifyDataSetChanged();
            }
        });
    }

    private void showSuccessData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
        if ((list != null && list.size() == 0) && (allList != null && allList.size() == 0)) {
            nodata_tv.setVisibility(View.VISIBLE);
        } else {
            nodata_tv.setVisibility(View.GONE);
        }
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showloading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_back:
                appointSkip();
                break;
            case R.id.view_loading_fail:
//                showloading();
                loadAllData();
                break;
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }

    public void appointSkip() {
        if (API.getAPI().alreadySignin()) {
            Intent intent = new Intent(CategoryCourseActivity.this, TabCourseActivity.class);
            intent.putExtra("TabTag", "Category");
            intent.putExtra("TabNum", 1);
            startActivity(intent);
            finish();
        } else {
            finish();
        }
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
            lv_all_course.onRefreshComplete();
            tempList.clear();
            if (allList.size() > 10) {
                tempList.addAll(allList.subList(0, 10));
                flag = false;
            } else {
                tempList.addAll(allList);
                flag = true;
            }
            list.addAll(tempList);
            allList.removeAll(tempList);

            if (flag) {
                lv_all_course.setLoadingDrawable(null);
                lv_all_course.setReleaseLabel("共" + list.size() + "门课程");
                lv_all_course.setRefreshingLabel("共" + list.size() + "门课程");
                lv_all_course.setPullLabel("共" + list.size() + "门课程");
            } else {
                lv_all_course.setLoadingDrawable(loadingDraw);
                lv_all_course.setReleaseLabel("放手刷新");
                lv_all_course.setRefreshingLabel("正在刷新...");
                lv_all_course.setPullLabel("上拉加载更多");
            }
        }
    }
}
