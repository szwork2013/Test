package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.fragment.CourseArrangeFragment;
import com.kaikeba.activity.phoneutil.CollectManager;
import com.kaikeba.adapter.AppraiseListAdapter;
import com.kaikeba.adapter.TeacherAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.download.DownloadInfo;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.entity.*;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.*;
import com.kaikeba.common.watcher.Watcher;
import com.kaikeba.common.widget.CollapsibleTextView;
import com.kaikeba.common.widget.MyToast;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.common.widget.XDListView;
import com.kaikeba.loaddata.LoadMyData;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.sso.UMSsoHandler;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GuideCourseLearnActivity extends BaseActivity implements Watcher {
    private static final String TAG = "GuideCourseLearnActivity";
    private static GuideCourseLearnActivity guidCourseLearnActivity;
    public boolean initVideoPlayerSuccess = false;
    private CourseArrangeAdapter adapter;
    private IAdapter load_adapter;
    //    private String courseID;
    private LayoutInflater inflater;
    private RelativeLayout view_loading;
    private ImageView loading_fail;
    private LinearLayout view_loading_fail;
    private XDListView exList;
    private String pageURL;
    private List<ModuleVideo> moduleVideos;
    private List<Appraisement> appraisementList;
    private List<CourseModel.CourseArrange> courseArranges;
    private List<CourseModel.Item> courseTitles;
    private CourseModel.Items item;
    private List<Module> modules;
    private List<ArrayList<Item>> olditemLists;
    private List<Item> items = new ArrayList<Item>();
    private List<String> modulesIds = new ArrayList<String>();
    private List<String> itemIds = new ArrayList<String>();
    private Map<String, String> urlMap = new HashMap<String, String>();
    private ImageView iv_course_info_play;
    private DownloadManager downloadManager;
    private String splitStr = "_";
    //    private String courseName;
//    private String bgUrl;
    private VideoPlayerView video_palyer;
    private RelativeLayout rl_video_player;
    private BitmapUtils bitmapUtils;
    private int height;
    private int width;
    private int bar_height;
    private int witchWeek;
    /**
     * ***************************************************************
     */
    private ImageView btn_course_info;
    private ImageView btnBackNormal;
    private TextView tvCourseTopName;
    private CourseArrangeFragment caf;
    private CourseModel c;
    private Context mContext;
    private String current_url;
    private String current_body;
    private String current_themeImg;
    private String current_title;
    private LinearLayout ll_bottom;
    private LinearLayout ll_course_info_title;
    private RelativeLayout rel_load_bottom;
    private RelativeLayout rel_appraise_bottom;
    private RelativeLayout rel_share_bottom;
    private RelativeLayout rel_collect_bottom;
    private ImageView iv_collect_num;
    private TextView tv_appraise_count;
    //遮罩View
    private View shade_view;
    //底部弹出评价页
    private PopupWindow mAppraisePopupWindow;
    private View appraise_pop;
    private View appraise_outside_view;
    private ListView appraise_list;
    private AppraiseListAdapter appraiseListAdapter;
    private RelativeLayout appraise_view_loading;
    private LinearLayout appraise_loading_fail;
    //底部弹出下载页
    private PopupWindow mDownloadPopupWindow;
    private View download_pop;
    private View download_outside_view;

    private ExpandableListView load_expandableCourseInfo;
    private RelativeLayout rel_go_download_manage;
    private TextView download_video_total_num;
    private TextView open_all_select;
    private TextView open_down_load;
    private int selected_num;
    private boolean allSelected;
    private boolean from_download_manage = true;
    private boolean is_all_loading = false;
    private CollectionCount collectionCount;
    private List<CourseModel> allCourseInfo = new ArrayList<CourseModel>();
    private int count;
    private Collection mCollection;
    private int popShowHeight;
    private int mCurVideoPos;
    private CourseModel curCourse;
    private ListView lv_video;
    private boolean isClick = true;
    private int lms_course_id;
    private int open_weeks;
    private int myguide_number;
    private boolean witchWeekFlag;
    private ArrayList<CourseModel.CourseArrange> modulesForDownload;
    private ArrayList<ArrayList<CourseModel.Items>> itemsForDownload;
    private boolean hasAppraiseData = false;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            int id = v.getId();
            switch (id) {
                case R.id.iv_back:
                    appointSkip();
                    break;
                case R.id.btn_share_normal:
                    if (InfoPopWindow.isShowing()) {
                        InfoPopWindow.dismiss();// 关闭
                    } else {
                        setInfoContent();
                        InfoPopWindow.showAsDropDown(btn_course_info);// 显示
                        pauseVideoPlayer();
                    }
                    break;
                case R.id.outside_view:
                    if (InfoPopWindow.isShowing()) {
                        InfoPopWindow.dismiss();// 关闭
                    }
                    break;
                case R.id.download_outside_view:
                    dismissPopuWindow();
                    break;
                case R.id.appraise_outside_view:
                    dismissPopuWindow();
                    break;
                case R.id.rel_load_bottom:
                    pauseVideoPlayer();
                    if (!API.getAPI().alreadySignin()) {
                        KKDialog.getInstance().showLoginDialog(GuideCourseLearnActivity.this, new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
                                Intent intent = new Intent(GuideCourseLearnActivity.this, LoginActivity2.class);
                                intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
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
                        load_adapter = new IAdapter(modulesForDownload, itemsForDownload);
                        load_expandableCourseInfo.setAdapter(load_adapter);
                        int groupCount = load_expandableCourseInfo.getCount();
                        for (int i = 0; i < groupCount; i++) {
                            load_expandableCourseInfo.expandGroup(i);
                        }
                        mDownloadPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
                        mDownloadPopupWindow.showAtLocation(GuideCourseLearnActivity.this.findViewById(R.id.open_course_info), Gravity.BOTTOM, 0, 0);
                        mDownloadPopupWindow.setAnimationStyle(R.style.app_pop);
                        mDownloadPopupWindow.setOutsideTouchable(true);
                        mDownloadPopupWindow.setFocusable(true);
                        mDownloadPopupWindow.update();
                        initSelectedAll();
                        initSelectedState();
                        shade_view.setVisibility(View.VISIBLE);
                    }

                    break;
                case R.id.rel_appraise_bottom:
                    pauseVideoPlayer();
                    if (appraiseListAdapter != null) {
                        appraiseListAdapter.notifyDataSetChanged();
                    }
                    if (!hasAppraiseData) {
                        showNoSuccess();
                    }
                    mAppraisePopupWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
                    mAppraisePopupWindow.showAtLocation(GuideCourseLearnActivity.this.findViewById(R.id.open_course_info), Gravity.BOTTOM, 0, 0);
                    mAppraisePopupWindow.setAnimationStyle(R.style.app_pop);
                    mAppraisePopupWindow.setOutsideTouchable(true);
                    mAppraisePopupWindow.setFocusable(true);
                    mAppraisePopupWindow.update();
                    shade_view.setVisibility(View.VISIBLE);
                    break;
                case R.id.rel_share_bottom:
                    pauseVideoPlayer();
                    CommonUtils.shareSettingContent(mContext, "http://www.kaikeba.com/courses/" + c.getId(), c.getName(),
                            "我正在开课吧观看《" + c.getName() + "》这门课，老师讲得吼赛磊呀！小伙伴们要不要一起来呀" + "http://www.kaikeba.com/courses/" + c.getId(), c.getCover_image(), "#新课抢先知#这课讲的太屌了，朕灰常满意！小伙伴们不要太想我，我在@开课吧官方微博 虐学渣，快来和我一起吧！" + "http://www.kaikeba.com/courses/" + c.getId());

                    break;
                case R.id.rel_collect_bottom:
                    if (!API.getAPI().alreadySignin()) {
                        KKDialog.getInstance().showLoginDialog(GuideCourseLearnActivity.this, new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
                                Intent intent = new Intent(GuideCourseLearnActivity.this, LoginActivity2.class);
                                intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
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
                        if (NetworkUtil.isNetworkAvailable(GuideCourseLearnActivity.this)) {
                            KKDialog.getInstance().showProgressBar(GuideCourseLearnActivity.this, KKDialog.IS_LOADING);
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
                                }
                            }).start();
                        } else {
                            Toast.makeText(GuideCourseLearnActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                        }
                    }
                    break;
                case R.id.open_all_select:
                    if (is_all_loading) {
                        return;
                    }
                    load_adapter.selected_all();
                    if (load_adapter.getIsNotLoadingNum() != 0) {
                        if (allSelected) {
                            open_all_select.setText("全选");
                            allSelected = false;
                        } else {
                            open_all_select.setText("取消全选");
                            allSelected = true;
                        }
                    }
                    break;
                case R.id.open_down_load:
                    if (is_all_loading) {
                        return;
                    }
                    if (Constants.NO_NET == NetUtil.getNetType(mContext)) {
                        KKDialog.getInstance().showNoNetToast(mContext);
                    } else {
                        if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(mContext)) {
                            KKDialog.getInstance().showNoWifi2Doload(mContext,
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            Constants.nowifi_doload = false;
                                            load_adapter.downloadSelected();
                                        }
                                    },
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                        }
                                    });
                        } else {
                            load_adapter.downloadSelected();
                        }
                    }
                    break;
                case R.id.rel_go_download_manage:
                    Intent intent = new Intent(GuideCourseLearnActivity.this, DownLoadMangerActivity.class);
                    startActivity(intent);
                    break;
                default:
                    break;
            }
        }
    };
    private ArrayList<CourseModel.Items> itemsVideoInfos = new ArrayList<CourseModel.Items>();
    // 右上角popupwindow 及其中内容
    private PopupWindow InfoPopWindow;
    private TextView course_name;
    private CollapsibleTextView tv_course_introduce;
    private ListView teacherListView;
    private TeacherAdapter teach_adapter;
    private View outside_view;
    private boolean isCollectflag = false;
    final Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
                    adapter.notifyDataSetChanged();
                    break;
                case 2:
                    if (mContext == null) {
                        showNoData();
                        return;
                    }
                    showNoData();
                    break;
                case 3:
                    adapter.notifyDataSetChanged();
                    int groupCount = exList.getCount();
                    if (witchWeek != 0 && witchWeek <= groupCount) {
                        // witchweek 需要分情况处理
                        String group0 = adapter.getGroup(0).getName();
                        if (!"了解课程".equals(group0) && !witchWeekFlag) {
                            witchWeek--;
                            witchWeekFlag = true;
                        }
                        exList.expandGroup(witchWeek);
                        adapter.setGroupClickStatus(witchWeek, XDListView.GROUP_EXPAND_STATUS);
                    } else if (mLastVideoId != 0) {
                        for (int i = 0; i < courseArranges.size(); i++) {
                            for (int j = 0; j < courseArranges.get(i).getItems().size(); j++) {
                                if (courseArranges.get(i).getItems().get(j).getId() == mLastVideoId) {
                                    updateSelectItem(i + "_" + j);
                                    exList.expandGroup(i);
                                    adapter.setGroupClickStatus(i, XDListView.GROUP_EXPAND_STATUS);
                                    break;
                                }
                            }
                        }
                    }
                    getAllVideoData();
                    showData();
                    break;
                case 4:
                    if (appraisementList != null) {
                        tv_appraise_count.setText("(" + appraisementList.size() + ")");
                    }

                    break;
                case 5:
                    showNoSuccess();
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
                    Toast.makeText(GuideCourseLearnActivity.this, "加载失败，请稍后再试", Toast.LENGTH_SHORT).show();
                    break;
                case Constants.LOGIN_TIME_OUT:
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                    break;
                case 8:
                    if (!initVideoPlayerSuccess) {
                        initVideoPlayer();
                    }
                    setText();
                    getCourseArrangeByC();
                    break;
            }
//			super.handleMessage(msg);
        }
    };
    private int mLastVideoId;
    private String mvideoUrl;

    public static GuideCourseLearnActivity getGuidCourseLearnActivity() {
        return guidCourseLearnActivity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.guide_course_learn);
        guidCourseLearnActivity = this;
        mContext = this;
        popShowHeight = CommonUtils.getScreenHeight(mContext);
        downloadManager = ContextUtil.downloadManager;
        initView();
        setListener();
        getCourseInfo();
        initCourseArrange();
        getCourseByID(true);
//        getCollectionCount(false);
        loadAppraiseData(true);
        loadAppraiseData(false);
    }

    private void initView() {
        ll_course_info_title = (LinearLayout) findViewById(R.id.ll_course_info_title);
        btnBackNormal = (ImageView) findViewById(R.id.iv_back);
        btn_course_info = (ImageView) findViewById(R.id.btn_share_normal);
        btn_course_info.setImageResource(R.drawable.info);
        btn_course_info.setVisibility(View.VISIBLE);
        tvCourseTopName = (TextView) findViewById(R.id.tv_text);
        tvCourseTopName.setText("");
        ll_bottom = (LinearLayout) findViewById(R.id.ll_bottom);
        shade_view = findViewById(R.id.shade_view);
        rel_load_bottom = (RelativeLayout) findViewById(R.id.rel_load_bottom);
        rel_appraise_bottom = (RelativeLayout) findViewById(R.id.rel_appraise_bottom);
        rel_share_bottom = (RelativeLayout) findViewById(R.id.rel_share_bottom);
        rel_collect_bottom = (RelativeLayout) findViewById(R.id.rel_collect_bottom);
        iv_collect_num = (ImageView) findViewById(R.id.iv_collect_num);
        appraise_pop = LayoutInflater.from(mContext).inflate(R.layout.appraise_list_pop, null);
        appraise_list = (ListView) appraise_pop.findViewById(R.id.appraise_list);
        tv_appraise_count = (TextView) findViewById(R.id.tv_appraise_count);
        appraise_view_loading = (RelativeLayout) appraise_pop.findViewById(R.id.view_loading);
        appraise_loading_fail = (LinearLayout) appraise_pop.findViewById(R.id.view_loading_fail);
        appraise_loading_fail.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(mContext)) {
                    KKDialog.getInstance().showNoNetToast(mContext);
                } else {
                    showLoadingAppr();
                    loadAppraiseData(false);
                }
            }
        });
        appraise_outside_view = appraise_pop.findViewById(R.id.appraise_outside_view);
        appraise_outside_view.setOnClickListener(listener);
        appraisementList = new ArrayList<Appraisement>();
        appraiseListAdapter = new AppraiseListAdapter(mContext, appraisementList);
        appraise_list.setAdapter(appraiseListAdapter);
        mAppraisePopupWindow = new PopupWindow(appraise_pop, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
        mAppraisePopupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                shade_view.setVisibility(View.GONE);
            }
        });
        download_pop = LayoutInflater.from(mContext).inflate(R.layout.download_edlist_pop, null);
        open_all_select = (TextView) download_pop.findViewById(R.id.open_all_select);
        open_down_load = (TextView) download_pop.findViewById(R.id.open_down_load);
        rel_go_download_manage = (RelativeLayout) download_pop.findViewById(R.id.rel_go_download_manage);
        download_video_total_num = (TextView) download_pop.findViewById(R.id.download_video_total_num);
        download_outside_view = download_pop.findViewById(R.id.download_outside_view);
        download_outside_view.setOnClickListener(listener);
        rel_go_download_manage.setOnClickListener(listener);
        open_all_select.setOnClickListener(listener);
        open_down_load.setOnClickListener(listener);
        mDownloadPopupWindow = new PopupWindow(download_pop, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
//        if(downloadManager.getDownloadInfoList()!=null){
//            download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//        }
        mDownloadPopupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                shade_view.setVisibility(View.GONE);
            }
        });
        courseArranges = new ArrayList<CourseModel.CourseArrange>();
        modules = new ArrayList<Module>();
        olditemLists = new ArrayList<ArrayList<Item>>();

        exList = (XDListView) findViewById(R.id.expandableCourseInfo);
        View headerView = LayoutInflater.from(mContext).inflate(R.layout.course_group, exList, false);
        exList.setHeaderView(headerView);
        adapter = new CourseArrangeAdapter(courseArranges);
        exList.setAdapter(adapter);

        load_expandableCourseInfo = (ExpandableListView) download_pop.findViewById(R.id.load_expandableCourseInfo);
//        View loadheaderView = LayoutInflater.from(mContext).inflate(R.layout.download_guide_group, load_expandableCourseInfo, false);
//        load_expandableCourseInfo.setHeaderView(loadheaderView);
        load_expandableCourseInfo.setOnGroupClickListener(new ExpandableListView.OnGroupClickListener() {
            @Override
            public boolean onGroupClick(ExpandableListView expandableListView, View view, int i, long l) {
                return true;
            }
        });
        iniPopupWindow();
    }

    private void dismissPopuWindow() {
        if (mDownloadPopupWindow.isShowing()) {
            shade_view.setVisibility(View.GONE);
            mDownloadPopupWindow.dismiss();// 关闭
        }
        if (mAppraisePopupWindow.isShowing()) {
            shade_view.setVisibility(View.GONE);
            mAppraisePopupWindow.dismiss();// 关闭
        }
    }

    private void iniPopupWindow() {

        View layout = LayoutInflater.from(mContext).inflate(R.layout.info_pop_view, null);
        course_name = (TextView) layout.findViewById(R.id.course_name);
        tv_course_introduce = (CollapsibleTextView) layout.findViewById(R.id.collapsible_textview);
        teacherListView = (ListView) layout.findViewById(R.id.teacher_listview);
        outside_view = layout.findViewById(R.id.outside_view);
        outside_view.setOnClickListener(listener);
        InfoPopWindow = new PopupWindow(layout, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, true);

        InfoPopWindow.setWidth(CommonUtils.getScreenWidth(GuideCourseLearnActivity.this));
        InfoPopWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
        InfoPopWindow.setOutsideTouchable(true);// 触摸popupwindow外部，popupwindow消失。这个要求你的popupwindow要有背景图片才可以成功，如上
    }

    /**
     * 设置info中数据
     */
    private void setInfoContent() {
        course_name.setText(c.getName());
        tv_course_introduce.setDesc(c.getIntro(), TextView.BufferType.NORMAL);
        teach_adapter = new TeacherAdapter(mContext, c.getTechInfo());
        teacherListView.setAdapter(teach_adapter);

    }

    private void setListener() {
        btnBackNormal.setOnClickListener(listener);
        btn_course_info.setOnClickListener(listener);
        rel_load_bottom.setOnClickListener(listener);
        rel_appraise_bottom.setOnClickListener(listener);
        rel_share_bottom.setOnClickListener(listener);
        rel_collect_bottom.setOnClickListener(listener);
        setOnChildClickListener();
    }

    private void setText() {
        tvCourseTopName.setText(c.getName());
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
        if (list != null) {
            for (int i = 0; i < list.size(); i++) {
                if (c.getId() == list.get(i).getCourseId()) {
                    isCollectflag = true;
                    break;
                }
            }
        }
        setFavorIcon(isCollectflag);
    }

    private void setFavorIcon(boolean isCollectflag) {
        if (isCollectflag) {
            iv_collect_num.setImageResource(R.drawable.collection_press);
        } else {
            iv_collect_num.setImageResource(R.drawable.collecion_normal);
        }
    }

    private void initCourseArrange() {
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        view_loading_fail.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(mContext)) {
                    KKDialog.getInstance().showNoNetToast(mContext);
                } else {
                    getCourseByID(true);
//                    getCollectionCount(false);
                    loadAppraiseData(false);
                }
            }
        });
        bar_height = CommonUtils.getStatusBarHeight(mContext);
        width = CommonUtils.getScreenWidth(mContext);
//        height = (int) (Constants.COVER_HEIGHT * (Constants.SCREEN_WIDTH - 10 * Constants.SCREEN_DENSITY) / Constants.COVER_WIDTH + 0.5);
        height = (int) (CommonUtils.getScreenWidth(GuideCourseLearnActivity.this) * 9) / 16;
        rl_video_player = (RelativeLayout) findViewById(R.id.rl_video_player);
        rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));

        Constants.FULL_SCREEN_NO_CLICK = false;
        video_palyer = new VideoPlayerView(mContext);

        new Button(this).performClick();
    }

    public void pauseVideoPlayer() {
        if (initVideoPlayerSuccess) {
            video_palyer.pauseMediaPlayer();
        }
    }

    public void initVideoPlayer() {
        if (!TextUtils.isEmpty(mvideoUrl)) {
            video_palyer.preparePlayData(mvideoUrl, c.getCover_image(), mCurVideoPos, lms_course_id, mLastVideoId);
        } else {
            if (c != null) {
                video_palyer.preparePlayData(c.getPromotional_video_url(), c.getCover_image(), mCurVideoPos, 0, 0);
            }
        }
        rl_video_player.addView(video_palyer.makeControllerView());
        initVideoPlayerSuccess = true;
    }

    private void getCourseInfo() {
        Bundle b = getIntent().getExtras();
        c = (CourseModel) b.getSerializable(ContextUtil.CATEGORY_COURSE);

        witchWeek = b.getInt("weeks");
        mLastVideoId = b.getInt("videoID");
        mCurVideoPos = b.getInt("duation");
        mvideoUrl = b.getString("videoUrl");
        lms_course_id = b.getInt("lms_course_id");
        myguide_number = b.getInt("number");
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

    private void loadAppraiseData(final boolean fromCache) {
        Type type = new TypeToken<ArrayList<Appraisement>>() {
        }.getType();
        String url = HttpUrlUtil.EVALUATION + c.getId();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    if (appraisementList != null) {
                        appraisementList.clear();
                    }
                    appraisementList.addAll((List<Appraisement>) data);
                    handler.sendEmptyMessage(4);
                    hasAppraiseData = true;
                    showDataSuccess();
                } else {
                    if (fromCache) {
                        hasAppraiseData = false;
                        handler.sendEmptyMessage(5);
                    }
                }
            }
        });
    }

    public void getCollectionCount(boolean fromCache) {
        Type type = new TypeToken<CollectionCount>() {
        }.getType();
        String url = HttpUrlUtil.COLLECTIONS + c.getId();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    collectionCount = (CollectionCount) data;
                    count = collectionCount.getCount();
                    handler.sendEmptyMessage(5);
                }
            }
        });
    }

    protected void getCourseByID(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        Type type = new TypeToken<CourseModel>() {
        }.getType();
        String url = HttpUrlUtil.COURSES + c.getId();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(final Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    c = (CourseModel) data;
                    handler.sendEmptyMessage(8);
                    if (Constants.NET_IS_SUCCESS && fromCache) {
                        getCourseByID(false);
                    }
                } else {
                    if (fromCache) {
                        handler.sendEmptyMessage(2);
                    }
                }
            }
        });
    }

    public void getOpenWeeks() {
        if (c.getLms_course_list() != null && c.getLms_course_list().size() != 0) {
            for (CourseModel.GuidCourseLMS guidCourseLMS : c.getLms_course_list()) {
                if (guidCourseLMS.getLms_course_id() == lms_course_id) {
                    open_weeks = guidCourseLMS.getOpened_weeks();
                }
            }
        }
        if (myguide_number != 0) {
            open_weeks = myguide_number;
        }
    }

    private void getCourseArrangeByC() {
        getOpenWeeks();
        List<CourseModel.CourseArrange> arranges = new ArrayList<CourseModel.CourseArrange>();
        if (c.getLms_course_list() != null && c.getLms_course_list().size() != 0) {
            for (CourseModel.GuidCourseLMS guidCourseLMS : c.getLms_course_list()) {
                if (guidCourseLMS.getLms_course_id() == lms_course_id) {
                    arranges = guidCourseLMS.getCourse_arrange();
                }
            }
        }
        List<CourseModel.CourseArrange> open_arranges = new ArrayList<CourseModel.CourseArrange>();

        if (open_weeks > 0) {
            if (arranges != null) {
                if (arranges.get(0) != null) {
                    if (arranges.get(0).getName().equals("了解课程")) {
                        open_weeks = open_weeks + 1;
                    }
                    if (arranges.size() <= open_weeks) {
                        open_arranges.addAll(arranges);
                    } else {
                        for (int i = 0; i < open_weeks; i++) {
                            open_arranges.add(arranges.get(i));
                        }
                    }

                }
            }
        }
        if (open_weeks == -1) {
            if (arranges != null) {
                open_arranges.addAll(arranges);
            }
        }
        if (open_weeks == -2) {
            if (arranges != null) {
                if (arranges.get(0) != null) {
                    if (arranges.get(0).getName().equals("了解课程")) {
                        open_arranges.add(arranges.get(0));
                    }
                }
            }
        }

        if (open_arranges != null && open_arranges.size() > 0) {
            if (courseArranges != null && courseArranges.size() > 0) {
                courseArranges.clear();
            }
            courseArranges.addAll(open_arranges);
            if (courseArranges == null || courseArranges.size() == 0) {
                handler.sendEmptyMessage(2);
            } else {
                handler.sendEmptyMessage(3);
            }
        } else {
            handler.sendEmptyMessage(2);
        }
    }

    /**
     * 筛选出 所有含视频的 module-item
     */
    public void getAllVideoData() {
        modulesForDownload = new ArrayList<CourseModel.CourseArrange>();
        itemsForDownload = new ArrayList<ArrayList<CourseModel.Items>>();
        if (courseArranges != null) {
            itemsVideoInfos.clear();
            for (CourseModel.CourseArrange courseArrange : courseArranges) {
                ArrayList<CourseModel.Items> items = new ArrayList<CourseModel.Items>();
                for (CourseModel.Items courseTitle : courseArrange.getItems()) {
                    if (courseTitle.getType().equals("ExternalTool")) {
                        items.add(courseTitle);
                        itemsVideoInfos.add(courseTitle);
                    }
                }
                if (items.size() > 0) {
                    itemsForDownload.add(items);
                    modulesForDownload.add(courseArrange);
                }
            }
        }
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showDataSuccess() {
        appraise_list.setVisibility(View.VISIBLE);
        appraise_view_loading.setVisibility(View.GONE);
        appraise_loading_fail.setVisibility(View.GONE);
    }

    private void showNoSuccess() {
        appraise_list.setVisibility(View.GONE);
        appraise_view_loading.setVisibility(View.GONE);
        appraise_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showLoadingAppr() {
        appraise_list.setVisibility(View.GONE);
        appraise_view_loading.setVisibility(View.VISIBLE);
        appraise_loading_fail.setVisibility(View.GONE);
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
        rl_video_player.setVisibility(View.VISIBLE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
        rl_video_player.setVisibility(View.GONE);
    }

    public void setGone() {
        ll_course_info_title.setVisibility(View.GONE);
        ll_bottom.setVisibility(View.GONE);
    }

    public void setVisible() {
        ll_course_info_title.setVisibility(View.VISIBLE);
        ll_bottom.setVisibility(View.VISIBLE);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (video_palyer != null) {
            video_palyer.screenChange(newConfig, height);
        }
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            exList.setVisibility(View.GONE);
            setGone();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            exList.setVisibility(View.VISIBLE);
            setVisible();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onBackPressed() {
        if (!video_palyer.isScaleTag) {
            appointSkip();
        } else {
            video_palyer.onBackPressed();
        }
    }

    public void appointSkip() {
        if (Constants.FROM_WHERE == Constants.FROM_DYNAMIC) {
            Constants.FROM_WHERE = 0;
            Intent intent = new Intent(GuideCourseLearnActivity.this, TabCourseActivity.class);
            intent.putExtra("TabTag", "Dynamic");
            intent.putExtra("TabNum", 0);
            startActivity(intent);
            finish();
        } else {
            finish();
        }
    }

    public void onResume() {
        super.onResume();
        Constants.FULL_SCREEN_NO_CLICK = false;
        MobclickAgent.onPageStart("GuideCourseLearn"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
        setCollection();
        from_download_manage = true;
        initSelectedAll();
        initSelectedState();
//        if(load_adapter!=null){
//            load_adapter.notifyDataSetChanged();
//        }
    }

    public void onPause() {
        super.onPause();
        if (initVideoPlayerSuccess) {
            if (video_palyer != null) {
                video_palyer.onDestroy();
                video_palyer.unregisterReceiver();
            }
        }
        MobclickAgent.onPageEnd("GuideCourseLearn");
        MobclickAgent.onPause(this);
    }

    private void setOnChildClickListener() {
        exList.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {

            @Override
            public boolean onChildClick(ExpandableListView parent, View v,
                                        final int groupPosition, final int childPosition, long id) {
                // TODO Auto-generated method stub

                int currentNetSate = NetUtil.getNetType(mContext);
                item = adapter.getChild(groupPosition, childPosition);
//                if (item.getType() != null && item.getType().equals("Page")) {
//                    if (item.getHtml_url() != null) {
//                        String[] pageStr = item.getHtml_url().split("/");
//                        pageURL = pageStr[pageStr.length - 1];
//                        Intent intent = new Intent();
//                        intent.putExtra("courseID+pageURL", courseID + "##"
//                                + pageURL);
//                        intent.putExtra("html_url",item.getHtml_url());
//                        intent.putExtra("title", item.getTitle());
////						intent.putExtra("url", item.getUrl());
//                        Log.e(tag,"sss"+item.getHtml_url());
//                        intent.setClass(mContext, UnitPageActivity.class);
//                        startActivity(intent);
//                    }
//                } else 
                if (item.getType() != null && "ExternalTool".equals(item.getType())) {
                    if (adapter.getSelectItem().equals(groupPosition + "_" + childPosition)) {
                        return false;
                    }
                    if (item.getUrl() != null) {
                        if (Constants.NO_NET != currentNetSate) {
                            if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) {

                                KKDialog.getInstance().showNoWifi2Play(mContext,
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                                toPlay();
                                                adapter.setSelectItem(groupPosition + "_" + childPosition);
                                                adapter.notifyDataSetInvalidated();
                                                Constants.nowifi_doplay = false;
                                            }
                                        },
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                            }
                                        });
                            } else {
                                toPlay();
                                adapter.setSelectItem(groupPosition + "_" + childPosition);
                                adapter.notifyDataSetInvalidated();
                            }
                        } else {
//                            KKDialog.getInstance().showNoNetToast(mContext);
                            Toast.makeText(GuideCourseLearnActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                        }
                    }
                } else {
                    KKDialog.getInstance().showGO3wDialg(mContext);
                }
                return true;
            }
        });
    }

    private void toPlay() {
        video_palyer.preparePlayData(itemsVideoInfos, getPositionById(), c.getCover_image(), 0, lms_course_id);
        video_palyer.addWatcher(GuideCourseLearnActivity.this);
//        video_palyer.preparePlayData(item.getUrl(),c.getCover_image(),0, lms_course_id ,item.getId());
        video_palyer.play(0);
    }

    private int getPositionById() {
        for (int i = 0; i < itemsVideoInfos.size(); i++) {
            if (itemsVideoInfos.get(i).getId() == item.getId()) {
                return i;
            }
        }
        return 0;
    }

    private String getPositionByItemId(int itemId) {
        for (int i = 0; i < courseArranges.size(); i++) {
            for (int j = 0; j < courseArranges.get(i).getItems().size(); j++) {
                if (courseArranges.get(i).getItems().get(j).getId() == itemId) {
                    return i + "_" + j;
                }
            }
        }
        return "";
    }

    @Override
    public void update(Object obj) {
        int itemId = (Integer) obj;
        updateSelectItem(getPositionByItemId(itemId));
    }

    private void updateSelectItem(String selectedPosition) {
        adapter.setSelectItem(selectedPosition);
        adapter.notifyDataSetInvalidated();
    }

    public void download(CourseModel.Items item) {
        if (item.getUrl() != null) {
            try {
                downloadManager.addNewDownload(API.getAPI().getUserObject().getId() + splitStr + c.getId() + splitStr + lms_course_id + splitStr + item.getId(),
                        c.getName(),
                        item.getUrl(),
                        c.getCover_image(),
                        item.getTitle(),
                        FileUtils.getVideoFilePath(API.getAPI().getUserObject().getId(), c.getId() + "", lms_course_id + "", item.getId() + "") + item.getTitle() + ".mp4",
                        true,
                        false,
                        null);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
        }
    }

    private void resumeDownLoad(final DownloadInfo downloadInfo) {
        try {
            downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
            load_adapter.notifyDataSetChanged();
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    /**
     * 设置已选数量
     */
    public void setAlreadyNum(int num) {
        if (open_down_load != null) {
            if (num != 0) {
                open_down_load.setText("下载(" + num + ")");
                open_down_load.setTextColor(getResources().getColor(R.color.text_selected_all));
            } else {
                open_down_load.setText("下载");
                open_down_load.setTextColor(getResources().getColor(R.color.text_download_normal));
            }
        }
    }

    public void initSelectedAll() {
        if (open_all_select != null) {
            open_all_select.setText("全选");
            allSelected = false;
        }
        selected_num = 0;
        setAlreadyNum(0);
    }

    public void initSelectedState() {
        if (itemsForDownload != null && itemsForDownload.size() > 0 && c != null && downloadManager != null) {
            for (int i = 0; i < itemsForDownload.size(); i++) {
                for (int j = 0; j < itemsForDownload.get(i).size(); j++) {
                    DownloadInfo info = downloadManager.getDownloadInfoByCourseId(c.getId() + "", itemsForDownload.get(i).get(j).getId());
                    if (info != null) {
                        if (info.getState() != HttpHandler.State.FAILURE) {
                            itemsForDownload.get(i).get(j).setDownLoading(true);
                            itemsForDownload.get(i).get(j).setIschildSelected(true);
                            itemsForDownload.get(i).get(j).setDownLoadFailure(false);
                        } else {
                            itemsForDownload.get(i).get(j).setDownLoading(false);
                            itemsForDownload.get(i).get(j).setIschildSelected(false);
                            itemsForDownload.get(i).get(j).setDownLoadFailure(true);
                        }
                    } else {
                        itemsForDownload.get(i).get(j).setDownLoading(false);
                        itemsForDownload.get(i).get(j).setIschildSelected(false);
                        itemsForDownload.get(i).get(j).setDownLoadFailure(false);
                    }
                }
            }
        }
        if (load_adapter != null) {
            load_adapter.notifyDataSetChanged();
        }
    }

    public void setChildSelectedState() {
        for (int i = 0; i < itemsForDownload.size(); i++) {
            for (int j = 0; j < itemsForDownload.get(i).size(); j++) {
                DownloadInfo info = downloadManager.getDownloadInfoByCourseId(c.getId() + "", itemsForDownload.get(i).get(j).getId());
                if (info != null) {
                    if (info.getState() != HttpHandler.State.FAILURE) {
                        itemsForDownload.get(i).get(j).setDownLoading(true);
                        itemsForDownload.get(i).get(j).setIschildSelected(true);
                        itemsForDownload.get(i).get(j).setDownLoadFailure(false);
                    } else {
                        itemsForDownload.get(i).get(j).setDownLoading(false);
                        itemsForDownload.get(i).get(j).setIschildSelected(false);
                        itemsForDownload.get(i).get(j).setDownLoadFailure(true);
                    }
                }
            }
        }
        load_adapter.notifyDataSetChanged();
    }

    /**
     * 自定义Module-Item二级菜单数据适配器
     *
     * @author Allen
     */
    class CourseArrangeAdapter extends BaseExpandableListAdapter implements XDListView.XDHeaderAdapter {

        private List<CourseModel.CourseArrange> mGroupArray;
        @SuppressLint("UseSparseArrays")
        private HashMap<Integer, Integer> groupStatusMap = new HashMap<Integer, Integer>();
        private String selectItem = "";

        public CourseArrangeAdapter(List<CourseModel.CourseArrange> groupArray) {
            super();
            this.mGroupArray = groupArray;
        }

        @Override
        public int getGroupCount() {
            if (mGroupArray.isEmpty()) {
                return 0;
            }
            return this.mGroupArray.size();
        }

        @Override
        public CourseModel.CourseArrange getGroup(int groupPosition) {
            if (mGroupArray.isEmpty() || mGroupArray.size() == 0 || groupPosition == -1) {
                return null;
            }
            return mGroupArray.get(groupPosition);
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (mGroupArray.isEmpty()) {
                return 0;
            }
            if (groupPosition >= mGroupArray.size()) return 0;
            if (mGroupArray.size() == 0 || mGroupArray.get(groupPosition) == null || mGroupArray.get(groupPosition).getItems() == null || mGroupArray.get(groupPosition).getItems().size() == 0) {
                return 0;
            }
            return mGroupArray.get(groupPosition).getItems().size();
        }

        @Override
        public CourseModel.Items getChild(int groupPosition, int childPosition) {
            if (mGroupArray.isEmpty()) {
                return null;
            }
            if (mGroupArray.get(groupPosition).getItems().isEmpty()) {
                return null;
            }
            return mGroupArray.get(groupPosition).getItems().get(childPosition);
        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return groupPosition + childPosition;
        }

        @Override
        public boolean hasStableIds() {
            return false;
        }

        @Override
        public View getGroupView(int groupPosition, boolean isExpanded,
                                 View convertView, ViewGroup parent) {
            CourseArrangeGroupViewHolder groupViewHolder = null;
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.course_group, null);
                groupViewHolder = new CourseArrangeGroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (CourseArrangeGroupViewHolder) convertView.getTag();
            }
            if (groupPosition < mGroupArray.size()) {
                groupViewHolder.module_name.setText(mGroupArray.get(groupPosition)
                        .getName());
            }
            if (isExpanded) {
                groupViewHolder.module_img.setImageResource(R.drawable.drop_menu_up);
            } else {
                groupViewHolder.module_img.setImageResource(R.drawable.drop_menu_down);
            }
            return convertView;
        }

        @Override
        public View getChildView(int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            CourseArrangeChildViewHolder childHolder = null;
            CourseModel.Items item = mGroupArray.get(groupPosition).getItems().get(childPosition);
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.course_child, null);
                childHolder = new CourseArrangeChildViewHolder(convertView);
                convertView.setTag(childHolder);
            } else {
                childHolder = (CourseArrangeChildViewHolder) convertView.getTag();
            }
            childHolder.course_name.setText(item.getTitle());
            if (c.getNumber() == -2) {
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_press));
            }
            String type = item.getType();
            if ("WikiPage".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_page_gray);
            } else if ("Quiz".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_quiz_gray);
            } else if ("Discussion".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            } else if ("Assignment".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_assignment_gray);
            } else if ("File".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            } else if ("ExternalUrl".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_link_gray);
            } else if ("ExternalTool".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_video_active_gray);
            } else {

            }

            if ((groupPosition + "_" + childPosition).equals(selectItem)) {
                convertView.setBackgroundColor(getResources().getColor(R.color.course_bg_color));
            } else {
                convertView.setBackgroundColor(getResources().getColor(R.color.white));
            }

            //convertView.getBackground().setAlpha(80);

            return convertView;
        }

        public String getSelectItem() {
            return selectItem;
        }

        public void setSelectItem(String selectItem) {
            this.selectItem = selectItem;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            if (c.getNumber() == -2) {
                return false;
            }
            return true;
        }

        @Override
        public int getXDHeaderState(int groupPosition, int childPosition) {
            // TODO Auto-generated method stub
            int childCount = 0;
            if (groupPosition > 0) {
                childCount = getChildrenCount(groupPosition);
            }
            if (childPosition == childCount - 1) {
                return PINNED_HEADER_PUSHED_UP;
            } else if (childPosition == -1 && !exList.isGroupExpanded(groupPosition)) {
                return PINNED_HEADER_GONE;
            } else {
                return PINNED_HEADER_VISIBLE;
            }
        }

        @Override
        public void configureXDHeader(View header, int groupPosition,
                                      int childPosition, int alpha) {
            // TODO Auto-generated method stub
            CourseModel.CourseArrange groupData = null;
            if (groupPosition != -1) {
                groupData = (CourseModel.CourseArrange) this.getGroup(groupPosition);
            }
            if (groupData != null) {
                ((TextView) header.findViewById(R.id.course_module)).setText(groupData.getName());
            }
            if (exList.isGroupExpanded(groupPosition)) {
                ((ImageView) header.findViewById(R.id.course_module_img)).setImageResource(R.drawable.drop_menu_up);
            } else {
                ((ImageView) header.findViewById(R.id.course_module_img)).setImageResource(R.drawable.drop_menu_down);
            }
        }

        @Override
            public void setGroupClickStatus(int groupPosition, int status) {
            // TODO Auto-generated method stub
            groupStatusMap.put(groupPosition, status);
        }

        @Override
        public int getGroupClickStatus(int groupPosition) {
            // TODO Auto-generated method stub
            if (groupStatusMap.containsKey(groupPosition)) {
                return groupStatusMap.get(groupPosition);
            } else {
                return 0;
            }
        }
    }

    public class CourseArrangeGroupViewHolder {
        TextView module_name;
        ImageView module_img;

        public CourseArrangeGroupViewHolder(View v) {
            module_name = (TextView) v.findViewById(R.id.course_module);
            module_img = (ImageView) v.findViewById(R.id.course_module_img);
        }
    }

    public class CourseArrangeChildViewHolder {
        //        TextView courseSpec;
        TextView course_name;
        ImageView course_ImView;
        ImageView load_video;
//        TextView load_progress;

        public CourseArrangeChildViewHolder(View v) {
            course_name = (TextView) v.findViewById(R.id.course_name);
            course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
            load_video = (ImageView) v.findViewById(R.id.load_video);
        }
    }

    class IAdapter extends BaseExpandableListAdapter {

        private ArrayList<CourseModel.CourseArrange> mGroupArray;
        //        private ArrayList<ArrayList<CourseModel.Items>> mArrayArray;
        @SuppressLint("UseSparseArrays")
        private HashMap<Integer, Integer> groupStatusMap = new HashMap<Integer, Integer>();
        private int gPosition;

        public IAdapter(ArrayList<CourseModel.CourseArrange> groupArray, ArrayList<ArrayList<CourseModel.Items>> mArrayArray) {
            super();
            this.mGroupArray = groupArray;
//            this.itemsForDownload = itemsForDownload;
            for (int i = 0; i < itemsForDownload.size(); i++) {
                for (int j = 0; j < itemsForDownload.get(i).size(); j++) {
                    DownloadInfo info = downloadManager.getDownloadInfoByCourseId(c.getId() + "", itemsForDownload.get(i).get(j).getId());
                    if (info != null) {
                        if (info.getState() != HttpHandler.State.FAILURE) {
                            itemsForDownload.get(i).get(j).setDownLoading(true);
                            itemsForDownload.get(i).get(j).setIschildSelected(true);
                            itemsForDownload.get(i).get(j).setDownLoadFailure(false);
                        } else {
                            itemsForDownload.get(i).get(j).setDownLoading(false);
                            itemsForDownload.get(i).get(j).setIschildSelected(false);
                            itemsForDownload.get(i).get(j).setDownLoadFailure(true);
                        }
                    } else {
                        itemsForDownload.get(i).get(j).setDownLoading(false);
                        itemsForDownload.get(i).get(j).setIschildSelected(false);
                        itemsForDownload.get(i).get(j).setDownLoadFailure(false);
                    }
                }
            }
        }

        @Override
        public int getGroupCount() {
            if (mGroupArray.isEmpty()) {
                return 0;
            }
            return this.mGroupArray.size();
        }

        @Override
        public CourseModel.CourseArrange getGroup(int groupPosition) {
            if (mGroupArray.isEmpty()) {
                return null;
            }
            return mGroupArray.get(groupPosition);
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (itemsForDownload.isEmpty() || itemsForDownload.size() == 0) {
                return 0;
            }
            if (groupPosition >= itemsForDownload.size()) return 0;
            return itemsForDownload.get(groupPosition).size();
        }

        @Override
        public CourseModel.Items getChild(int groupPosition, int childPosition) {
            if (itemsForDownload.isEmpty()) {
                return null;
            }
            return itemsForDownload.get(groupPosition).get(childPosition);
        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return groupPosition + childPosition;
        }

        @Override
        public boolean hasStableIds() {
            return false;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

        @Override
        public View getGroupView(int groupPosition, boolean isExpanded,
                                 View convertView, ViewGroup parent) {
            GroupViewHolder groupViewHolder = null;
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.download_guide_group, null);
                groupViewHolder = new GroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GroupViewHolder) convertView.getTag();
            }
            groupViewHolder.load_group_name.setText(mGroupArray.get(groupPosition)
                    .getName());
//            if(isExpanded){
//                groupViewHolder.download_down_up.setImageResource(R.drawable.drop_menu_up);
//            }else{
//                groupViewHolder.download_down_up.setImageResource(R.drawable.drop_menu_down);
//            }
            if (getAlreadySelectNumByGroup(groupPosition) == getIsNotLoadingNumByGroup(groupPosition)) {
                mGroupArray.get(groupPosition).setGroupSelected(true);
            } else {
                mGroupArray.get(groupPosition).setGroupSelected(false);
            }
            final GroupViewHolder finalGroupViewHolder = groupViewHolder;
            if (mGroupArray.get(groupPosition).isGroupSelected()) {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_select);
            } else {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_circle);
            }
            gPosition = groupPosition;
            if (getIsNotLoadingNumByGroup(groupPosition) == 0) {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_selected);
            } else {
                convertView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if (!is_all_loading) {
                            groupVideo_selected(finalGroupViewHolder, mGroupArray.get(gPosition), gPosition);
                        }
                    }
                });
            }
            return convertView;
        }

        @Override
        public View getChildView(final int groupPosition, final int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            ChildViewHolder childHolder = null;
//            final CourseModel.Items item = itemsForDownload.get(groupPosition).get(childPosition);
            DownloadInfo downloadInfo = downloadManager.getDownloadInfoByCourseId(c.getId() + "", itemsForDownload.get(groupPosition).get(childPosition).getId());
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.openc_download_child, parent, false);
                childHolder = new ChildViewHolder(convertView);
                convertView.setTag(childHolder);
                childHolder.refresh();
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
            }
            childHolder.course_name.setText(itemsForDownload.get(groupPosition).get(childPosition).getTitle());
            childHolder.load_video_state.setVisibility(View.INVISIBLE);
//            childHolder.course_selected.setVisibility(View.VISIBLE);
            if (downloadInfo != null) {
                HttpHandler.State state = downloadInfo.getState();
                if (state != HttpHandler.State.FAILURE) {
                    childHolder.load_video_state.setVisibility(View.VISIBLE);
//                    childHolder.course_selected.setVisibility(View.INVISIBLE);
                } else {
                    childHolder.load_video_state.setVisibility(View.VISIBLE);
//                    childHolder.course_selected.setVisibility(View.VISIBLE);
                }
                switch (state) {
                    case WAITING:
                        childHolder.load_video_state.setImageResource(R.drawable.download_ing);
                        break;
                    case STARTED:
                        childHolder.load_video_state.setImageResource(R.drawable.download_ing);
                        break;
                    case LOADING:
                        childHolder.load_video_state.setImageResource(R.drawable.download_ing);
                        break;
                    case CANCELLED:
                        childHolder.load_video_state.setImageResource(R.drawable.download_ing);
                        break;
                    case SUCCESS:
                        childHolder.load_video_state.setImageResource(R.drawable.download_done);
                        break;
                    case FAILURE:
                        childHolder.load_video_state.setImageResource(R.drawable.download_error);
                        childHolder.course_selected.setImageResource(R.drawable.download_circle);
                        is_all_loading = false;
                        open_all_select.setTextColor(getResources().getColor(R.color.text_selected_all));
                        break;
                }
                HttpHandler<File> handler = downloadInfo.getHandler();
                if (handler != null) {
                    RequestCallBack callBack = handler.getRequestCallBack();
                    if (callBack instanceof DownloadManager.ManagerCallBack) {
                        DownloadManager.ManagerCallBack managerCallBack = (DownloadManager.ManagerCallBack) callBack;
                        if (managerCallBack.getBaseCallBack() == null) {
                            managerCallBack.setBaseCallBack(new DownloadRequestCallBack());
                        }
                    }
                    callBack.setUserTag(new WeakReference<GuideCourseLearnActivity.ChildViewHolder>(childHolder));
                }
            } else {
                if (from_download_manage) {
                    itemsForDownload.get(groupPosition).get(childPosition).setDownLoading(false);
                    itemsForDownload.get(groupPosition).get(childPosition).setIschildSelected(false);
                    childHolder.load_video_state.setVisibility(View.INVISIBLE);
                    childHolder.course_selected.setVisibility(View.VISIBLE);
                }
            }

            if (itemsForDownload.get(groupPosition).get(childPosition).isChildSelected()) {
                childHolder.course_selected.setImageResource(R.drawable.download_select);
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_pressed));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_title));
            } else {
                childHolder.course_selected.setImageResource(R.drawable.download_circle);
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_normal));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_unselected_item));
            }
            if (itemsForDownload.get(groupPosition).get(childPosition).isDownLoading()) {
                childHolder.course_selected.setImageResource(R.drawable.download_selected);
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_pressed));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_title));
            }

            if (!itemsForDownload.get(groupPosition).get(childPosition).isDownLoading()) {
                final ChildViewHolder finChildHolder = childHolder;
                convertView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (!is_all_loading) {
                            childVideo_selected(finChildHolder, itemsForDownload.get(groupPosition).get(childPosition));
                        }
                    }
                });
            } else {
                convertView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {

                    }
                });
            }
//            if(downloadManager.getDownloadInfoList()!=null){
//                download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//            }
//            if(getAlreadySelectNum()==getIsNotLoadingNum()){
//                open_all_select.setText("取消全选");
//                allSelected = true;
//            }else{
//                open_all_select.setText("全选");
//                allSelected = false;
//            }
            if (getIsNotLoadingNum() == 0) {
                open_all_select.setText("全选");
                open_all_select.setTextColor(getResources().getColor(R.color.text_download_normal));
                is_all_loading = true;
            } else {
                open_all_select.setTextColor(getResources().getColor(R.color.text_selected_all));
                is_all_loading = false;
            }
            return convertView;
        }


        private void groupVideo_selected(GroupViewHolder groupViewHolder, CourseModel.CourseArrange courseArrange, int groupPositon) {
            if (courseArrange.isGroupSelected()) {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_circle);
                for (CourseModel.Items item : itemsForDownload.get(groupPositon)) {
                    if (!item.isDownLoading()) {
                        if (item.isChildSelected()) {
                            item.setIschildSelected(false);
                            selected_num--;
                        }
                    }
                }
                courseArrange.setGroupSelected(false);
                setAlreadyNum(selected_num);
            } else {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_select);
                for (CourseModel.Items item : itemsForDownload.get(groupPositon)) {
                    if (!item.isDownLoading()) {
                        if (!item.isChildSelected()) {
                            item.setIschildSelected(true);
                            selected_num++;
                        }
                    }
                }
                courseArrange.setGroupSelected(true);
                setAlreadyNum(selected_num);
            }
            setAllSelectState();
            from_download_manage = false;
            notifyDataSetChanged();
        }

        private void childVideo_selected(ChildViewHolder childViewHolder, CourseModel.Items item) {
            if (item.isChildSelected()) {
                childViewHolder.course_selected.setImageResource(R.drawable.download_circle);
                item.setIschildSelected(false);
                selected_num--;
                setAlreadyNum(selected_num);
            } else {
                childViewHolder.course_selected.setImageResource(R.drawable.download_select);
                item.setIschildSelected(true);
                selected_num++;
                setAlreadyNum(selected_num);
            }
            setAllSelectState();
            from_download_manage = false;
            notifyDataSetChanged();
        }

        public void setAllSelectState() {
            if (getAlreadySelectNum() == getIsNotLoadingNum()) {
                open_all_select.setText("取消全选");
                allSelected = true;
            } else {
                open_all_select.setText("全选");
                allSelected = false;
            }
        }

        /**
         * 获取每组已选视频
         */
        public int getAlreadySelectNumByGroup(int groupPosition) {
            int num = 0;
            for (CourseModel.Items itemVideo : itemsForDownload.get(groupPosition)) {
                if (!itemVideo.isDownLoading()) {
                    if (itemVideo.isChildSelected()) {
                        num++;
                    }
                }
            }
            return num;
        }

        /**
         * 获取每组不在下载的视频
         */
        public int getIsNotLoadingNumByGroup(int groupPosition) {
            int num = 0;
            for (CourseModel.Items itemVideo : itemsForDownload.get(groupPosition)) {
                if (!itemVideo.isDownLoading()) {
                    num++;
                }
            }
            return num;
        }

        /**
         * 获取已选数量
         */
        public int getAlreadySelectNum() {
            int num = 0;
            for (ArrayList<CourseModel.Items> itemses : itemsForDownload) {
                for (CourseModel.Items itemVideo : itemses) {
                    if (!itemVideo.isDownLoading()) {
                        if (itemVideo.isChildSelected()) {
                            num++;
                        }
                    }
                }
            }
            return num;
        }

        /**
         * 获取不在下载的数量
         */
        public int getIsNotLoadingNum() {
            int num = 0;
            for (ArrayList<CourseModel.Items> itemses : itemsForDownload) {
                for (CourseModel.Items itemVideo : itemses) {
                    if (!itemVideo.isDownLoading()) {
                        num++;
                    }
                }
            }
            return num;
        }

        /**
         * 全选和取消全选操作
         */
        public void selected_all() {
            from_download_manage = false;
            if (allSelected) {
                selected_num = 0;
            } else {
                for (ArrayList<CourseModel.Items> itemses : itemsForDownload) {
                    for (CourseModel.Items itemVideo : itemses) {
                        if (!itemVideo.isChildSelected() && !itemVideo.isDownLoading()) {
                            selected_num++;
                        }
                    }
                }

            }
            if (allSelected) {
                for (int i = 0; i < itemsForDownload.size(); i++) {
                    for (int j = 0; j < itemsForDownload.get(i).size(); j++) {
                        if (!itemsForDownload.get(i).get(j).isDownLoading()) {
                            itemsForDownload.get(i).get(j).setIschildSelected(false);
                        }
                    }
                }
                for (CourseModel.CourseArrange courseArrange : mGroupArray) {
                    if (courseArrange.isGroupSelected()) {
                        courseArrange.setGroupSelected(false);
                    }
                }
            } else {
                for (int i = 0; i < itemsForDownload.size(); i++) {
                    for (int j = 0; j < itemsForDownload.get(i).size(); j++) {
                        if (!itemsForDownload.get(i).get(j).isDownLoading()) {
                            itemsForDownload.get(i).get(j).setIschildSelected(true);
                        }
                    }
                }
//                for(ArrayList<CourseModel.Items> itemses : itemsForDownload){
//                    for(CourseModel.Items itemVideo:itemses){
//                        if(!itemVideo.isDownLoading()){
//                            itemVideo.setIschildSelected(true);
//                        }
//                    }
//                }
                for (CourseModel.CourseArrange courseArrange : mGroupArray) {
                    if (!courseArrange.isGroupSelected()) {
                        courseArrange.setGroupSelected(true);
                    }

                }
            }
            if (selected_num != 0) {
                setAlreadyNum(selected_num);
            } else {
                setAlreadyNum(0);
            }
            notifyDataSetChanged();
        }

        /**
         * 下载已选
         */
        private void downloadSelected() {
            for (ArrayList<CourseModel.Items> items : itemsForDownload) {
                for (CourseModel.Items item : items) {
                    if (item.isChildSelected()) {
                        if (item.isDownLoadFailure()) {
                            DownloadInfo downloadInfo = downloadManager.getDownloadInfoByCourseId(c.getId() + "", item.getId());
                            resumeDownLoad(downloadInfo);
                            item.setDownLoadFailure(false);
                        } else {
                            download(item);
                        }
                        item.setDownLoading(true);
                        item.setIschildSelected(false);
                    }
                }
            }
            if (selected_num > 0) {
                MyToast.getInstance().okToast("已加入下载列表");
            }
            from_download_manage = false;
            selected_num = 0;
            open_down_load.setText("下载");
            open_down_load.setTextColor(getResources().getColor(R.color.text_download_normal));
//            if(downloadManager.getDownloadInfoList()!=null){
//                download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//            }
            allSelected = false;
            open_all_select.setText("全选");
            if (getAlreadySelectNum() == getIsNotLoadingNum()) {
                open_all_select.setText("全选");
                open_all_select.setTextColor(getResources().getColor(R.color.text_download_normal));
                is_all_loading = true;
            } else {
                open_all_select.setTextColor(getResources().getColor(R.color.text_selected_all));
                is_all_loading = false;
            }
            notifyDataSetChanged();
        }
    }

    public class GroupViewHolder {
        TextView load_group_name;
        //        ImageView download_down_up;
        ImageView load_check_group;

        public GroupViewHolder(View v) {
            load_group_name = (TextView) v.findViewById(R.id.load_group_name);
//            download_down_up = (ImageView) v.findViewById(R.id.download_down_up);
            load_check_group = (ImageView) v.findViewById(R.id.load_check_group);
        }
    }

    public class ChildViewHolder {
        TextView course_name;
        ImageView course_selected;
        ImageView load_video_state;

        public ChildViewHolder(View v) {
            course_name = (TextView) v.findViewById(R.id.course_name);
            course_selected = (ImageView) v.findViewById(R.id.course_selected);
            load_video_state = (ImageView) v.findViewById(R.id.load_video_state);
        }

        public void refresh() {
            load_adapter.notifyDataSetChanged();
        }

    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {

        @SuppressWarnings("unchecked")
        private void refreshListItem() {
            if (userTag == null) return;
            try {
                WeakReference<GuideCourseLearnActivity.ChildViewHolder> tag = (WeakReference<GuideCourseLearnActivity.ChildViewHolder>) userTag;
                GuideCourseLearnActivity.ChildViewHolder holder = tag.get();
                if (holder != null) {
                    holder.refresh();
                }
            } catch (ClassCastException e) {
                WeakReference<DownLoadMangerActivity.ChildViewHolder> tag = (WeakReference<DownLoadMangerActivity.ChildViewHolder>) userTag;
                DownLoadMangerActivity.ChildViewHolder holder = tag.get();
                if (holder != null) {
                    holder.refresh();
                }
            }

        }

        @Override
        public void onStart() {
            refreshListItem();
        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            refreshListItem();
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            refreshListItem();
        }

        @Override
        public void onFailure(HttpException error, String msg) {
            setChildSelectedState();
            refreshListItem();
        }

        @Override
        public void onCancelled() {
            refreshListItem();
        }
    }
}
