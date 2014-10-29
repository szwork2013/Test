package com.kaikeba.activity;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.fragment.BaseCouseFragment;
import com.kaikeba.activity.fragment.CourseRecommendFragment;
import com.kaikeba.activity.fragment.LookRemarkFragment;
import com.kaikeba.activity.fragment.OutLineCourseFragment;
import com.kaikeba.activity.phoneutil.CollectManager;
import com.kaikeba.adapter.StudyAdapter;
import com.kaikeba.common.BaseClass.BaseFragmentActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.EnrollCourseAPI;
import com.kaikeba.common.entity.CollectInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.ErrorInfo;
import com.kaikeba.common.entity.LmsCourseInfo;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.MyToast;
import com.kaikeba.loaddata.LoadMyData;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.sso.UMSsoHandler;

import java.lang.reflect.Type;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by mjliu on 14-7-29.
 */

public class GuideCourseAcitvity extends BaseFragmentActivity {
    private static GuideCourseAcitvity guideCourseAcitvity;
    public boolean isFromMyCourse;
    /**
     * 最后引入的班次
     */
    LmsCourseInfo.Lms_Course_List nearest_lms_course;
    AdapterView.OnItemClickListener item2ClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {
            String status = unenrolled_lms_course_list.get(position).getStatus();
            nearest_lms_course = unenrolled_lms_course_list.get(position);
            enrollLmsCourse(nearest_lms_course.getLms_course_id());
        }
    };
    private ImageView btn_share_normal;
    private ImageView btnBackNormal;
    private ImageView btn_favor;
    private TextView tvCourseTopName;
    private TextView tvCourseInfo;
    private TextView tvCourseOutline;
    private TextView tvLookRemark;
    private TextView tvCourseRecommend;
    private BaseCouseFragment baseCouseFragment;
    private OutLineCourseFragment outLineCourseFragment;
    private LookRemarkFragment lookRemarkFragment;
    private CourseRecommendFragment courseRecommendFragment;
    private LinearLayout go_study_layout;
    private LinearLayout go_on_study;
    private TextView go_to_study;
    private TextView has_joined_course;
    private LinearLayout see_more_course;
    private LinearLayout translate;
    private ListView study_listview;
    private ListView unenrolled_listview;
    private RelativeLayout favor_course;
    private ImageView favor_course_txt;
    private LinearLayout ll_course_guide_info;
    private TextView tv_go_study;
    private ImageView iv_go_to_study;
    private FragmentManager fm;
    private CourseModel c;
    private Bundle b;
    AdapterView.OnItemClickListener item1ClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {
            String status = enrolled_or_close_list.get(position).getStatus();
            if (!status.equals("unenrolled")) {
                Intent intent = new Intent(GuideCourseAcitvity.this, GuideCourseLearnActivity.class);
                b.putSerializable(ContextUtil.CATEGORY_COURSE, c);
                b.putInt("lms_course_id", lmsCourseInfo.getLms_course_list().get(position).getLms_course_id());
                intent.putExtras(b);
                startActivity(intent);
            }
        }
    };
    private Bundle bundle;
    private LinearLayout courseInfoContainer;
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;
    private RelativeLayout rel_enrolled;
    private RelativeLayout rel_unenrolled;
    private boolean has_enrolled_or_close;
    private boolean has_unenrolled;
    /**
     * enrolled_or_close列表
     */
    private List<LmsCourseInfo.Lms_Course_List> enrolled_or_close_list;
    /**
     * unenrolled列表
     */
    private List<LmsCourseInfo.Lms_Course_List> unenrolled_lms_course_list;
    /**
     * 已加入班次ID
     */
    private int lms_course_id;
    /**
     * 班次信息
     */
    private LmsCourseInfo lmsCourseInfo;
    /**
     * enroll班次数量
     */
    private int number_of_enrolled_lms_course;
    /**
     * 班次列表
     */
    private List<LmsCourseInfo.Lms_Course_List> lms_course_list;
    /**
     * 最后引入的班次位置
     */
    private int position_of_nearest_enrolled;
    private RelativeLayout rl_video_player;
    private StudyAdapter enrolledAdapter;
    private StudyAdapter unenrolledAdapter;
    private Context mContext;
    private Logcat mlogcat;
    private ObjectAnimator fadeAnim;
    private int fromHight;
    private int toHight;
    private List<TextView> tvs;
    //班次信息
    private PopupWindow mNearest_info_pop;
    private View mNearest_view;
    private TextView nearest_txt;
    private View top_line;
    //班次开始和结束时间
    private String start_at;
    private String end_at;
    private View.OnClickListener listener = new View.OnClickListener() {

        @Override
        public void onClick(View v) {
            int id = v.getId();
            switch (id) {
                case R.id.iv_back:
                    appointSkip();
                    break;
                case R.id.favor:
                    if (!API.getAPI().alreadySignin()) {
                        KKDialog.getInstance().showLoginDialog(GuideCourseAcitvity.this, new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_GUIDECOURSE;
                                Intent intent = new Intent(GuideCourseAcitvity.this, LoginActivity2.class);
                                intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
                                intent.putExtra(ContextUtil.CATEGORY_COURSE, c);
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
                        if (NetworkUtil.isNetworkAvailable(GuideCourseAcitvity.this)) {
                            KKDialog.getInstance().showProgressBar(GuideCourseAcitvity.this, KKDialog.IS_LOADING);
                            new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        CollectManager.getInstance().collect(isCollectflag, handler, c);
                                    } catch (DibitsExceptionC e) {
                                        e.printStackTrace();
                                        if (e.getErrorCode() == 401) {
                                            handler.sendEmptyMessage(Constants.LOGIN_TIME_OUT);
                                        } else {
                                            handler.sendEmptyMessage(Constants.COLLECT_EEROR);
                                        }
                                    }
                                    //执行收藏操作

                                }
                            }).start();
                        } else {
                            Toast.makeText(GuideCourseAcitvity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                        }

                    }
                    break;
                case R.id.btn_share_normal:
                    baseCouseFragment.pauseVideoPlayer();
                    CommonUtils.shareSettingContent(GuideCourseAcitvity.this, "http://www.kaikeba.com/courses/" + c.getId(), c.getName(),
                            "我正在开课吧观看《" + c.getName() + "》这门课，老师讲得吼赛磊呀！小伙伴们要不要一起来呀" + "http://www.kaikeba.com/courses/" + c.getId(), c.getCover_image(), "#新课抢先知#这课讲的太屌了，朕灰常满意！小伙伴们不要太想我，我在@开课吧官方微博 虐学渣，快来和我一起吧！" + "http://www.kaikeba.com/courses/" + c.getId());
                    break;
                case R.id.tv_course_info:
                    Constants.current_position = Constants.BASE_COURSE;
                    resetFocuse(R.id.tv_course_info);
                    setBaseCourseFragment();
                    break;
                case R.id.tv_course_outline:
                    Constants.current_position = Constants.OUT_LINE_COURSE;
                    resetFocuse(R.id.tv_course_outline);
                    setCourseOutLineFragment();
                    break;
                case R.id.tv_look_remark:
                    Constants.current_position = Constants.LOOK_REMARK;
                    resetFocuse(R.id.tv_look_remark);
                    stLooKRemarkFragment();
                    break;
                case R.id.tv_course_recommend:
                    Constants.current_position = Constants.RECOMMEND_COURSE;
                    resetFocuse(R.id.tv_course_recommend);
                    setCourseRecommendFragment();
                    break;
                case R.id.go_on_study:
                    if (go_to_study.getText().toString().equals("学习此课程")) {
                        baseCouseFragment.pauseVideoPlayer();
                    }
                    if (!API.getAPI().alreadySignin()) {
                        KKDialog.getInstance().showLoginDialog(GuideCourseAcitvity.this, new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_GUIDECOURSE;
                                Intent intent = new Intent(GuideCourseAcitvity.this, LoginActivity2.class);
                                intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
                                intent.putExtra(ContextUtil.CATEGORY_COURSE, c);
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
                        if (go_to_study.getText().toString().equals("学习此课程")) {
                            startAnimition();
                            if (translate.getVisibility() == View.VISIBLE) {
                                translate.setVisibility(View.GONE);
                            } else {
                                translate.setVisibility(View.VISIBLE);
                            }
                            if (has_enrolled_or_close) {
                                rel_enrolled.setVisibility(View.VISIBLE);
                            }
                            if (has_unenrolled) {
                                rel_unenrolled.setVisibility(View.VISIBLE);
                            }
                            favor_course.setVisibility(View.VISIBLE);
                        } else {
                            Intent intent = new Intent(GuideCourseAcitvity.this, GuideCourseLearnActivity.class);
                            b.putInt("lms_course_id", lms_course_id);
                            b.putSerializable(ContextUtil.CATEGORY_COURSE, c);
                            intent.putExtras(b);
                            startActivity(intent);
                        }
                    }
                    break;
                case R.id.translate:
                    translate.setVisibility(View.GONE);
                    ll_course_guide_info.setVisibility(View.VISIBLE);
                    if (see_more_course.getVisibility() == View.VISIBLE) {
                        go_on_study.setVisibility(View.VISIBLE);
                        startZoomedAnimition();
                        leftIn();
                    } else {
                        startAnimition();
                    }
                    break;
                case R.id.see_more_course:
                    baseCouseFragment.pauseVideoPlayer();
                    if (translate.getVisibility() == View.VISIBLE) {
                        translate.setVisibility(View.GONE);
                    } else {
                        translate.setVisibility(View.VISIBLE);
                    }
                    if (go_on_study.getVisibility() == View.VISIBLE) {
                        disMissLms_pop();
                        startZoomacAnimition();
                        leftOut();
                    } else {
                        go_on_study.setVisibility(View.VISIBLE);
                        startZoomedAnimition();
                        leftIn();
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                showLMS_pop("班次:" + start_at + "-" + end_at);
                            }
                        }, 700);
                    }
                    break;
                case R.id.favor_course:
                    if (NetworkUtil.isNetworkAvailable(GuideCourseAcitvity.this)) {
                        KKDialog.getInstance().showProgressBar(GuideCourseAcitvity.this, KKDialog.IS_LOADING);
                        new Thread(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    CollectManager.getInstance().collect(isCollectflag, handler, c);
                                } catch (DibitsExceptionC e) {
                                    e.printStackTrace();
                                    if (e.getErrorCode() == 401) {
                                        handler.sendEmptyMessage(Constants.LOGIN_TIME_OUT);
                                    } else {
                                        handler.sendEmptyMessage(Constants.COLLECT_EEROR);
                                    }
                                }
                                //执行收藏操作
                            }
                        }).start();
                    } else {
                        Toast.makeText(GuideCourseAcitvity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                    }

                    break;

                default:
                    break;
            }
        }
    };
    private int bottom_height;
    private int location[];
    private boolean is_DisWindow = false;
    private boolean isHas_data = false;
    private boolean isCollectflag = false;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case Constants.GET_DATA_SUCCESS:
                    isEnroll();
                    break;
                case Constants.LOGIN_TIME_OUT:
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                    break;
                case Constants.COURSE_TIME_OUT:
                    KKDialog.getInstance().dismiss();
                    Toast.makeText(GuideCourseAcitvity.this, "请求失败，稍候再试", Toast.LENGTH_SHORT).show();
                    break;
                case Constants.THERE_IS_NONET:
                    KKDialog.getInstance().dismiss();
                    KKDialog.getInstance().showNoNetToast(GuideCourseAcitvity.this);
                    break;
                case Constants.COURSE_JOIN_SUCCESS:
                    String url = HttpUrlUtil.COURSES + c.getId() + "/user";
                    //enroll成功后加载下班次信息
                    loadLmsCourseInfo(url, false);
                    //enroll成功后加载下我的导学课
                    LoadMyData.loadMyGuideCourse(mContext);
                    KKDialog.getInstance().dismiss();
                    lms_course_id = nearest_lms_course.getLms_course_id();
                    iv_go_to_study.setImageResource(R.drawable.iv_go_to_study);
                    go_to_study.setText("继续学习");
                    start_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(nearest_lms_course.getStart_at())));
                    end_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(nearest_lms_course.getConclude_at())));
                    try {
                        start_at = DateUtils.getYR(start_at);
                        end_at = DateUtils.getYR(end_at);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            showLMS_pop("班次:" + start_at + "-" + end_at);
                        }
                    }, 700);
//                    has_joined_course.setText("加入过班次：" + nearest_lms_course.getStart_at() + "———" + nearest_lms_course.getConclude_at());
//                    has_joined_course.setVisibility(View.VISIBLE);
                    see_more_course.setVisibility(View.VISIBLE);
                    go_on_study.setVisibility(View.VISIBLE);
                    if (translate.getVisibility() == View.VISIBLE) {
                        translate.setVisibility(View.GONE);
                        ll_course_guide_info.setVisibility(View.VISIBLE);
                        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) see_more_course.getLayoutParams();
                        layoutParams.weight = 0;
                        see_more_course.setLayoutParams(layoutParams);
                        startZoomedAnimition();
                        leftIn();
                    }
                    Intent intent = new Intent(GuideCourseAcitvity.this, GuideCourseLearnActivity.class);
                    b.putSerializable(ContextUtil.CATEGORY_COURSE, c);
                    b.putInt("lms_course_id", lms_course_id);
                    intent.putExtras(b);
                    startActivity(intent);

                    break;
                case 6:
                    KKDialog.getInstance().dismiss();
                    setFavorIcon(false);
                    isCollectflag = false;
                    try {
                        List<CollectInfo> list = getCollectCourseList();
                        CollectInfo cancelInfo = null;
                        for (int index = 0; index < list.size(); index++) {
                            if (c.getId() == list.get(index).getCourseId()) {
                                cancelInfo = list.get(index);
                            }
                        }
                        DataSource.getDataSourse().deleteCollectData(cancelInfo);
                    } catch (DbException e) {
                        e.printStackTrace();
                    }
                    Toast.makeText(mContext, "取消收藏", Toast.LENGTH_SHORT).show();
                    break;
                case 7:
                    KKDialog.getInstance().dismiss();
                    setFavorIcon(true);
                    isCollectflag = true;
                    LoadMyData.loadCollect(mContext);
                    try {
                        CollectInfo info = new CollectInfo();
                        info.setConllect(true);
                        info.setCourseId(c.getId());
                        info.setUserId(API.getAPI().getUserObject().getId() + "");
                        DataSource.getDataSourse().addCollectData(info);
                    } catch (DbException e) {
                        e.printStackTrace();
                    }
//                    Toast.makeText(mContext, "收藏成功", Toast.LENGTH_SHORT).show();
                    MyToast.getInstance().okToast("收藏成功");
                    break;
                case Constants.COLLECT_EEROR:
                    KKDialog.getInstance().dismiss();
                    Toast.makeText(GuideCourseAcitvity.this, "加载失败，请稍后再试", Toast.LENGTH_SHORT).show();
                    break;
            }

        }
    };
    private List<CourseModel> cs = new ArrayList<CourseModel>();
    private int screenHeight;
    private int screenWeight;

    public static GuideCourseAcitvity getGuideCourseAcitvity() {
        return guideCourseAcitvity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.guide_course_info);
        guideCourseAcitvity = this;
        mContext = this;
        fm = getSupportFragmentManager();
        mlogcat = new Logcat();
        getCourseInfo();
        initView();
        initData();
//        setBaseCourseFragment();
        loadAllCourseData();
        tvCourseInfo.performClick();
        toHight = CommonUtils.getScreenHeight(this) * 2 / 3;
        screenHeight = CommonUtils.getScreenHeight(this);
        screenWeight = CommonUtils.getScreenWidth(this);
    }

    private void initData() {
        lms_course_list = new ArrayList<LmsCourseInfo.Lms_Course_List>();
        enrolled_or_close_list = new ArrayList<LmsCourseInfo.Lms_Course_List>();
        unenrolled_lms_course_list = new ArrayList<LmsCourseInfo.Lms_Course_List>();
        enrolledAdapter = new StudyAdapter(GuideCourseAcitvity.this, enrolled_or_close_list);
        unenrolledAdapter = new StudyAdapter(GuideCourseAcitvity.this, unenrolled_lms_course_list);
        study_listview.setAdapter(enrolledAdapter);
        study_listview.setOnItemClickListener(item1ClickListener);
        unenrolled_listview.setAdapter(unenrolledAdapter);
        unenrolled_listview.setOnItemClickListener(item2ClickListener);
    }

    private void setBaseCourseFragment() {
        FragmentTransaction ft1 = fm.beginTransaction();
        baseCouseFragment = new BaseCouseFragment();
        baseCouseFragment.setArguments(bundle);
        ft1.replace(R.id.course_info_container, baseCouseFragment);
        ft1.commit();
    }

    private void setCourseOutLineFragment() {
        FragmentTransaction ft1 = fm.beginTransaction();
        outLineCourseFragment = new OutLineCourseFragment();
        outLineCourseFragment.setArguments(bundle);
        ft1.replace(R.id.course_info_container, outLineCourseFragment);
        ft1.commit();
    }

    private void stLooKRemarkFragment() {
        FragmentTransaction ft1 = fm.beginTransaction();
        lookRemarkFragment = new LookRemarkFragment();
        lookRemarkFragment.setArguments(bundle);
        ft1.replace(R.id.course_info_container, lookRemarkFragment);
        ft1.commit();
    }

    private void setCourseRecommendFragment() {
        FragmentTransaction ft1 = fm.beginTransaction();
        courseRecommendFragment = new CourseRecommendFragment();
        courseRecommendFragment.setArguments(bundle);
        ft1.replace(R.id.course_info_container, courseRecommendFragment);
        ft1.commit();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("GuideCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
        isFromMyCourse = false;
        isCollectflag = false;
        setCollection();
        if (API.getAPI().alreadySignin()) {
            initLmsCourseListData(true);
            initLmsCourseListData(false);
        }
        is_DisWindow = false;
    }

    private void initView() {
        btnBackNormal = (ImageView) findViewById(R.id.iv_back);
        btn_share_normal = (ImageView) findViewById(R.id.btn_share_normal);
        btn_share_normal.setVisibility(View.VISIBLE);
        btn_favor = (ImageView) findViewById(R.id.favor);
        btn_favor.setVisibility(View.VISIBLE);
        tvCourseTopName = (TextView) findViewById(R.id.tv_text);
        tvCourseInfo = (TextView) findViewById(R.id.tv_course_info);
        tvCourseOutline = (TextView) findViewById(R.id.tv_course_outline);
        tvLookRemark = (TextView) findViewById(R.id.tv_look_remark);
        tvCourseRecommend = (TextView) findViewById(R.id.tv_course_recommend);
        tvs = new ArrayList<TextView>();
        tvs.add(tvCourseInfo);
        tvs.add(tvCourseOutline);
        tvs.add(tvLookRemark);
        tvs.add(tvCourseRecommend);
        rel_enrolled = (RelativeLayout) findViewById(R.id.rel_enrolled);
        rel_unenrolled = (RelativeLayout) findViewById(R.id.rel_unenrolled);
        go_on_study = (LinearLayout) findViewById(R.id.go_on_study);
        go_to_study = (TextView) findViewById(R.id.go_to_study);
        iv_go_to_study = (ImageView) findViewById(R.id.iv_go_to_study);
        has_joined_course = (TextView) findViewById(R.id.has_joined_course);
        see_more_course = (LinearLayout) findViewById(R.id.see_more_course);
        study_listview = (ListView) findViewById(R.id.enrolled_listview);
        unenrolled_listview = (ListView) findViewById(R.id.unenrolled_listview);
        favor_course = (RelativeLayout) findViewById(R.id.favor_course);
        favor_course_txt = (ImageView) findViewById(R.id.favor_course_txt);
//        tv_go_study = (TextView)findViewById(R.id.tv_go_study);
        ll_course_guide_info = (LinearLayout) findViewById(R.id.ll_course_guide_info);
        courseInfoContainer = (LinearLayout) findViewById(R.id.course_info_container);
        go_study_layout = (LinearLayout) findViewById(R.id.study_layout);
        translate = (LinearLayout) findViewById(R.id.translate);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        btn_favor.setOnClickListener(listener);
        btnBackNormal.setOnClickListener(listener);
        btn_share_normal.setOnClickListener(listener);
        tvCourseInfo.setOnClickListener(listener);
        tvCourseOutline.setOnClickListener(listener);
        tvLookRemark.setOnClickListener(listener);
        favor_course.setOnClickListener(listener);
        if (translate.getVisibility() != View.VISIBLE) {
            go_on_study.setOnClickListener(listener);
            see_more_course.setOnClickListener(listener);
        }
        tvCourseRecommend.setOnClickListener(listener);
        translate.setOnClickListener(listener);
        top_line = findViewById(R.id.top_line);

        tvCourseTopName.setText(c.getName());
        mNearest_view = LayoutInflater.from(mContext).inflate(R.layout.nearest_lms_info, null);
        nearest_txt = (TextView) mNearest_view.findViewById(R.id.nearest_txt);
        mNearest_info_pop = new PopupWindow(mNearest_view, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, true);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
                int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
                go_study_layout.measure(w, h);
                bottom_height = go_study_layout.getMeasuredHeight();
                location = new int[2];
                top_line.getLocationOnScreen(location);
            }
        }, 600);

    }

    private List<CollectInfo> getCollectCourseList() {
        try {
            return DataSource.getDataSourse().findAllCollect();

        } catch (DbException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void setCollection() {
        List<CollectInfo> list = getCollectCourseList();

        if (list == null) {
            return;
        }
        for (int i = 0; i < list.size(); i++) {
            if (c.getId() == list.get(i).getCourseId()) {
                isCollectflag = true;
                break;
            }
        }
        setFavorIcon(isCollectflag);
    }

    private void setFavorIcon(boolean isCollect) {
        if (isCollect) {
            btn_favor.setImageResource(R.drawable.collection_press_head);
            favor_course_txt.setImageResource(R.drawable.collected_guide);
        } else {
            btn_favor.setImageResource(R.drawable.collection_normal_head);
            favor_course_txt.setImageResource(R.drawable.add_colloct_guide);
        }
    }

    public void showLMS_pop(String info) {
        if (!is_DisWindow) {
            nearest_txt.setText(info);
            mNearest_info_pop.showAtLocation(top_line, Gravity.NO_GRAVITY, location[0], location[1] - bottom_height - 10);
            mNearest_info_pop.setAnimationStyle(R.style.app_pop);
            mNearest_info_pop.setOutsideTouchable(false);
            mNearest_info_pop.setFocusable(false);
            mNearest_info_pop.update();
        }
    }

    public void disMissLms_pop() {
        if (mNearest_info_pop != null && mNearest_info_pop.isShowing()) {
            mNearest_info_pop.dismiss();
        }
    }

    private void getCourseInfo() {
        b = getIntent().getExtras();
        bundle = new Bundle();
        bundle = b;
        c = (CourseModel) b.getSerializable(ContextUtil.CATEGORY_COURSE);
        bundle.putSerializable(ContextUtil.CATEGORY_COURSE, c);
    }

    private void isEnroll() {
        if (API.getAPI().alreadySignin()) {
            if (number_of_enrolled_lms_course > 0 && lmsCourseInfo.getLms_course_list().get(position_of_nearest_enrolled) != null) {
                boolean flag = false;
                for (int i = 0; i < number_of_enrolled_lms_course; i++) {
                    if (!lmsCourseInfo.getLms_course_list().get(i).getStatus().equals("close")) {
                        flag = true;
                        break;
                    }
                }
                if (flag) {
                    nearest_lms_course = lmsCourseInfo.getLms_course_list().get(position_of_nearest_enrolled);
                    lms_course_id = nearest_lms_course.getLms_course_id();
                    iv_go_to_study.setImageResource(R.drawable.iv_go_to_study);
                    go_to_study.setText("继续学习");
                    start_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(nearest_lms_course.getStart_at())));
                    end_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(nearest_lms_course.getConclude_at())));
                    try {
                        start_at = DateUtils.getYR(start_at);
                        end_at = DateUtils.getYR(end_at);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
//                has_joined_course.setText("班次:"+start_at+"-"+end_at);
//                has_joined_course.setVisibility(View.VISIBLE);
                    see_more_course.setVisibility(View.VISIBLE);
                    isHas_data = true;
                    if (translate.getVisibility() != View.VISIBLE) {
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                showLMS_pop("班次:" + start_at + "-" + end_at);
                            }
                        }, 700);
                    }
                } else {
                    see_more_course.setVisibility(View.GONE);
                    has_joined_course.setVisibility(View.GONE);
                }
            }
        } else {
            see_more_course.setVisibility(View.GONE);
            has_joined_course.setVisibility(View.GONE);
        }
    }

    private void initLmsCourseListData(boolean fromCache) {
        String url = "https://api.kaikeba.com/v1/courses/" + c.getId() + "/user";
        if (fromCache) {
            showloading();
        }
        loadLmsCourseInfo(url, fromCache);
    }

    private void showloading() {
        /*view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);*/
    }

    private void showSuccessData() {
        /*view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);*/
    }

    private void showNoData() {
       /* view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);*/
    }

    private void loadLmsCourseInfo(String url, final boolean fromCache) {
        Type type = new TypeToken<LmsCourseInfo>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    lmsCourseInfo = (LmsCourseInfo) data;
                    number_of_enrolled_lms_course = lmsCourseInfo.getNumber_of_enrolled_lms_course();
                    position_of_nearest_enrolled = lmsCourseInfo.getPosition_of_nearest_enrolled();
                    if (lmsCourseInfo.getLms_course_list() != null) {
                        lms_course_list.clear();
                        enrolled_or_close_list.clear();
                        unenrolled_lms_course_list.clear();
                        lms_course_list.addAll(lmsCourseInfo.getLms_course_list());
                        List<LmsCourseInfo.Lms_Course_List> enroll_list = new ArrayList<LmsCourseInfo.Lms_Course_List>();
                        List<LmsCourseInfo.Lms_Course_List> unenroll_list = new ArrayList<LmsCourseInfo.Lms_Course_List>();
                        if (lms_course_list != null && lms_course_list.size() > 0) {
                            for (LmsCourseInfo.Lms_Course_List lms_course : lms_course_list) {
                                if (lms_course.getStatus().equals("close") || lms_course.getStatus().equals("enrolled")) {
                                    enroll_list.add(lms_course);
                                } else {
                                    unenroll_list.add(lms_course);
                                }
                            }
                            if (enroll_list != null) {
                                enrolled_or_close_list.addAll(enroll_list);
                            }
                            if (unenroll_list != null) {
                                unenrolled_lms_course_list.addAll(unenroll_list);
                            }
                        }
                        if (enrolled_or_close_list != null && enrolled_or_close_list.size() > 0) {
                            has_enrolled_or_close = true;
                        }
                        if (unenrolled_lms_course_list != null && unenrolled_lms_course_list.size() > 0) {
                            has_unenrolled = true;
                        }
                        enrolledAdapter.notifyDataSetChanged();
                        unenrolledAdapter.notifyDataSetChanged();
                    }
                    handler.sendEmptyMessage(Constants.GET_DATA_SUCCESS);
                    showSuccessData();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    protected void loadAllCourseData() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    cs.clear();
                    cs.addAll((ArrayList<CourseModel>) data);
                }
                if (cs == null || cs.size() == 0) {
                    handler.sendEmptyMessage(2);
                } else {
                    for (CourseModel info : cs) {
                        if (c.getId() == info.getId()) {
                            c = info;
                            bundle.putSerializable(ContextUtil.CATEGORY_COURSE, c);
//                            lms_course_list.addAll(c.getLms_course_list());
                            enrolledAdapter.notifyDataSetChanged();
                            unenrolledAdapter.notifyDataSetChanged();
                            break;
                        }
                    }
                }
            }
        });
    }

    public void enrollLmsCourse(final int cLms_course_id) {
        if (Constants.NO_NET == NetUtil.getNetType(GuideCourseAcitvity.this)) {
            handler.sendEmptyMessage(Constants.THERE_IS_NONET);
            return;
        }
        KKDialog.getInstance().showLoadCourse(GuideCourseAcitvity.this, "正在加载中");
        new Thread() {
            public void run() {
                try {
                    ErrorInfo errorInfo = EnrollCourseAPI.entrollCourse(cLms_course_id);
                    if (null == errorInfo) {
                        handler.sendEmptyMessage(Constants.COURSE_TIME_OUT);
                    } else {
                        if (errorInfo.getMessage().equals("success")) {
                            handler.sendEmptyMessage(Constants.COURSE_JOIN_SUCCESS);

                            lms_course_id = cLms_course_id;
                        }
                    }
                } catch (DibitsExceptionC e) {
                    if (e.getErrorCode() == 401) {
                        handler.sendEmptyMessage(Constants.LOGIN_TIME_OUT);
                    }
                }


            }

            ;
        }.start();
    }

    public void leftOut() {
        fadeAnim = ObjectAnimator.ofFloat(go_on_study, "x", 0, -screenWeight / 2).setDuration(200);
        fadeAnim.start();
        fadeAnim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animator) {

            }

            @Override
            public void onAnimationEnd(Animator animator) {
                go_on_study.setVisibility(View.GONE);
                startAnimition();
                if (has_enrolled_or_close) {
                    rel_enrolled.setVisibility(View.VISIBLE);
                }
                if (has_unenrolled) {
                    rel_unenrolled.setVisibility(View.VISIBLE);
                }
                favor_course.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationCancel(Animator animator) {

            }

            @Override
            public void onAnimationRepeat(Animator animator) {

            }
        });
    }

    public void leftIn() {
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) go_on_study.getLayoutParams();
        layoutParams.weight = 1;
        fadeAnim = ObjectAnimator.ofFloat(go_on_study, "x", -screenWeight / 2, 0).setDuration(200);
        fadeAnim.start();
        fadeAnim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animator) {

            }

            @Override
            public void onAnimationEnd(Animator animator) {
                startAnimition();
            }

            @Override
            public void onAnimationCancel(Animator animator) {

            }

            @Override
            public void onAnimationRepeat(Animator animator) {

            }
        });
    }

    private void startAnimition() {
        CommonUtils.measureView(go_study_layout);
        fromHight = go_study_layout.getMeasuredHeight();
//        if(fromHight<toHight){
//            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) go_study_layout.getLayoutParams();
//            layoutParams.weight = 1;
//            go_study_layout.setLayoutParams(layoutParams);
//            LinearLayout.LayoutParams transParams = (LinearLayout.LayoutParams) translate.getLayoutParams();
//            layoutParams.weight = 2;
//            translate.setLayoutParams(transParams);
//        }else {
//            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) go_study_layout.getLayoutParams();
//            layoutParams.weight = 0;
//            go_study_layout.setLayoutParams(layoutParams);
//            LinearLayout.LayoutParams transParams = (LinearLayout.LayoutParams) translate.getLayoutParams();
//            layoutParams.weight = 0;
//            translate.setLayoutParams(transParams);
//        }

        ViewWrapper viewWrapper = new ViewWrapper(go_study_layout);
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "height", fromHight, toHight)
        );
        set.setDuration(1 * 200).start();
        toHight = fromHight;
    }

    private void startZoomacAnimition() {
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) see_more_course.getLayoutParams();
        layoutParams.weight = 0;
        see_more_course.setLayoutParams(layoutParams);
        ViewWrapper viewWrapper = new ViewWrapper(see_more_course);
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "width", screenWeight / 2,
                        screenWeight)
        );
        set.setDuration(200).start();
    }

    private void startZoomedAnimition() {
        ViewWrapper viewWrapper = new ViewWrapper(see_more_course);
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "width",
                        screenWeight, screenWeight / 2)
        );
        set.setDuration(200).start();
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("GuideCourse");
        MobclickAgent.onPause(this);
        is_DisWindow = true;
    }

    @Override
    public void onBackPressed() {
        if (translate.getVisibility() == View.VISIBLE) {
            translate.setVisibility(View.GONE);
            ll_course_guide_info.setVisibility(View.VISIBLE);
            if (see_more_course.getVisibility() == View.VISIBLE) {
                go_on_study.setVisibility(View.VISIBLE);
                startZoomedAnimition();
                leftIn();
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        showLMS_pop("班次:" + start_at + "-" + end_at);
                    }
                }, 700);
            } else {
                startAnimition();
            }
        } else {
//            Log.i("GuidCourseActivity",Constants.current_position+"");
            if (baseCouseFragment != null && Constants.current_position == Constants.BASE_COURSE) {
                baseCouseFragment.onBackPressed();
            } else {
                super.onBackPressed();
                appointSkip();
            }
        }
    }

    public void appointSkip() {
        if (Constants.FROM_WHERE == Constants.FROM_DYNAMIC) {
            Constants.FROM_WHERE = 0;
            Intent intent = new Intent(GuideCourseAcitvity.this, TabCourseActivity.class);
            intent.putExtra("TabTag", "Dynamic");
            intent.putExtra("TabNum", 0);
            startActivity(intent);
            finish();
        } else {
            finish();
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

    private void resetFocuse(int curId) {
        for (TextView tv : tvs) {
            if (tv.getId() == curId) {
                tv.setEnabled(false);
                tv.setTextColor(getResources().getColor(R.color.text_pressed));
            } else {
                tv.setEnabled(true);
                tv.setTextColor(getResources().getColor(R.color.text_normal));
            }
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
