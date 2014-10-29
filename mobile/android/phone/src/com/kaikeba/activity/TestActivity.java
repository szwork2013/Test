package com.kaikeba.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import com.kaikeba.phone.R;

/**
 * Created by cwang on 14-7-9.
 */
public class TestActivity extends Activity {
    private TextView btn_login;
    private TextView btn_register;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test);
        btn_login = (TextView) findViewById(R.id.common_login);
        btn_register = (TextView) findViewById(R.id.common_register);
        setOnListener();
    }

    public void setOnListener() {
        btn_login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(TestActivity.this, LoginActivity2.class);
                startActivity(intent);
            }
        });
        btn_register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(TestActivity.this, RegistActivity.class);
                startActivity(intent);
            }
        });
    }

}
