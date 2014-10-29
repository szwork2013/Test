package com.example.myapp.activity.test1;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import com.example.myapp.R;
import com.example.myapp.activity.test1.widget.CustomImageVIew;

/**
 * Created by sjyin on 14-9-24.
 */
public class SystemShare extends Activity {

    private static final String TAG = "SystemShare";
    private CustomImageVIew mImage;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_system_share);
        initView();
        initData();
    }


    private void initView() {
        mImage = (CustomImageVIew)findViewById(R.id.customImageVIew1);
    }

    private void initData() {
        /*Bitmap launcher = BitmapFactory.decodeResource(getResources(), R.drawable.video_default);
        Log.i(TAG,launcher == null ?"bitmap is null":"bitmap isnot null");
        mImage.setBitmap(launcher);*/
    }

    public void click(View view) {
        Intent email = new Intent(android.content.Intent.ACTION_SEND);
        email.setType("text/plain");
// 设置邮件默认地址
// email.putExtra(android.content.Intent.EXTRA_EMAIL, "1");
// 设置邮件默认标题
        email.putExtra(android.content.Intent.EXTRA_SUBJECT,
                "我是邮件的标题");
// 设置要默认发送的内容
        email.putExtra(android.content.Intent.EXTRA_TEXT,
                "我是分享的内容");
// 调用系统的邮件系统
        startActivity(Intent.createChooser(email, "分享方式"));
    }
}
