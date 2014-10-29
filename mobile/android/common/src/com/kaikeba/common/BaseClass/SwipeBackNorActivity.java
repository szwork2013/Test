package com.kaikeba.common.BaseClass;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.kaikeba.common.R;
import com.kaikeba.common.widget.SwipeBackLayout;

/**
 * Created by cwang on 14-7-30.
 */

/**
 * 想要实现向右滑动删除Activity效果只需要继承SwipeBackActivity即可，如果当前页面含有ViewPager
 * 只需要调用SwipeBackLayout的setViewPager()方法即可
 *
 * @author
 */
public abstract class SwipeBackNorActivity extends Activity {
    protected SwipeBackLayout layout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 设置无标题栏
//        requestWindowFeature(Window.FEATURE_NO_TITLE);
//        // 设置竖屏
//        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
//        layout = (SwipeBackLayout) LayoutInflater.from(this).inflate(
//                R.layout.swipeback_base, null);
//        layout.attachToActivity(this);
    }

    @Override
    public void startActivity(Intent intent) {
        super.startActivity(intent);
        overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    }

    // Press the back button in mobile phone
//    @Override
//    public void onBackPressed() {
//        super.onBackPressed();
//        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
//    }


    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
    }
}
