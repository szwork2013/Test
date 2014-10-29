package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
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
import com.kaikeba.phone.R;

/**
 * 课程介绍Activity
 *
 * @author Allen
 */
@SuppressLint("SetJavaScriptEnabled")
public class CourseIntroduceFragment extends Fragment {

    private String msgStr;
    private WebView course_intro;
    private String courseId;
    private LinearLayout view_loading;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    view_loading.setVisibility(View.GONE);
                    Toast.makeText(getActivity(), msgStr, Toast.LENGTH_SHORT).show();
                    break;
                default:
                    break;
            }
        }

        ;
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stubs

        View v = inflater.inflate(R.layout.course_intro, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        course_intro = (WebView) v.findViewById(R.id.wv_course_intro);
        course_intro.getSettings().setJavaScriptEnabled(true);
        course_intro.getSettings().setUseWideViewPort(true);
        course_intro.getSettings().setLoadWithOverviewMode(true);
//		course_intro.setDownloadListener(new MyWebViewDownLoadListener());
//		course_intro.setWebViewClient(new WebViewClient(){
//			@Override
//			public boolean shouldOverrideUrlLoading(WebView view, String url) {
//				// TODO Auto-generated method stub
//				view.loadUrl(url);
//				return super.shouldOverrideUrlLoading(view, url);
//			}
//		});
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
        course_intro.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                super.onProgressChanged(view, newProgress);
                if (newProgress == 100) {
                    view_loading.setVisibility(View.GONE);
                }
            }
        });
        return v;
    }

    /**
     * 加载数据
     *
     * @param course_intro
     * @param page
     */
    private void loadData(WebView course_intro, Page page) {
        ConfigLoader.Canvas c = ConfigLoader.getLoader().getCanvas();
        course_intro.clearCache(true);
        course_intro.getSettings().setDefaultTextEncodingName("utf-8");
        String data = c.getHtmlHead() + page.getBody() + c.getHtmlTail();
        course_intro
                .loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
    }

    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        new Thread() {
            public void run() {
                try {
                    final Page page = PagesAPI.getIntroduction(courseId);
                    handler.post(new Runnable() {
                        public void run() {
                            loadData(course_intro, page);
                        }

                        ;
                    });
                } catch (DibitsExceptionC e) {
                    // TODO Auto-generated catch block
                    msgStr = "无课程简介";
                    handler.sendEmptyMessage(0);
                    e.printStackTrace();
                    return;
                }
            }

            ;
        }.start();
    }

    ;

}
