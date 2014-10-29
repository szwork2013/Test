package com.kaikeba.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.fragment.CourseArrangeFragment;
import com.kaikeba.activity.fragment.CourseInfomationFragment;
import com.kaikeba.activity.fragment.CourseIntroduceFragment;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.api.EnrollCourseAPI;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.bean.RequestType;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.controller.UMServiceFactory;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.sso.*;
import com.umeng.socialize.weixin.controller.UMWXHandler;

import java.util.ArrayList;

public class CourseInfomationActivity extends FragmentActivity {
    private static CourseInfomationActivity courseinfoActivity;
    public LinearLayout ll_go_to_study;
    public boolean isFromMyCourse;
    private ImageView btn_share_normal;
    private ImageView btnBackNormal;
    private TextView tvCourseTopName;
    private TextView tvCourseInfo;
    private TextView tvInstructorInfo;
    private TextView tv_go_study;
    private TextView tvCourseArrange;
    private FragmentManager fm;
    private CourseArrangeFragment caf;
    private CourseIntroduceFragment cif;
    private CourseInfomationFragment ciif;
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
                case R.id.btn_share_normal:
                    shareSetting();
                    // 是否只有已登录用户才能打开分享选择页
                    mController.openShare(CourseInfomationActivity.this, false);
                    break;
                case R.id.tv_course_info:
                    hideView(R.id.tv_course_info);
                    changeBg(v);
                    FragmentTransaction ft1 = fm.beginTransaction();
                    ciif = new CourseInfomationFragment();
                    ciif.setArguments(b);
                    ft1.replace(R.id.sv_info_container, ciif);
                    ft1.commit();
                    if (caf != null) {
                        caf.release();
                    }
               /* if (ciif == null) {
                }*/
                    break;
                case R.id.tv_instructor_info:
                    hideView(R.id.tv_instructor_info);
                    changeBg(v);
                    API.which = 1;
                    if (cif == null) {
                        FragmentTransaction ft2 = fm.beginTransaction();
                        cif = new CourseIntroduceFragment();
                        cif.setArguments(b);
                        ft2.add(R.id.ll_course_info_container, cif);
                        ft2.commit();
                    }
                    break;
                case R.id.tv_go_study:
                    entrollCourse();
                    break;
                case R.id.tv_course_arrange:
                    API.VIEW_INTO = 1;
                    stepIntoCourseArrange();
                    break;
                default:
                    break;
            }
        }
    };
    private LinearLayout ll_course_info_container;
    private LinearLayout ll_course_arrange_container;
    private ScrollView sv;
    /**
     * 友盟分享设置
     */
    private UMSocialService mController;
    private ArrayList<Badge> badges;
    private String current_url;
    private String current_body;
    private String current_themeImg;
    private String current_title;
    private LinearLayout ll_course_info_title;
    private LinearLayout ll_course_info_tab;
    private View top_line;
    private VideoPlayerView videoPlayerView;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case Constants.THERE_IS_NONET:
//                    Toast.makeText(getApplicationContext(), "网络未连接",Toast.LENGTH_SHORT).show();
                    KKDialog.getInstance().showNoNetToast(CourseInfomationActivity.this);
                    break;
            }

        }
    };

    public static CourseInfomationActivity getCourseInfoActivity() {
        return courseinfoActivity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.course_info);
        courseinfoActivity = this;
        videoPlayerView = new VideoPlayerView(this);
        initView();
        setListener();
        initClass();
        getCourseInfo();
        setText();

    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("course_detail"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
        isFromMyCourse = false;
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("course_detail");
        MobclickAgent.onPause(this);
    }

    private void initView() {
        ll_course_info_title = (LinearLayout) findViewById(R.id.ll_course_info_title);
        ll_course_info_tab = (LinearLayout) findViewById(R.id.ll_course_info_tab);
        btnBackNormal = (ImageView) findViewById(R.id.btn_back_normal);
        btn_share_normal = (ImageView) findViewById(R.id.btn_share_normal);
        tvCourseTopName = (TextView) findViewById(R.id.tv_course_top_name);
        tvCourseInfo = (TextView) findViewById(R.id.tv_course_info);
        tvInstructorInfo = (TextView) findViewById(R.id.tv_instructor_info);
        tvCourseArrange = (TextView) findViewById(R.id.tv_course_arrange);
        ll_course_info_container = (LinearLayout) findViewById(R.id.ll_course_info_container);
        ll_course_arrange_container = (LinearLayout) findViewById(R.id.ll_course_arrange_container);
        ll_go_to_study = (LinearLayout) findViewById(R.id.ll_go_to_study);
        tv_go_study = (TextView) findViewById(R.id.tv_go_study);
        sv = (ScrollView) findViewById(R.id.sv_info_container);
    }

    private void setListener() {
        btnBackNormal.setOnClickListener(listener);
        btn_share_normal.setOnClickListener(listener);
        tvCourseInfo.setOnClickListener(listener);
        tvInstructorInfo.setOnClickListener(listener);
        tvCourseArrange.setOnClickListener(listener);
        tv_go_study.setOnClickListener(listener);
    }

    private void setText() {
        tvCourseTopName.setText(c.getName());
    }

    private void initClass() {
        fm = getSupportFragmentManager();
    }

    private void getCourseInfo() {
        badges = (ArrayList<Badge>) getIntent().getSerializableExtra("badge");
        c = (CourseModel) getIntent().getSerializableExtra(ContextUtil.CATEGORY_COURSE);
        b = new Bundle();
        b.putInt("courseID", c.getId());
        b.putString("courseName", c.getName());
        b.putString("bgUrl", c.getCover_image());
        b.putSerializable(ContextUtil.CATEGORY_COURSE, c);
        b.putSerializable("badge", badges);
        isFromMyCourse = Constants.MY_COURSE.equals(getIntent().getStringExtra(Constants.ACTIVITY_NAME_KEY));
        if (isFromMyCourse) {
            ll_go_to_study.setVisibility(View.VISIBLE);
            tvCourseArrange.performClick();
        } else {
            tvCourseInfo.performClick();
        }
    }
//    private ProgressDialog loading;

    private void entrollCourse() {
        if (!API.getAPI().alreadySignin()) {
            KKDialog.getInstance().showLoginDialog(this, new OnClickListener() {
                @Override
                public void onClick(View v) {
                    Constants.LOGIN_FROM = Constants.FROM_PAY;
                    Intent intent = new Intent(CourseInfomationActivity.this, LoginActivity2.class);
                    intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
                    intent.putExtra("badge", badges);
                    intent.putExtra(ContextUtil.CATEGORY_COURSE, c);
                    startActivity(intent);
                    KKDialog.getInstance().dismiss();
                }
            }, new OnClickListener() {
                @Override
                public void onClick(View v) {
                    KKDialog.getInstance().dismiss();
                }
            });
            return;
        } else {
            if (Constants.NO_NET == NetUtil.getNetType(CourseInfomationActivity.this)) {
                handler.sendEmptyMessage(Constants.THERE_IS_NONET);
                return;
            }
//            loading = ProgressDialog.show(CourseInfomationActivity.this,"系统提示","正在进入课程安排",true,false);
            KKDialog.getInstance().showLoadCourse(CourseInfomationActivity.this, "");
            new Thread() {
                public void run() {
                    Constants.isFreshMyCourse = true;
                    try {
                        EnrollCourseAPI.entrollCourse(c.getId());
                        if (CourseSquareActivity.getMainActivity() != null) {
                            LocalStorage.sharedInstance().setIds(CoursesAPI.getMyCoursesId(false));
                        }
                    } catch (DibitsExceptionC e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                    KKDialog.getInstance().dismiss();
//                    loading.dismiss();
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            clickCourseArrange();
                        }
                    });
                }

                ;
            }.start();
        }
    }

    public void stepIntoCourseArrange() {
        if (ll_go_to_study.getVisibility() == View.VISIBLE && !isFromMyCourse) {
            KKDialog.getInstance().showErollCourseDialog(this,
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            KKDialog.getInstance().dismiss();
                            entrollCourse();
                        }
                    },
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            KKDialog.getInstance().dismiss();
                        }
                    });
        } else {
            clickCourseArrange();
        }
    }

    private void clickCourseArrange() {
        hideView(R.id.tv_course_arrange);
        changeBg(tvCourseArrange);
        if (caf == null) {
            FragmentTransaction ft3 = fm.beginTransaction();
            caf = new CourseArrangeFragment();
            caf.setArguments(b);
            ft3.add(R.id.ll_course_arrange_container, caf);
            ft3.commit();
        }
        if (ciif != null) {
            ciif.release();
        }
    }

    private void hideView(int id) {
        switch (id) {
            case R.id.tv_course_info:
                sv.setVisibility(View.VISIBLE);
                ll_course_info_container.setVisibility(View.GONE);
                ll_course_arrange_container.setVisibility(View.GONE);
                break;
            case R.id.tv_instructor_info:
                sv.setVisibility(View.GONE);
                ll_course_info_container.setVisibility(View.VISIBLE);
                ll_course_arrange_container.setVisibility(View.GONE);
                break;
            case R.id.tv_course_arrange:
                ll_go_to_study.setVisibility(View.GONE);
                sv.setVisibility(View.GONE);
                ll_course_info_container.setVisibility(View.GONE);
                ll_course_arrange_container.setVisibility(View.VISIBLE);
                break;
            default:
                break;
        }
    }

    private void changeBg(View v) {
        TextView[] vs = {tvCourseInfo, tvInstructorInfo, tvCourseArrange};
        for (TextView view : vs) {
            view.setBackgroundDrawable(getResources().getDrawable(R.drawable.allcourse_tab_bg));
            if (view == v) {
                v.setBackgroundColor(getResources().getColor(R.color.white));
            }
        }
    }

    // 友盟分享设置
    public void shareSetting() {
        // 首先在您的Activity中添加如下成员变量
        mController = UMServiceFactory.getUMSocialService("com.umeng.share",
                RequestType.SOCIAL);
        mController.getConfig().removePlatform(SHARE_MEDIA.EMAIL, SHARE_MEDIA.SMS);

        String QQappID = "1101226009";
        String QQappKey = "c7394704798a158208a74ab60104f0ba";

        //分享到  QQ
        UMQQSsoHandler qqSsoHandler = new UMQQSsoHandler(this, QQappID,
                QQappKey);
        qqSsoHandler.addToSocialSDK();

        //分享到  QQ空间
        QZoneSsoHandler qZoneSsoHandler = new QZoneSsoHandler(this, "QQappID",
                QQappKey);
        qZoneSsoHandler.addToSocialSDK();

        String WeiXinappID = "wxef4c838d5f6cb77f";
        // 添加微信平台
        UMWXHandler wxHandler = new UMWXHandler(this, WeiXinappID);
        wxHandler.addToSocialSDK();
        // 支持微信朋友圈
        UMWXHandler wxCircleHandler = new UMWXHandler(this, WeiXinappID);
        wxCircleHandler.setToCircle(true);
        wxCircleHandler.addToSocialSDK();
        // 设置新浪SSO handler
        mController.getConfig().setSsoHandler(new SinaSsoHandler());
        // 设置腾讯微博SSO handler
        mController.getConfig().setSsoHandler(new TencentWBSsoHandler());
        //添加人人网SSO授权功能
        String RRappId = "270160";
        String RRAPI_KEY = "0d60afd0779b4126af1ff2b71e18ce6c";
        String RRSecret_Key = "908619d4f50147138e67f87a7ad888b3";
        RenrenSsoHandler renrenSsoHandler = new RenrenSsoHandler(this,
                RRappId, RRAPI_KEY,
                RRSecret_Key);
        mController.getConfig().setSsoHandler(renrenSsoHandler);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /** 使用SSO授权必须添加如下代码 */
        UMSsoHandler ssoHandler = mController.getConfig().getSsoHandler(
                requestCode);
        if (ssoHandler != null) {
            ssoHandler.authorizeCallBack(requestCode, resultCode, data);
        }
    }

    public void setTv_go_studyVis() {
        ll_go_to_study.setVisibility(View.VISIBLE);
    }

    public void setTv_go_studyGone() {
        ll_go_to_study.setVisibility(View.GONE);
    }

    public void setGone() {
        ll_course_info_title.setVisibility(View.GONE);
        ll_course_info_tab.setVisibility(View.GONE);
    }

    public void setVisible() {
        ll_course_info_title.setVisibility(View.VISIBLE);
        ll_course_info_tab.setVisibility(View.VISIBLE);
    }

    @Override
    public void onBackPressed() {
        if (ciif != null) {
            ciif.onBackPressed();
        }
        if (caf != null) {
            caf.onBackPressed();
        }
    }
}
