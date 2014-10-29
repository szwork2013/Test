package com.kaikeba.activity.dialog;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.CookieManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.activity.view.SigninWebViewClient;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.api.UsersAPI;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import org.json.JSONException;

import java.util.HashMap;

public class WebViewDialog extends Activity {

    private Context selfContext;
    private View view_loading;
    private View load_progressBar;
    private Handler oAuthHandler = new Handler() {

        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            super.handleMessage(msg);
            CookieManager cookieManager = CookieManager.getInstance();
            final String loginCookie = cookieManager.getCookie(ConfigLoader
                    .getLoader().getCanvas().getLoginURL());
            final String code = msg.getData().getString("code");
            if (code != null) {
                load_progressBar.setVisibility(View.VISIBLE);
                Toast.makeText(selfContext, "正在登录", Toast.LENGTH_SHORT).show();
                finish();
                new Thread() {
                    public void run() {
                        try {
                            HashMap<String, String> map = UsersAPI
                                    .exchangeToken(code);
                            String token = map.get(API.JS_TOKEN);
                            User user = new User();
                            API.getAPI().setUserObject(user);
                            API.getAPI().getUserObject().setAccessToken(token);
                            API.getAPI().getUserObject().setCookie(loginCookie);
                            Log.d("OAuth", code + " --> " + token);

                            user = UsersAPI.getUserProfile(map
                                    .get(API.JS_USER_ID));
                            user.setAccessToken(token);
                            user.setCookie(loginCookie);
                            API.getAPI().writeUserInfo2SP(user, null);
                            MainActivity.getMainActivity()
                                    .setIds(CoursesAPI.getMyCoursesId(false));
                            MainActivity.getMainActivity().getDownloadManager().refreshDownloadInfo();
                            post(new Runnable() {
                                public void run() {
                                    User _user = API.getAPI().getUserObject();
                                    MainActivity
                                            .getMainActivity()
                                            .getMainNavFragment()
                                            .changeUserInMainNav(
                                                    _user.getUserName(),
                                                    _user.getAvatarUrl());

                                    MainActivity.getMainActivity()
                                            .getSettingFragment()
                                            .setSignin(true);

                                    CookieManager cm = CookieManager.getInstance();
                                    cm.setCookie("login", "login");

                                    MainActivity.getMainActivity().showActiveView();
                                    Toast.makeText(selfContext, "登录成功", Toast.LENGTH_LONG).show();
                                    if (Constants.LOGIN_FROM == Constants.FROM_PAY) {
                                        Course course = (Course) getIntent().getSerializableExtra("course");
                                        Constants.DOWNLOAD_VIEW = 1;
                                        if (course.getStartDate().equals("2020-01-01")) {
                                            Toast.makeText(WebViewDialog.this, "此课程为精彩预告，敬请期待！", Toast.LENGTH_SHORT).show();
                                            return;
                                        }
                                        Intent mIntent = new Intent();
                                        mIntent.putExtra("course", course);
                                        mIntent.setClass(WebViewDialog.this, ModuleActivity.class);
                                        startActivity(mIntent);
                                    }
                                }

                                ;
                            });
                        } catch (DibitsExceptionC e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                    }

                    ;
                }.start();
            }
        }
    };

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dlg_webview);
        view_loading = findViewById(R.id.view_loading);
        load_progressBar = findViewById(R.id.load_progressBar);
        selfContext = this;
        TextView tv_signin = (TextView) findViewById(R.id.tv_signin);
        tv_signin.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                Intent intent = new Intent(WebViewDialog.this,
                        SignupDialog.class);
                startActivity(intent);
                finish();
            }
        });
        WebView webView4Signin = (WebView) findViewById(R.id.webView);
        WebSettings webSettings = webView4Signin.getSettings();
        webSettings.setSavePassword(false);
        webSettings.setSaveFormData(false);
        webSettings.setJavaScriptEnabled(true);
        webSettings.setBuiltInZoomControls(true);
        webView4Signin.clearCache(true);
        webView4Signin.requestFocus();
        SigninWebViewClient client = new SigninWebViewClient(oAuthHandler);
        webView4Signin.setWebViewClient(client);
        webView4Signin.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                super.onProgressChanged(view, newProgress);
                if (newProgress == 100) {
                    view_loading.setVisibility(View.GONE);
                }
            }
        });

        if (getIntent().getExtras() == null || getIntent().getExtras().getString("URL") == null) {
            webView4Signin.loadUrl(ConfigLoader.getLoader().getCanvas()
                    .getLoginURL());
        }
        // else if ("payment".equals(getIntent().getStringExtra("login")))
        // {
        // webView4Signin.loadUrl(ConfigLoader.getLoader().getCanvas().getLoginURL());
        // }
        else {
            String url = getIntent().getExtras().getString("URL");
            webView4Signin.loadUrl(url);
            tv_signin.setVisibility(View.INVISIBLE);
        }
        // tv_signin.setVisibility(View.GONE);
    }
}
