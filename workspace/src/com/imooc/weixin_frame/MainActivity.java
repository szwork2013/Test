package com.imooc.weixin_frame;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.example.myapp.R;
import com.imooc.weixin_frame.fragment.FragmentOne;
import com.imooc.weixin_frame.fragment.FragmentThree;
import com.imooc.weixin_frame.fragment.FragmentTwo;
import com.xiaoai.badgeview.widget.BadgeView;

import java.util.ArrayList;

/**
 * Created by sjyin on 14-11-3.
 */
public class MainActivity extends FragmentActivity{

    private ViewPager viewPager;
    private TextView tv_chat;
    private TextView tv_find;
    private TextView tv_contact;
    private LinearLayout ll_chat;
    private ArrayList<Fragment> data;
    private FragmentPagerAdapter pagerAdapter;
    private BadgeView badgeView;
    private ImageView iv_separate;

    private String tag = "sjyin";
    private int separateWidth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_weixin);
        viewPager = (ViewPager) findViewById(R.id.view_pager);
        tv_chat = (TextView) findViewById(R.id.tv_chat);
        tv_find = (TextView) findViewById(R.id.tv_find);
        tv_contact = (TextView) findViewById(R.id.tv_contact);
        ll_chat  = (LinearLayout) findViewById(R.id.ll_chat);
        iv_separate = (ImageView) findViewById(R.id.iv_separate);
        data = new ArrayList<Fragment>();

        DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        Log.i(tag,"screen width : " + displayMetrics.widthPixels);
        separateWidth = iv_separate.getLayoutParams().width = (displayMetrics.widthPixels / 3);
        FragmentOne one = new FragmentOne();
        FragmentTwo two = new FragmentTwo();
        FragmentThree three = new FragmentThree();
        data.add(one);
        data.add(two);
        data.add(three);
        pagerAdapter = new FragmentPagerAdapter(getSupportFragmentManager()) {
            @Override
            public Fragment getItem(int i) {
                return data.get(i);
            }

            @Override
            public int getCount() {
                return data.size();
            }
        };
        viewPager.setAdapter(pagerAdapter);
        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffSet, int positionOffSetPx) {
                int marginLeft = (int) (position * separateWidth + positionOffSet * separateWidth);
                Log.i(tag,"margin left: " + marginLeft);
                LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) iv_separate.getLayoutParams();
                layoutParams.leftMargin = marginLeft;
                iv_separate.setLayoutParams(layoutParams);
            }

            @Override
            public void onPageSelected(int position) {
                restTop();
                switch (position){
                    case 0 :
                        tv_chat.setTextColor(Color.parseColor("#008000"));
                        if( badgeView != null){
                            ll_chat.removeView(badgeView);
                        }else{
                            badgeView = new BadgeView(MainActivity.this);
                        }
                        badgeView.setText("7");
                        ll_chat.addView(badgeView);
                        break;
                    case 1:
                        tv_find.setTextColor(Color.parseColor("#008000"));
                        break;
                    case 2:
                        tv_contact.setTextColor(Color.parseColor("#008000"));
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                Log.i(tag,"<-- page scroll state changed i = " + state);
            }
        });

    }

        private void restTop() {
            tv_chat.setTextColor(Color.parseColor("#000000"));
            tv_find.setTextColor(Color.parseColor("#000000"));
            tv_contact.setTextColor(Color.parseColor("#000000"));
        }

}
