package com.kaikeba.activity;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.*;
import com.google.gson.JsonObject;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.adapter.CategoryCourseAdapter;
import com.kaikeba.adapter.MicroCourseAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.HttpUtilInterface;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.MicroInfo;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.MyListVIew;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.loaddata.LoadMyData;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.sso.UMSsoHandler;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by chris on 14-7-15.
 */
public class MicroCourseActivity extends BaseActivity implements View.OnClickListener {

    private LinearLayout microHead;
    private LinearLayout microBody;
    private LinearLayout ll_join_in_micro;
    private LinearLayout translate;
    private TextView joinMicro;
    private ImageView btnBackNormal;
    private ImageView btn_share_normal;
    private TextView tvCourseTopName;
    private TextView microIntroduction;  //微课程的介绍
    private ImageView microPrize;
    private ListView microCourseListView;
    private MyListVIew micro_course_lv;
    private CategoryCourseAdapter adapter;
    private MicroCourseAdapter microCourseAdapter;
    private ArrayList<CourseInfo.MicroSpecialties.Courses> microCourselist;

    private ArrayList<CourseModel> allCourseList = new ArrayList<CourseModel>();
    private CourseInfo.MicroSpecialties microCourseInfo;

    private RelativeLayout ll_video_player;
    private VideoPlayerView video_palyer;
    private int height;
    private int width;

    private BitmapUtils bitmapUtil;
    private int mCurVideoPos = 0;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    };

    private Context mContext;
    private AdapterView.OnItemClickListener onItemMicroCourseClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            if (!"online".equals(microCourselist.get(position).getStatus())) {
                return;
            }
            Intent it = new Intent();
            Bundle b = new Bundle();
            if (microCourselist.get(position).getType().equals("OpenCourse")) {
                it.setClass(MicroCourseActivity.this, OpenCourseActivity.class);
            } else {
                it.setClass(MicroCourseActivity.this, GuideCourseAcitvity.class);
            }
            b.putSerializable(ContextUtil.CATEGORY_COURSE, getCategoryCourseInfo(microCourselist.get(position)));
            it.putExtras(b);
            startActivity(it);
        }
    };

    private AdapterView.OnItemClickListener onItemMicro_CourseClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            if (!"online".equals(microCourselist.get(position).getStatus())) {
                return;
            }
            startAnimition();
            Intent it = new Intent();
            Bundle b = new Bundle();
            if (microCourselist.get(position).getType().equals("OpenCourse")) {
                it.setClass(MicroCourseActivity.this, OpenCourseActivity.class);
            } else {
                it.setClass(MicroCourseActivity.this, GuideCourseAcitvity.class);
            }
            b.putSerializable(ContextUtil.CATEGORY_COURSE, getCategoryCourseInfo(microCourselist.get(position)));
            it.putExtras(b);
            startActivity(it);
        }
    };

    private int fromHight;
    private int toHight;
    private boolean hasJoined = false;
    private HttpUtilInterface callBack = new HttpUtilInterface() {
        @Override
        public void onStart() {

        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {

        }

        @Override
        public void onSuccess(ResponseInfo<String> responseInfo) {
            KKDialog.getInstance().dismiss();
            Toast.makeText(MicroCourseActivity.this, "加入成功", Toast.LENGTH_LONG).show();
            joinMicro.setText("已经加入微专业,开始学习吧");
            hasJoined = true;
            startAnimition();
//            ll_join_in_micro.setEnabled(false);
            joinMicro.setTextColor(0xff008ccc);
            LoadMyData.loadMicroCourse(mContext);
            MicroInfo info = new MicroInfo();
            info.setJoin(true);
            info.setMicroId(microCourseInfo.getId());
            info.setUserId(API.getAPI().getUserObject().getId() + "");
            try {
                DataSource.getDataSourse().addMicroData(info);
            } catch (DbException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFailure(HttpException e, String s) {
            KKDialog.getInstance().dismiss();
            Toast.makeText(MicroCourseActivity.this, "加入失败", Toast.LENGTH_LONG).show();
            if (e.getExceptionCode() == 401) {
                Intent i = new Intent(mContext, AllCourseActivity.class);
                mContext.startActivity(i);
                ((Activity) mContext).finish();
            }
        }
    };
    private List<MicroInfo> list = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.micro_course_detail);
        mContext = this;
        microCourseInfo = (CourseInfo.MicroSpecialties) getIntent().getExtras().getSerializable("microcourseinfo");
        bitmapUtil = BitmapHelp.getBitmapUtils(MicroCourseActivity.this);
        initView();
        setData();
        initMediaPlayer();
        loadAllCourse();
    }
    public void pauseVideoPlayer(){
        video_palyer.pauseMediaPlayer();
    }
    @Override
    protected void onResume() {
        super.onResume();
        toHight = CommonUtils.getScreenHeight(MicroCourseActivity.this) * 2 / 3;
        if (API.getAPI().alreadySignin()) {
            setJoinMicro();
        }
        MobclickAgent.onPageStart("MicroCourseDetail"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    private void loadAllCourse() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object allCourseData) {
                if (allCourseData != null) {
                    allCourseList.addAll((ArrayList<CourseModel>) allCourseData);
                }
            }
        });
    }

    private CourseModel getCategoryCourseInfo(CourseModel course) {
        CourseModel info = null;
        if (allCourseList != null) {
            for (int i = 0; i < allCourseList.size(); i++) {
                if (course.getId() == allCourseList.get(i).getId()) {
                    info = allCourseList.get(i);
                }
            }
        }
        if (info == null) {
            return course;
        }
        return info;
    }

    private void initMediaPlayer() {
        width = CommonUtils.getScreenWidth(MicroCourseActivity.this);
//        height = (int)(Constants.COVER_HEIGHT * (Constants.SCREEN_WIDTH - 10 * Constants.SCREEN_DENSITY) /Constants.COVER_WIDTH + 0.5);
        height = (CommonUtils.getScreenWidth(MicroCourseActivity.this) * 9) / 16;
        Log.e("ssss", "Constants.SCREEN_WIDTH:" + CommonUtils.getScreenWidth(MicroCourseActivity.this) + "   height:" + height);
        ll_video_player = (RelativeLayout) findViewById(R.id.rl_video_player);
        ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        Constants.FULL_SCREEN_NO_CLICK = false;
        video_palyer = new VideoPlayerView(MicroCourseActivity.this);

        video_palyer.preparePlayData(microCourseInfo.getUrl_about_video(), microCourseInfo.getImage_url(), mCurVideoPos, 0, 0);
        ll_video_player.addView(video_palyer.makeControllerView());
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (video_palyer != null) {
            video_palyer.screenChange(newConfig, height);
        }
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setMicroVisiable(false);
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            setMicroVisiable(true);
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onBackPressed() {
        if (translate.getVisibility() == View.VISIBLE) {
            startAnimition();
            return;
        }

        if (!video_palyer.isScaleTag) {
            if (API.getAPI().alreadySignin()) {
                if (Constants.LOGIN_FROM != Constants.FROM_MYMICRO_COURSE) {
                    Intent intent = new Intent(MicroCourseActivity.this, TabCourseActivity.class);
                    intent.putExtra("TabTag", "CourseHome");
                    intent.putExtra("TabNum", 2);
                    startActivity(intent);
                    finish();
                } else {
                    finish();
                }
            } else {
                finish();
            }
        } else {
            video_palyer.onBackPressed();
            setMicroVisiable(true);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (video_palyer != null) {
            video_palyer.onDestroy();
            video_palyer.unregisterReceiver();
        }
        MobclickAgent.onPageEnd("MicroCourseDetail");
        MobclickAgent.onPause(this);
    }

    private void setData() {
        tvCourseTopName.setText(microCourseInfo.getName());
        microIntroduction.setText(microCourseInfo.getIntro());
        microCourselist = microCourseInfo.getCourses();
        adapter = new CategoryCourseAdapter(this, microCourselist, handler);
        microCourseAdapter = new MicroCourseAdapter(this, microCourselist);
        microCourseListView.setAdapter(adapter);
        micro_course_lv.setAdapter(microCourseAdapter);
    }

    private void initView() {
        findViewById(R.id.btn_course_info).setVisibility(View.GONE);
        findViewById(R.id.btn_share_normal).setVisibility(View.VISIBLE);
        btnBackNormal = (ImageView) findViewById(R.id.iv_back);
        btn_share_normal = (ImageView) findViewById(R.id.btn_share_normal);
        tvCourseTopName = (TextView) findViewById(R.id.tv_text);
        microIntroduction = (TextView) findViewById(R.id.micro_introduction);
        // 证书根据实际图片大小设置
        microPrize = (ImageView) findViewById(R.id.micro_prize);
        double picHeight = (1275 / 1620.0) * (CommonUtils.getScreenWidth(MicroCourseActivity.this) - CommonUtils.dip2px(MicroCourseActivity.this, 48)) + 0.5;
        int height = (int) picHeight;
        Log.i("picHeight", picHeight + "");
        microPrize.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, height));

        microCourseListView = (ListView) findViewById(R.id.micro_course_listview);
        microCourseListView.setFocusable(false);
        microCourseListView.setOnItemClickListener(onItemMicroCourseClickListener);
        micro_course_lv = (MyListVIew) findViewById(R.id.micro_course_lv);
        micro_course_lv.setOnItemClickListener(onItemMicro_CourseClickListener);
        microBody = (LinearLayout) findViewById(R.id.micro_body);
        microHead = (LinearLayout) findViewById(R.id.micro_head);
        ll_join_in_micro = (LinearLayout) findViewById(R.id.ll_join_in_micro);
        translate = (LinearLayout) findViewById(R.id.translate);
        joinMicro = (TextView) findViewById(R.id.join_in_micro);

        bitmapUtil.display(microPrize, microCourseInfo.getCertificate_url(),BitmapHelp.getBitMapConfig(MicroCourseActivity.this,R.drawable.certificate_default));
        Log.i("MicroCourseActivity", microCourseInfo.getCertificate_url());

        btn_share_normal.setVisibility(View.VISIBLE);
        btnBackNormal.setOnClickListener(this);
        btn_share_normal.setOnClickListener(this);
        microPrize.setOnClickListener(this);
        ll_join_in_micro.setOnClickListener(this);
        translate.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(btnBackNormal)) {
            if (API.getAPI().alreadySignin()) {
                if (Constants.LOGIN_FROM != Constants.FROM_MYMICRO_COURSE) {
                    Intent intent = new Intent(MicroCourseActivity.this, TabCourseActivity.class);
                    intent.putExtra("TabTag", "CourseHome");
                    intent.putExtra("TabNum", 2);
                    startActivity(intent);
                    finish();
                } else {
                    finish();
                }
            } else {
                finish();
            }
        } else if (v.equals(btn_share_normal)) {
            pauseVideoPlayer();
            CommonUtils.shareSettingContent(mContext, "http://www.kaikeba.com/micro_specialties/" + microCourseInfo.getId(), microCourseInfo.getName(),
                    "我参加了开课吧的微专业，小伙伴们有木有一起来哒？" + "http://www.kaikeba.com/micro_specialties/" + microCourseInfo.getId(), microCourseInfo.getImage_url(), "#新课抢先知#我已经快要拿到@开课吧官方微博 的“" + microCourseInfo.getName() + "”微专业证书了，好开森。这年头纸证书擦屁股都嫌硬，唯有电子证书才高端大气。" + "http://www.kaikeba.com/micro_specialties/" + microCourseInfo.getId());
        } else if (microPrize.equals(v)) {

            System.out.println("microPrize height " + microPrize.getMeasuredHeight() + "");
            System.out.println("microPrize width " + microPrize.getMeasuredWidth() + "");

            Intent it = new Intent();
            it.putExtra("zoom_img_url", microCourseInfo.getCertificate_url());
            it.setClass(MicroCourseActivity.this, ZoomImageActivity.class);
            startActivity(it, null);
//            doImage();
        } else if (ll_join_in_micro.equals(v)) {
            pauseVideoPlayer();
            if (!API.getAPI().alreadySignin()) {
                KKDialog.getInstance().showLoginDialog(MicroCourseActivity.this, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
                        Intent intent = new Intent(MicroCourseActivity.this, LoginActivity2.class);
                        intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
                        intent.putExtra(ContextUtil.CATEGORY_COURSE, microCourseInfo);
                        startActivity(intent);
                        KKDialog.getInstance().dismiss();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        KKDialog.getInstance().dismiss();
                    }
                });
                return;
            } else {
                if (NetworkUtil.isNetworkAvailable(MicroCourseActivity.this)) {
                    if (hasJoined) {
                        startAnimition();
                    } else {
                        joinMicroCourse();
                    }
                } else {
                    Toast.makeText(MicroCourseActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                }
            }
        } else if (v.equals(translate)) {
            startAnimition();
            translate.setVisibility(View.GONE);
        }
    }

    private void joinMicroCourse() {
        String url = HttpUrlUtil.MICRO_JOIN;//"https://api.kaikeba.com/v1/micro_specialties/join";
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("user_id", API.getAPI().getUserObject().getId());
        jsonObject.addProperty("micro_specialty_id", microCourseInfo.getId());
        String jsonStr = jsonObject.toString();
        KKDialog.getInstance().showLoadCourse(MicroCourseActivity.this, "正在加载中");
        try {
            UploadData.getInstance().sendData(jsonStr, url, callBack);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void startAnimition() {
        if (translate.getVisibility() == View.VISIBLE) {
            translate.setVisibility(View.GONE);
        } else {
            translate.setVisibility(View.VISIBLE);
        }
        CommonUtils.measureView(ll_join_in_micro);
        fromHight = ll_join_in_micro.getMeasuredHeight();

        ViewWrapper viewWrapper = new ViewWrapper(ll_join_in_micro);
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "height", fromHight, toHight)
        );
        set.setDuration(1 * 200).start();
        toHight = fromHight;
    }

    private String getKey() {
        return API.getAPI().getUserObject().getId() + microCourseInfo.getId() + "";
    }

    private void setMicroVisiable(boolean visiable) {
        if (visiable) {
            microBody.setVisibility(View.VISIBLE);
            microHead.setVisibility(View.VISIBLE);
            ll_join_in_micro.setVisibility(View.VISIBLE);
        } else {
            microBody.setVisibility(View.GONE);
            microHead.setVisibility(View.GONE);
            ll_join_in_micro.setVisibility(View.GONE);
        }
    }

    private void setJoinMicro() {
        try {
            list = DataSource.getDataSourse().findAllMicro();
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    if (microCourseInfo.getId() == list.get(i).getMicroId()) {
                        if (list.get(i).isJoin()) {
                            joinMicro.setText("已经加入微专业,开始学习吧");
                            hasJoined = true;
//                            ll_join_in_micro.setEnabled(false);
                            joinMicro.setTextColor(0xff008ccc);
                        }
                    }
                }
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /** 使用SSO授权必须添加如下代码 */
        UMSsoHandler ssoHandler = CommonUtils.mController.getConfig().getSsoHandler(
                requestCode);
        if (ssoHandler != null) {
            ssoHandler.authorizeCallBack(requestCode, resultCode, data);
        }
    }

    class ViewWrapper {
        private View mTarget;

        public ViewWrapper(View target) {
            mTarget = target;
        }

        public int getWidth() {
            return mTarget.getLayoutParams().width;
        }

        public void setWidth(int width) {
            mTarget.getLayoutParams().width = width;
            mTarget.requestLayout();
        }

        public int getHeight() {
            return mTarget.getLayoutParams().height;
        }

        private void setHeight(int height) {
            mTarget.getLayoutParams().height = height;
            mTarget.requestLayout();
        }
    }
}
