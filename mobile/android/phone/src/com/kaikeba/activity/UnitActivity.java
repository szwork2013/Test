package com.kaikeba.activity;

import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.fragment.CourseArrangeFragment;
import com.kaikeba.activity.fragment.CourseIntroduceFragment;
import com.kaikeba.activity.fragment.UnitRightNavFragment;
import com.kaikeba.common.api.API;
import com.kaikeba.common.base.BaseSlidingFragmentActivity;
import com.kaikeba.common.base.SlidingMenu;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

public class UnitActivity extends BaseSlidingFragmentActivity {

    public SlidingMenu mSlidingMenu;
    private UnitRightNavFragment mFragment;
    private ImageView back;
    private ImageView iv_menu;
    private TextView topName;
    private FragmentManager fm;
    private CourseArrangeFragment caf;
    private CourseIntroduceFragment courseFragment;
    private CourseIntroduceFragment instrustorFragment;
    private LinearLayout ll_course_info_container;
    private LinearLayout ll_instrustor_info_container;
    private LinearLayout ll_course_arrange_container;
    private CourseModel c;
    private Bundle b;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            int id = v.getId();
            switch (id) {
                case R.id.btn_back_normal:
                    finish();
                    break;
                case R.id.iv_menu:
                    mSlidingMenu.showSecondaryMenu(true);
                    break;
                default:
                    break;
            }

        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        c = (CourseModel) getIntent().getSerializableExtra(ContextUtil.CATEGORY_COURSE);
        initSlidingMenu();
        setContentView(R.layout.unit);
        initView();
        setListener();
        fm = getSupportFragmentManager();
        getCourseInfo();
        topName.setText(c.getName());
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("my_course_page"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("my_course_page");
        MobclickAgent.onPause(this);
    }

    private void initView() {
        mSlidingMenu.setSecondaryMenu(R.layout.main_right_layout);
        FragmentTransaction mFragementTransaction = getSupportFragmentManager()
                .beginTransaction();
        mFragment = new UnitRightNavFragment();
        Bundle bundle = new Bundle();
        bundle.putString("courseName", c.getName());
        mFragment.setArguments(bundle);
        mFragementTransaction.add(R.id.main_right_fragment, mFragment);
        mFragementTransaction.commit();
        back = (ImageView) findViewById(R.id.btn_back_normal);
        iv_menu = (ImageView) findViewById(R.id.iv_menu);
        topName = (TextView) findViewById(R.id.tv_course_top_name);
        ll_course_info_container = (LinearLayout) findViewById(R.id.ll_course_info_container);
        ll_instrustor_info_container = (LinearLayout) findViewById(R.id.ll_instrustor_info_container);
        ll_course_arrange_container = (LinearLayout) findViewById(R.id.ll_course_arrange_container);
    }

    private void getCourseInfo() {
        b = new Bundle();
        b.putSerializable(ContextUtil.CATEGORY_COURSE, c);
        b.putString("courseID", c.getId() + "");
        b.putString("courseName", c.getName());
        b.putString("bgUrl", c.getCover_image());
    }

    private void initSlidingMenu() {
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        int mScreenWidth = dm.widthPixels;
        setBehindContentView(R.layout.main_left_layout);
        mSlidingMenu = getSlidingMenu();
        mSlidingMenu.setMode(SlidingMenu.RIGHT);
        mSlidingMenu.setShadowWidth(mScreenWidth / 40);
        mSlidingMenu.setBehindOffset(mScreenWidth / 6);
        mSlidingMenu.setFadeDegree(0.35f);
        mSlidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_FULLSCREEN);
        mSlidingMenu.setFadeEnabled(true);
        mSlidingMenu.setBehindScrollScale(0.333f);
    }

    private void setListener() {
        back.setOnClickListener(listener);
        iv_menu.setOnClickListener(listener);
    }

    public void showCourseInfo() {
        ll_course_info_container.setVisibility(View.VISIBLE);
        ll_instrustor_info_container.setVisibility(View.GONE);
        ll_course_arrange_container.setVisibility(View.GONE);
        API.which = 1;
        if (courseFragment == null) {
            FragmentTransaction ft1 = fm.beginTransaction();
            courseFragment = new CourseIntroduceFragment();
            courseFragment.setArguments(b);
            ft1.add(R.id.ll_course_info_container, courseFragment);
            ft1.commit();
        }
    }

    public void showInstrustorInfo() {
        ll_course_info_container.setVisibility(View.GONE);
        ll_instrustor_info_container.setVisibility(View.VISIBLE);
        ll_course_arrange_container.setVisibility(View.GONE);
        API.which = 2;
        if (instrustorFragment == null) {
            FragmentTransaction ft2 = fm.beginTransaction();
            instrustorFragment = new CourseIntroduceFragment();
            instrustorFragment.setArguments(b);
            ft2.add(R.id.ll_instrustor_info_container, instrustorFragment);
            ft2.commit();
        }
    }

    public void showUnitInfo() {
        API.VIEW_INTO = 2;
        ll_course_info_container.setVisibility(View.GONE);
        ll_instrustor_info_container.setVisibility(View.GONE);
        ll_course_arrange_container.setVisibility(View.VISIBLE);
        if (caf == null) {
            FragmentTransaction ft3 = fm.beginTransaction();
            caf = new CourseArrangeFragment();
            caf.setArguments(b);
            ft3.add(R.id.ll_course_arrange_container, caf);
            ft3.commit();
        }
    }
}
