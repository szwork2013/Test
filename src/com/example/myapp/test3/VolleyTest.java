package com.example.myapp.test3;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-9-27.
 */
public class VolleyTest extends Activity{

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button btn = (Button) findViewById(R.id.start_float_window);
        btn.setText("volley requset www.baidu.com");
    }

    public void click(View view){
        requst();
    }

    public void requst(){
        RequestQueue mQueue = Volley.newRequestQueue(this);
        StringRequest stringRequest = new StringRequest("http://www.baidu.com",
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Log.d("TAG", response);
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("TAG", error.getMessage(), error);
            }
        });
        mQueue.add(stringRequest);
        mQueue.start();
    }
}
