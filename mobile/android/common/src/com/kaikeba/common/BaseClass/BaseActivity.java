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
public abstract class BaseActivity extends Activity {
    protected SwipeBackLayout layout;
    private BaseActivityImpl baseActivityImpl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        baseActivityImpl = new BaseActivityImpl(BaseActivity.this);
    }

    @Override
    public void startActivity(Intent intent) {
        super.startActivity(intent);
        overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left);
    }



    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        baseActivityImpl.onDestroy(BaseActivity.this);
    }
}
