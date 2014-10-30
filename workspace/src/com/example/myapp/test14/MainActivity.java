package com.example.myapp.test14;

import android.app.Activity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.View;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-28.
 */
public class MainActivity extends Activity {

    private MyViewGroup my_view;
    public static int screenWidth;
    public static int screenHeight;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main14);
        my_view = (MyViewGroup) findViewById(R.id.my_view);

        DisplayMetrics metric = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metric);
        screenWidth = metric.widthPixels;
        screenHeight = metric.heightPixels;
    }

    public void scrollToLeft(View v){
        my_view.startMove();
    }

    public void stop(View v){
        my_view.stopMove();
    }
}
