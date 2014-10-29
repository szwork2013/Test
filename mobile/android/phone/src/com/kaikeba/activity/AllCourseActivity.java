package com.kaikeba.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.igexin.sdk.PushManager;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.view.CourseAnimateView;
import com.kaikeba.adapter.CategoryAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.Category;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.listeners.OnScrollListener;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.*;
import com.kaikeba.common.watcher.Watcher;
import com.kaikeba.common.widget.CGridView;
import com.kaikeba.common.widget.MyScrollView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * Created by user on 14-7-15.
 */
public class AllCourseActivity extends BaseActivity implements Watcher, View.OnClickListener,OnScrollListener {

    private static AllCourseActivity allCourseActivity;
    LinearLayout ll_intro;
    LinearLayout micro_header_layout;
    private ArrayList<CourseInfo> CourseInfoList;
    private LinearLayout container;
    private FrameLayout ll_all_course;
    private CourseAnimateView tempAnimateView;
    private MyScrollView myScrollView;
    private CGridView gv;
    private CategoryAdapter categoryAdapter;
    private ArrayList<Category> categories = new ArrayList<Category>();
    private TextView btn_login;
    private TextView btn_register;
    private LinearLayout login_or_register;
    private String TAG = "AllCourseActivity";
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private RelativeLayout view_loading;
    private TextView tv_header_title;
    private TextView tv_header_intro;
    private boolean hasAllCourse = false;
    private boolean hasMajorCourse = false;
    private NetBroadcastReceiver mNetBroadcastReceiver;
    private SharedPreferences appPrefs;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            int what = msg.what;
            switch (what) {
                case 1:

                    break;
            }
        }
    };
    private long exitTime = 0;

    public static AllCourseActivity getAllCourseActivity() {
        return allCourseActivity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceStmate) {
        super.onCreate(savedInstanceStmate);
        setContentView(R.layout.mall_course);
        //   初始化推送SDK：
        PushManager.getInstance().initialize(this.getApplicationContext());
        allCourseActivity = this;
        initView();
        initData(true);
        initData(false);
        loadallData();
        //自动更新
        UmengUpdateAgent.update(this);
        //注册网络监听
        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mNetBroadcastReceiver = NetBroadcastReceiver.getInstance();
        registerReceiver(mNetBroadcastReceiver, filter);

        //判断用户是否第一次登陆kkb，并上传数据
        appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);

        boolean isFirstOpen = appPrefs.getBoolean(ContextUtil.isFirstOpened, true);


        if (isFirstOpen) {
            try {
                UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(AllCourseActivity.this, "");
                UploadData.getInstance().addDbData(AllCourseActivity.this, logininfo, "CPA");
            } catch (DbException e) {
                e.printStackTrace();
            }
            SharedPreferences.Editor editor = appPrefs.edit();
            editor.putBoolean(ContextUtil.isFirstOpened, false);
            editor.commit();

        }
        UploadData.getInstance().upload(AllCourseActivity.this);
    }

    private void loadallData() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object allCourseData) {
                if (allCourseData != null) {
                    hasAllCourse = true;
                    showData();
                } else {
                    showNoData();
                }

            }
        });
    }

    private void initView() {
        ll_intro = (LinearLayout) findViewById(R.id.ll_intro);
        micro_header_layout = (LinearLayout) findViewById(R.id.micro_header_layout);
        tv_header_title = (TextView) findViewById(R.id.tv_header_title);
        tv_header_intro = (TextView) findViewById(R.id.tv_header_intro);
        login_or_register = (LinearLayout) findViewById(R.id.login_or_register);
//        ll_main_container = (LinearLayout) findViewById(R.id.ll_main_container);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        login_or_register = (LinearLayout) findViewById(R.id.login_or_register);
        btn_login = (TextView) findViewById(R.id.common_login);
        btn_register = (TextView) findViewById(R.id.common_register);
        ll_all_course = (FrameLayout) findViewById(R.id.ll_all_course);
        ll_all_course.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                onScroll(myScrollView.getScrollY());
            }
        });

        container = (LinearLayout) findViewById(R.id.course_container);

        myScrollView = (MyScrollView) findViewById(R.id.myScrollView);
        myScrollView.setOnScrollListener(this);
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        login_or_register.measure(w, h);
        int headerHeight = (int) (55 * Constants.SCREEN_DENSITY + 0.5);
        int height = login_or_register.getMeasuredHeight() + headerHeight;

        categoryAdapter = new CategoryAdapter(AllCourseActivity.this, categories, handler, height);
        gv = (CGridView) findViewById(R.id.gv_categories);
        gv.setAdapter(categoryAdapter);
        gv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                Intent intent = new Intent(AllCourseActivity.this, CategoryCourseActivity.class);
                Bundle b = new Bundle();
                b.putSerializable("category", categories.get(position));
                intent.putExtras(b);
                startActivity(intent);
            }
        });
        displayCourseInfo();

        btn_login.setOnClickListener(this);
        btn_register.setOnClickListener(this);
        loading_fail.setOnClickListener(this);
    }

    private void displayCourseInfo() {
        if (CourseInfoList == null || CourseInfoList.size() <= 0) {
            return;
        }
        container.removeAllViews();
        for (int i = 0; i < CourseInfoList.size(); i++) {
            CourseAnimateView view = new CourseAnimateView(this, CourseInfoList.get(i));
            addCourseItem(view.getLayout());
        }
        hasMajorCourse = true;
        showData();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.common_login:
                Constants.LOGIN_FROM = Constants.FROM_ALLCOURSE;
                Intent intent = new Intent(AllCourseActivity.this, LoginActivity2.class);
                startActivity(intent);
                break;
            case R.id.common_register:
                Constants.LOGIN_FROM = Constants.FROM_ALLCOURSE;
                Intent intent1 = new Intent(AllCourseActivity.this, RegistActivity.class);
                startActivity(intent1);
                break;
            case R.id.loading_fail:
                initData(true);
                loadallData();
                break;
            default:
                break;
        }
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
        if (hasMajorCourse && hasAllCourse) {
            view_loading.setVisibility(View.GONE);
            view_loading_fail.setVisibility(View.GONE);
        }
    }

    private void initData(final boolean fromcache) {
        if (fromcache) {
            showLoading();
        }
        String specialtyUrl = HttpUrlUtil.SPECIALTY;//"https://api.kaikeba.com/v1/specialty";
        Type specialtyType = new TypeToken<ArrayList<CourseInfo>>() {
        }.getType();

        String categoryUrl = HttpUrlUtil.CATEGORY;//"https://api.kaikeba.com/v1/category";
        Type categoryType = new TypeToken<ArrayList<Category>>() {
        }.getType();

        ServerDataCache.getInstance().dataWithURL(specialtyUrl, null, fromcache, specialtyType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                Log.i(TAG, data == null ? "getspecialty from cache " + fromcache + "data == null" : "data is not null");
                if (data != null) {
                    CourseInfoList = (ArrayList<CourseInfo>) data;
                    displayCourseInfo();
                } else if (CourseInfoList != null) {
                    displayCourseInfo();
                } else {
                    if (fromcache)
                        showNoData();
                }
            }
        });

        ServerDataCache.getInstance().dataWithURL(categoryUrl, null, fromcache, categoryType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                Log.i(TAG, data == null ? "getCategory from cache " + fromcache + "data == null" : "data is not null");
                if (data != null) {
                    ArrayList<Category> temp = (ArrayList<Category>) data;
                    categories.clear();
                    categories.addAll(temp);
                    categoryAdapter.notifyDataSetChanged();
                } else {

                }
            }
        });

    }

    private void addCourseItem(FrameLayout layout) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        params.setMargins(0, 20, 0, 20);
        container.addView(layout, params);
    }

    @Override
    public void update(Object obj) {
        CourseAnimateView view = (CourseAnimateView) obj;
        if (tempAnimateView == view) {
            view.closeAnimate();
            tempAnimateView = null;
        } else {
            view.openAnimate();
            if (tempAnimateView != null) {
                tempAnimateView.closeAnimate();
            }
            tempAnimateView = view;
        }
    }

    @Override
    public void onBackPressed() {
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            finish();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("AnonymousHome"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("AnonymousHome");
        MobclickAgent.onPause(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
    }

    @Override
    public void onScroll(int scrollY) {

    }
}
