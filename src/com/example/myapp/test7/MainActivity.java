package com.example.myapp.test7;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-11.
 */
public class MainActivity extends Activity {

    private static final String TAG = "MainActivity";
    private Button btn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main7);
        btn = (Button) findViewById(R.id.btn);
    }


    public void click(View view){
        Intent intent = new Intent(this,MyCertificate.class);
        startActivity(intent);
    }
}
