package com.kaikeba.activity.fragment;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.dialog.EditProfileDialog;
import com.kaikeba.activity.dialog.SigninupDialog;
import com.kaikeba.activity.dialog.WebViewDialog;
import com.kaikeba.common.api.API;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import com.umeng.fb.FeedbackAgent;
import com.umeng.update.UmengDownloadListener;
import com.umeng.update.UmengUpdateAgent;
import com.umeng.update.UmengUpdateListener;
import com.umeng.update.UpdateResponse;

/**
 * 设置Fragment
 *
 * @author Super Man
 */
public class SettingFragment extends Fragment {
    private static final String LOG_TAG = SettingFragment.class.getName();

    private MainActivity mainActivity;

    private TextView tvSigninup;
    private TextView tvProfile;

    private FeedbackAgent agent;
    private TextView txtFeedback;
    private TextView txtAboutMe;
    private TextView txtStarMe;
    private TextView txtCheckLatest;
    private ImageButton btn_togo;

    /*
     * (non-Javadoc)
     *
     * @see android.app.Fragment#onCreateView(android.view.LayoutInflater,
     * android.view.ViewGroup, android.os.Bundle)
     */
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final View v = inflater.inflate(R.layout.layout_setting, container,
                false);
        agent = new FeedbackAgent(mainActivity);
        UmengUpdateAgent.setUpdateOnlyWifi(false);
        tvSigninup = (TextView) v.findViewById(R.id.txtSigninup);
        tvProfile = (TextView) v.findViewById(R.id.txtProfile);

        txtFeedback = (TextView) v.findViewById(R.id.txtFeedback);
        txtAboutMe = (TextView) v.findViewById(R.id.txtAboutMe);
        txtStarMe = (TextView) v.findViewById(R.id.txtStarMe);
        txtCheckLatest = (TextView) v.findViewById(R.id.txtCheckLatest);
        if (API.getAPI().alreadySignin()) {
            setSignin(true);
        } else {
            setSignin(false);
        }
        btn_togo = (ImageButton) v.findViewById(R.id.btn_togo);
        btn_togo.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                MainActivity.getMainActivity().getMslidingMenu().showMenu();
            }
        });

        // TODO
        tvSigninup.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (API.getAPI().alreadySignin()) {
                    ConfirmExit();
                } else {
                    Constants.LOGIN_FROM = Constants.FROM_MAIN;
                    Intent intent = new Intent(mainActivity,
                            SigninupDialog.class);
                    startActivity(intent);
                }

            }

            ;
        });

        tvProfile.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (API.getAPI().alreadySignin()) {
                    Intent intent = new Intent(mainActivity,
                            EditProfileDialog.class);
                    startActivity(intent);
                }
            }
        });

        txtFeedback.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                agent.startFeedbackActivity();
            }
        });

        txtAboutMe.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent intent = new Intent(mainActivity, WebViewDialog.class);
                intent.putExtra("URL", ConfigLoader.getLoader().getCanvas()
                        .getAbout4TabletURL());
                intent.putExtra("Title", "关于");
                mainActivity.startActivity(intent);
            }
        });

        txtStarMe.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                // Uri uri =
                // Uri.parse("market://details?id=com.digimobistudio.dibits");
                Uri uri = Uri.parse("market://details?id=com.kaikeba");
                Intent it = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(it);
            }
        });

        txtCheckLatest.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                // 如果想程序启动时自动检查是否需要更新， 把下面两行代码加在Activity 的onCreate()函数里。
                UmengUpdateAgent.setUpdateOnlyWifi(false); // 目前我们默认在Wi-Fi接入情况下才进行自动提醒。如需要在其他网络环境下进行更新自动提醒，则请添加该行代码
                UmengUpdateAgent.setUpdateAutoPopup(false);
                UmengUpdateAgent.setUpdateListener(new UmengUpdateListener() {

                    @Override
                    public void onUpdateReturned(int updateStatus,
                                                 UpdateResponse updateInfo) {
                        switch (updateStatus) {
                            case 0: // has update
                                Log.i("--->", "callback result");
                                UmengUpdateAgent.showUpdateDialog(mainActivity,
                                        updateInfo);
                                break;
                            case 1: // has no update
                                Toast.makeText(mainActivity, "没有更新",
                                        Toast.LENGTH_SHORT).show();
                                break;
                            case 2: // none wifi
                                Toast.makeText(mainActivity, "没有wifi连接， 只在wifi下更新",
                                        Toast.LENGTH_SHORT).show();
                                break;
                            case 3: // time out
                                Toast.makeText(mainActivity, "超时",
                                        Toast.LENGTH_SHORT).show();
                                break;
                            case 4: // is updating
                                Toast.makeText(mainActivity, "正在下载更新...",
                                        Toast.LENGTH_SHORT).show();
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
                        Toast.makeText(mainActivity, "download result : " + s, Toast.LENGTH_SHORT)
                                .show();
                    }
                });

                UmengUpdateAgent.update(mainActivity);
            }
        });

        return v;
    }

    /**
     * 确认退出
     */
    public void ConfirmExit() {
        AlertDialog.Builder ad = new AlertDialog.Builder(getActivity());
        ad.setTitle("注销");
        ad.setMessage("您确认注销么?");
        ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {

            }
        });
        ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
            @Override
            public void onClick(DialogInterface dialog, int i) {

                // 移除session
                CookieSyncManager.createInstance(getActivity()
                        .getApplicationContext());
                CookieManager cookieManager = CookieManager
                        .getInstance();
                cookieManager.setAcceptCookie(true);
                cookieManager.removeSessionCookie();// 移除
                API.getAPI().cleanUserInfo();
                // mainActivity.getMainNavFragment().changeMenuOneType(MainNavFragment.SIGNINPU);
                mainActivity.getMainNavFragment().cleanUserInMainNav();
                mainActivity.removeActivityStream();
                mainActivity.removeDownload();
                mainActivity.hideActiveView();
                mainActivity.signOutHideView();
                setSignin(false);
                FragmentTransaction ft = getFragmentManager()
                        .beginTransaction();
                if (getFragmentManager()
                        .findFragmentByTag(
                                getResources().getString(
                                        R.string.tag_mycourse)) != null) {
                    ft.remove(getFragmentManager().findFragmentByTag(
                            getResources().getString(
                                    R.string.tag_mycourse)));
                }
                ft.commit();
            }
        });
        ad.show();
    }

    /**
     * 设置账号登录状态
     *
     * @param alreadySignin true：已登录； false：未登录
     */
    public void setSignin(boolean alreadySignin) {
        if (API.getAPI().alreadySignin()) {// 已经登录（登出、可查看个人资料）
            tvSigninup.setText(R.string.signout);
            tvProfile
                    .setTextColor(getResources().getColor(R.color.txt_setting));
            tvProfile.setClickable(true);
        } else {// 未登录（登录/注册、不可查看个人资料）
            tvSigninup.setText(R.string.signin_signup);
            tvProfile.setTextColor(getResources().getColor(
                    R.color.txt_setting_unavailable));
            tvProfile.setClickable(false);
        }
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mainActivity = (MainActivity) getActivity();
    }

}
