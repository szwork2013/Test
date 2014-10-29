package com.kaikeba.mitv;

import android.app.Application;
import com.kaikeba.common.network.CreateDbHelper;
import com.umeng.analytics.MobclickAgent;

/**
 * Created by caojing on 14-5-12.
 */
public class MyApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        CreateDbHelper.setContext(this);
        MobclickAgent.openActivityDurationTrack(false);
        MobclickAgent.setDebugMode(false);
    }
}
