package com.kaikeba.activity.fragment;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.dialog.SigninupDialog;
import com.kaikeba.common.api.API;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.FileSizeUtil;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.lidroid.xutils.view.annotation.event.OnClick;
import com.lidroid.xutils.view.annotation.event.OnRadioGroupCheckedChange;

/**
 * 主界面导航Fragment
 *
 * @author Super Man
 */
public class MainNavFragment extends Fragment {

    boolean isFirst = true;
    Handler handler = new Handler();
    private MainActivity mainActivity;
    @ViewInject(R.id.layout_main_splitbar)
    private RelativeLayout singInUp;
    @ViewInject(R.id.btn_main_setting)
    private ImageButton settingBtn;
    @ViewInject(R.id.rg_buttons)
    private RadioGroup radioGroup;
    private View selfView;
    @ViewInject(R.id.main_nav_allcourse)
    private RadioButton buttonAllCourse;
    @ViewInject(R.id.main_nav_mycourse)
    private RadioButton buttonMyCourse;
    @ViewInject(R.id.main_nav_active)
    private RadioButton buttonActive;
    @ViewInject(R.id.main_nav_download)
    private RadioButton buttonDownload;
    private FrameLayout allcourse_container;
    private FrameLayout mycourse_container;
    private FrameLayout setting_container;
    private FrameLayout activity_content_container;
    private FrameLayout download_content_container;
    private TextView userName;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        Log.d("NavFragment", "onCreateView");
        View inflaterView = inflater.inflate(R.layout.main_nav, container,
                false);
        ViewUtils.inject(this, inflaterView);
        selfView = inflaterView;
        return inflaterView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        findMainActivityView();
        if (API.getAPI().alreadySignin()) {
            changeUserInMainNav(API.getAPI().getUserObject().getUserName(),
                    API.getAPI().getUserObject().getAvatarUrl());
            buttonMyCourse.setVisibility(View.VISIBLE);
            buttonActive.setVisibility(View.VISIBLE);
            buttonDownload.setVisibility(View.VISIBLE);
        }
    }

    private void findMainActivityView() {
        allcourse_container = (FrameLayout) mainActivity
                .findViewById(R.id.allcourse_container);
        mycourse_container = (FrameLayout) mainActivity
                .findViewById(R.id.mycourse_container);
        setting_container = (FrameLayout) mainActivity
                .findViewById(R.id.setting_container);
        activity_content_container = (FrameLayout) mainActivity
                .findViewById(R.id.activity_content_container);
        download_content_container = (FrameLayout) mainActivity
                .findViewById(R.id.download_content_container);
        userName = (TextView) selfView.findViewById(R.id.txtUserName);
    }

    @OnRadioGroupCheckedChange(R.id.rg_buttons)
    public void onCheckedChanged(RadioGroup radioGroup, int checkedId) {
        // TODO Auto-generated method stub
        switch (radioGroup.getCheckedRadioButtonId()) {
            case R.id.main_nav_allcourse:
                hideView(allcourse_container);
                settingBtn.setBackground(getResources().getDrawable(R.drawable.selector_main_setting));
                break;
            case R.id.main_nav_mycourse:
                hideView(mycourse_container);
                settingBtn.setBackground(getResources().getDrawable(R.drawable.selector_main_setting));
                mainActivity.loadAllMyCourse();
                if (Constants.isFreshMyCourse) {
                    refreshView();
                    Constants.isFreshMyCourse = false;
                }
                break;
            case R.id.main_nav_active:
                hideView(activity_content_container);
                settingBtn.setBackground(getResources().getDrawable(R.drawable.selector_main_setting));
                mainActivity.showActivityStream();
                break;
            case R.id.main_nav_download:
                hideView(download_content_container);
                settingBtn.setBackground(getResources().getDrawable(R.drawable.selector_main_setting));
                if (mainActivity.getDownloadManagerFragment() != null) {
                    mainActivity.getDownloadManagerFragment().refreshView();
                }
                FileSizeUtil.getSdcardInfo();
                FileSizeUtil.getUsedSpaceInfo();
                mainActivity.showDownload();
                break;
            default:
                break;
        }

    }

    @OnClick(R.id.layout_main_splitbar)
    public void signInUp(View view) {
        if (!API.getAPI().alreadySignin()) {
            Constants.LOGIN_FROM = Constants.FROM_MAIN;
            Intent intent = new Intent(mainActivity, SigninupDialog.class);
            startActivity(intent);
        }
    }

    @OnClick(R.id.btn_main_setting)
    public void clickSetting(View view) {
        radioGroup.check(-1);
        hideView(setting_container);
        view.setBackgroundResource(R.drawable.icon_set_selected);
    }

    private void hideView(final View view) {

        final View[] views = {allcourse_container, mycourse_container,
                activity_content_container, download_content_container,
                setting_container};
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                for (View v : views) {
                    if (v != view) {
                        v.setVisibility(View.INVISIBLE);
                    } else {
                        view.setVisibility(View.VISIBLE);
                    }
                }
            }
        }, 50);
    }

    public void signOutHideView() {
        View[] views = {allcourse_container, mycourse_container,
                activity_content_container, setting_container};
        for (View view : views) {
            if (setting_container == view) {
                view.setVisibility(View.VISIBLE);
            } else {
                view.setVisibility(View.GONE);
            }
        }
    }

    public void goMyAllcourse() {
        buttonMyCourse.performClick();
    }

    public void getAllCourse() {
        buttonAllCourse.performClick();
    }

    /**
     * 更换主导航上的用户信息
     *
     * @param name
     * @param avatarURL
     */
    public void changeUserInMainNav(String name, String avatarURL) {
        userName.setText(name);
        userName.invalidate();
        ImageView userAvatar = (ImageView) selfView
                .findViewById(R.id.imgUserAvatar);

        userAvatar.setBackground(new BitmapDrawable(getResources(),
                ImgLoaderUtil.getLoader().loadImg(avatarURL, new ImgLoaderUtil.ImgCallback() {

                    @Override
                    public void refresh(Bitmap bitmap) {
                        ImageView userAvatar = (ImageView) selfView
                                .findViewById(R.id.imgUserAvatar);
                        userAvatar.setBackground(new BitmapDrawable(
                                getResources(), bitmap));
                    }
                }, handler)));
    }

    /**
     * 清空主导航上的用户信息
     */
    public void cleanUserInMainNav() {
        userName.setText(getResources().getString(R.string.signin_signup));
        ImageView userAvatar = (ImageView) selfView
                .findViewById(R.id.imgUserAvatar);
        userAvatar.setBackground(getResources().getDrawable(
                R.drawable.icon_default_profile_s));
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mainActivity = (MainActivity) getActivity();
        Log.d("NavFragment", "onAttach");
    }

    public void hideActiveView() {
        buttonMyCourse.setVisibility(View.INVISIBLE);
        buttonActive.setVisibility(View.INVISIBLE);
        buttonDownload.setVisibility(View.INVISIBLE);
    }

    public void showActiveView() {
        buttonMyCourse.setVisibility(View.VISIBLE);
        buttonActive.setVisibility(View.VISIBLE);
        buttonDownload.setVisibility(View.VISIBLE);
    }

    public void refreshView() {
        mainActivity.refreshView();
    }
}
