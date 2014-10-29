package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.view.SigninWebViewClient;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.api.UsersAPI;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.util.HashMap;


public class LoginActivity extends Activity {

    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private TextView tv_signup;
    private ImageView iv_login_logo;
    private ImageView iv_login_back;
    private WebView webView4Signin;
    private SigninWebViewClient client;

    private HashMap<String, String> actionmap;
    private Handler oAuthHandler = new Handler() {

        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            super.handleMessage(msg);
            CookieManager cookieManager = CookieManager.getInstance();
            final String loginCookie = cookieManager.getCookie(ConfigLoader.getLoader().getCanvas().getLoginURL());
            final String code = msg.getData().getString("code");
            view_loading.setVisibility(View.VISIBLE);
            if (code != null) {
                //TODO
                new Thread(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        HashMap<String, String> map = null;

                        try {
                            map = UsersAPI.exchangeToken(code);
                        } catch (Exception e) {
                            // TODO Auto-generated catch block
                            oAuthHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    // TODO Auto-generated method stub
                                    actionmap.put("signin_failed", "true");
                                    Toast.makeText(LoginActivity.this, "登录失败！", Toast.LENGTH_LONG).show();
                                    showNoData();
                                    finish();
                                }
                            });
                            e.printStackTrace();
                        }
                        String token = map.get(API.JS_TOKEN);
                        User user = new User();
                        API.getAPI().setUserObject(user);
                        API.getAPI().getUserObject().setAccessToken(token);
                        API.getAPI().getUserObject().setCookie(loginCookie);
                        Log.d("OAuth", code + " --> " + token);

                        try {
                            user = UsersAPI.getUserProfile(map.get(API.JS_USER_ID));
                        } catch (DibitsExceptionC e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                        user.setAccessToken(token);
                        user.setCookie(loginCookie);
                        API.getAPI().writeUserInfo2SP(user, null);
                        try {
                            LocalStorage.sharedInstance().setIds(CoursesAPI.getMyCoursesId(false));
                        } catch (DibitsExceptionC e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                        actionmap.put("user_id", user.getId() + "");
                        actionmap.put("signin_succeed", "true");
                        MobclickAgent.onEvent(LoginActivity.this, "signin", actionmap);//友盟统计登陆发生事件

                        oAuthHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                finish();
                                // TODO Auto-generated method stub
                                Toast.makeText(LoginActivity.this, "登录成功！", Toast.LENGTH_LONG).show();
                                UploadData.getInstance().uploadPushInfo(LoginActivity.this);
                                showData();
                                if (Constants.LOGIN_FROM == Constants.FROM_ALLCOURSE) {
                                    Intent intent2 = new Intent(LoginActivity.this, TabCourseActivity.class);
                                    intent2.putExtra("isSuccess", true);
                                    intent2.putExtra("isFirst", true);
                                    startActivity(intent2);
                                    AllCourseActivity.getAllCourseActivity().finish();
                                    finish();
                                }

                                if (Constants.LOGIN_FROM == Constants.FROM_OPENCOURSE) {
                                    CourseModel course = (CourseModel) getIntent().getSerializableExtra(ContextUtil.CATEGORY_COURSE);
                                    Constants.DOWNLOAD_VIEW = 1;
                                    Intent mIntent = new Intent();
                                    mIntent.putExtra(ContextUtil.CATEGORY_COURSE, course);
                                    mIntent.putExtra(Constants.ACTIVITY_NAME_KEY, Constants.MY_COURSE);
                                    mIntent.setClass(LoginActivity.this, OpenCourseActivity.class);
                                    startActivity(mIntent);
                                }

                            }
                        });
                    }
                }).start();
            }
        }
    };

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dlg_webview);
        actionmap = new HashMap<String, String>();
        CookieSyncManager.createInstance(LoginActivity.this);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.removeAllCookie();
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        webView4Signin = (WebView) findViewById(R.id.webView);
        WebSettings webSettings = webView4Signin.getSettings();
        webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        webSettings.setSavePassword(false);
        webSettings.setSaveFormData(false);
        webSettings.setJavaScriptEnabled(true);
        loadData();

        tv_signup = (TextView) findViewById(R.id.tv_signup);
        tv_signup.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                actionmap.put("goto_signup", "");
                Intent intent = new Intent(LoginActivity.this, RegistActivity.class);
                if (Constants.LOGIN_FROM == Constants.FROM_PAY)
                    intent.putExtra(ContextUtil.CATEGORY_COURSE, getIntent().getSerializableExtra(ContextUtil.CATEGORY_COURSE));
                startActivity(intent);
                finish();
            }
        });
        iv_login_logo = (ImageView) findViewById(R.id.iv_login_logo);
        iv_login_back = (ImageView) findViewById(R.id.iv_login_back);
        iv_login_back.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                actionmap.put("goback", "");
                finish();
            }
        });

        if (API.COUNT == 1) {
            iv_login_back.setVisibility(View.GONE);
            iv_login_logo.setVisibility(View.VISIBLE);
        } else {
            iv_login_back.setVisibility(View.VISIBLE);
            iv_login_logo.setVisibility(View.GONE);
            actionmap.put("enter", getIntent().getStringExtra(Constants.ACTIVITY_NAME_KEY));
        }

        loading_fail.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(LoginActivity.this)) {
                    KKDialog.getInstance().showNoNetToast(LoginActivity.this);
                } else {
                    showLoading();
                    loadData();
                }
            }
        });
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("login_opened"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

//    private void setCookie() {
//    	CookieSyncManager.createInstance(getApplicationContext());
//        CookieManager cookieManager = CookieManager.getInstance();
//        cookieManager.removeSessionCookie();
//        
//        cookieManager.setAcceptCookie(true);  
//        cookieManager.setCookie("http://learn.kaikeba.com", "OAuth");//cookies是在HttpClient中获得的cookie  
//        CookieSyncManager.getInstance().sync(); 
//    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("login_opened");
        MobclickAgent.onPause(this);
    }

    private void loadData() {
        webView4Signin.clearCache(true);
        webView4Signin.requestFocus();
        if (client == null) {
            client = new SigninWebViewClient(oAuthHandler, view_loading, view_loading_fail);
        }
        webView4Signin.setWebViewClient(client);
        webView4Signin.loadUrl(ConfigLoader.getLoader().getCanvas().getLoginURL());
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }
}
