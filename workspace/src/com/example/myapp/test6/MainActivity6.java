package com.example.myapp.test6;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import com.example.myapp.R;
import com.lidroid.xutils.BitmapUtils;

/**
 * Created by sjyin on 14-10-9.
 */
public class MainActivity6 extends Activity{

    private ImageView iv_img;
    private BitmapUtils bitmapUtils;
    private String TAG = "MainActivity6";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main6);
        iv_img = (ImageView) findViewById(R.id.iv_img);
        bitmapUtils = BitmapHelp.getBitmapUtils(this);
    }

    public void click(View view){
        Log.i(TAG,"click");
        bitmapUtils.display(iv_img,"http://www.kaikeba.com/uploads/course_image/link/242/normal______________-___.png");
    }
}
