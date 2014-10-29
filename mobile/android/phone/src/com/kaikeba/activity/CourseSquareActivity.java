package com.kaikeba.activity;

import android.app.Activity;
import android.content.*;
import android.graphics.Color;
import android.graphics.Paint;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.DisplayMetrics;
import android.view.*;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.google.gson.reflect.TypeToken;
import com.igexin.sdk.PushManager;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.fragment.LoadMangerFragment;
import com.kaikeba.activity.fragment.MyCourseFragment;
import com.kaikeba.activity.fragment.RightNavFragment;
import com.kaikeba.adapter.CourseSquareAdapter;
import com.kaikeba.adapter.PageAdapter;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.base.BaseSlidingFragmentActivity;
import com.kaikeba.common.base.SlidingMenu;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.download.DownloadService;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.PromoInfo;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.LoadMoreListView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;

import java.io.File;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class CourseSquareActivity extends BaseSlidingFragmentActivity implements
        OnClickListener, LoadMoreListView.IXListViewListener {
    private final static String tag = "CourseSquareActivity";
    private static CourseSquareActivity mainActivity;
    /**
     * 滑动菜单
     */
    public SlidingMenu mSlidingMenu;
    public Button load_edit;
    private int currentItem = 0; // 当前图片的索引号
    /**
     * 按时间安排执行的任务， 这里指切换轮播图
     */
    private ScheduledExecutorService scheduledExecutorService;
    /**
     * 主页面自定义的ListView
     */
    private LoadMoreListView lv_all_course;
    /**
     * 主页面Adapter
     */
    private CourseSquareAdapter cAdapter;
    private List<String> urls = new ArrayList<String>();
    /**
     * 轮播图信息
     */
    private ArrayList<PromoInfo> courseInfoList;
    // 切换当前显示的图片
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1:
                    cAdapter.notifyDataSetChanged();
                    Toast.makeText(CourseSquareActivity.this, "加载成功",
                            Toast.LENGTH_SHORT).show();
                    onLoad();
                    break;
                case 2:
                    Toast.makeText(CourseSquareActivity.this, "没有更多课程",
                            Toast.LENGTH_SHORT).show();
                    break;
                case 3:
                case 4:
                    showNoData();
                    break;
                case 5:
                    if (cAdapter != null) {
                        cAdapter.notifyDataSetChanged();
                    }
                    break;
                default:
                    viewPager.setCurrentItem(currentItem);// 切换当前显示的图片
                    if (currentItem < viewPager.getChildCount() && courseInfoList == null) {
                        scheduledExecutorService.shutdown();
                    }
                    break;
            }
        }

        ;
    };
    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(Constants.ACTION_IS_REFRESH)) {
                if (courseInfoList == null && !Constants.NET_IS_SUCCESS) {
                    loadData(true);
                }
            }
        }
    };
    private ArrayList<PromoInfo> allPromoinfos;
    private TextView pro_title;
    private TextView pro_content;
    private List<CourseModel> invisibleAllCourses;
    /**
     * 轮播图圆点容器
     */
    private LinearLayout pointLinear;
    private RelativeLayout rl_layout;
    private ViewPager viewPager; // android-support-v4中的滑动组件
    private BitmapManager bmpManager;
    private ImageView ib_signup;
    private List<CourseModel> curCourses;
    /**
     * 右侧侧边栏Fragment
     */
    private RightNavFragment mFrag;
    private MyCourseFragment myCourseFragment;
    private LoadMangerFragment loadMagerFragment;
    private RelativeLayout view_loading;
    private LinearLayout ll_my_course_container;
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    ;
    private TextView tv_logo_mycourse;
    private ImageView iv_logo;
    private ArrayList<Badge> badges;
    private List<CourseModel> visibleAllCourses;
    private FragmentManager fm;
    private ScrollTask task;
    private TextView load_title;
    private LinearLayout ll_load_manager_container;
    private DownloadManager downloadManager;
    /**
     * 首页“全部课程”按钮
     */
    private PopupWindow window;
    private ArrayList<String> categories;
    private LinearLayout all_course_btn;
    private TextView tv_all_course;
    private NetBroadcastReceiver mNetBroadcastReceiver;
    private SharedPreferences appPrefs;
    private OnItemClickListener listViewListener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            transInfo2Drawer((CourseModel) parent.getAdapter().getItem(position));
        }
    };
    private long exitTime = 0;

    public static CourseSquareActivity getMainActivity() {
        return mainActivity;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        UmengUpdateAgent.update(this);//自动更新
        //   初始化推送SDK：
        PushManager.getInstance().initialize(this.getApplicationContext());
        fm = getSupportFragmentManager();
        mainActivity = this;
        initSlidingMenu();
        setContentView(R.layout.all_courses);
        initView(savedInstanceState);
        if (getIntent().getBooleanExtra("isSuccess", false)) {
            mFrag.changeState();
            Toast.makeText(this, "登录成功", Toast.LENGTH_LONG).show();
        } else if (getIntent().getBooleanExtra("isFirst", false)) {
            Toast.makeText(this, "登录失败,请重新登录", Toast.LENGTH_LONG).show();
        }

        if (API.getAPI().alreadySignin()) {
            mFrag.changeState();
        }

        bmpManager = new BitmapManager();
        allPromoinfos = new ArrayList<PromoInfo>();
        loadData(true);
        scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
        IntentFilter myIntentFilter = new IntentFilter();
        myIntentFilter.addAction(Constants.ACTION_IS_REFRESH);
        //注册网络监听
        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
//        mNetBroadcastReceiver = new NetBroadcastReceiver();
//        registerReceiver(mNetBroadcastReceiver, filter);
        //注册广播
        registerReceiver(mBroadcastReceiver, myIntentFilter);
        downloadManager = DownloadService.getDownloadManager(mainActivity.getApplicationContext());
        if (NetUtil.getNetType(this) != Constants.NO_NET) {
            //全部开始下载
            try {
                downloadManager.resumeDownloadAll(new DownloadRequestCallBack());
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
        }
        //判断用户是否第一次登陆kkb，并上传数据
        appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);

        boolean isFirstOpen = appPrefs.getBoolean(ContextUtil.isFirstOpened, true);


        if (isFirstOpen) {
            try {

                UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(CourseSquareActivity.this, "");
                UploadData.getInstance().addDbData(CourseSquareActivity.this, logininfo, "CPA");
            } catch (DbException e) {
                e.printStackTrace();
            }
            SharedPreferences.Editor editor = appPrefs.edit();
            editor.putBoolean(ContextUtil.isFirstOpened, false);
            editor.commit();

//            Log.d("jack","第一次登陆");
//            UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(CourseSquareActivity.this);
//            Type type = new TypeToken<UserLoginInfo>() {
//            }.getType();
//            jsonStr = JsonEngine.toJson(logininfo, type);
//            sendData(jsonStr);
//        }else {
//            Log.d("jack","非第一次登陆,使用缓存提交");
//            try {
//                DBUploadInfo uploadInfo = dataSource.selectData();
//                if(uploadInfo != null){
//                    sendData(uploadInfo.getContent());
//                }
//            } catch (DbException e) {
//                e.printStackTrace();
//            }
        }
        UploadData.getInstance().upload(CourseSquareActivity.this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mBroadcastReceiver != null) {
            unregisterReceiver(mBroadcastReceiver);
            mBroadcastReceiver = null;
        }
        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void initView(Bundle savedInstanceState) {
        mSlidingMenu.setSecondaryMenu(R.layout.main_right_layout);
        FragmentTransaction mFragementTransaction = getSupportFragmentManager()
                .beginTransaction();
        mFrag = new RightNavFragment();
        curCourses = new ArrayList<CourseModel>();
        badges = new ArrayList<Badge>();
        mFragementTransaction.add(R.id.main_right_fragment, mFrag);
        mFragementTransaction.commit();

        lv_all_course = (LoadMoreListView) findViewById(R.id.lv_all_course);
        lv_all_course.setPullLoadEnable(true);
        lv_all_course.setPullRefreshEnable(false);
        lv_all_course.setXListViewListener(this);
        lv_all_course.setOnItemClickListener(listViewListener);
        lv_all_course.setCacheColorHint(Color.TRANSPARENT);
        lv_all_course.requestFocus(0);
        rl_layout = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.all_course_listview_header, null);
        lv_all_course.addHeaderView(rl_layout);

        all_course_btn = (LinearLayout) LayoutInflater.from(this).inflate(R.layout.all_course_btn, null);
        tv_all_course = (TextView) all_course_btn.findViewById(R.id.tv_all_course);
        all_course_btn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(CourseSquareActivity.this, "LinearLayout click", Toast.LENGTH_SHORT).show();
            }
        });
//        lv_all_course.addHeaderView(all_course_btn);

        pointLinear = (LinearLayout) findViewById(R.id.gallery_point_linear);
        pro_title = (TextView) findViewById(R.id.pro_title);
        pro_content = (TextView) findViewById(R.id.pro_content);
        viewPager = (ViewPager) findViewById(R.id.view_pager);
        viewPager.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                viewPager.requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });
        // 设置一个监听器，当ViewPager中的页面改变时调用
        viewPager.setOnPageChangeListener(new MyPageChangeListener());
        mSlidingMenu.addIgnoredView(viewPager);
        ib_signup = (ImageView) findViewById(R.id.ib_signup);
        ib_signup.setOnClickListener(this);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        loading_fail.setOnClickListener(this);
        ll_my_course_container = (LinearLayout) findViewById(R.id.ll_my_course_container);
        tv_logo_mycourse = (TextView) findViewById(R.id.tv_logo_mycourse);
        iv_logo = (ImageView) findViewById(R.id.iv_logo);

        load_edit = (Button) findViewById(R.id.download_edit);
        load_edit.setOnClickListener(this);
        load_title = (TextView) findViewById(R.id.load_logo_loadmanager);
        ll_load_manager_container = (LinearLayout) findViewById(R.id.ll_load_manager_container);
        cAdapter = new CourseSquareAdapter(curCourses,
                CourseSquareActivity.this, handler,
                bmpManager, badges, lv_all_course);
        lv_all_course.setAdapter(cAdapter);

        new Thread() {
            @Override
            public void run() {
                super.run();
                try {
                    categories = CoursesAPI.getCourseCategory();
                } catch (Exception e) {
                    System.out.println("getCourseCategory failed");
                    e.printStackTrace();
                }
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        initPopup();
                    }
                });
            }
        }.start();
    }

    private void initPopup() {
        window = new PopupWindow(getPopupWindowView(), ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        window.setOutsideTouchable(true);
        tv_all_course.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (window.isShowing()) {
                    window.dismiss();
                    Toast.makeText(CourseSquareActivity.this, "关闭", Toast.LENGTH_SHORT).show();
                    tv_all_course.setBackgroundDrawable(getResources().getDrawable(R.drawable.allcourses_up));
                } else {
                    window.showAsDropDown(all_course_btn, 0, 0);
                    Toast.makeText(CourseSquareActivity.this, "打开", Toast.LENGTH_SHORT).show();
                    tv_all_course.setBackgroundDrawable(getResources().getDrawable(R.drawable.allcourses_down));
                }
            }
        });
    }

    private View getPopupWindowView() {
        LinearLayout pop_content = (LinearLayout) View.inflate(CourseSquareActivity.this, R.layout.popup_window_item, null);

        LinearLayout linear_layout_item = (LinearLayout) View.inflate(CourseSquareActivity.this, R.layout.linear_layout_item, null);

        if (categories == null) {
            return pop_content;
        }
        Paint paint = new Paint();
        int screen_width = CommonUtils.getScreenWidth(CourseSquareActivity.this);
        int linear_layout_item_width = 0;

        StringBuffer sb = new StringBuffer();
        for (String category : categories) {
            sb.append(category + ",");
        }
        System.out.print("课程类别的个数：" + categories.size() + System.getProperty("line.separator") + "类别为：" + sb.toString());
        categories.add(0, "全部");
        for (int i = 0; i < categories.size(); i++) {
            System.out.println(categories.get(i));
            LinearLayout category_item_view = (LinearLayout) View.inflate(CourseSquareActivity.this, R.layout.text_view_item, null);
            TextView tv_category = (TextView) category_item_view.findViewById(R.id.tv_category);
            tv_category.setText(categories.get(i));
            tv_category.setTag(i);
            tv_category.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    Toast.makeText(CourseSquareActivity.this, (Integer) v.getTag(), Toast.LENGTH_SHORT).show();
                }
            });
            linear_layout_item.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            linear_layout_item_width += (20 + paint.measureText(categories.get(i)) + 24 + 40 + 1);
            if (linear_layout_item.getMeasuredWidth() + 1 < screen_width) {
                linear_layout_item.addView(category_item_view);
            } else {
                linear_layout_item.removeView(category_item_view);
                linear_layout_item.getChildAt(linear_layout_item.getChildCount() - 1).findViewById(R.id.iv_category).setVisibility(View.GONE);
                pop_content.addView(linear_layout_item);
                linear_layout_item = (LinearLayout) View.inflate(CourseSquareActivity.this, R.layout.linear_layout_item, null);
                linear_layout_item.addView(category_item_view);
            }
        }
        if (linear_layout_item.getChildCount() > 0) {
            linear_layout_item.getChildAt(linear_layout_item.getChildCount() - 1).findViewById(R.id.iv_category).setVisibility(View.GONE);
            pop_content.addView(linear_layout_item);
        } else if (pop_content.getChildCount() <= 0) {
            pop_content.addView(linear_layout_item);
        }
        return pop_content;
    }

    private int computeMaxStringWidth(int currentMax, String[] strings, Paint p) {
        float maxWidthF = 0.0f;
        int len = strings.length;
        for (int i = 0; i < len; i++) {
            float width = p.measureText(strings[i]);
            maxWidthF = Math.max(width, maxWidthF);
        }
        int maxWidth = (int) (maxWidthF + 0.5);
        if (maxWidth < currentMax) {
            maxWidth = currentMax;
        }
        return maxWidth;
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

    @Override
    public void onStart() {
        // 当Activity显示出来后，每两秒钟切换一次图片显示
//		if (task == null) {
//			task = new ScrollTask();
//            synchronized (scheduledExecutorService) {
//                scheduledExecutorService.scheduleAtFixedRate(task, 1, 5, TimeUnit.SECONDS);
//            }
//		}
        super.onStart();
    }

    private void diagamSchedule() {
        if (task == null) {
            task = new ScrollTask();
            synchronized (scheduledExecutorService) {
                scheduledExecutorService.scheduleAtFixedRate(task, 5, 5, TimeUnit.SECONDS);
            }
        }
    }

    @Override
    public void onStop() {
        // 当Activity不可见的时候停止切换
        // scheduledExecutorService.shutdown();
        super.onStop();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("all_courses"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("all_courses");
        MobclickAgent.onPause(this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 可以根据多个请求代码来作相应的操作
        if (1 == resultCode && data.getBooleanExtra("isSuccess", false)) {
        } else if (1 == resultCode && !data.getBooleanExtra("isSuccess", false)) {
        }
        if (resultCode == 2 && data.getBooleanExtra("setting", false)) {
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    public void changeLoginState() {

        if (API.getAPI().alreadySignin()) {
            mFrag.changeState();
            FragmentTransaction mFragementTransaction = fm.beginTransaction();
            Fragment fragment = fm.findFragmentByTag("MyCourse");
            if (fragment != null) {
                mFragementTransaction.remove(fragment);
            }
            mFragementTransaction.commitAllowingStateLoss();
        } else {
            mFrag.loginToLogout();
            FragmentTransaction mFragementTransaction = fm.beginTransaction();
            Fragment fragment = fm.findFragmentByTag("MyCourse");
            if (fragment != null) {
                mFragementTransaction.remove(fragment);
            }
            mFragementTransaction.commitAllowingStateLoss();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ib_signup:
                mSlidingMenu.showSecondaryMenu(true);
                break;
            case R.id.download_edit:
                if (!Constants.IS_EDIT) {
                    Constants.IS_EDIT = true;
                    load_edit.setText(getResources().getString(R.string.load_finish));
                    loadMagerFragment.edit_State();
                } else {
                    Constants.IS_EDIT = false;
                    load_edit.setText(getResources().getString(R.string.load_edit));
                    loadMagerFragment.edit_State();
                }
                break;
            case R.id.loading_fail:
                if (Constants.NO_NET == NetUtil.getNetType(CourseSquareActivity.this)) {
                    KKDialog.getInstance().showNoNetToast(CourseSquareActivity.this);
                } else {
                    showLoading();
                    loadData(false);
                }
                break;
            default:
                break;
        }
    }

    public void showLoading() {
        view_loading_fail.setVisibility(View.GONE);
        view_loading.setVisibility(View.VISIBLE);
    }

    private void loadData(boolean fromCache) {
        drawPromo(fromCache);
    }

    private void drawPromo(final boolean fromCache) {
        new Thread(new Runnable() {
            @Override
            public void run() {

                Type type = new TypeToken<ArrayList<PromoInfo>>() {
                }.getType();
                ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildPromoInfoURL(), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
                    @Override
                    public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                        if (data != null) {
                            courseInfoList = (ArrayList<PromoInfo>) data;
                            if (courseInfoList != null) {
                                allPromoinfos.addAll(courseInfoList);
                            }
                            if (allPromoinfos == null || allPromoinfos.size() == 0) {
                                handler.sendEmptyMessage(4);
                                return;
                            }
                            if (courseInfoList == null) {
                                return;
                            }
                            drawAllCourse(fromCache);
                            // 轮播图加载数据
                            handler.post(new Runnable() {
                                @Override
                                public void run() {

                                    urls.clear();
                                    for (PromoInfo pro : courseInfoList) {
                                        urls.add(pro.getSliderImage());
                                    }
                                    initPointView();
                                    PageAdapter adapter = new PageAdapter(urls,
                                            CourseSquareActivity.this, bmpManager,
                                            new PagerListener());
                                    // MyAdapter adapter = new MyAdapter();
                                    viewPager.setAdapter(adapter);// 设置填充ViewPager页面的适配器
                                }
                            });
                        } else if (data == null && courseInfoList == null) {
                            handler.sendEmptyMessage(3);
                            return;
                        } else {
                            //
                        }
                    }
                });
            }
        }).start();
    }

    private void drawAllCourse(final boolean fromCache) {

        ImgLoaderUtil.threadPool.submit(new Runnable() {

            public void run() {
                Type type = new TypeToken<ArrayList<CourseModel>>() {
                }.getType();
                ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildAllCoursesURL(), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
                    @Override
                    public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                        if (data != null) {
                            List<CourseModel> allCourses = (ArrayList<CourseModel>) data;
                            if (allCourses != null) {
                                if (API.getAPI().alreadySignin()) {
                                    try {
                                        ArrayList<Long> ids = CoursesAPI.getMyCoursesId(fromCache);
                                        LocalStorage.sharedInstance().setIds(ids);
//                                    refreshMyCourse();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                        return;
                                    }
                                }
                                invisibleAllCourses = new ArrayList<CourseModel>();
                                for (CourseModel c : allCourses) {
//                                    if (c.isVisible()) {
                                    invisibleAllCourses.add(c);
//                                    }
                                }
                                visibleAllCourses = new ArrayList<CourseModel>();
                                visibleAllCourses.addAll(allCourses);
                                allCourses.clear();
                                allCourses = null;

                                Type type = new TypeToken<ArrayList<Badge>>() {
                                }.getType();
                                ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildBadgeURL(), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
                                    @Override
                                    public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                                        if (data != null) {
                                            badges.addAll((ArrayList<Badge>) data);
                                            handler.post(new Runnable() {
                                                public void run() {
                                                    if (curCourses != null) {
                                                        curCourses.clear();
                                                    }
                                                    if (invisibleAllCourses.size() <= 4) {
                                                        curCourses.addAll(invisibleAllCourses);
                                                    } else {
                                                        curCourses.addAll(invisibleAllCourses.subList(
                                                                0, 4));
                                                    }
                                                    invisibleAllCourses.removeAll(curCourses);
                                                    handler.sendEmptyMessage(5);
                                                    showData();
                                                    diagamSchedule();
                                                }

                                                ;
                                            });
                                        }
                                    }
                                });
                                if (NetUtil.getNetType(mainActivity) != Constants.NO_NET && fromCache) {
                                    loadData(false);
                                }
                            }
                            if (invisibleAllCourses == null) {
                                handler.sendEmptyMessage(4);
                            }
                        } else {
                            handler.sendEmptyMessage(3);
                            return;
                        }
                    }
                });
            }

            ;
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
            if ((System.currentTimeMillis() - exitTime) > 2000) {
                Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
                exitTime = System.currentTimeMillis();
            } else {
                SharedPreferences appPrefs = ContextUtil.getContext()
                        .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
                SharedPreferences.Editor prefsEditor = appPrefs.edit();
                prefsEditor.putInt("isFirst", 2);
                prefsEditor.commit();
                new ProgressDialogHelper(CourseSquareActivity.this, new Handler())
                        .showProgressDialog("正在退出，请稍后",
                                new ProgressDialogHelper.ProgressCallBack() {
                                    public void action() {
                                        try {
                                            downloadManager.clearCheckState();
                                            downloadManager.stopAllDownload();
                                            downloadManager = null;
                                        } catch (DbException e) {
                                            LogUtils.e(e.getMessage(), e);
                                        }
                                    }
                                });
//				finish();
//				ActivityManager activityMgr = (ActivityManager) this
//						.getSystemService(ACTIVITY_SERVICE);
//				activityMgr.killBackgroundProcesses(getPackageName());
//				System.exit(0);
            }
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 传递信息到浮层
     *
     * @param c
     */
    private void transInfo2Drawer(CourseModel c) {
        Intent mIntent = new Intent(this, OpenCourseActivity.class);
        Bundle mbBundle = new Bundle();
        mbBundle.putSerializable(ContextUtil.CATEGORY_COURSE, c);
        mbBundle.putSerializable("badge", badges);
        mIntent.putExtras(mbBundle);
        startActivity(mIntent);
    }

    /**
     * 初始化轮播图下部小点
     */
    private void initPointView() {

        pointLinear.setBackgroundColor(Color.argb(0, 0, 0, 0));
        pointLinear.removeAllViews();
        for (int i = 0; i < courseInfoList.size(); i++) {
            ImageView pointView = new ImageView(this);
            if (i == 0) {
                pointView.setBackgroundResource(R.drawable.page_point_active);
                pro_title.setText(courseInfoList.get(0).getCourseTitle());
                pro_content.setText(courseInfoList.get(0).getCourseBrief());
            } else
                pointView.setBackgroundResource(R.drawable.page_point_dim);
            pointLinear.addView(pointView);
        }
    }

    @Override
    public void onRefresh() {

    }

    @Override
    public void onLoadMore() {
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                if (invisibleAllCourses.isEmpty()) {
//					handler.sendEmptyMessage(2);
                    lv_all_course.stopLoadMore();
                    lv_all_course.setRefreshText();
                    return;
                }
                List<CourseModel> newCourses = new ArrayList<CourseModel>();
                if (invisibleAllCourses.size() <= 4) {
                    newCourses.addAll(invisibleAllCourses);
                } else {
                    newCourses.addAll(invisibleAllCourses.subList(0, 4));
                }
                invisibleAllCourses.removeAll(newCourses);
                cAdapter.addCourseDate(newCourses);
            }
        }, 2000);
    }

    protected void onLoad() {
        lv_all_course.stopRefresh();
        lv_all_course.stopLoadMore();
        lv_all_course.setRefreshTime("刚刚");
    }

    public void showAllCourse() {
        if (View.VISIBLE == view_loading_fail.getVisibility()) {
            showNoData();
        }
        ll_my_course_container.setVisibility(View.GONE);
        lv_all_course.setVisibility(View.VISIBLE);
        tv_logo_mycourse.setVisibility(View.GONE);
        iv_logo.setVisibility(View.VISIBLE);
        load_edit.setVisibility(View.GONE);
        load_title.setVisibility(View.GONE);
        ll_load_manager_container.setVisibility(View.GONE);
    }

    public void showMyCourse() {
        showData();
        ll_my_course_container.setVisibility(View.VISIBLE);
        lv_all_course.setVisibility(View.GONE);
        tv_logo_mycourse.setVisibility(View.VISIBLE);
        iv_logo.setVisibility(View.GONE);
        load_edit.setVisibility(View.GONE);
        load_title.setVisibility(View.GONE);
        ll_load_manager_container.setVisibility(View.GONE);
        FragmentTransaction mFragementTransaction = fm.beginTransaction();
        if (fm.findFragmentByTag("MyCourse") == null) {
            myCourseFragment = new MyCourseFragment();
            mFragementTransaction.add(R.id.ll_my_course_container,
                    myCourseFragment, "MyCourse");
        } else {
            mFragementTransaction.show(myCourseFragment);
        }
        mFragementTransaction.commit();
    }

    public void showLoadManager() {
        ll_my_course_container.setVisibility(View.GONE);
        showData();
        lv_all_course.setVisibility(View.GONE);
        tv_logo_mycourse.setVisibility(View.GONE);
        iv_logo.setVisibility(View.GONE);
        load_edit.setVisibility(View.VISIBLE);
        load_title.setVisibility(View.VISIBLE);
        ll_load_manager_container.setVisibility(View.VISIBLE);
        FragmentTransaction mFragementTransaction = fm.beginTransaction();
        if (fm.findFragmentByTag("LoadManger") == null) {
            loadMagerFragment = new LoadMangerFragment();
            mFragementTransaction.add(R.id.ll_load_manager_container,
                    loadMagerFragment, "LoadManger");
            if (NetUtil.getNetType(mainActivity) == Constants.NO_NET) {
//                Toast.makeText(mainActivity,"网络已断开,请检查网络",Toast.LENGTH_SHORT).show();
                KKDialog.getInstance().showNoNetToast(this);
                loadMagerFragment.allPause();
            }
        } else {
            mFragementTransaction.show(loadMagerFragment);
            //当再次进入时，下载信息改变，刷新适配器
            loadMagerFragment.showCurrentFragment();
            loadMagerFragment.downloadInfoIsEmpty();
        }
        mFragementTransaction.commit();
    }

    public void goneEditButton() {
        load_edit.setVisibility(View.GONE);
    }

    public List<CourseModel> getAllCourse() {
        return visibleAllCourses;
    }

    public List<Badge> getBadges() {
        return badges;
    }

    public void refreshMyCourse() {
        myCourseFragment.loadMyCourseIds(true);
    }

    public DownloadManager getDownloadManager() {
        return downloadManager;
    }

    public void setDownloadManager(DownloadManager downloadManager) {
        this.downloadManager = downloadManager;
    }

    /**
     * 换行切换任务
     *
     * @author Administrator
     */
    private class ScrollTask implements Runnable {

        public void run() {
            synchronized (viewPager) {
                currentItem = (currentItem + 1) % urls.size();
                handler.obtainMessage().sendToTarget(); // 通过Handler切换图片
            }
        }

    }

    public class PagerListener implements OnClickListener {

        public void onClick(View v) {
            if (courseInfoList == null) {
                return;
            }
            if (visibleAllCourses != null) {
                for (CourseModel c : visibleAllCourses) {
                    if (courseInfoList.get(currentItem).getId().equals(c.getId())) {
                        transInfo2Drawer(c);
                    }
                }
            }
        }
    }

    /**
     * 当ViewPager中页面的状态发生改变时调用
     *
     * @author Administrator
     */
    private class MyPageChangeListener implements OnPageChangeListener {
        private int oldPosition = 0;

        /**
         * This method will be invoked when a new page becomes selected.
         * position: Position index of the new selected page.
         */
        public void onPageSelected(int position) {
            try {
                currentItem = position;
                View view = pointLinear.getChildAt(oldPosition);
                View curView = pointLinear.getChildAt(position);
                ImageView pointView = (ImageView) view;
                ImageView curPointView = (ImageView) curView;
                pointView.setBackgroundResource(R.drawable.page_point_dim);
                curPointView
                        .setBackgroundResource(R.drawable.page_point_active);
                pro_title.setText(courseInfoList.get(currentItem)
                        .getCourseTitle());
                pro_content.setText(courseInfoList.get(currentItem)
                        .getCourseBrief());
                oldPosition = position;
            } catch (NullPointerException e) {
                e.printStackTrace();
            }

        }

        public void onPageScrollStateChanged(int arg0) {

        }

        public void onPageScrolled(int arg0, float arg1, int arg2) {

        }
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {
        @Override
        public void onStart() {
        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
        }

        @Override
        public void onFailure(HttpException error, String msg) {
        }

        @Override
        public void onCancelled() {
        }
    }
}
