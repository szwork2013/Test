package com.kaikeba.mitv.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import com.kaikeba.common.widget.MyScrollView;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

public class MyCourseFragment extends Fragment {
    public static BitmapUtils bitmapUtils;
    public MyScrollView mView;
    Context mActivity;
    private LinearLayout mContentLL;
    private LinearLayout.LayoutParams LP_FF = new LinearLayout.LayoutParams(
            LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);

    public static MyCourseFragment newInstance() {
        MyCourseFragment newFragment = new MyCourseFragment();
        return newFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mActivity = getActivity();
        mView = (MyScrollView) inflater.inflate(R.layout.fragment_guiding, container, false);
        mView.setVerticalScrollBarEnabled(false);
//        mView.setNextFocusUpId(R.id.tv_tab_my);
        mView.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                MainActivity.setHorizonEdge(true, true);
            }
        });
        mContentLL = (LinearLayout) mView.findViewById(R.id.ll2);
        init();
        return mView;
    }


    public void init() {
//		bitmapUtils = BitmapHelp.getBitmapUtils(mActivity
//                .getApplicationContext());
//		if (!StaticDate.guideCourseList.isEmpty()) {
//            FragmentHelper.createCoursesView(mActivity, "最近学习的导学课", StaticDate.guideCourseList,
//                    mContentLL, R.id.tv_tab_my);
//		}
//		if (!StaticDate.openCourseList.isEmpty()) {
//            FragmentHelper.createCoursesView(mActivity, "最近学习的公开课", StaticDate.openCourseList,
//                    mContentLL, StaticDate.guideCourseList.isEmpty() ? R.id.tv_tab_my : -1);
//		}
    }

    public void refreshView() {
        if (mContentLL != null) {
            mContentLL.removeAllViews();
            init();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("MyCourse"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MyCourse");
    }

}
