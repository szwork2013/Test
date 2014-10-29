package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.PagesAPI;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

/**
 * 课程介绍Activity
 *
 * @author Allen
 */
@SuppressLint("SetJavaScriptEnabled")
public class CourseIntroduceFragment extends Fragment {

    private String msgStr;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    view_loading.setVisibility(View.GONE);
                    if (msgStr != null) {
//                    Toast.makeText(getActivity(), msgStr, Toast.LENGTH_SHORT).show();
                        view_loading_fail.setVisibility(View.VISIBLE);
                    }
                    break;
                default:
                    break;
            }
        }

        ;
    };
    private WebView course_intro;
    private String courseId;
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private Page page;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub

        View v = inflater.inflate(R.layout.course_intro, container, false);
        view_loading = (RelativeLayout) v.findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) v.findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) v.findViewById(R.id.loading_fail);
        course_intro = (WebView) v.findViewById(R.id.wv_course_intro);
        // 设置可以使用本地缓存
        course_intro.getSettings().setDomStorageEnabled(true);
        // 设置可以有数据库
        course_intro.getSettings().setDatabaseEnabled(true);
        String htmlDb = getActivity().getApplicationContext()
                .getDir("database", Context.MODE_PRIVATE).getPath();
        course_intro.getSettings().setDatabasePath(htmlDb);
        // 设置可以有缓存
        course_intro.getSettings().setAppCacheEnabled(true);
        String appCache = getActivity().getApplicationContext().getDir("cache", Context.MODE_PRIVATE).getPath();
        course_intro.getSettings().setAppCachePath(appCache);
        if (Constants.NO_NET != NetUtil.getNetType(getActivity())) {
            course_intro.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
        } else {
            course_intro.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        }
        course_intro.getSettings().setJavaScriptEnabled(true);
        courseId = getArguments().getString("courseID");
        course_intro.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                super.onProgressChanged(view, newProgress);
//				if (newProgress < 10) {
//					progressBar.setProgress(10);
//				} else {
//					progressBar.setProgress(newProgress);
//				}
                if (newProgress == 100) {
                    view_loading.setVisibility(View.GONE);
                    view_loading_fail.setVisibility(View.GONE);
                }
            }
        });
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoNetToast(getActivity());
                } else {
                    showLoading();
                    loadData();
                }
            }
        });
        return v;
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    /**
     * 加载数据
     *
     * @param course_intro
     * @param page
     */
    private void loadData(WebView course_intro, Page page) {
        ConfigLoader.Canvas c = ConfigLoader.getLoader().getCanvas();
        course_intro.clearCache(false);
        course_intro.getSettings().setDefaultTextEncodingName("utf-8");
        String data = c.getHtmlHead() + page.getBody() + c.getHtmlTail();
        course_intro
                .loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
    }

    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        loadData();
    }

    ;

    private void loadData() {
        new Thread() {
            public void run() {
                if (API.which == 1) {
                    try {
                        page = (Page) ObjectSerializableUtil.readObject(Constants.PAGE + courseId);
                    } catch (Exception e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                    if (page == null) {
                        try {
                            page = PagesAPI.getIntroduction(courseId);
                            try {
                                ObjectSerializableUtil.writeObject(page, Constants.PAGE + courseId);
                            } catch (Exception e) {
                                // TODO Auto-generated catch block
                                e.printStackTrace();
                            }
                        } catch (DibitsExceptionC e) {
                            // TODO Auto-generated catch block
                            msgStr = "无课程简介";
                            handler.sendEmptyMessage(0);
                            e.printStackTrace();
                            return;
                        }
                    }
                    handler.post(new Runnable() {
                        public void run() {
                            loadData(course_intro, page);
                        }

                        ;
                    });
                } else {
                    try {
                        final Page page = PagesAPI.getInstructor(courseId);
                        handler.post(new Runnable() {
                            public void run() {
                                loadData(course_intro, page);
                            }

                            ;
                        });
                    } catch (DibitsExceptionC e) {
                        msgStr = "无讲师简介";
                        handler.sendEmptyMessage(0);
                        return;
                    }
                }
            }

            ;
        }.start();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("course_detail_introduction"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("course_detail_introduction");
    }
}
