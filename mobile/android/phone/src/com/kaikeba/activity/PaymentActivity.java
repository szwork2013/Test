package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

public class PaymentActivity extends BaseActivity {

    private WebView payment_webview;
    private String url;
    private ImageView btn_back_normal;
    private OnClickListener backListener = new OnClickListener() {

        public void onClick(View v) {
            // TODO Auto-generated method stub
            if (v == btn_back_normal) {
//				payment_webview.goBack();
//				FragmentTransaction ft = getFragmentManager().beginTransaction();
//				ft.remove(PaymentFragment.this);
//				((CourseInfoActivity)getActivity()).getCourse_content_container().setVisibility(View.VISIBLE);
//				ft.commit();
                finish();
            }
        }
    };
    private RelativeLayout viewLoading;
    private TextView tv_title_name;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.payment);
        tv_title_name = (TextView) findViewById(R.id.tv_title_name);
        if (getIntent().getStringExtra("Title") != null && getIntent().getStringExtra("Title").equals("关于")) {
            tv_title_name.setText("关于我们");
        } else {
            tv_title_name.setText("支付");
        }
        viewLoading = (RelativeLayout) findViewById(R.id.view_loading);
        btn_back_normal = (ImageView) findViewById(R.id.btn_back_normal);
        btn_back_normal.setOnClickListener(backListener);
        payment_webview = (WebView) findViewById(R.id.payment_webview);
        payment_webview.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                super.onProgressChanged(view, newProgress);
                if (newProgress == 100) {
                    viewLoading.setVisibility(View.GONE);
                }
            }
        });
        url = getIntent().getStringExtra("url");
        WebSettings webSettings = payment_webview.getSettings();
        webSettings.setJavaScriptEnabled(true);
//		payment_webview.requestFocusFromTouch();
//		payment_webview.requestFocus();
        payment_webview.setScrollBarStyle(0);

        payment_webview.loadUrl(url);

        payment_webview.setWebViewClient(new WebViewClient() {
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }
        });
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("AboutUs"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("AboutUs");
        MobclickAgent.onPause(this);
    }
}
