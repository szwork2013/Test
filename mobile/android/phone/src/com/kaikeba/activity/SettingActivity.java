package com.kaikeba.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.*;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.igexin.sdk.PushManager;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.Certificate;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.NetworkUtil;
import com.kaikeba.common.util.UploadData;
import com.kaikeba.common.widget.SwitchButton;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;
import com.umeng.fb.FeedbackAgent;
import com.umeng.update.UmengDownloadListener;
import com.umeng.update.UmengUpdateAgent;
import com.umeng.update.UmengUpdateListener;
import com.umeng.update.UpdateResponse;

import java.io.Serializable;
import java.util.ArrayList;


public class SettingActivity extends BaseActivity implements OnClickListener {

    private static final String TAG = "SettingActivity";
//    private MainActivity mainActivity;

    private TextView tvSigninup;
    private TextView tvProfile;
    private TextView btnFeedback;
    private TextView btnAbout;
    private TextView btnStarMe;
    private TextView btnCheckLatest;
    private TextView tv;
    private ImageView btn_back_normal;
    private FeedbackAgent agent;
    private boolean mbCourse = false;
    private SwitchButton message_push_flag;
    private boolean pushFlag;
    //    private SwitchButton download_flag;
    private Context mContext;
    private SharedPreferences appPrefs;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.settings);
        agent = new FeedbackAgent(this);
        mContext = this;
        tvSigninup = (TextView) findViewById(R.id.tv_setting_zhuxiao);
        tvProfile = (TextView) findViewById(R.id.tv_setting_profile);
        btnFeedback = (TextView) findViewById(R.id.tv_setting_feedback);
        btnAbout = (TextView) findViewById(R.id.tv_setting_about);
        btnStarMe = (TextView) findViewById(R.id.tv_setting_stat_me);
        btnCheckLatest = (TextView) findViewById(R.id.tv_setting_check);
        btn_back_normal = (ImageView) findViewById(R.id.iv_back);
        message_push_flag = (SwitchButton) findViewById(R.id.message_push_flag);
//        download_flag = (SwitchButton)findViewById(R.id.download_flag);
        TextView tv_text = (TextView) findViewById(R.id.tv_text);
        tv_text.setText("设置");
        findViewById(R.id.tv_zhifu_pay).setOnClickListener(new OnClickListener() {//支付宝支付
            @Override
            public void onClick(View v) {
                Intent alipay = new Intent(SettingActivity.this, AlipayActivity.class);
                startActivity(alipay);
            }
        });
        findViewById(R.id.tv_my_certificate).setOnClickListener(new OnClickListener() {//我的证书
            @Override
            public void onClick(View v) {
                Intent myCertificate = new Intent(SettingActivity.this, MyCertificate.class);
                Bundle bundle = new Bundle();
                myCertificate.putExtra("my_certificate_data",(Serializable)myCertificates);
                startActivity(myCertificate);
            }
        });

        appPrefs = ContextUtil.getContext().getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        message_push_flag.setChecked(appPrefs.getBoolean(API.PUSHSTATE,false));

        tv = (TextView) findViewById(R.id.tv);
        message_push_flag.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                pushFlag = isChecked;
                if (isChecked) {
                    PushManager.getInstance().turnOnPush(SettingActivity.this);
//                    Toast.makeText(mContext,"打开",Toast.LENGTH_SHORT).show();
                } else {
                    PushManager.getInstance().turnOffPush(SettingActivity.this);
//                    Toast.makeText(mContext,"关闭",Toast.LENGTH_SHORT).show();
                }
            }
        });

//        download_flag.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
//            @Override
//            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
//                if(isChecked){
//                    Toast.makeText(mContext,"打开",Toast.LENGTH_SHORT).show();
//                }else{
//                    Toast.makeText(mContext,"关闭",Toast.LENGTH_SHORT).show();
//                }
//            }
//        });

        if (API.getAPI().alreadySignin()) {
            setSignin(true);
        } else {
            setSignin(false);
        }
        try {
            PackageManager manager = this.getPackageManager();
            PackageInfo info = manager.getPackageInfo(this.getPackageName(), 0);
            String version = info.versionName;
            tv.setText("当前版本：  " + version);
        } catch (PackageManager.NameNotFoundException exception) {
            exception.printStackTrace();
        }

        //TODO
        tvSigninup.setOnClickListener(this);

        tvProfile.setOnClickListener(this);

        btnFeedback.setOnClickListener(this);

        btnAbout.setOnClickListener(this);

        btnStarMe.setOnClickListener(this);

        btnCheckLatest.setOnClickListener(this);

        btn_back_normal.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                appointSkip();
            }
        });

        btn_back_normal.setOnClickListener(this);

        initMyCertificate();
    }

    private ArrayList<Certificate> myCertificates = new ArrayList<Certificate>();
    private void initMyCertificate() {
        PretreatDataCache.loadMyCertificate(this, new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    myCertificates.addAll((ArrayList<Certificate>) data);
                }
            }
        });
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("Setting");
        MobclickAgent.onPause(this);

        if(appPrefs.getBoolean(API.PUSHSTATE,false) != pushFlag){
            SharedPreferences.Editor prefsEditor = appPrefs.edit();
            prefsEditor.putBoolean(API.PUSHSTATE, pushFlag);
            prefsEditor.commit();
        }
    }


    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
        if (API.getAPI().alreadySignin()) {
            setSignin(true);
        } else {
            setSignin(false);
        }
        MobclickAgent.onPageStart("Setting");
        MobclickAgent.onResume(this);
    }

    /**
     * 确认退出
     */
    public void ConfirmExit() {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle("注销当前账号");
        ad.setMessage("您确认注销么?");
        ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {

            }
        });
        ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {//退出按钮
            @Override
            public void onClick(DialogInterface dialog, int i) {
                UploadData.getInstance().uploadPushInfo(SettingActivity.this);
                API.getAPI().cleanUserInfo();
                setSignin(false);
                Intent intent = new Intent(SettingActivity.this, AllCourseActivity.class);
                startActivity(intent);
                finish();
                if (TabCourseActivity.getTabCourseActivity() != null) {
                    TabCourseActivity.getTabCourseActivity().finish();
                }
                Toast.makeText(SettingActivity.this, "注销成功", Toast.LENGTH_SHORT).show();
                ServerDataCache.getInstance().clearCacheItem();
            }
        });
        ad.show();
    }

    /**
     * 设置账号登录状态
     *
     * @param alreadySignin true：已登录；  false：未登录
     */
    public void setSignin(boolean alreadySignin) {
        if (API.getAPI().alreadySignin()) {//已经登录（登出、可查看个人资料）
            tvSigninup.setText(R.string.signout);
//            btnProfile.setClickable(true);
        } else {//未登录（登录/注册、不可查看个人资料）
            tvSigninup.setText(R.string.signin_signup);
//            btnProfile.setClickable(false);
        }
    }

    @Override
    public void onClick(View v) {
        if (v.equals(tvSigninup)) {
            if (API.getAPI().alreadySignin()) {
                ConfirmExit();
            } else {
//                    mainActivity.getSigninpuDialog().show();
                Constants.LOGIN_FROM = Constants.FROM_SETTING;
                Intent intent = new Intent(SettingActivity.this, LoginActivity2.class);
                intent.putExtra(Constants.ACTIVITY_NAME_KEY, "setting");
                startActivityForResult(intent, 3);
            }
        } else if (v.equals(tvProfile)) {
            if (API.getAPI().alreadySignin()) {
                Intent intent = new Intent(SettingActivity.this, UpdateUserInfoActivity.class);
                startActivity(intent);
            }
        } else if (v.equals(btnFeedback)) {
            if (NetworkUtil.isNetworkAvailable(SettingActivity.this)) {
                agent.startFeedbackActivity();
                overridePendingTransition(com.kaikeba.common.R.anim.in_from_right, com.kaikeba.common.R.anim.out_to_left);
            } else {
                Toast.makeText(SettingActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
            }
        } else if (v.equals(btnAbout)) {
            Intent intent = new Intent(SettingActivity.this, PaymentActivity.class);
            intent.putExtra("url", ConfigLoader.getLoader().getCanvas().getAbout4TabletURL());
            intent.putExtra("Title", "关于");
            startActivity(intent);
        } else if (v.equals(btnStarMe)) {
            Uri uri = Uri.parse("market://details?id=com.kaikeba.phone");
            Intent it = new Intent(Intent.ACTION_VIEW, uri);
            try {
                startActivity(it);
            } catch (ActivityNotFoundException exception) {
                agent.startFeedbackActivity();
            }
        } else if (v.equals(btnCheckLatest)) {
            if (NetworkUtil.isNetworkAvailable(SettingActivity.this)) {
                UmengUpdateAgent.forceUpdate(SettingActivity.this);
                UmengUpdateAgent.setUpdateListener(new UmengUpdateListener() {
                    @Override
                    public void onUpdateReturned(int updateStatus, UpdateResponse updateInfo) {
                        switch (updateStatus) {
                            case 0: // has update
                                Log.i("--->", "callback result");
                                UmengUpdateAgent.showUpdateDialog(SettingActivity.this, updateInfo);
                                break;
                            case 1: // has no update
                                Toast.makeText(SettingActivity.this, "已经是最新版本", Toast.LENGTH_SHORT).show();
                                break;
                            case 2: // none wifi
                                Toast.makeText(SettingActivity.this, "没有wifi连接， 只在wifi下更新", Toast.LENGTH_SHORT).show();
                                break;
                            case 3: // time out
                                Toast.makeText(SettingActivity.this, "超时", Toast.LENGTH_SHORT).show();
                                break;
                            case 4: // is updating
                                Toast.makeText(SettingActivity.this, "正在下载更新...", Toast.LENGTH_SHORT).show();
                                break;
                        }
                    }
                });

                UmengUpdateAgent.setDownloadListener(new UmengDownloadListener() {

                    @Override
                    public void OnDownloadStart() {

                    }

                    @Override
                    public void OnDownloadUpdate(int i) {

                    }

                    @Override
                    public void OnDownloadEnd(int i, String s) {
                        Log.i(TAG, "download result : " + s);
                        Toast.makeText(SettingActivity.this, "download result : " + s, Toast.LENGTH_SHORT)
                                .show();
                    }
                });
            } else {
                Toast.makeText(SettingActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
            }
        } else if (v.equals(btn_back_normal)) {
            if (API.getAPI().alreadySignin() && mbCourse) {
                Intent intent = new Intent();
                intent.putExtra("isSuccess", true);
                setResult(1, intent);
            }
            appointSkip();
        } else {
            //
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }

    public void appointSkip() {
        Intent intent = new Intent(SettingActivity.this, TabCourseActivity.class);
        intent.putExtra("TabTag", "UserCenter");
        intent.putExtra("TabNum", 3);
        startActivity(intent);
        finish();
    }
}
