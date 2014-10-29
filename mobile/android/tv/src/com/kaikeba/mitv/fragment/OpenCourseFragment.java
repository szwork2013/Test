package com.kaikeba.mitv.fragment;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.widget.MyScrollView;
import com.kaikeba.mitv.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.List;
import java.util.Map;

public class OpenCourseFragment extends Fragment {
    public static BitmapUtils bitmapUtils;
    public MyScrollView mView;
    Context mActivity;
    Map<String, List<Course>> guideInfo;
    private Handler mHandler = new Handler();
    private LinearLayout mContentLL;
    private LinearLayout.LayoutParams LP_FF = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);

    public static OpenCourseFragment newInstance() {
        OpenCourseFragment newFragment = new OpenCourseFragment();
        return newFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mActivity = getActivity();
        mView = (MyScrollView) inflater.inflate(R.layout.fragment_guiding, container, false);
        mView.setVerticalScrollBarEnabled(false);
        mContentLL = (LinearLayout) mView.findViewById(R.id.ll2);
        init();
        return mView;
    }

    public void init() {
        bitmapUtils = BitmapHelp.getBitmapUtils(mActivity.getApplicationContext());
        final Type type = new TypeToken<String>() {
        }.getType();
//        ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildAllCoursesURL(), null, false,type, new ServerDataCache.LoadDataCallbacks() {
//            @Override
//            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                if (errorCode != ServerDataCache.ERROR_OK) return;
//
//                final List<Course> currentAllcourse = CoursesAPI.getAllCourses((String)data);
//
//                ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildCategoryURL(), null, false,type,new ServerDataCache.LoadDataCallbacks() {
//                    @Override
//                    public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                        if (errorCode != ServerDataCache.ERROR_OK) return;
//
//                        ArrayList<String> categories = CoursesAPI.getCourseCategory((String)data);
//
//                        //
//                        guideInfo = CoursesAPI.getOpenAllCourse(currentAllcourse, categories);
//                        boolean isFirstLine = true;
//                        for (Map.Entry<String, List<Course>> entry : guideInfo.entrySet()) {
//                            FragmentHelper.createCoursesView(mActivity, entry.getKey(), entry.getValue(),
//                                    mContentLL, isFirstLine ? R.id.tv_tab_open: -1);
//                            isFirstLine = false;
//                        }
//                    }
//                });
//
//            }
//        });
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("OpenCourse"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("OpenCourse");
    }
}
