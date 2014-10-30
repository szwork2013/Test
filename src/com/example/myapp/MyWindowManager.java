package com.example.myapp;

import android.app.ActivityManager;
import android.content.Context;
import android.util.Log;
import android.view.Gravity;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.LinearLayout;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

/**
 * Created by sjyin on 14-9-1.
 */
public class MyWindowManager {

    private static final String TAG = "MyWindowManager";
    private static LinearLayout smallWindow;
    private static LinearLayout largeWindow;
    private static ActivityManager mActivityManager;

    private static LayoutParams largeLayoutParams;
    private static LayoutParams smallLayoutParams;

    public static boolean isWindowShowing() {
        return false;
    }

    public static void createSmallWindow(Context context) {
        WindowManager windowManager = getWindowManager(context);
        int screenWidth = windowManager.getDefaultDisplay().getWidth();
        int screenHeight = windowManager.getDefaultDisplay().getHeight();

        if(smallWindow == null){
            smallWindow = new FloatWindowSmallView(context);
            if(smallLayoutParams != null){
                smallLayoutParams = new LayoutParams();
                smallLayoutParams.x = screenWidth/2 - FloatWindowSmallView.viewWidth /2;
                smallLayoutParams.y = screenHeight/2 - FloatWindowSmallView.viewHeight/2;
                smallLayoutParams.gravity = Gravity.LEFT | Gravity.TOP;
                smallLayoutParams.width = FloatWindowSmallView.viewWidth;
                smallLayoutParams.height = FloatWindowSmallView.viewHeight;
            }
        }
        windowManager.addView(smallWindow,smallLayoutParams);
    }

    private static WindowManager getWindowManager(Context context) {
        return (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    }

    public static String getUsePercentValue(Context context) {
        String dir = "/proc/meminfo";
        StringBuffer sb = new StringBuffer(1024);
        String line;
        try {
            FileReader fileReader = new FileReader(dir);
            BufferedReader br = new BufferedReader(fileReader,Integer.MAX_VALUE);
            String memoryLine = null;
            while((line=br.readLine()) != null){
                if(memoryLine == null){
                    memoryLine = line;
                }
                sb.append(line);
                sb.append("***");
            }
            br.close();
            Log.i(TAG,sb.toString());
            String subMemoryLine = memoryLine.substring(memoryLine.indexOf("MemTotal"));
            long totalMemorySize = Integer.parseInt(subMemoryLine.replaceAll("\\D",""));
            long availableSize = getAvailabeMemory(context)/1024;
            int percent = (int) ((totalMemorySize - availableSize)/totalMemorySize);
            return percent +"%";
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "悬浮窗";
    }

    private static long getAvailabeMemory(Context context) {
        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        getActivityManager(context).getMemoryInfo(mi);
        return mi.availMem;
    }

    private static ActivityManager getActivityManager(Context context) {
        if(mActivityManager == null){
            mActivityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        }
        return mActivityManager;
    }

    public static void createBigWindow(Context context) {
        WindowManager windowManager = getWindowManager(context);
        int screenWidth = windowManager.getDefaultDisplay().getWidth();
        int screenHeight = windowManager.getDefaultDisplay().getHeight();
        if(largeWindow != null){
            largeWindow = new FloatWindowBigView(context);
            if(largeLayoutParams == null){
                largeLayoutParams = new WindowManager.LayoutParams();
                largeLayoutParams.x = screenWidth /2 - FloatWindowBigView.viewWidth/2;
                largeLayoutParams.y = screenHeight/2 - FloatWindowBigView.viewHeight/2;
                largeLayoutParams.gravity = Gravity.LEFT|Gravity.TOP;
                largeLayoutParams.width =FloatWindowBigView.viewWidth;
                largeLayoutParams.height = FloatWindowBigView.viewHeight;
            }
        }
        windowManager.addView(largeWindow,largeLayoutParams);
    }

    public static void removeSmallWindow(Context context) {
        if(smallWindow != null){
            WindowManager windowManager = getWindowManager(context);
            windowManager.removeView(smallWindow);
            smallWindow = null;
        }
    }

    public static void removeBigWindow(Context context) {
        if (largeWindow != null) {
            WindowManager windowManager = getWindowManager(context);
            windowManager.removeView(largeWindow);
            largeWindow = null;
        }
    }
}
