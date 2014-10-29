package com.example.myapp;

import android.app.ActivityManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by sjyin on 14-9-1.
 */
public class FloatWindowService extends Service{

    private static final String TAG = "FloatWindowService";
    private Timer timer;
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    };

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG,"onStartCommand run");

        if(timer == null){
            timer = new Timer();
            timer.scheduleAtFixedRate(new RefreshTask(),0,200);
        }

        return super.onStartCommand(intent, flags, startId);
    }

    class RefreshTask extends TimerTask{

        @Override
        public void run() {
            if(isHome() && !MyWindowManager.isWindowShowing()){
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        MyWindowManager.createSmallWindow(getApplicationContext());
                    }
                });
            }
        }
    }

    private boolean isHome() {
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningTaskInfo> rti = activityManager.getRunningTasks(1);
        return getHomes().contains(rti.get(0).topActivity.getPackageName());
    }

    private List<String> getHomes() {
        List<String> names = new ArrayList<String>();
        PackageManager packageManager = getPackageManager();
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        int flags = PackageManager.MATCH_DEFAULT_ONLY;
        List<ResolveInfo> resolveInfos = packageManager.queryIntentActivities(intent, flags);
        for(ResolveInfo ri : resolveInfos){
            names.add(ri.activityInfo.name);
        }
        return names;
    }

}
