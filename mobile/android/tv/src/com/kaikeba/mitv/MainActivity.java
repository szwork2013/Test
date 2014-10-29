package com.kaikeba.mitv;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.common.entity.StaticDate;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.MyViewPager;
import com.kaikeba.mitv.adapter.MyFragmentPagerAdapter;
import com.kaikeba.mitv.fragment.FavorFragment;
import com.kaikeba.mitv.fragment.HistoryFragment;
import com.kaikeba.mitv.fragment.MainTabFragment;
import com.kaikeba.mitv.fragment.MoreFragment;
import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;

import java.util.ArrayList;

//import com.kaikeba.common.network.ServerDataCache;

public class MainActivity extends FragmentActivity {

    public static boolean isHorizonEdgeLeft = true;
    public static boolean isHorizonEdgeRight = false;
    public static boolean isVerticalBelow = false;
    private static MainActivity mainActivity;
    /**
     * 加载页面的ViewPager
     */
    public MyViewPager mPager;
    /**
     * 最近学习Fragment
     */
//    private MyCourseFragment myCourseFragment;


    FavorFragment favorFragment;
    HistoryFragment historyFragment;

    /**
     * 导学Fragment
     */
//    private GuideCourseFragment mGuideCourseFragment;

    /**
     * 公开Fragment
     */
//    private OpenCourseFragment mOpenCourseFragment;
    /**
     * 页面FragmentList
     */
    private ArrayList<Fragment> fragmentsList;
    /**
     * Tab Button
     */
    private Button tvTabMain, tvTabFavor, tvTabHistory, tvTabMore;
    /**
     * 页面初始化之前是否可点击
     */
    private boolean isCanClick = false;
    /**
     * 当前页面索引
     */
    private int mCurrentFragmentIndex = 0;
    /**
     * 当前行
     */
    private int mCurrentLine = 0;
    /**
     * 首页Fragment
     */
    private MainTabFragment mainTabFragment;
    /**
     * 更多Fragment
     */
    private MoreFragment moreFragment;
    private TextView[] btns = new TextView[4];
    /**
     * 当前获得焦点的ImageButton
     */
    private View imgButton;
    private Button buttonLostFocus;
    private View.OnFocusChangeListener mButtonOnFocusChangeListener;
    private long exitTime = 0;

    public static void setHorizonEdge(boolean left, boolean right) {
        isHorizonEdgeLeft = left;
        isHorizonEdgeRight = right;
    }

    public static void setVerticalEdge(boolean below) {
        isVerticalBelow = below;
    }

    public static MainActivity getMainActivity() {
        return mainActivity;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.main);
        mainActivity = this;
        UmengUpdateAgent.setUpdateOnlyWifi(false);
        UmengUpdateAgent.update(this);
        // 加载最近学习
//        new Thread(){
//        	@SuppressWarnings("unchecked")
//			public void run() {
//        		try {
//                	List<Course> openCourseList = (List<Course>)ObjectSerializableUtil.readObject("OpenCourseList");
//                	StaticDate.setOpenCourseList(openCourseList);
//                	List<Course> guideCourseList = (List<Course>)ObjectSerializableUtil.readObject( "GuideCourseList");
//                	StaticDate.setGuideCourseList(guideCourseList);
//                	ObjectSerializableUtil.readObject("GuideCourseList");
//                	ObjectSerializableUtil.readObject( "OpenCourseList");
//                }
//                catch (Exception e) {
//                	e.printStackTrace();
//                }
//        	};
//        }.start();
        initTextView();
        initViewPager();
        getScreenInfo();
        if (!NetworkUtil.isNetworkAvailable(MainActivity.this)) {
            Toast.makeText(MainActivity.this, "网络未连接", Toast.LENGTH_LONG).show();
        }

    }

    private void getScreenInfo() {
        int screenWidth = getWindowManager().getDefaultDisplay().getWidth();       // 屏幕宽（像素，如：480px）
        int screenHeight = getWindowManager().getDefaultDisplay().getHeight();      // 屏幕高（像素，如：800p）

        Log.e("  getDefaultDisplay", "screenWidth=" + screenWidth + "; screenHeight=" + screenHeight);

        DisplayMetrics dm = new DisplayMetrics();
        dm = getResources().getDisplayMetrics();

        float density = dm.density;        // 屏幕密度（像素比例：0.75/1.0/1.5/2.0）
        int densityDPI = dm.densityDpi;     // 屏幕密度（每寸像素：120/160/240/320）
        float xdpi = dm.xdpi;
        float ydpi = dm.ydpi;

        // 获取屏幕密度（方法3）
        dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);

        density = dm.density;      // 屏幕密度（像素比例：0.75/1.0/1.5/2.0）
        densityDPI = dm.densityDpi;     // 屏幕密度（每寸像素：120/160/240/320）
        xdpi = dm.xdpi;
        ydpi = dm.ydpi;

        Log.e("  DisplayMetrics", "xdpi=" + xdpi + "; ydpi=" + ydpi);
        Log.e("  DisplayMetrics", "density=" + density + "; densityDPI=" + densityDPI);
        Log.e("  DisplayMetrics", "scaledDensity=" + dm.scaledDensity);

        int screenWidthDip = dm.widthPixels;        // 屏幕宽（dip，如：320dip）
        int screenHeightDip = dm.heightPixels;      // 屏幕宽（dip，如：533dip）

        Log.e("  DisplayMetrics(222)", "screenWidthDip=" + screenWidthDip + "; screenHeightDip=" + screenHeightDip);

        screenWidth = (int) (dm.widthPixels * density + 0.5f);      // 屏幕宽（px，如：480px）
        screenHeight = (int) (dm.heightPixels * density + 0.5f);     // 屏幕高（px，如：800px）

        Log.e("  DisplayMetrics(222)", "screenWidth=" + screenWidth + "; screenHeight=" + screenHeight);
    }

    private void initTextView() {
        tvTabMain = (Button) findViewById(R.id.tv_tab_main);
        tvTabFavor = (Button) findViewById(R.id.tv_tab_favor);
        tvTabHistory = (Button) findViewById(R.id.tv_tab_history);
        tvTabMore = (Button) findViewById(R.id.tv_tab_more);
        tvTabMain.setNextFocusDownId(R.id.category_title_txt);
        btns[0] = tvTabMain;
        btns[1] = tvTabFavor;
        btns[2] = tvTabHistory;
        btns[3] = tvTabMore;

        mButtonOnFocusChangeListener = new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                BitmapHelp.getBitmapUtils(MainActivity.this).clearMemoryCache();
                System.gc();

                Button btn = (Button) v;

                resetTabsUI();
                if (hasFocus) {
                    if (!NetworkUtil.isNetworkAvailable(MainActivity.this)) {
                        Toast.makeText(MainActivity.this, "网络未连接", Toast.LENGTH_LONG).show();
                    }

                    btn.setTextColor(getResources().getColor(R.color.color_bai));
                    btn.setBackgroundResource(R.drawable.focus);

                    switch (btn.getId()) {
                        case R.id.tv_tab_main:
                            if (mPager.getCurrentItem() != 0) {
                                if (mainTabFragment.scrollView.getVisibility() == View.VISIBLE) {
                                    mainTabFragment.setBottomView();
                                } else {
                                    mainTabFragment.showSelectedCategory();
                                }
                            }
                            mPager.setCurrentItem(0);
                            setHorizonEdge(true, false);
                            break;
                        case R.id.tv_tab_favor:
                            if (mPager.getCurrentItem() != 1) {
                                favorFragment.initData();
                            }
                            mPager.setCurrentItem(1);
                            setHorizonEdge(false, false);
                            break;
                        case R.id.tv_tab_history:
                            if (mPager.getCurrentItem() != 2) {
                                historyFragment.initData();
                            }
                            mPager.setCurrentItem(2);
                            setHorizonEdge(false, false);
                            break;
                        case R.id.tv_tab_more:
                            mPager.setCurrentItem(3);
                            setHorizonEdge(false, true);
                            break;
                        default:
                            break;
                    }

                    buttonLostFocus = btn;
                } else {
//                    btns[mPager.getCurrentItem()].setBackgroundResource(R.drawable.focus);
//                    btns[mPager.getCurrentItem()].setTextColor(getResources().getColor(R.color.course_card_title_color));


                    buttonLostFocus.setBackgroundResource(getResources().getColor(R.color.transparent));
                    buttonLostFocus.setTextColor(getResources().getColor(R.color.color_lan));
                }
            }
        };
        for (int i = 0; i < btns.length; i++) {
            btns[i].setOnFocusChangeListener(mButtonOnFocusChangeListener);
        }
//    	tvTabMain.requestFocus();
        tvTabMain.clearFocus();
    }

    public void refreshView() {

    }

    private void initViewPager() {
        mPager = (MyViewPager) findViewById(R.id.vPager_content);

        fragmentsList = new ArrayList<Fragment>();

        favorFragment = FavorFragment.newInstance();
        historyFragment = HistoryFragment.newInstance();
        moreFragment = MoreFragment.newInstance();
        mainTabFragment = MainTabFragment.newInstance();

        fragmentsList.add(mainTabFragment);
        fragmentsList.add(favorFragment);
        fragmentsList.add(historyFragment);
        fragmentsList.add(moreFragment);


        mPager.setAdapter(new MyFragmentPagerAdapter(getSupportFragmentManager(), fragmentsList));
        mPager.setOffscreenPageLimit(3);
        mPager.setFocusable(false);
        mPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int i, float v, int i2) {

            }

            @Override
            public void onPageSelected(int i) {

                if (!btns[i].isFocused()) {
                    resetTabsUI();
                    btns[i].setBackgroundResource(R.color.transparent);
                    btns[i].setTextColor(getResources().getColor(R.color.color_lan));
                }
            }

            @Override
            public void onPageScrollStateChanged(int i) {

            }
        });
        mPager.setCurrentItem(0);
        isCanClick = true;
    }

    public MyViewPager getViewPager() {
        return mPager;
    }

    private void resetTabsUI() {
        tvTabMain.setBackgroundColor(0x00ffffff);
        tvTabFavor.setBackgroundColor(0x00ffffff);
        tvTabHistory.setBackgroundColor(0x00ffffff);
        tvTabMore.setBackgroundColor(0x00ffffff);

        tvTabMain.setTextColor(getResources().getColor(R.color.tab_normal));
        tvTabFavor.setTextColor(getResources().getColor(R.color.tab_normal));
        tvTabHistory.setTextColor(getResources().getColor(R.color.tab_normal));
        tvTabMore.setTextColor(getResources().getColor(R.color.tab_normal));
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        Log.v("MainActivity", "KeyEvent " + event.getAction() + " " + event.getKeyCode());
        if (!isCanClick) {
            return true;
        }

        if (event.getAction() == KeyEvent.ACTION_UP) {
            return true;
        } else if (event.getAction() == KeyEvent.ACTION_DOWN) {
            int keyCode = event.getKeyCode();
            switch (keyCode) {
                case KeyEvent.KEYCODE_DPAD_LEFT:
                    if (isHorizonEdgeLeft) {
                        return true;
                    }
                    if (mainTabFragment.galleryIndex == 0) {
                        mainTabFragment.categoryTitle.requestFocus();
                    }
                    break;
                case KeyEvent.KEYCODE_DPAD_RIGHT:
                    if (isHorizonEdgeRight) {
                        return true;
                    }
                    break;
                case KeyEvent.KEYCODE_DPAD_DOWN:
                    if (isVerticalBelow) {
                        return true;
                    }
                    break;
                default:
                    break;
            }
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    Log.v("MainActivity", "KeyEvent getCurrentFocus=" + getCurrentFocus());
                }
            }, 1000);
            return super.dispatchKeyEvent(event);
        }
        return false;
    }

    public void updateTabBackground() {
        resetTabsUI();
        btns[mPager.getCurrentItem()].setBackgroundResource(R.drawable.main_title_selected);
        btns[mPager.getCurrentItem()].requestFocus();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        MemoryUtil.isLowMemory();
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
            if (!btns[mPager.getCurrentItem()].isFocused()) {
                try {
                    switch (mPager.getCurrentItem()) {
                        case 0:
//                            ((MyScrollView)mainTabFragment.mView.findViewById(R.id.tab_main_scrollview)).fullScroll(ScrollView.FOCUS_UP);
                            break;
                        case 1:
//                            favorFragment.mView.fullScroll(ScrollView.FOCUS_UP);
                            break;
                        case 2:
//                            historyFragment.mView.fullScroll(ScrollView.FOCUS_UP);
                            break;
//                        case 3:
//                            myCourseFragment.mView.fullScroll(ScrollView.FOCUS_UP);
//                            break;
                        default:
                            break;
                    }
                    btns[mPager.getCurrentItem()].requestFocus();

                    if (moreFragment.getPreviousSelectedButton() != null) {
                        moreFragment.getPreviousSelectedButton().setTextColor(getResources().getColor(R.color.tab_color_focused));
                    }

                } catch (NullPointerException e) {
                    e.printStackTrace();
                    Log.e("kaikeba", e.getMessage());
                }
            } else {
                showExitPopup();
            }
            return true;
        }

        if (keyCode == KeyEvent.KEYCODE_DPAD_UP && event.getAction() == KeyEvent.ACTION_DOWN) {

            if (moreFragment.getPreviousSelectedButton() != null && moreFragment.getPreviousSelectedButton() == moreFragment.btn1) {

                btns[mPager.getCurrentItem()].requestFocus();

                moreFragment.getPreviousSelectedButton().setTextColor(getResources().getColor(R.color.tab_color_focused));
                moreFragment.getPreviousSelectedButton().setBackgroundDrawable(null);

                return true;
            }
        }

        return super.onKeyDown(keyCode, event);
    }

    private Button exit_ok;
    private Button exit_cancel;
    protected void showExitPopup() {
        View view = getLayoutInflater().inflate(R.layout.exit_app, null);
        exit_ok = (Button) view.findViewById(R.id.exit_ok);
        exit_ok.requestFocus();
        exit_cancel = (Button) view.findViewById(R.id.exit_cancel);

        final Dialog dialog = new Dialog(MainActivity.this,R.style.dialog);

        dialog.setContentView(view);

        dialog.show();

        exit_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    ObjectSerializableUtil.writeObject(StaticDate.openCourseList, "OpenCourseList");
                    ObjectSerializableUtil.writeObject(StaticDate.guideCourseList, "GuideCourseList");
                } catch (Exception e) {
                    e.printStackTrace();
                }
//                ServerDataCache.getInstance().saveCache();
                finish();
                System.exit(0);
            }
        });
        exit_ok.setNextFocusRightId(R.id.exit_cancel);
        exit_cancel.setNextFocusLeftId(R.id.exit_ok);
        exit_ok.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if(hasFocus){
                    exit_ok.setTextColor(0xff4686b3);
                    exit_cancel.setTextColor(0xff717171);
                }else {
                    exit_ok.setTextColor(0xff717171);
                    exit_cancel.setTextColor(0xff4686b3);
                }
            }
        });

        exit_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        exit_cancel.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if(hasFocus){
                    exit_cancel.setTextColor(0xff4686b3);
                    exit_ok.setTextColor(0xff717171);
                }else {
                    exit_cancel.setTextColor(0xff717171);
                    exit_ok.setTextColor(0xff4686b3);
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }
}
