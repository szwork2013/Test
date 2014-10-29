package com.example.myapp.test11;

import android.animation.LayoutTransition;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.animation.*;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-22.
 */
public class MainActivity extends Activity {

    int x = 0;
    int y = 0;
    int rawx = 0;
    int rawy = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main7);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_MOVE:
//                Log.i("sjyin","event.getX = " + event.getX() +" event.getY = " + event.getY());
//                Log.i("sjyin","event.getRawX = " + event.getRawX() +" event.getRawY = " + event.getRawY());

                x = (int) event.getX();
                y = (int) event.getY();
                rawx = (int) event.getRawX();
                rawy = (int) event.getRawY();
                Log.d("DEBUG", " getX=" + x + " getY=" + y + " getRawX=" + rawx + " getRawY=" + rawy);
                break;
        }
        return false;
    }
}
