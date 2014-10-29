package com.kaikeba.activity;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.StrictMode;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.widget.Toast;
import com.kaikeba.activity.fragment.*;
import com.kaikeba.common.base.BaseSlidingFragmentActivity;
import com.kaikeba.common.base.SlidingMenu;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.download.DownloadService;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.NetBroadcastReceiver;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.common.util.ProgressDialogHelper;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends BaseSlidingFragmentActivity {


    private static MainActivity mainActivity;
    public SlidingMenu mSlidingMenu;
    NetBroadcastReceiver mNetBroadcastReceiver;
    private FragmentManager fm;
    /**
     * 导航Fragment
     */
    private MainNavFragment mainNavFragment;
    /**
     * 全部课程Fragment
     */
    private AllCoursesFragment allCoursesFragment;
    private SettingFragment settingFragment;
    private MyCourseContentFragment courseContentFragment;
    private ActivityStreamFragment asFragment;
    private DownLoadManagerFragment downloadFragment;
    private DownloadManager downloadManager;
    private ArrayList<Long> ids;
    private long exitTime = 0;

    public static MainActivity getMainActivity() {
        return mainActivity;
    }

    public ArrayList<Long> getIds() {
        return ids;
    }

    public void setIds(ArrayList<Long> ids) {
        this.ids = ids;
    }

    private final void initStrictMode() {
        String strVer = android.os.Build.VERSION.RELEASE;
        strVer = strVer.substring(0, 3).trim();
        float fv = Float.valueOf(strVer);
        if (fv > 2.3) {
            StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
                    .detectDiskReads().detectDiskWrites().detectNetwork() // 这里可以替换为detectAll()
                            // 就包括了磁盘读写和网络I/O
                    .penaltyLog() // 打印logcat，当然也可以定位到dropbox，通过文件保存相应的log
                    .build());
            StrictMode.setVmPolicy(new StrictMode.VmPolicy.Builder()
                    .detectLeakedSqlLiteObjects() // 探测SQLite数据库操作
                    .penaltyLog() // 打印logcat
                    .penaltyDeath().build());
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        initStrictMode();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        fm = getFragmentManager();
        initSlidingMenu();
        initBroadcast();
        mainActivity = this;


        UmengUpdateAgent.update(this);
        initLayout();
        downloadManager = DownloadService.getDownloadManager(mainActivity.getApplicationContext());
//		MyApplication.getInstance().addActivity(this);
        if (NetUtil.getNetType(this) != Constants.NO_NET) {
            //全部开始下载
            try {
                downloadManager.resumeDownloadAll(new DownloadRequestCallBack());
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
        }
    }

    /**
     * 初始化SlidingMenu
     */
    private void initSlidingMenu() {
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        int mScreenWidth = dm.widthPixels;
        System.out.println("当前的屏幕：width*height = " + dm.widthPixels + "*" + dm.heightPixels);
        setBehindContentView(R.layout.main_left_layout);
        mSlidingMenu = getSlidingMenu();
        mSlidingMenu.setMode(SlidingMenu.LEFT);
        mSlidingMenu.setShadowWidth(mScreenWidth / 40);
        mSlidingMenu.setBehindOffset(mScreenWidth - 180);
        mSlidingMenu.setFadeDegree(0.35f);
        mSlidingMenu.setBehindWidth(180);
        mSlidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_FULLSCREEN);
        mSlidingMenu.setFadeEnabled(true);
        mSlidingMenu.setBehindScrollScale(0.333f);
//		mSlidingMenu.showContent();
    }

    private void initBroadcast() {
        //注册网络监听
        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mNetBroadcastReceiver = NetBroadcastReceiver.getInstance();
        registerReceiver(mNetBroadcastReceiver, filter);
    }

    /**
     * 初始化界面布局
     */
    private final void initLayout() {

//		mSlidingMenu.setContent(R.layout.main_nav);
        FragmentTransaction mFragementTransaction = getFragmentManager().beginTransaction();
        mainNavFragment = new MainNavFragment();
        allCoursesFragment = new AllCoursesFragment();
        settingFragment = new SettingFragment();
        mFragementTransaction.replace(R.id.allcourse_container, allCoursesFragment);
        mFragementTransaction.replace(R.id.main_left_fragment, mainNavFragment);
        mFragementTransaction.replace(R.id.setting_container, settingFragment);
        mFragementTransaction.commit();
    }

    /**
     * 加载我的全部课程
     */
    public void loadAllMyCourse() {
        String tag = getResources().getString(R.string.tag_mycourse);
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        if (courseContentFragment == null) {
            courseContentFragment = new MyCourseContentFragment();
            ft.replace(R.id.mycourse_container, courseContentFragment, tag);
        } else {
            if (null == fm.findFragmentByTag(tag)) {
                ft.replace(R.id.mycourse_container, courseContentFragment, tag);
            }
        }
        ft.commitAllowingStateLoss();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    @Override
    protected void onStop() {
        // TODO Auto-generated method stub
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
            if ((System.currentTimeMillis() - exitTime) > 2000) {
                Toast.makeText(mainActivity, "再按一次退出程序", Toast.LENGTH_SHORT)
                        .show();
                exitTime = System.currentTimeMillis();
            } else {
                if (mNetBroadcastReceiver != null) {
                    unregisterReceiver(mNetBroadcastReceiver);
                    mNetBroadcastReceiver = null;
                }
                new ProgressDialogHelper(MainActivity.this, new Handler())
                        .showProgressDialog("正在退出，请稍后",
                                new ProgressDialogHelper.ProgressCallBack() {
                                    public void action() {
                                        try {
                                            downloadManager.stopAllDownload();
                                            downloadManager = null;
                                        } catch (DbException e) {
                                            LogUtils.e(e.getMessage(), e);
                                        }
//							new Handler().post(new Runnable(){
//								@Override
//								public void run() {
//									// TODO Auto-generated method stub
//									ActivityManager activityMgr = (ActivityManager) mainActivity.getSystemService(ACTIVITY_SERVICE);
//									activityMgr.killBackgroundProcesses(getPackageName());
////									finish();
//								}
//							});
                                    }
                                });
            }
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    public MainNavFragment getMainNavFragment() {
        return mainNavFragment;
    }

    public AllCoursesFragment getAllCoursesFragment() {
        return allCoursesFragment;
    }

    public SettingFragment getSettingFragment() {
        return settingFragment;
    }

    public MyCourseContentFragment getMyAllCourseFragment() {
        return courseContentFragment;
    }

    public void goMyCourse() {
        getMainNavFragment().goMyAllcourse();
    }

    public void showDownload() {
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        if (downloadFragment == null) {
            downloadFragment = new DownLoadManagerFragment();
            ft.add(R.id.download_content_container, downloadFragment, "download");
        } else {
            if (fm.findFragmentByTag("download") == null) {
                ft.add(R.id.download_content_container, downloadFragment, "download");
            }
        }
        ft.commitAllowingStateLoss();
    }

    public void showActivityStream() {
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        if (asFragment == null) {
            asFragment = new ActivityStreamFragment();
            ft.add(R.id.activity_content_container, asFragment, "activity");
        } else {
            if (fm.findFragmentByTag("activity") == null) {
                ft.add(R.id.activity_content_container, asFragment, "activity");
            }
        }
        ft.commitAllowingStateLoss();
    }

    public Course getCourse(Long courseId) {
        List<Course> courses = allCoursesFragment.getAllCourse();
        if (courses != null)
            for (Course c : courses) {
                if (c.getId().equals(courseId)) {
                    return c;
                }
            }
        return null;
    }

    public void removeActivityStream() {
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        if (fm.findFragmentByTag("activity") != null) {
            ft.remove(asFragment);
        }
        ft.commitAllowingStateLoss();
    }

    public void removeDownload() {
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        if (fm.findFragmentByTag("download") != null) {
            ft.remove(downloadFragment);
        }
        ft.commitAllowingStateLoss();
    }

    public void hideActiveView() {
        mainNavFragment.hideActiveView();
    }

    public void showActiveView() {
        mainNavFragment.showActiveView();
    }

    public void signOutHideView() {
        mainNavFragment.signOutHideView();
    }

    public DownloadManager getDownloadManager() {
        return downloadManager;
    }

    public void setDownloadManager(DownloadManager downloadManager) {
        this.downloadManager = downloadManager;
    }

    public DownLoadManagerFragment getDownloadManagerFragment() {
        return downloadFragment;
    }

    public SlidingMenu getMslidingMenu() {
        return mSlidingMenu;
    }

    public List<Course> getAllCourse() {
        return allCoursesFragment.getAllCourse();
    }

    public void refreshView() {
        courseContentFragment.refreshView();
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
