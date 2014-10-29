package com.kaikeba.activity;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.api.LoginAPI;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.loaddata.LoadMyData;
import com.kaikeba.phone.R;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.utils.HttpUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.controller.listener.SocializeListeners;
import com.umeng.socialize.exception.SocializeException;
import com.umeng.socialize.sso.UMSsoHandler;
import com.umeng.socialize.utils.OauthHelper;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;


/**
 * Created by user on 14-6-20.
 */
public class LoginActivity2 extends BaseActivity implements View.OnClickListener {

    Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
//                    load_progressBar.setVisibility(View.GONE);
                    UploadData.getInstance().uploadPushInfo(LoginActivity2.this);
                    KKDialog.getInstance().dismiss();
                    LoadMyData.loadCollect(LoginActivity2.this);
                    LoadMyData.loadMicroCourse(LoginActivity2.this);
                    LoadMyData.loadMyGuideCourse(LoginActivity2.this);
                    LoadMyData.loadMyOpenCourse(LoginActivity2.this);
                    LoadMyData.loadMyCertificate(LoginActivity2.this);
                    Toast.makeText(LoginActivity2.this, "登录成功！", Toast.LENGTH_LONG).show();
                    finish();
                    if (AllCourseActivity.getAllCourseActivity() != null) {
                        AllCourseActivity.getAllCourseActivity().finish();
                    }
                    if (Constants.LOGIN_FROM == Constants.FROM_ALLCOURSE) {
                        Intent intent2 = new Intent(LoginActivity2.this, TabCourseActivity.class);
                        intent2.putExtra("isSuccess", true);
                        intent2.putExtra("isFirst", true);
                        startActivity(intent2);
                    }
//                    if (Constants.LOGIN_FROM == Constants.FROM_OPENCOURSE) {
//                        Intent mIntent = new Intent();
//                        mIntent.setClass(LoginActivity2.this, OpenCourseActivity.class);
//                        startActivity(mIntent);
//                    }
//                    if (Constants.LOGIN_FROM == Constants.FROM_GUIDECOURSE) {
//                        Intent mIntent = new Intent();
//                        mIntent.setClass(LoginActivity2.this, GuideCourseAcitvity.class);
//                        startActivity(mIntent);
//                    }
                    break;
                case 2:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    Toast.makeText(LoginActivity2.this, "登录失败！", Toast.LENGTH_LONG).show();
                    tv_errorinfo.setText("邮箱密码不匹配！");
                    break;
                case 0:
                    KKDialog.getInstance().dismiss();
                    load_progressBar.setVisibility(View.GONE);
                    tv_errorinfo.setText(((DibitsExceptionC) msg.obj).getMessageX());
                    break;
            }
        }
    };
    private ImageView iv_back;
    private TextView tv_text;
    private EditText et_login_email;
    private EditText et_login_password;
    private TextView tv_login;
    private TextView tv_forget_psw;
    private TextView iv_go_regist;
    private ImageView iv_email_error;
    private ImageView iv_password_error;
    private TextView tv_errorinfo;
    private ProgressBar load_progressBar;
    /**
     * ************第三方注册*******************
     */
    private ImageView signup_sina;
    private ImageView signup_qq;
    private ImageView signup_renren;
    private LinearLayout signup_logos;
    private Activity context;
    private MIUiListener qqListener;
    private Tencent mTencent;
    private UMSocialService mloginController;
    private String TAG = "LoginActivity2";
    private View.OnFocusChangeListener emailFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                try {
                    checkEmailInput(((EditText) v).getText().toString());
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                }
            } else {
                int i = 0;
            }
        }
    };
    private View.OnFocusChangeListener pwdFocusListener = new View.OnFocusChangeListener() {

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (!hasFocus) {//失去焦点
                try {
                    checkPasswordInput(((EditText) v).getText().toString());
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                }
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        context = this;
        initView();
        initData();
        initActivity();
    }

    private void initActivity() {
        tv_text.setText("登录");
    }

    private void initView() {
        iv_back = (ImageView) findViewById(R.id.iv_back);
        tv_text = (TextView) findViewById(R.id.tv_text);
        et_login_email = (EditText) findViewById(R.id.et_login_email);
        et_login_password = (EditText) findViewById(R.id.et_login_password);
        tv_login = (TextView) findViewById(R.id.tv_login);
        tv_forget_psw = (TextView) findViewById(R.id.tv_forget_psw);
        iv_go_regist = (TextView) findViewById(R.id.iv_go_regist);
        iv_go_regist.setVisibility(View.VISIBLE);
        iv_email_error = (ImageView) findViewById(R.id.iv_email_error);
        iv_password_error = (ImageView) findViewById(R.id.iv_password_error);
        tv_errorinfo = (TextView) findViewById(R.id.tv_errorinfo);
        load_progressBar = (ProgressBar) findViewById(R.id.load_progressBar);
        iv_back.setOnClickListener(this);
        tv_login.setOnClickListener(this);
        iv_go_regist.setOnClickListener(this);
        tv_forget_psw.setOnClickListener(this);
        et_login_email.setOnFocusChangeListener(emailFocusListener);
        et_login_password.setOnFocusChangeListener(pwdFocusListener);
        LognupClickListener listener = new LognupClickListener();
        signup_logos = (LinearLayout) findViewById(R.id.ll_signup_logo);
        signup_sina = (ImageView) findViewById(R.id.signup_sina);
        signup_qq = (ImageView) findViewById(R.id.signup_qq);
        signup_renren = (ImageView) findViewById(R.id.signup_renren);
        signup_sina.setOnClickListener(listener);
        signup_qq.setOnClickListener(listener);
        signup_renren.setOnClickListener(listener);

    }

    private void printError(ImageView v, String msg) throws DibitsExceptionC {
        setError(v);
        throw new DibitsExceptionC(DEC.Syntax.USER_EMAIL, msg);
    }

    protected void checkEmailInput(String email) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserEmailErrorInfo(email);
        switch (checkErrorInput) {
            case EMAIL_ERROR_EMPTY:
                printError(iv_email_error, "邮箱不能为空！");
                break;
            case EMAIL_ERROR_ILLEGAL:
                printError(iv_email_error, "邮箱格式错误，请输入正确的邮箱！");
                break;
            case SUCCESS:
                setTrue(iv_email_error);
                tv_errorinfo.setText("");
                break;
            default:
                break;
        }
    }

    protected void checkPasswordInput(String password) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserPasswordErrorInfo(password);
        switch (checkErrorInput) {
            case PASSWORD_ERROR_EMPTY:
                printError(iv_password_error, "密码不能为空！");
                break;
            case PASSWORD_ERROR_LENGTH:
                printError(iv_password_error, "密码长度必须为6-16位！");
                break;
            case SUCCESS:
                setTrue(iv_password_error);
                tv_errorinfo.setText("");
                break;
            default:
                break;
        }
    }

    protected void checkInput(final String email, String password) throws DibitsExceptionC {
        Syntax.ERROR_INFO checkErrorInput = Syntax.getUserEmailErrorInfo(email);
        if (checkErrorInput != Syntax.ERROR_INFO.SUCCESS) {
            printError(iv_email_error, Syntax.ERROR_INFO.getType(checkErrorInput));
        } else {
            checkErrorInput = Syntax.getUserPasswordErrorInfo(password);
            if (checkErrorInput != Syntax.ERROR_INFO.SUCCESS) {
                printError(iv_password_error, Syntax.ERROR_INFO.getType(checkErrorInput));
            }
        }
    }

    private void setTrue(final ImageView v) {
        v.post(new Runnable() {
            @SuppressWarnings("deprecation")
            @Override
            public void run() {
                // TODO Auto-generated method stub
                v.setVisibility(View.VISIBLE);
                v.setBackgroundDrawable(getResources().getDrawable(R.drawable.validate_true));
            }
        });
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

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_back:
                this.finish();
                break;
            case R.id.tv_login:
                //hide SoftInputMethod
                ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).
                        hideSoftInputFromWindow(
                                LoginActivity2.this.getCurrentFocus().getWindowToken(),
                                InputMethodManager.HIDE_NOT_ALWAYS);
                final String email = et_login_email.getText().toString().trim();
                final String password = et_login_password.getText().toString().trim();
                try {
                    checkInput(email, password);
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    Message msg = Message.obtain();
                    msg.obj = e;
                    msg.what = 0;
                    handler.sendMessage(msg);
                    return;
                }
                if (NetworkUtil.isNetworkAvailable(LoginActivity2.this)) {
                    KKDialog.getInstance().showProgressBar(LoginActivity2.this, KKDialog.IS_LOADING);
                    new Thread() {
                        @Override
                        public void run() {
                            //login
                            User user;
                            try {
                                user = LoginAPI.login(email, password);
                                if (user != null) {
                                    handler.sendEmptyMessage(1);
                                } else {
                                    handler.sendEmptyMessage(2);
                                }

                            } catch (DibitsExceptionC e) {
                                e.printStackTrace();
                                Message msg = Message.obtain();
                                msg.obj = e;
                                msg.what = 2;
                                handler.sendMessage(msg);
                            }
                        }
                    }.start();
                } else {
                    Toast.makeText(LoginActivity2.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                }


                break;
            case R.id.tv_forget_psw:
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse("http://www.kaikeba.com/users/password/new");
                intent.setData(content_url);
                startActivity(intent);
//                startActivity(new Intent(this,FindPasswordActivity.class));
                break;
            case R.id.iv_go_regist:
                //hide SoftInputMethod
                ((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)).
                        hideSoftInputFromWindow(
                                LoginActivity2.this.getCurrentFocus().getWindowToken(),
                                InputMethodManager.HIDE_NOT_ALWAYS);
                startActivity(new Intent(this, RegistActivity.class));
                break;
        }
    }

    private void initData() {
        mloginController = UMLoginController.getController().getUMSocialService(this);
    }

    private void doOauthVerify(SHARE_MEDIA media) {
        if (OauthHelper.isAuthenticated(context, media)) {
            Toast.makeText(context, "当前平台已经授权.", Toast.LENGTH_SHORT).show();
            goRegist();
        } else {
            mloginController.doOauthVerify(context, media,
                    new SocializeListeners.UMAuthListener() {
                        @Override
                        public void onError(SocializeException e, SHARE_MEDIA platform) {
                            Toast.makeText(context, "授权失败 " + e.getMessage(), Toast.LENGTH_SHORT).show();
                        }

                        @Override
                        public void onComplete(Bundle value, SHARE_MEDIA platform) {
                            Toast.makeText(context, "授权成功.", Toast.LENGTH_SHORT).show();
                            goRegist();
                        }

                        @Override
                        public void onCancel(SHARE_MEDIA arg0) {
                            Toast.makeText(context, "授权取消.", Toast.LENGTH_SHORT).show();
                        }

                        @Override
                        public void onStart(SHARE_MEDIA arg0) {
                            Toast.makeText(context, "授权开始.", Toast.LENGTH_SHORT).show();
                        }

                    });
        }
    }

    private void goRegist() {
        Intent intent = new Intent(context, RegistActivity.class);
        intent.putExtra("OauthVerify", true);
        intent.putExtra("SHARE_MEDIA",media);
        startActivity(intent);
    }

    public void getUserInfoInThread() {
        new Thread() {
            @Override
            public void run() {
                JSONObject json = null;
                try {
                    json = mTencent.request(Constants.GRAPH_SIMPLE_USER_INFO, null,
                            Constants.HTTP_GET);

                } catch (IOException e) {
                    e.printStackTrace();
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (HttpUtils.NetworkUnavailableException e) {
                    e.printStackTrace();
                } catch (HttpUtils.HttpStatusException e) {
                    e.printStackTrace();
                }

                Log.i(TAG, json.toString());
            }
        }.start();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        //        mTencent.onActivityResult(requestCode, resultCode, data);
        /**使用SSO授权必须添加如下代码 */
        UMSsoHandler ssoHandler = mloginController.getConfig().getSsoHandler(requestCode);
        if (ssoHandler != null) {
            ssoHandler.authorizeCallBack(requestCode, resultCode, data);
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("Signin"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("Signin");
        MobclickAgent.onPause(this);
    }
    private SHARE_MEDIA media;
    private class LognupClickListener implements View.OnClickListener {
        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.signup_sina:
                    media = SHARE_MEDIA.SINA;
                    doOauthVerify(SHARE_MEDIA.SINA);
                    break;
                case R.id.signup_qq:
                    media = SHARE_MEDIA.QQ;
                    doOauthVerify(SHARE_MEDIA.QQ);
                    break;
                case R.id.signup_renren:
                    media = SHARE_MEDIA.RENREN;
                    doOauthVerify(SHARE_MEDIA.RENREN);
                    break;
                default:
                    break;
            }
        }
    }

    private class MIUiListener implements IUiListener {
        public void onComplete(java.lang.Object o) {
            Log.i(TAG, "login complete");

            getUserInfoInThread();
        }

        public void onError(com.tencent.tauth.UiError uiError) {
            Log.i(TAG, "login error");
        }

        public void onCancel() {
            Log.i(TAG, "login cancle");
        }
    }
}