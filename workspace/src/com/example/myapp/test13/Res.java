package com.example.myapp.test13;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import com.example.myapp.R;

public class Res extends Activity implements View.OnTouchListener {
    Button btn = null;
    ImageView control;
    int x = 0;
    int y = 0;
    int rawx = 0;
    int rawy = 0;
    ImageView mouse = null;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        mouse = (ImageView) findViewById(R.id.imageview);
        btn = (Button) findViewById(R.id.button);
        btn.setOnTouchListener(this);
//        mGestureDetector = new GestureDetector(this, new LearnGestureListener());
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        int eventaction = event.getAction();
        switch (eventaction) {
            case MotionEvent.ACTION_DOWN:
                break;
            case MotionEvent.ACTION_MOVE:
                x = (int) event.getX();
                y = (int) event.getY();
                rawx = (int) event.getRawX();
                rawy = (int) event.getRawY();
                Log.d("DEBUG", "onTouchEvent getX=" + x + " getY=" + y + " getRawX=" + rawx + " getRawY=" + rawy);
                break;
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean onTouch(View view, MotionEvent event) {
        int eventaction = event.getAction();
        switch (eventaction) {
            case MotionEvent.ACTION_DOWN:
                break;
            case MotionEvent.ACTION_MOVE:
                x = (int) event.getX();
                y = (int) event.getY();
                rawx = (int) event.getRawX();
                rawy = (int) event.getRawY();
                Log.d("DEBUG", " getX=" + x + " getY=" + y + " getRawX=" + rawx + " getRawY=" + rawy);
                break;
            case MotionEvent.ACTION_UP:
                break;
        }
        return false;
    }
}

