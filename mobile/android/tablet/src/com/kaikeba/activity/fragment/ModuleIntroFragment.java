package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.Toast;
import com.kaikeba.common.api.PagesAPI;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;

/**
 * 加载课程介绍，讲师介绍Fragment
 *
 * @author Allen
 */
public class ModuleIntroFragment extends Fragment {

    private WebView course_intro;
    private String courseId;
    //	private ProgressBar progressBar;
    private Page page;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    loadData(course_intro, page);
                    break;
                case 2:
                    Toast.makeText(getActivity(), "无数据", Toast.LENGTH_SHORT).show();
                    view_Loading.setVisibility(View.GONE);
                    break;
                default:
                    break;
            }
        }

        ;
    };
    private LinearLayout view_Loading;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.course_intro, container, false);
        course_intro = (WebView) v.findViewById(R.id.wv_course_intro);
        // TODO
        course_intro.getSettings().setJavaScriptEnabled(true);
        view_Loading = (LinearLayout) v.findViewById(R.id.view_loading);
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
//		progressBar = (ProgressBar)v.findViewById(R.id.progressBar);
        course_intro.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                if (newProgress == 100) {
                    view_Loading.setVisibility(View.GONE);
                }
                super.onProgressChanged(view, newProgress);
            }
        });
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        refreshUI();
    }

    public void refreshUI() {
        view_Loading.setVisibility(View.VISIBLE);
        new Thread() {
            public void run() {
                if (Constants.goWhich == 1) {
                    try {
                        page = PagesAPI.getIntroduction(courseId);
                        handler.sendEmptyMessage(0);
                    } catch (DibitsExceptionC e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                        handler.sendEmptyMessage(2);
                        return;
                    }
                } else {
                    try {
                        page = PagesAPI.getInstructor(courseId);
                        handler.sendEmptyMessage(0);
                    } catch (DibitsExceptionC e) {
                        handler.sendEmptyMessage(2);
                        return;
                    }
                }
            }

            ;
        }.start();
    }

    private void loadData(WebView course_intro, Page page) {
        ConfigLoader.Canvas c = ConfigLoader.getLoader().getCanvas();
        course_intro.clearCache(true);
        course_intro.getSettings().setDefaultTextEncodingName("utf-8");
        String data = c.getHtmlHead() + page.getBody() + c.getHtmlTail();
        course_intro
                .loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
    }
}
