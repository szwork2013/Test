package com.example.myapp.screen_fit;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.WindowManager;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-28.
 */
public class MainActivity extends Activity{
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main7);
        WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        int screenWidth = wm.getDefaultDisplay().getWidth();
        int screenHeight = wm.getDefaultDisplay().getHeight();
        System.out.println("screen width = " + screenWidth+"  screen height = " + screenHeight);

        Configuration config = getResources().getConfiguration();
        int  smallestScreenWidth = config.smallestScreenWidthDp;
        System.out.println("smallestScreenWidth = " + smallestScreenWidth);

    }
}
