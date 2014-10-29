package com.kaikeba.common.util;

import android.app.Activity;
import android.app.Application;

import java.util.LinkedList;
import java.util.List;

public class MyApplication extends Application {

    private static MyApplication instance;
    private List<Activity> activityList = new LinkedList<Activity>();

    private MyApplication() {

    }

    public static synchronized MyApplication getInstance() {
        if (instance == null) {
            instance = new MyApplication();
        }
        return instance;
    }

    public void addActivity(Activity activity) {
        activityList.add(activity);
    }

    public void exit() {
        for (Activity a : activityList) {
            a.finish();
        }
        System.exit(0);
    }

    public List<Activity> getActivityList() {
        return activityList;
    }

    public void removeActivity(Activity activity) {
        activityList.remove(activity);
    }
}
