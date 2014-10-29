package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.VideoURLAPI;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.FileSizeUtil;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

public class LoadingActivity extends Activity {

    private Handler mHandler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1:
                    Toast.makeText(LoadingActivity.this, "请检查您的网络",
                            Toast.LENGTH_SHORT).show();
                    break;
                case 2:
                    Toast.makeText(LoadingActivity.this, "您的设备不支持此程序",
                            Toast.LENGTH_SHORT).show();
                    break;
                default:
                    break;
            }
        }

        ;
    };

    // private ArrayList<PromoInfo> courseInfoList;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.loading);
        // setCookie();
        if (!isPad()) {
            mHandler.sendEmptyMessage(2);
            finish();
        } else {
            new Thread(new LoadingStuffThread()).start();
        }
    }

    private void openMainActivity() {
        Intent intent = new Intent(this, MainActivity.class);
        // intent.putExtra("promoInfo", courseInfoList);
        startActivity(intent);
        finish();
    }

    /**
     * 判断是否为平板
     *
     * @return
     */
    @SuppressWarnings("deprecation")
    private boolean isPad() {
        WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        // 屏幕宽度
        float screenWidth = display.getWidth();
        Constants.window_width = screenWidth;
        // 屏幕高度
        @SuppressWarnings({"unused"})
        float screenHeight = display.getHeight();
        DisplayMetrics dm = new DisplayMetrics();
        display.getMetrics(dm);
        double x = Math.pow(dm.widthPixels / dm.xdpi, 2);
        double y = Math.pow(dm.heightPixels / dm.ydpi, 2);
        // 屏幕尺寸
        double screenInches = Math.sqrt(x + y);
        // 大于6尺寸则为Pad
        if (screenInches >= 6.0) {
            return true;
        }
        return false;
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
        }
        return false;
    }

    public class LoadingStuffThread implements Runnable {

        @Override
        public void run() {
            VideoURLAPI.getVideoURL("0_jmu0dpto");
            API.getAPI().readUserInfo4SP2Object();
            ImgLoaderUtil.getLoader();
            FileSizeUtil.getSdcardInfo();
            FileSizeUtil.getUsedSpaceInfo();
            try {
                Thread.sleep(1500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            openMainActivity();
        }

    }

}
