package com.kaikeba.mitv;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.Window;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.mitv.utils.PretreatDataCache;
import com.umeng.analytics.MobclickAgent;

public class LoadingActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.loading);

        PretreatDataCache.loadAllData();
        PretreatDataCache.loadData();
        PretreatDataCache.loadCategory();
        new Thread(new LoadingStuffThread()).start();
        DisplayMetrics metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);
        Constants.SCREEN_DENSITY = metrics.density;
        Constants.SCALE_DENSITY = metrics.scaledDensity;
        System.out.println("当前的屏幕：width*height = " + metrics.widthPixels + "*" + metrics.heightPixels);
        NetUtil.getNetType(this);

    }


    private void openMainActivity() {
        Intent intent = null;
        intent = new Intent(this, MainActivity.class);
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

    }

    public class LoadingStuffThread implements Runnable {

        @Override
        public void run() {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            openMainActivity();
        }

    }
}
