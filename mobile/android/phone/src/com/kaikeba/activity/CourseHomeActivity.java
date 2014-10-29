package com.kaikeba.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.activity.view.CourseAnimateView;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.watcher.Watcher;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * Created by chris on 14-7-9.
 */
public class CourseHomeActivity extends Activity implements Watcher {
    private LinearLayout container;
    private CourseAnimateView tempAnimateView;
    private ArrayList<CourseInfo> CourseInfoList;

    private ImageView loading_fail;
    private LinearLayout view_loading_fail;
    private RelativeLayout view_loading;
    private ScrollView sv_container;
    private long exitTime = 0;

    private void showLoading(){
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
        sv_container.setVisibility(View.GONE);
    }

    private void showData(){
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
        sv_container.setVisibility(View.VISIBLE);
    }

    private void showNoData(){
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
        sv_container.setVisibility(View.GONE);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.course_display);

        container = (LinearLayout) findViewById(R.id.course_container);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        sv_container = (ScrollView) findViewById(R.id.sv_container);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initData(true);
            }
        });
        initData(true);
        initData(false);


    }

    private void initData(final boolean fromCache) {

        if (fromCache) {
            showLoading();
//            KKDialog.getInstance().showProgressBar(CourseHomeActivity.this, KKDialog.IS_LOADING);
        }

        String url = HttpUrlUtil.SPECIALTY;//"https://api.kaikeba.com/v1/specialty";
        Type type = new TypeToken<ArrayList<CourseInfo>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {

                if (data != null) {
                    CourseInfoList = (ArrayList<CourseInfo>) data;
                    initView();
                } else if (CourseInfoList != null) {
                    initView();
                } else {

                    if (fromCache)
//                        KKDialog.getInstance().showProgressBar(CourseHomeActivity.this, KKDialog.LOADING_FAIL);
                        showNoData();
                }
            }
        });

    }

    private void initView() {
        showData();
//        KKDialog.getInstance().dismiss();
        container.removeAllViews();
        for (int i = 0; i < CourseInfoList.size(); i++) {
            CourseAnimateView view = new CourseAnimateView(this, CourseInfoList.get(i));
            addCourseItem(view.getLayout());
        }
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
        MobclickAgent.onPageStart("MicroCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MicroCourse");
        MobclickAgent.onPause(this);
    }
}
