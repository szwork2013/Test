package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.Window;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.common.api.API;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.NetBroadcastReceiver;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.loaddata.LoadMyData;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

public class LoadingActivity extends Activity {

    // private ArrayList<PromoInfo> courseInfoList;
    private Context mContext;
    private NetBroadcastReceiver mNetBroadcastReceiver;
    private SharedPreferences appPrefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.loading);
        mContext = this;
        //判断用户是否第一次登陆kkb，
        appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        new Thread(new LoadingStuffThread()).start();
        DisplayMetrics metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);
//        Constants.SCREEN_WIDTH = metrics.widthPixels;
//        Constants.SCREEN_HEIGHT = metrics.heightPixels;
        Constants.SCREEN_DENSITY = metrics.density;
        Constants.SCALE_DENSITY = metrics.scaledDensity;
        System.out.println("当前的屏幕：width*height = " + metrics.widthPixels + "*" + metrics.heightPixels);
        NetUtil.getNetType(this);
        PretreatDataCache.loadCourses(LoadingActivity.this);
        LoadMyData.loadCollect(mContext);
        LoadMyData.loadMicroCourse(mContext);

        //注册网络监听
        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mNetBroadcastReceiver = NetBroadcastReceiver.getInstance();
        registerReceiver(mNetBroadcastReceiver, filter);
    }


    private void openMainActivity() {
        Intent intent = null;

        boolean isFirstOpen = appPrefs.getBoolean(ContextUtil.isFirstLead, true);
        if (isFirstOpen) {
            intent = new Intent(this, LeadViewActivity.class);
        } else {
            if (!API.getAPI().alreadySignin()) {
                intent = new Intent(this, AllCourseActivity.class);
            } else {
                intent = new Intent(this, TabCourseActivity.class);
            }
        }
        startActivity(intent);
        finish();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("loading"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("loading");
        MobclickAgent.onPause(this);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
        }
        return false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
    }

    public class LoadingStuffThread implements Runnable {

        @Override
        public void run() {
            API.getAPI().readUserInfo4SP2Object();
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            openMainActivity();
        }

    }
}
