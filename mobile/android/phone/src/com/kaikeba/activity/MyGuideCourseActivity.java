package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.activity.fragment.MyGuideCourseFragment;
import com.kaikeba.common.BaseClass.BaseFragmentActivity;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by sjyin on 14-8-4.
 */
public class MyGuideCourseActivity extends BaseFragmentActivity implements View.OnClickListener {

    private ArrayList<CourseModel> courses;
    private ImageView back_normal;
    private TextView tv_course_top_name;
    private FragmentManager fm;

    private MyGuideCourseFragment fragment1;
    private MyGuideCourseFragment fragment2;
    private MyGuideCourseFragment fragment3;

    private TextView tv_working;
    private TextView tv_worked;
    private TextView tv_go_work;

    private List<TextView> tvs;

    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private RelativeLayout view_loading;
    private Context mContext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab_guide_course);
        mContext = this;
        initView();
        initData(true);
        initData(false);
    }

    private void initData(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        String url = HttpUrlUtil.INSTRUCTIVE_COURSES;//"https://api.kaikeba.com/v1/instructive_courses";
        Type type = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    courses = (ArrayList<CourseModel>) data;
                    if (fromCache) {
                        showData();
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

        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initData(true);
            }
        });

        tvs = new ArrayList<TextView>();
        back_normal = (ImageView) findViewById(R.id.iv_back);
        tv_course_top_name = (TextView) findViewById(R.id.tv_text);
        tv_course_top_name.setText(getResources().getString(R.string.my_guide_course));
        back_normal.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                appointSkip();
            }
        });

        tv_working = (TextView) findViewById(R.id.tv_working);
        tv_worked = (TextView) findViewById(R.id.tv_worked);
        tv_go_work = (TextView) findViewById(R.id.tv_go_work);
        tv_worked.setOnClickListener(this);
        tv_working.setOnClickListener(this);
        tv_go_work.setOnClickListener(this);
        tvs.add(tv_working);
        tvs.add(tv_worked);
        tvs.add(tv_go_work);
        fm = getSupportFragmentManager();

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
        tv_working.performClick();
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void setWorkingFrag() {
        FragmentTransaction ft1 = fm.beginTransaction();
        Bundle bundle = new Bundle();
        bundle.putSerializable("courses", courses);
        bundle.putInt("flag", 11);
        if (fragment1 == null) {
            fragment1 = new MyGuideCourseFragment();
            fragment1.setArguments(bundle);
        } else {
            fragment1.setArguments(bundle);
        }
        ft1.replace(R.id.container, fragment1);
        ft1.commit();
    }

    private void setWorkedFrag() {
        FragmentTransaction ft1 = fm.beginTransaction();
        Bundle bundle = new Bundle();
        bundle.putSerializable("courses", courses);
        bundle.putInt("flag", 22);
        if (fragment2 == null) {
            fragment2 = new MyGuideCourseFragment();
            fragment2.setArguments(bundle);
        } else {
            fragment2.setArguments(bundle);
        }
        ft1.replace(R.id.container, fragment2);
        ft1.commit();
    }

    private void setGoWorkFrag() {
        FragmentTransaction ft1 = fm.beginTransaction();
        Bundle bundle = new Bundle();
        bundle.putSerializable("courses", courses);
        bundle.putInt("flag", 33);
        if (fragment3 == null) {
            fragment3 = new MyGuideCourseFragment();
            fragment3.setArguments(bundle);
        } else {
            fragment3.setArguments(bundle);
        }
        ft1.replace(R.id.container, fragment3);
        ft1.commit();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tv_working:
                setWorkingFrag();
                resetFocuse(tv_working);
                break;
            case R.id.tv_worked:
                setWorkedFrag();
                resetFocuse(tv_worked);
                break;
            case R.id.tv_go_work:
                setGoWorkFrag();
                resetFocuse(tv_go_work);
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
        MobclickAgent.onPageStart("MyGuideCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MyGuideCourse");
        MobclickAgent.onPause(this);
    }
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }
    public void appointSkip() {
        Intent intent = new Intent(MyGuideCourseActivity.this, TabCourseActivity.class);
        intent.putExtra("TabTag", "UserCenter");
        intent.putExtra("TabNum", 3);
        startActivity(intent);
        finish();
    }

}
