package com.kaikeba.activity;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.phone.R;

/**
 * Created by user on 14-6-20.
 */
public class FindPasswordActivity extends BaseActivity implements View.OnClickListener {

    private EditText et_login_email;
    private TextView tv_send;
    private ImageView iv_email_error;
    private TextView tv_text;
    private ImageView iv_back;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_find_psw);
        initView();
    }

    private void initView() {
        tv_text = (TextView) findViewById(R.id.tv_text);
        tv_text.setText("忘记密码");
        iv_back = (ImageView) findViewById(R.id.iv_back);
        et_login_email = (EditText) findViewById(R.id.et_login_email);
        tv_send = (TextView) findViewById(R.id.tv_send);
        iv_email_error = (ImageView) findViewById(R.id.iv_email_error);
        iv_back.setOnClickListener(this);
        tv_send.setOnClickListener(this);
    }

    private void setError(final ImageView v) {
        v.post(new Runnable() {
            @SuppressWarnings("deprecation")
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setVisibility(View.VISIBLE);
                v.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_false));
            }
        });
    }

    private void setTrue(final ImageView v) {
        v.post(new Runnable() {
            @SuppressWarnings("deprecation")
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_true));
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_back:
                this.finish();
                break;
            case R.id.tv_send:
                Toast.makeText(this, "立即发送邮件", Toast.LENGTH_SHORT).show();
                break;
        }
    }
}
