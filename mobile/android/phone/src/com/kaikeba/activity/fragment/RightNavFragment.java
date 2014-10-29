package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import com.android.CaptureActivity;
import com.kaikeba.activity.*;
import com.kaikeba.common.api.API;
import com.kaikeba.common.util.BitmapManager;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;

public class RightNavFragment extends Fragment implements OnClickListener {

    private CourseSquareActivity mainActivity;

    private TextView tvLogin;
    private ImageView ivSideUserAvatar;
    private TextView tvUserName;
    private TextView tvMainAllCourses;
    private TextView tvMyAllcourse;
    private TextView load_manage;
    private BitmapManager bmpManager;
    private ImageButton ib_setting;

    private Handler handler = new Handler();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.right_navbar, container, false);
        initView(view);
        setListener();
        bmpManager = new BitmapManager();
        return view;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        mainActivity = (CourseSquareActivity) getActivity();
    }

    public void onResume() {
        super.onResume();
    }

    public void onPause() {
        super.onPause();
    }

    private void initView(View view) {
        view.findViewById(R.id.tv_main_all_courses);
        ivSideUserAvatar = (ImageView) view.findViewById(R.id.iv_side_user_avatar);
        tvUserName = (TextView) view.findViewById(R.id.tv_username);
        tvLogin = (TextView) view.findViewById(R.id.tv_right_nav_login);
        tvMainAllCourses = (TextView) view.findViewById(R.id.tv_main_all_courses);
        tvMyAllcourse = (TextView) view.findViewById(R.id.tv_my_allcourse);
        ib_setting = (ImageButton) view.findViewById(R.id.ib_setting);
        load_manage = (TextView) view.findViewById(R.id.tv_load_manager);

        TextView test = (TextView) view.findViewById(R.id.test);
        test.setOnClickListener(this);
        TextView test2 = (TextView) view.findViewById(R.id.test2);
        test2.setOnClickListener(this);
        TextView test3 = (TextView) view.findViewById(R.id.test3);
        test3.setOnClickListener(this);
        TextView tv_user_center = (TextView) view.findViewById(R.id.tv_user_center);
        tv_user_center.setOnClickListener(this);
    }

    private void setListener() {
        tvLogin.setOnClickListener(this);
        tvMainAllCourses.setOnClickListener(this);
        tvMyAllcourse.setOnClickListener(this);
        ib_setting.setOnClickListener(this);
        load_manage.setOnClickListener(this);
    }

    public void changeState() {
        handler.post(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                BitmapDrawable bd = (BitmapDrawable) getResources().getDrawable(R.drawable.sidebar_icon_login);
                Bitmap bm = bd.getBitmap();
                if (API.getAPI().getUserObject().getAvatarUrl() != null) {
                    bmpManager.loadBitmap(API.getAPI().getUserObject().getAvatarUrl(), ivSideUserAvatar, bm);
                }
                tvUserName.setVisibility(View.VISIBLE);
                tvUserName.setText(API.getAPI().getUserObject().getUserName());
                tvLogin.setVisibility(View.GONE);
                tvMyAllcourse.setVisibility(View.VISIBLE);
                tvMainAllCourses.performClick();
                load_manage.setVisibility(View.VISIBLE);
            }

        });
    }

    public void loginToLogout() {
        handler.post(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                ivSideUserAvatar.setBackgroundDrawable(getResources().getDrawable(R.drawable.sidebar_icon_login));
                tvUserName.setVisibility(View.GONE);
                tvMyAllcourse.setVisibility(View.GONE);
                tvLogin.setVisibility(View.VISIBLE);
                tvMainAllCourses.performClick();
                load_manage.setVisibility(View.GONE);
            }

        });
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        switch (v.getId()) {
            case R.id.tv_right_nav_login:
                Constants.LOGIN_FROM = Constants.FROM_MAIN;
                Intent intent = new Intent(mainActivity, LoginActivity.class);
                intent.putExtra(Constants.ACTIVITY_NAME_KEY, "side_menu");
                startActivityForResult(intent, 1);
                break;
            case R.id.tv_main_all_courses:
                changeBg(v);
                mainActivity.mSlidingMenu.toggle();
                mainActivity.showAllCourse();
                break;
            case R.id.tv_my_allcourse:
                changeBg(v);
//			handler.postDelayed(new Runnable(){
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					
//				}
//			}, 100);
                mainActivity.mSlidingMenu.toggle();
                mainActivity.showMyCourse();
                if (Constants.isFreshMyCourse) {
                    mainActivity.refreshMyCourse();
                    Constants.isFreshMyCourse = false;
                }
                break;
            case R.id.tv_load_manager:
                changeBg(v);
                mainActivity.mSlidingMenu.toggle();
                mainActivity.showLoadManager();
                break;
            case R.id.ib_setting:
                Intent intent2 = new Intent(mainActivity, SettingActivity.class);
                startActivityForResult(intent2, 2);
                break;
            case R.id.test:
                Intent it = new Intent(mainActivity, MicroCourseActivity.class);
                startActivity(it);
                break;
            case R.id.test2:
                Intent it2 = new Intent(mainActivity, TabCourseActivity.class);
                startActivity(it2);
                break;
            case R.id.test3:
                Intent it3 = new Intent();
                it3.setClass(mainActivity, CaptureActivity.class);
                startActivity(it3);
                break;
            case R.id.tv_user_center:
                Intent userCenter = new Intent(mainActivity, UserCenterActivity.class);
                startActivity(userCenter);
                break;
            default:
                break;
        }
    }

    private void changeBg(View v) {
        if (v == tvMainAllCourses) {
            tvMyAllcourse.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            tvMainAllCourses.setBackgroundDrawable(getResources().getDrawable(R.drawable.button_selected));
            load_manage.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            tvMainAllCourses.setTextColor(getResources().getColor(R.color.white));
            tvMyAllcourse.setTextColor(getResources().getColor(R.color.right_txt_default_color));
            load_manage.setTextColor(getResources().getColor(R.color.right_txt_default_color));
        } else if (v == tvMyAllcourse) {
            tvMainAllCourses.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            tvMyAllcourse.setBackgroundDrawable(getResources().getDrawable(R.drawable.button_selected));
            load_manage.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            tvMainAllCourses.setTextColor(getResources().getColor(R.color.right_txt_default_color));
            tvMyAllcourse.setTextColor(getResources().getColor(R.color.white));
            load_manage.setTextColor(getResources().getColor(R.color.right_txt_default_color));
        } else if (v == load_manage) {
            tvMainAllCourses.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            tvMyAllcourse.setBackgroundColor(getResources().getColor(R.color.all_course_button_bg));
            load_manage.setBackgroundDrawable(getResources().getDrawable(R.drawable.button_selected));
            tvMainAllCourses.setTextColor(getResources().getColor(R.color.right_txt_default_color));
            tvMyAllcourse.setTextColor(getResources().getColor(R.color.right_txt_default_color));
            load_manage.setTextColor(getResources().getColor(R.color.white));
        }
    }
}
