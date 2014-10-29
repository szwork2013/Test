package com.kaikeba.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.adapter.UserCenterAdapter;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

/**
 * Created by user on 14-7-22.
 */
public class UserCenterActivity extends BaseActivity {

    private Context mContext;
    private User user;
    private Intent intent;
    private ListView userRight;
    private TextView tv_user_name;
    private ImageView iv_user_head;
    private long exitTime = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.user_center);
        mContext = UserCenterActivity.this;
        initView();
        initData();
    }

    private void initView() {
        intent = new Intent();
        userRight = (ListView) findViewById(R.id.lv_info);
        userRight.setFocusable(false);
        userRight.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (!API.getAPI().alreadySignin()) {
                    intent.setClass(mContext, LoginActivity2.class);
                    startActivity(intent);
                }

                switch (position) {
                    /*case 0:
                        //下载中心
                        intent.setClass(mContext,DownLoadMangerActivity.class);
                        startActivity(intent);
                        break;*/
                    case 0:
                        //我的微专业
                        intent.setClass(mContext, MyMicroActivity.class);
                        intent.putExtra("user", user);
                        startActivity(intent);
                        break;
                    case 1:
                        //我的公开课
                        intent.setClass(mContext, MyOpenCourseActivity.class);
                        intent.putExtra("user", user);
                        startActivity(intent);
                        break;
                    case 2:
                        //我的导学课
                        intent.setClass(mContext, MyGuideCourseActivity.class);
                        intent.putExtra("user", user);
                        startActivity(intent);
                        break;
                    case 3:
                        //收藏的课程
                        intent.setClass(mContext, MyCollectCourseActivity.class);
                        intent.putExtra("user", user);
                        startActivity(intent);
                        break;
                    default:

                        break;
                }
            }
        });
        findViewById(R.id.ll_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                intent.setClass(mContext, SettingActivity.class);
                startActivity(intent);
            }
        });
        tv_user_name = (TextView) findViewById(R.id.tv_user_name);
        iv_user_head = (ImageView) findViewById(R.id.iv_user_head);
        findViewById(R.id.ll_download_center).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                intent.setClass(mContext, DownLoadMangerActivity.class);
                Constants.FROM_WHERE = Constants.FROM_USER_CENTET;
                startActivity(intent);
            }
        });
    }

    private void setListViewHeight(ListView lv) {
        ListAdapter la = lv.getAdapter();
        if (null == la) {
            return;
        }
        // calculate height of all items.
        int h = 0;
        final int cnt = la.getCount();
        for (int i = 0; i < cnt; i++) {
            View item = la.getView(i, null, lv);
            item.measure(0, 0);
            h += item.getMeasuredHeight();
        }
        // reset ListView height
        ViewGroup.LayoutParams lp = lv.getLayoutParams();
        lp.height = h + (lv.getDividerHeight() * (cnt - 1));
        lv.setLayoutParams(lp);
    }

    private void initData() {

        BaseAdapter rightAdapter = new UserCenterAdapter(this);
        userRight.setAdapter(rightAdapter);
        setListViewHeight(userRight);
    }

    @Override
    protected void onResume() {
        super.onResume();
        BitmapUtils bitmapUtils = BitmapHelp.getBitmapUtils(mContext);
        user = API.getAPI().getUserObject();
        if (user == null)
            return;
        if (user.getAvatarUrl() != null) {
//            bitmapUtils.display(iv_user_head, user.getAvatarUrl());
            bitmapUtils.display(iv_user_head, user.getAvatarUrl(),BitmapHelp.getBitMapConfig(UserCenterActivity.this,R.drawable.personal_head_user));
        }
        if (user.getUserName() != null) {
            tv_user_name.setText(user.getUserName());
        }
        MobclickAgent.onPageStart("UserCenter"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("UserCenter");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onBackPressed() {
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            finish();
        }
    }

}
