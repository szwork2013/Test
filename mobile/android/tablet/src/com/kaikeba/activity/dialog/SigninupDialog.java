package com.kaikeba.activity.dialog;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;


public class SigninupDialog extends Activity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dlg_signinup);
        TextView tvSignIn = (TextView) findViewById(R.id.txtSignin);
        TextView tvSignUp = (TextView) findViewById(R.id.txtSignup);
        tvSignUp.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
//                hide();
                if (!Constants.NET_IS_SUCCESS) {
                    Toast.makeText(SigninupDialog.this, "网络未连接", Toast.LENGTH_SHORT).show();
                }
                Intent intent = new Intent(SigninupDialog.this, SignupDialog.class);
                startActivity(intent);
                finish();
            }
        });


        tvSignIn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
//                hide();
                if (!Constants.NET_IS_SUCCESS) {
                    Toast.makeText(SigninupDialog.this, "网络未连接", Toast.LENGTH_SHORT).show();
                }
                Intent intent = new Intent(SigninupDialog.this, WebViewDialog.class);
//                if (Constants.LOGIN_FROM == Constants.FROM_PAY) {
//                	intent.putExtra("course", getIntent().getSerializableExtra("course"));
//                }
                startActivity(intent);
                finish();
            }
        });
    }

}
