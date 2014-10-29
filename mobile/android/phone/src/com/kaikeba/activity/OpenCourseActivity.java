package com.kaikeba.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.fragment.CourseArrangeFragment;
import com.kaikeba.activity.phoneutil.CollectManager;
import com.kaikeba.adapter.AppraiseListAdapter;
import com.kaikeba.adapter.TeacherAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.EnrollCourseAPI;
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
import java.util.*;

public class OpenCourseActivity extends BaseActivity implements Watcher {
    private final static String tag = "OpenCourseActivity";
    private static OpenCourseActivity openCourseActivity;
    public boolean initVideoPlayerSuccess = false;
    /**
     * 课程安排*********************************************
     */
    private int courseID;
    private LayoutInflater inflater;
    private RelativeLayout view_loading;
    private ImageView loading_fail;
    private RelativeLayout rl_video_player;
    private LinearLayout view_loading_fail;
    //    private XDListView exList;
    private String pageURL;
    private Item item;
    private List<ModuleVideo> moduleVideos;
    private ArrayList<Appraisement> appraisementList;
    private ArrayList<Module> modules;
    private ArrayList<ArrayList<Item>> olditemLists;
    private ArrayList<Item> items = new ArrayList<Item>();
    private List<String> modulesIds = new ArrayList<String>();
    private List<String> itemIds = new ArrayList<String>();
    private Map<String, String> urlMap = new HashMap<String, String>();
    private ImageView iv_course_info_play;
    private DownloadManager downloadManager;
    private String splitStr = "_";
    private String courseName;
    private String bgUrl;
    private VideoPlayerView video_palyer;
    private BitmapUtils bitmapUtils;
    private int height;
    private int width;
    private int bar_height;
    /**
     * ***************************************************************
     */
    private ImageView btn_course_info;
    private ImageView btnBackNormal;
    private ImageView iv_collect_num;
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
    private TextView tv_appraise_count;
    //遮罩View
    private View shade_view;
    //    private TextView collect_num;
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
    private ListView load_listview;
    private RelativeLayout rel_go_download_manage;
    private TextView download_video_total_num;
    private int selected_num;
    private boolean is_all_loading = false;
    private CollectionCount collectionCount;
    private int count;
    private int popShowHeight;
    private int mCurVideoPos;
    //    private TextView course_info;
    private CourseModel curCourse;
    private String TAG = "OpenCourseActivity";
    private ListView lv_video;
    private VideoAdapter videoAdapter;
    private VideoLoadAdapter popVideoAdapter;
    private boolean isClick = true;
    private int lms_course_id;
    private int video_id = 0;
    private String video_url = "";
    private PopupWindow InfoPopWindow;// 右上角popupwindow 及其中内容
    private TextView course_name;
    private CollapsibleTextView tv_course_introduce;
    private ListView teacherListView;
    private TeacherAdapter teach_adapter;
    private View outside_view;
    private boolean from_download_manage = true;
    private ArrayList<CourseModel> myOpenCourse;
    private boolean isCollectflag = false;
    final Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
                    if(!initVideoPlayerSuccess){
                        initVideoPlayer();
                    }
                    showData();
                    videoAdapter.notifyDataSetChanged();
                    setInfoContent();
                    if (c != null && c.getLms_course_list() != null && c.getLms_course_list().size() != 0 && c.getLms_course_list().get(0) != null) {
                        lms_course_id = c.getLms_course_list().get(0).getLms_course_id();
                    }
                    break;
               /*   case 2:
                    if (mContext == null) {
                        showNoData();
                        return;
                    }
                    showNoData();
                    break;
              /*  case 3:
                    adapter.notifyDataSetChanged();
                   *//* int groupCount = exList.getCount();
                    for (int i = 0; i < groupCount; i++) {
                        exList.expandGroup(i);
                    }*//*
//                    if(Constants.isFreshMyCourse){
//                        Toast.makeText(mContext,"您已加入此课程，可以开始学习啦！",Toast.LENGTH_SHORT).show();
//                    }
                    showData();
                    break;*/
                case Constants.LOGIN_TIME_OUT:
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
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
                    iv_collect_num.setImageResource(R.drawable.collection_normal);
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
                    iv_collect_num.setImageResource(R.drawable.collection_press);
                    isCollectflag = true;
                    LoadMyData.loadMyGuideCourse(mContext);
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
                    Toast.makeText(OpenCourseActivity.this, "加载失败，请稍后再试", Toast.LENGTH_SHORT).show();
                    break;
                case Constants.COURSE_JOIN_SUCCESS:
                    LoadMyData.loadMyOpenCourse(mContext);
                    break;
            }
//			super.handleMessage(msg);
        }
    };
    private TextView open_all_select;
    private TextView open_down_load;
    private boolean allSelected;
    private boolean allDownload;
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
                case R.id.btn_course_info:
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
                        KKDialog.getInstance().showLoginDialog(OpenCourseActivity.this, new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
                                Intent intent = new Intent(OpenCourseActivity.this, LoginActivity2.class);
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
                        popVideoAdapter = new VideoLoadAdapter();
                        load_listview.setAdapter(popVideoAdapter);
                        mDownloadPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
                        mDownloadPopupWindow.showAtLocation(OpenCourseActivity.this.findViewById(R.id.open_course_info), Gravity.BOTTOM, 0, 0);
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
                    if (appraiseListAdapter != null) {
                        appraiseListAdapter.notifyDataSetChanged();
                    }
                    if (!hasAppraiseData) {
                        showNoSuccess();
                    }
                    mAppraisePopupWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
                    mAppraisePopupWindow.showAtLocation(OpenCourseActivity.this.findViewById(R.id.open_course_info), Gravity.BOTTOM, 0, 0);
                    mAppraisePopupWindow.setAnimationStyle(R.style.app_pop);
                    mAppraisePopupWindow.setOutsideTouchable(true);
                    mAppraisePopupWindow.setFocusable(true);
                    mAppraisePopupWindow.update();
                    shade_view.setVisibility(View.VISIBLE);
                    pauseVideoPlayer();
//                    if (!API.getAPI().alreadySignin()) {
//                        KKDialog.getInstance().showLoginDialog(OpenCourseActivity.this, new OnClickListener() {
//                            @Override
//                            public void onClick(View v) {
//                                Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
//                                Intent intent = new Intent(OpenCourseActivity.this, LoginActivity2.class);
//                                intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
//                                intent.putExtra(ContextUtil.CATEGORY_COURSE, c);
//                                startActivity(intent);
//                                KKDialog.getInstance().dismiss();
//                            }
//                        }, new OnClickListener() {
//                            @Override
//                            public void onClick(View v) {
//                                KKDialog.getInstance().dismiss();
//                            }
//                        });
//                        return;
//                    }else{
//
//                    }
                    break;
                case R.id.rel_share_bottom:
                    pauseVideoPlayer();
                    CommonUtils.shareSettingContent(mContext, "http://www.kaikeba.com/courses/" + c.getId(), c.getName(),
                            "我正在开课吧观看《" + c.getName() + "》这门课，老师讲得吼赛磊呀！小伙伴们要不要一起来呀" + "http://www.kaikeba.com/courses/" + c.getId(), c.getCover_image(), "#新课抢先知#这课讲的太屌了，朕灰常满意！小伙伴们不要太想我，我在@开课吧官方微博 虐学渣，快来和我一起吧！" + "http://www.kaikeba.com/courses/" + c.getId());
                    break;
                case R.id.rel_collect_bottom:
                    if (!API.getAPI().alreadySignin()) {
                        KKDialog.getInstance().showLoginDialog(OpenCourseActivity.this, new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Constants.LOGIN_FROM = Constants.FROM_OPENCOURSE;
                                Intent intent = new Intent(OpenCourseActivity.this, LoginActivity2.class);
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
                        if (NetworkUtil.isNetworkAvailable(OpenCourseActivity.this)) {
                            KKDialog.getInstance().showProgressBar(OpenCourseActivity.this, KKDialog.IS_LOADING);
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
                            Toast.makeText(OpenCourseActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                        }
                    }
                    break;
                case R.id.open_all_select:
                    if (is_all_loading) {
                        return;
                    }
                    selected_all();
                    if (getIsNotLoadingNum() != 0) {
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
                                            downLoadSelected();
                                        }
                                    },
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                        }
                                    });
                        } else {
                            downLoadSelected();
                        }
                    }

                    break;
                case R.id.rel_go_download_manage:
                    Intent intent = new Intent(OpenCourseActivity.this, DownLoadMangerActivity.class);
                    startActivity(intent);
                    break;
                default:
                    break;
            }
        }
    };
    private List<CourseModel.ItemVideo> videoInfos;
    private List<CourseModel.Items> itemVideoInfos = new ArrayList<CourseModel.Items>();
    private List<DownloadInfo> selectedVideos = new ArrayList<DownloadInfo>();
    private Set<DownloadInfo> allDownLoadInfos = new HashSet<DownloadInfo>();
    private List<CourseModel> cs = new ArrayList<CourseModel>();

    public static OpenCourseActivity getOpenCourseActivity() {
        return openCourseActivity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.open_course_info);
        openCourseActivity = this;
        mContext = this;
        popShowHeight = CommonUtils.getScreenHeight(mContext);
        downloadManager = ContextUtil.downloadManager;
        loadMyOpenCourse();
        initView();
        setListener();
        initCourseArrange();
        getCourseInfo();
        setText();
        setCollectNum();
//        getCollectionCount(false);
        showData();
        loadAppraiseData(true);
        loadAppraiseData(false);
    }

    private List<CollectInfo> getCollectCourseList() {
        try {

            return DataSource.getDataSourse().findAllCollect();

        } catch (DbException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void setCollectNum() {
        List<CollectInfo> list = getCollectCourseList();
        if (list != null && list.size() != 0) {
            for (int i = 0; i < list.size(); i++) {
                if (c.getId() == list.get(i).getCourseId()) {
                    isCollectflag = true;
                    break;
                }
            }
        }
        if (isCollectflag) {
            iv_collect_num.setImageResource(R.drawable.collection_press);
        } else {
            iv_collect_num.setImageResource(R.drawable.collecion_normal);
        }
    }

    private void initView() {
        ll_course_info_title = (LinearLayout) findViewById(R.id.ll_course_info_title);
        btnBackNormal = (ImageView) findViewById(R.id.iv_back);
        btn_course_info = (ImageView) findViewById(R.id.btn_course_info);
        btn_course_info.setVisibility(View.VISIBLE);
        tvCourseTopName = (TextView) findViewById(R.id.tv_text);
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
        appraise_loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(mContext)) {
                    KKDialog.getInstance().showNoNetToast(mContext);
                } else {
                    showLoadingAppr();
                    loadModuleData();
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
        download_pop = LayoutInflater.from(mContext).inflate(R.layout.download_list_pop, null);
        load_listview = (ListView) download_pop.findViewById(R.id.load_listview);
        open_all_select = (TextView) download_pop.findViewById(R.id.open_all_select);
        open_down_load = (TextView) download_pop.findViewById(R.id.open_down_load);
        rel_go_download_manage = (RelativeLayout) download_pop.findViewById(R.id.rel_go_download_manage);
        download_video_total_num = (TextView) download_pop.findViewById(R.id.download_video_total_num);
        rel_go_download_manage.setOnClickListener(listener);
//        if(downloadManager.getDownloadInfoList()!=null){
//           download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//        }
        open_all_select.setOnClickListener(listener);
        open_down_load.setOnClickListener(listener);
        mDownloadPopupWindow = new PopupWindow(download_pop, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
        download_outside_view = download_pop.findViewById(R.id.download_outside_view);
        download_outside_view.setOnClickListener(listener);
        mDownloadPopupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                shade_view.setVisibility(View.GONE);
            }
        });
        videoAdapter = new VideoAdapter();
//        course_info = (TextView)findViewById(R.id.course_info);
        lv_video = (ListView) findViewById(R.id.lv_video);
        lv_video.setAdapter(videoAdapter);
        lv_video.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, final int position, long id) {
                if (videoAdapter.getSelectItem() == position) {
                    return;
                }
                int currentNetSate = NetUtil.getNetType(mContext);

                if (NetworkUtil.isNetworkAvailable(OpenCourseActivity.this)) {
                    if (API.getAPI().alreadySignin()) {
                        if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) { // 判断是否正在使用GPRS网络
                            KKDialog.getInstance().showNoWifi2Play(mContext,
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            Constants.nowifi_doplay = false;
                                            KKDialog.getInstance().dismiss();
                                            playAfterLogin(position);
                                        }
                                    },
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                        }
                                    });
                        } else {
                            playAfterLogin(position);
                        }

                    } else {
                        if (position < 2) {
                            if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) { // 判断是否正在使用GPRS网络
                                KKDialog.getInstance().showNoWifi2Play(mContext,
                                        new OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                Constants.nowifi_doplay = false;
                                                KKDialog.getInstance().dismiss();
                                                playBeforeLogin(position);
                                            }
                                        },
                                        new OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                            }
                                        });
                            } else {
                                playBeforeLogin(position);
                            }
                        } else {
                            KKDialog.getInstance().showLoginDialog(OpenCourseActivity.this, new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    Constants.LOGIN_FROM = Constants.FROM_GUIDECOURSE;
                                    Intent intent = new Intent(OpenCourseActivity.this, LoginActivity2.class);
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
                        }
                    }
                } else {
                    Toast.makeText(OpenCourseActivity.this, "已断开网络连接，请检查您的网络状态", Toast.LENGTH_LONG).show();
                }
            }
        });

        findViewById(R.id.btn_share_normal).setVisibility(View.GONE);
        iniPopupWindow();
    }

    private void playAfterLogin(int position){
        videoAdapter.setSelectItem(position);
        videoAdapter.notifyDataSetInvalidated();
        video_palyer.preparePlayData(getItemVideoInfos(), position, c.getCover_image(), 0, lms_course_id);
        video_palyer.play(0);
        enrollLmsWithExistCheck();
    }

    private void playBeforeLogin(int position){
        videoAdapter.setSelectItem(position);
        videoAdapter.notifyDataSetInvalidated();
        video_palyer.preparePlayData(getItemVideoInfos(), position, c.getCover_image(), 0, lms_course_id);
        video_palyer.play(0);
    }

    private void enrollLmsWithExistCheck() {
        //如果已经加入过了就不需要再次加入到我的公开课中
        if (isHas_join()) {
            if (c.getLms_course_list() != null && c.getLms_course_list().get(0) != null) {
                enrollLmsCourse(c.getLms_course_list().get(0).getLms_course_id());
            }
        }
    }

    private void dismissPopuWindow(){
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

        InfoPopWindow.setWidth(CommonUtils.getScreenWidth(OpenCourseActivity.this));
        InfoPopWindow.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#00000000")));
        InfoPopWindow.setOutsideTouchable(true);// 触摸popupwindow外部，popupwindow消失。这个要求你的popupwindow要有背景图片才可以成功，如上
    }

    private void setListener() {
        btnBackNormal.setOnClickListener(listener);
        btn_course_info.setOnClickListener(listener);
        rel_load_bottom.setOnClickListener(listener);
        rel_appraise_bottom.setOnClickListener(listener);
        rel_share_bottom.setOnClickListener(listener);
        rel_collect_bottom.setOnClickListener(listener);
    }

    private void setText() {
        tvCourseTopName.setText(c.getName());
    }

    private void initCourseArrange() {
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(mContext)) {
                    KKDialog.getInstance().showNoNetToast(mContext);
                } else {
                    showLoadingAppr();
                    loadModuleData();
                }
            }
        });
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        bar_height = CommonUtils.getStatusBarHeight(mContext);
        width = CommonUtils.getScreenWidth(mContext);
        height = (int) (CommonUtils.getScreenWidth(OpenCourseActivity.this) * 9) / 16;
        rl_video_player = (RelativeLayout) findViewById(R.id.rl_video_player);
        rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        Constants.FULL_SCREEN_NO_CLICK = false;
        video_palyer = new VideoPlayerView(mContext);
        video_palyer.setOnPlayClickListener(new OnClickListener(){
            @Override
            public void onClick(View v) {
                //播放公开课介绍视频 enroll 公开课视频
                enrollLmsWithExistCheck();
            }
        });
    }

    public void pauseVideoPlayer() {
        if (initVideoPlayerSuccess) {
            video_palyer.pauseMediaPlayer();
        }
    }

    public void initVideoPlayer() {
        if (!video_url.equals("")) {
            video_palyer.preparePlayData(video_url, c.getCover_image(), mCurVideoPos, lms_course_id, video_id);
            if (videoInfos != null && videoInfos.size() > 0 && video_id != 0) {
                for (int i = 0; i < videoInfos.size(); i++) {
                    if (video_id == videoInfos.get(i).getItemID()) {
                        updateSelectItem(i);
                        break;
                    }
                }
            }
        } else {
            if (videoInfos != null && videoInfos.get(0) != null) {
                video_palyer.preparePlayData(getItemVideoInfos(), 0, c.getCover_image(), mCurVideoPos, lms_course_id);
            }
        }
        rl_video_player.addView(video_palyer.makeControllerView());
        initVideoPlayerSuccess = true;
    }

    //判断是否加入到我的公开课中了
    public boolean isHas_join() {
        if (myOpenCourse != null && myOpenCourse.size() != 0) {
            for (CourseModel courseInfo : myOpenCourse) {
                if (courseInfo.getId() == c.getId()) {
                    return false;
                }
            }
            return true;
        } else {
            return true;
        }
    }

    private void getCourseInfo() {
        Bundle b = getIntent().getExtras();
        c = (CourseModel) b.getSerializable(ContextUtil.CATEGORY_COURSE);
        video_id = b.getInt("videoID", 0);
        mCurVideoPos = b.getInt("duation", 0);
        video_url = b.getString("videoUrl", "");
        if (c != null) {
            courseID = c.getId();
            courseName = c.getName();
            bgUrl = c.getCover_image();
            videoInfos = c.getVideos();
            if(videoInfos!=null){
                if (!initVideoPlayerSuccess) {
                    initVideoPlayer();
                }
            }
        }
        if (videoInfos == null || videoInfos.size() == 0) {
            loadModuleData();
        }
        if (c != null && c.getLms_course_list() != null && c.getLms_course_list().size() != 0 && c.getLms_course_list().get(0) != null) {
            lms_course_id = c.getLms_course_list().get(0).getLms_course_id();
        }
    }

    private void loadCourseById(final boolean fromCache) {
        Type type = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        String url = HttpUrlUtil.COURSES + c.getId();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    if (videoInfos != null) {
                        videoInfos.clear();
                    }
                    curCourse = (CourseModel) data;
                    videoInfos = curCourse.getVideos();
                    handler.sendEmptyMessage(1);
                }
            }
        });
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

    //下载选中项
    public void downLoadSelected() {
        for (CourseModel.ItemVideo info : videoInfos) {
            if (info.getIsSelected()) {
                if (info.isLoadFailure()) {
                    DownloadInfo downloadInfo = downloadManager.getDownloadInfoByCourseId(c.getId() + "", info.getItemID());
                    resumeDownLoad(downloadInfo);
                    info.setLoadFailure(false);
                } else {
                    download(info);
                }
                info.setIsSelected(false);
                info.setIsLoading(true);
            }
        }
        if (selected_num > 0) {
            MyToast.getInstance().okToast("已加入下载列表");
        }
        selected_num = 0;
        open_down_load.setText("下载");
        open_down_load.setTextColor(getResources().getColor(R.color.text_download_normal));
//        if(downloadManager.getDownloadInfoList()!=null){
//           download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//        }
        allSelected = false;
        open_all_select.setText("全选");
        popVideoAdapter.notifyDataSetChanged();
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
        String url = HttpUrlUtil.EVALUATION + courseID;
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    if (appraisementList != null) {
                        appraisementList.clear();
                    }
                    hasAppraiseData = true;
                    appraisementList.addAll((List<Appraisement>) data);
                    handler.sendEmptyMessage(4);
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

    //加载我的公开课信息
    private void loadMyOpenCourse() {
        myOpenCourse = new ArrayList<CourseModel>();
        PretreatDataCache.loadMyOpenCourse(mContext, new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    myOpenCourse.addAll((List<CourseModel>) data);
                }
            }
        });
    }

    public void getCollectionCount(boolean fromCache) {
        Type type = new TypeToken<CollectionCount>() {
        }.getType();
        String url = HttpUrlUtil.COLLECTIONS + "1";
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
        ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
            @Override
            public void onAuthenticationFail() {
                Intent i = new Intent(mContext, AllCourseActivity.class);
                mContext.startActivity(i);
                ((Activity) mContext).finish();
            }
        });
    }

    public void enrollLmsCourse(final int cLms_course_id) {
        new Thread() {
            public void run() {
                try {
                    if (null == EnrollCourseAPI.entrollCourse(cLms_course_id)) {

                    } else {
                        handler.sendEmptyMessage(Constants.COURSE_JOIN_SUCCESS);
                    }
                } catch (DibitsExceptionC e) {

                }


            }

            ;
        }.start();
    }

    protected void loadModuleData() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    cs.clear();
                    cs.addAll((List<CourseModel>) data);
                }
                if (cs == null || cs.size() == 0) {
                    handler.sendEmptyMessage(2);
                } else {
                    for (CourseModel info : cs) {
                        if (courseID == info.getId()) {
                            c = info;
                            break;
                        }
                    }
//                    if (curCourse.getIntro() != null) {
//                        course_info.setText(curCourse.getIntro());
//                    }
                    videoInfos = c.getVideos();
                    handler.sendEmptyMessage(1);
                }
            }

        });
    }

    private List<CourseModel.Items> getItemVideoInfos() {
        itemVideoInfos.clear();
        for (CourseModel.ItemVideo videoInfo : videoInfos) {
            CourseModel.Items item = new CourseModel.Items();
            item.setUrl(videoInfo.getVideoURL());
            item.setId(videoInfo.getItemID());
            itemVideoInfos.add(item);
        }
        return itemVideoInfos;
    }

    private int getPosition(int itemId) {
        for (int i = 0; i < videoInfos.size(); i++) {
            if (videoInfos.get(i).getItemID() == itemId) {
                return i;
            }
        }
        return 0;
    }

    @Override
    public void update(Object obj) {
        int itemId = (Integer) obj;
        updateSelectItem(getPosition(itemId));
    }

    private void updateSelectItem(int position){
        videoAdapter.setSelectItem(position);
        videoAdapter.notifyDataSetInvalidated();
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
        if (videoInfos != null && videoInfos.size() > 0 && c != null && downloadManager != null) {
            for (int i = 0; i < videoInfos.size(); i++) {
                DownloadInfo info = downloadManager.getDownloadInfoByCourseId(c.getId() + "", videoInfos.get(i).getItemID());
                if (info != null) {
                    if (info.getState() != HttpHandler.State.FAILURE) {
                        videoInfos.get(i).setIsLoading(true);
                        videoInfos.get(i).setIsSelected(true);
                    } else {
                        videoInfos.get(i).setIsLoading(false);
                        videoInfos.get(i).setIsSelected(false);
                        videoInfos.get(i).setLoadFailure(true);
                    }
                } else {
                    videoInfos.get(i).setIsSelected(false);
                    videoInfos.get(i).setIsLoading(false);
                    videoInfos.get(i).setLoadFailure(false);
                }
            }
        }
        if (popVideoAdapter != null) {
            popVideoAdapter.notifyDataSetChanged();

        }
    }

    /**
     * 获取已选数量
     */
    public int getAlreadySelectNum() {
        int num = 0;
        for (CourseModel.ItemVideo info : videoInfos) {
            if (!info.getIsLoading()) {
                if (info.getIsSelected()) {
                    num++;
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
        for (CourseModel.ItemVideo info : videoInfos) {
            if (!info.getIsLoading()) {
                num++;
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
            for (CourseModel.ItemVideo info : videoInfos) {
                if (!info.getIsSelected() && !info.getIsLoading()) {
                    selected_num++;
                }
            }
        }
        if (allSelected) {
            for (CourseModel.ItemVideo info : videoInfos) {
                if (!info.getIsLoading()) {
                    info.setIsSelected(false);
                }
            }
        } else {
            for (CourseModel.ItemVideo info : videoInfos) {
                if (!info.getIsLoading()) {
                    info.setIsSelected(true);
                }
            }
        }
        if (selected_num != 0) {
            setAlreadyNum(selected_num);
        } else {
            setAlreadyNum(0);
        }
        popVideoAdapter.notifyDataSetChanged();
    }

    private void download(CourseModel.ItemVideo video) {
        try {
            downloadManager.addNewDownload(API.getAPI().getUserObject().getId() + splitStr + courseID + splitStr + lms_course_id + splitStr + video.getItemID(),
                    courseName,
                    video.getVideoURL(),
                    bgUrl,
                    video.getItemTitle(),
                    FileUtils.getVideoFilePath(API.getAPI().getUserObject().getId(), courseID + "", lms_course_id + "", video.getItemID() + "") + video.getItemTitle() + ".mp4",
                    true,
                    false,
                    null);
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
        if (getAlreadySelectNum() == getIsNotLoadingNum()) {
            open_all_select.setText("全选");
            open_all_select.setTextColor(getResources().getColor(R.color.text_download_normal));
            is_all_loading = true;
        } else {
            open_all_select.setTextColor(getResources().getColor(R.color.text_selected_all));
            is_all_loading = false;
        }
        popVideoAdapter.notifyDataSetChanged();
    }

    private void resumeDownLoad(final DownloadInfo downloadInfo) {
        if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(OpenCourseActivity.this)) {
            KKDialog.getInstance().showNoWifi2Doload(OpenCourseActivity.this,
                    new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            KKDialog.getInstance().dismiss();
                            Constants.nowifi_doload = false;
                            try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                                popVideoAdapter.notifyDataSetChanged();
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                        }
                    },
                    new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            KKDialog.getInstance().dismiss();
                        }
                    });
        } else {
            try {
                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                popVideoAdapter.notifyDataSetChanged();
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
        }
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
        rl_video_player.setVisibility(View.VISIBLE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
        rl_video_player.setVisibility(View.GONE);
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
            lv_video.setVisibility(View.GONE);
            setGone();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            lv_video.setVisibility(View.VISIBLE);
            setVisible();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        if (!video_palyer.isScaleTag) {
            appointSkip();
        } else {
            video_palyer.onBackPressed();
        }
    }

    public void appointSkip() {
        if (Constants.FROM_WHERE == Constants.FROM_DYNAMIC) {
            Constants.FROM_WHERE = 0;
            Intent intent = new Intent(OpenCourseActivity.this, TabCourseActivity.class);
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
        MobclickAgent.onPageStart("OpenCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
        from_download_manage = true;
        initSelectedAll();
        initSelectedState();
        video_palyer.addWatcher(this);
    }

    public void onPause() {
        super.onPause();
        if (initVideoPlayerSuccess) {
            if (video_palyer != null) {
                video_palyer.onDestroy();
                video_palyer.unregisterReceiver();
            }
        }
        MobclickAgent.onPageEnd("OpenCourse");
        MobclickAgent.onPause(this);
    }

    private class VideoLoadAdapter extends BaseAdapter {
        private DownloadInfo downloadInfo;
        private int position;

        private VideoLoadAdapter() {
            if (videoInfos != null) {
                for (int i = 0; i < videoInfos.size(); i++) {
                    DownloadInfo info = downloadManager.getDownloadInfoByCourseId(courseID + "", videoInfos.get(i).getItemID());
                    if (info != null) {
                        if (info.getState() != HttpHandler.State.FAILURE) {
                            videoInfos.get(i).setIsLoading(true);
                            videoInfos.get(i).setIsSelected(true);
                            videoInfos.get(i).setLoadFailure(false);
                        } else {
                            videoInfos.get(i).setIsLoading(false);
                            videoInfos.get(i).setIsSelected(false);
                            videoInfos.get(i).setLoadFailure(true);
                        }
                    } else {
                        videoInfos.get(i).setIsLoading(false);
                        videoInfos.get(i).setIsSelected(false);
                        videoInfos.get(i).setLoadFailure(false);
                    }
                }
            }
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public Object getItem(int position) {
            if (videoInfos != null) {
                return videoInfos.get(position);
            }
            return null;
        }

        @Override
        public int getCount() {
            if (videoInfos != null) {
                return videoInfos.size();
            }
            return 0;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            ChildViewHolder childHolder = null;
            this.position = position;

            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.openc_download_child, null);
                childHolder = new ChildViewHolder(convertView);
                convertView.setTag(childHolder);
                childHolder.refresh();
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
            }
            childHolder.course_name.setText(videoInfos.get(position).getItemTitle());
            childHolder.course_selected.setVisibility(View.VISIBLE);
            childHolder.load_video_state.setVisibility(View.INVISIBLE);
            downloadInfo = downloadManager.getDownloadInfoByCourseId(c.getId() + "", videoInfos.get(position).getItemID());
            allDownLoadInfos.add(downloadInfo);

            if (downloadInfo != null) {
                HttpHandler.State state = downloadInfo.getState();
                if (state != HttpHandler.State.FAILURE) {
                    childHolder.load_video_state.setVisibility(View.VISIBLE);
//                    videoInfos.get(position).setIsLoading(true);
//                    videoInfos.get(position).setIsSelected(true);
                } else {
                    childHolder.load_video_state.setVisibility(View.VISIBLE);
//                    videoInfos.get(position).setIsSelected(false);
//                    videoInfos.get(position).setIsLoading(false);
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
                    callBack.setUserTag(new WeakReference<OpenCourseActivity.ChildViewHolder>(childHolder));
                }
                notifyDataSetChanged();
            } else {
                if (from_download_manage) {
                    for (int i = 0; i < videoInfos.size(); i++) {
                        childHolder.load_video_state.setVisibility(View.INVISIBLE);
                        childHolder.course_selected.setVisibility(View.VISIBLE);
                        videoInfos.get(position).setIsLoading(false);
                        videoInfos.get(position).setIsSelected(false);
                    }
                }
            }


            if (videoInfos.get(position).getIsSelected()) {
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_pressed));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_title));
                childHolder.course_selected.setImageResource(R.drawable.download_select);
            } else {
                childHolder.course_selected.setImageResource(R.drawable.download_circle);
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_normal));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_unselected_item));
            }
            final ChildViewHolder finChildHolder = childHolder;
            convertView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!is_all_loading) {
                        if (!videoInfos.get(position).getIsLoading()) {
                            video_selected(finChildHolder, position);
                        }
//                        videoInfos.get(position).setLoadFailure(true);
                    }
                }
            });

//            if(downloadManager.getDownloadInfoList()!=null){
//                download_video_total_num.setText("查看下载视频(共"+downloadManager.getDownloadInfoList().size()+"个视频)");
//            }
            if (videoInfos.get(position).getIsLoading()) {
                childHolder.course_selected.setImageResource(R.drawable.download_selected);
                convertView.setBackgroundColor(getResources().getColor(R.color.item__bg_pressed));
                childHolder.course_name.setTextColor(getResources().getColor(R.color.text_color_title));
//                childHolder.course_selected.setVisibility(View.INVISIBLE);
            }
//            else{
//                childHolder.course_selected.setVisibility(View.VISIBLE);
//            }
            if (getIsNotLoadingNum() == 0) {
                open_all_select.setText("全选");
                open_all_select.setTextColor(getResources().getColor(R.color.text_download_normal));
                is_all_loading = true;
            } else {
                is_all_loading = false;
                open_all_select.setTextColor(getResources().getColor(R.color.text_selected_all));
            }
            return convertView;
        }

        private void video_selected(ChildViewHolder childViewHolder, int position) {
            if (videoInfos.get(position).getIsSelected()) {
                childViewHolder.course_selected.setImageResource(R.drawable.download_circle);
                videoInfos.get(position).setIsSelected(false);
                selected_num--;
                setAlreadyNum(selected_num);
            } else {
                childViewHolder.course_selected.setImageResource(R.drawable.download_select);
                videoInfos.get(position).setIsSelected(true);
                selected_num++;
                setAlreadyNum(selected_num);
            }
            if (getAlreadySelectNum() == getIsNotLoadingNum()) {
                open_all_select.setText("取消全选");
                allSelected = true;
            } else {
                open_all_select.setText("全选");
                allSelected = false;
            }
            from_download_manage = false;
            notifyDataSetChanged();
        }

    }

    private class VideoAdapter extends BaseAdapter {

        private int selectItem = 0;

        @Override
        public int getCount() {
            if (videoInfos != null) {
                return videoInfos.size();
            }
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            CourseChildViewHolder childHolder = null;
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.course_child, null);
                childHolder = new CourseChildViewHolder(convertView);
                convertView.setTag(childHolder);
            } else {
                childHolder = (CourseChildViewHolder) convertView.getTag();
            }
            childHolder.course_name.setText(videoInfos.get(position).getItemTitle());


            if (position == selectItem) {
                convertView.setBackgroundColor(getResources().getColor(R.color.course_bg_color));
            } else {
                convertView.setBackgroundColor(getResources().getColor(R.color.white));
            }

            //convertView.getBackground().setAlpha(80);

            return convertView;
        }

        public int getSelectItem() {
            return selectItem;
        }

        public void setSelectItem(int selectItem) {
            this.selectItem = selectItem;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public Object getItem(int position) {
            if (videoInfos != null) {
                return videoInfos.get(position);
            }
            return null;
        }
    }

    public class CourseChildViewHolder {
        TextView course_name;
        ImageView course_ImView;

        public CourseChildViewHolder(View v) {
            course_name = (TextView) v.findViewById(R.id.course_name);
            course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
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
            popVideoAdapter.notifyDataSetChanged();
        }
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {

        @SuppressWarnings("unchecked")
        private void refreshListItem() {
            if (userTag == null) return;
            try {
                WeakReference<OpenCourseActivity.ChildViewHolder> tag = (WeakReference<OpenCourseActivity.ChildViewHolder>) userTag;
                OpenCourseActivity.ChildViewHolder holder = tag.get();
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
            for (int i = 0; i < videoInfos.size(); i++) {
                DownloadInfo info = downloadManager.getDownloadInfoByCourseId(c.getId() + "", videoInfos.get(i).getItemID());
                if (info != null) {
                    if (info.getState() != HttpHandler.State.FAILURE) {
                        videoInfos.get(i).setIsLoading(true);
                        videoInfos.get(i).setIsSelected(true);
                    } else {
                        videoInfos.get(i).setIsLoading(false);
                        videoInfos.get(i).setIsSelected(false);
                        videoInfos.get(i).setLoadFailure(true);
                    }
                }
            }
            refreshListItem();
        }

        @Override
        public void onCancelled() {
            refreshListItem();
        }
    }

}
