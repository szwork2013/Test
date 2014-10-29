package com.kaikeba.activity;

import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TabHost;
import com.kaikeba.common.BaseClass.BaseTabActivity;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.NetBroadcastReceiver;
import com.kaikeba.phone.R;
import com.umeng.update.UmengUpdateAgent;

/**
 * Created by chris on 14-7-16.
 */
public class TabCourseActivity extends BaseTabActivity {

    private static LinearLayout ll_tab_bottom;
    private static TabCourseActivity tabCourseActivity;
    private static int tab_height;
    String tabTag;
    int tabNum;
    /**
     * *
     * 单击监听
     */
    View.OnClickListener onClickListener = new View.OnClickListener() {

        public void onClick(View v) {
            int id = v.getId();
            if (id == R.id.tab_item_1) {
                tabhost.setCurrentTabByTag("Dynamic");
            } else if (id == R.id.tab_item_2) {
                tabhost.setCurrentTabByTag("Category");
            } else if (id == R.id.tab_item_3) {
                tabhost.setCurrentTabByTag("CourseHome");
            } else if (id == R.id.tab_item_4) {
                tabhost.setCurrentTabByTag("UserCenter");
            }
        }
    };
    /**
     * 选项卡对象
     */
    private TabHost tabhost;
    /**
     * 选项卡按钮
     */
    private RadioButton radioButton[] = new RadioButton[4];
    /**
     * 选项卡按钮ID数组 *
     */
    private int radioButtonId[] = {R.id.tab_item_1, R.id.tab_item_2,
            R.id.tab_item_3, R.id.tab_item_4};
    private NetBroadcastReceiver mNetBroadcastReceiver;

    public static TabCourseActivity getTabCourseActivity() {
        return tabCourseActivity;
    }

    public static int getTabHeight4Dynamic() {
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        ll_tab_bottom.measure(w, h);
        int height = ll_tab_bottom.getMeasuredHeight();
        return height;
    }

    public static int getTabHeight4Find() {
        ViewTreeObserver vto2 = TabCourseActivity.getTabView().getViewTreeObserver();
        vto2.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                ll_tab_bottom.getViewTreeObserver().removeGlobalOnLayoutListener(this);
                tab_height = ll_tab_bottom.getHeight();
            }
        });
        return tab_height;
    }

    public static View getTabView() {

        return ll_tab_bottom;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab_course_layout);
        ll_tab_bottom = (LinearLayout) findViewById(R.id.ll_tab_bottom);
        tabCourseActivity = this;
        //注册网络监听
        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mNetBroadcastReceiver = NetBroadcastReceiver.getInstance();
        registerReceiver(mNetBroadcastReceiver, filter);
        //自动更新
        UmengUpdateAgent.update(this);
    }
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
    }
    @Override
    protected void onResume() {
        super.onResume();
        getFromWhereTo();
        tabhostInit(tabTag, tabNum);
    }

    public void getFromWhereTo() {
        Intent intent = getIntent();
        tabTag = intent.getStringExtra("TabTag");
        tabNum = intent.getIntExtra("TabNum", 0);
    }

    /**
     * 选项卡的初始化
     */
    public void tabhostInit(String tabTag, int tabNum) {
        tabhost = this.getTabHost();
        tabhost.addTab(tabhost.newTabSpec("Dynamic").setIndicator("11")
                .setContent(new Intent(this, DynamicActivity.class)));
        tabhost.addTab(tabhost.newTabSpec("Category").setIndicator("22")
                .setContent(new Intent(this, CategoryActivity.class)));
        tabhost.addTab(tabhost.newTabSpec("CourseHome").setIndicator("33")
                .setContent(new Intent(this, CourseHomeActivity.class)));// FirstActivity
        tabhost.addTab(tabhost.newTabSpec("UserCenter").setIndicator("44")
                .setContent(new Intent(this, UserCenterActivity.class)));
        for (int i = 0; i < radioButton.length; i++) {
            radioButton[i] = (RadioButton) this.findViewById(radioButtonId[i]);
            radioButton[i].setOnClickListener(onClickListener);
        }
        if (tabTag != null) {
            tabhost.setCurrentTabByTag(tabTag);
            radioButton[tabNum].setChecked(true);
        } else {
            tabhost.setCurrentTabByTag("Dynamic");
            radioButton[0].setChecked(true);
        }
        // ---------------------------------------------
    }



    @Override
    protected void onPause() {
        super.onPause();
        if (Constants.search_is_click) {
            overridePendingTransition(0, 0);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
    }
}
