package com.kaikeba.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.adapter.LeadViewAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by cwang on 14-7-9.
 */
public class LeadViewActivity extends BaseActivity implements View.OnClickListener, ViewPager.OnPageChangeListener {


    public static final int[] pics = {R.drawable.lead_1, R.drawable.lead_2,
            R.drawable.lead_3, R.drawable.lead_4};
    private ViewPager viewPager;
    private LeadViewAdapter adapter;
    private List<View> views;
    //底部小点
    private ImageView[] dots;
    //记住当前位置
    private int current;
    private TextView go_to_play;
    private ImageView go_go;
    private SharedPreferences appPrefs;

    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);//全屏
        setContentView(R.layout.activity_lead_view);
        //判断用户是否第一次登陆kkb，
        appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        views = new ArrayList<View>();
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        go_to_play = (TextView) findViewById(R.id.go_to_play);
        go_go = (ImageView) findViewById(R.id.go_go);
//        params.setMargins(0, 200, 20, 20);
        for (int i = 0; i < pics.length; i++) {
            ImageView iv = new ImageView(this);
            //设置随机显示位置
            iv.setLayoutParams(params);
            iv.setImageResource(pics[i]);
            views.add(iv);
        }

        viewPager = (ViewPager) findViewById(R.id.view_pager);
        Log.i("life", "" + viewPager);
        adapter = new LeadViewAdapter(views);
        viewPager.setAdapter(adapter);
        //绑定回调
        viewPager.setOnPageChangeListener(this);
        init();

    }

    private void init() {
        go_to_play.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(LeadViewActivity.this, AllCourseActivity.class);
                startActivity(intent);
                SharedPreferences.Editor editor = appPrefs.edit();
                editor.putBoolean(ContextUtil.isFirstLead, false);
                editor.commit();
            }
        });
        go_go.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(LeadViewActivity.this, AllCourseActivity.class);
                startActivity(intent);
                SharedPreferences.Editor editor = appPrefs.edit();
                editor.putBoolean(ContextUtil.isFirstLead, false);
                editor.commit();
            }
        });
        LinearLayout ll = (LinearLayout) findViewById(R.id.ll);
        dots = new ImageView[pics.length];
        for (int i = 0; i < pics.length; i++) {
            dots[i] = (ImageView) ll.getChildAt(i);//索引
            dots[i].setEnabled(true);  //都设置灰色
            dots[i].setOnClickListener(this);
            dots[i].setTag(i); //设置标签
        }
        current = 0;
        dots[current].setEnabled(false);//设置白色，选中状态
        go_to_play.setVisibility(View.VISIBLE);
        go_go.setVisibility(View.GONE);

    }

    //设置当前的引导页
    private void setViews(int position) {
        if (position < 0 || position >= pics.length) {
            return;
        }
        viewPager.setCurrentItem(position);
    }

    //设置当前小点
    private void setDots(int position) {
        if (position < 0 || position > pics.length - 1 || current == position) {
            return;
        }
        dots[position].setEnabled(false);
        dots[current].setEnabled(true);
        current = position;
    }

    //当页面滑动状态改变调用
    @Override
    public void onPageScrollStateChanged(int arg0) {

    }

    //当页面滑动的时候调用
    @Override
    public void onPageScrolled(int arg0, float arg1, int arg2) {
        if (arg0 < 3) {
            go_to_play.setVisibility(View.VISIBLE);
            go_go.setVisibility(View.GONE);
        } else {
            go_to_play.setVisibility(View.GONE);
            go_go.setVisibility(View.VISIBLE);
        }
    }

    //当页面选中的时候调用
    @Override
    public void onPageSelected(int arg0) {
        setDots(arg0);
    }

    @Override
    public void onClick(View v) {
        int position = (Integer) v.getTag();
        setViews(position);
        setDots(position);
    }
}
