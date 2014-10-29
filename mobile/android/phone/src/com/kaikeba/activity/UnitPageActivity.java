package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.kaikeba.common.api.PagesAPI;
import com.kaikeba.common.api.VideoURLAPI;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.util.HashMap;

public class UnitPageActivity extends Activity {

    RelativeLayout mVideoFrameLayout;
    String videoUrl = null;
    private ImageView iv_unit_back;
    private WebView wv_course_item_intro;
    private Page page;
    private TextView tv_unit_item_name;
    private VideoPlayerView video_palyer;


    //************************播放器相关****************************//
    private Handler handler = new Handler() {
        public void handleMessage(Message msg) {
        }

        ;
    };
    private WebChromeClient m_chromeClient = new WebChromeClient() {

        public void onProgressChanged(WebView view, int progress) {// 载入进度改变而触发
            if (progress == 100) {
//				view_loading.setVisibility(View.GONE);
            }
            super.onProgressChanged(view, progress);
        }
    };

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.unit_page);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mVideoFrameLayout = (RelativeLayout) findViewById(R.id.surfaceView_framelayout);
        iv_unit_back = (ImageView) findViewById(R.id.iv_unit_back);
        wv_course_item_intro = (WebView) findViewById(R.id.wv_course_item_intro);
//		view_loading = (LinearLayout) findViewById(R.id.view_loading);
        tv_unit_item_name = (TextView) findViewById(R.id.tv_unit_item_name);
        tv_unit_item_name.setText(getIntent().getStringExtra("title"));
        WebSettings setting = wv_course_item_intro.getSettings();
//		setting.setUserAgentString("Mozilla/5.0 (Linux; U; Android 4.2.2; zh-cn; GT-I9001 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1");
//		setting.setUseWideViewPort(true);
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        setting.setSupportZoom(true);
        setting.setBuiltInZoomControls(true);
//		setting.setPluginState(PluginState.ON);

        wv_course_item_intro.setWebChromeClient(m_chromeClient);

        iv_unit_back.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                finish();
            }
        });

        String url = getIntent().getStringExtra("url");

        if (url != null) {
            videoUrl = url;
            Log.e("xxxxxxxxxxxx", videoUrl);
            mVideoFrameLayout.setVisibility(View.VISIBLE);
            video_palyer = new VideoPlayerView(this);
            Constants.FULL_SCREEN_NO_CLICK = true;
//            video_palyer.setUrl(videoUrl);
            mVideoFrameLayout.addView(video_palyer.makeControllerView());
//            video_palyer.play(0);
            return;
        }


        new Thread(new Runnable() {

            @Override
            public void run() {
                try {
                    String argument = getIntent().getStringExtra("courseID+pageURL");
                    final String courseID = argument.split("##")[0];
                    final String pageURL = argument.split("##")[1];
                    page = PagesAPI.getPage(courseID, pageURL);
                    handler.post(new Runnable() {
                        public void run() {

                            String data = page.getBody();
                            Document doc = Jsoup.parse(data);
                            Element a = doc.getElementById("embed_media_0");
                            if (a == null) {
                                mVideoFrameLayout.setVisibility(View.GONE);
                                wv_course_item_intro.loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
                            } else {
                                videoUrl = VideoURLAPI.getVideoURL(a.text());
                                mVideoFrameLayout.setVisibility(View.VISIBLE);
//								new PlayMovie(0).start();
                            }
//							if (Constants.videoUrlIsNull) {
//								Document doc = Jsoup.parse(data);
//								Element a=doc.getElementById("embed_media_0");
//
//							}
//							else {
//								wv_course_item_intro.loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
//							}
                        }

                        ;
                    });
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                }
            }
        }).start();

    }

    public void onPause() {
        super.onPause();
        wv_course_item_intro.onPause();
        MobclickAgent.onPageStart("my_course_page_detail");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onResume() {
        super.onResume();
        wv_course_item_intro.onResume();
        MobclickAgent.onPageEnd("my_course_page_detail");
        MobclickAgent.onResume(this);
    }

    @Override
    public void onStop() {
        super.onStop();
        wv_course_item_intro.stopLoading();
        if (video_palyer != null) {
            video_palyer.onDestroy();
        }
        Constants.FULL_SCREEN_NO_CLICK = false;
    }

    public WebView getWebView() {
        return this.wv_course_item_intro;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        int duration = 0;
        if (video_palyer != null) {
            video_palyer.onDestroy();
            Constants.FULL_SCREEN_NO_CLICK = false;

            //友盟统计
            duration = video_palyer.getDuration(); //开发者需要自己计算音乐播放时长
        }

        HashMap<String, String> map = new HashMap<String, String>();
        Intent intent = getIntent();
        map.put("type", "");
        if (intent.getStringExtra("user_id") != null)
            map.put("user_id", intent.getStringExtra("user_id"));
        map.put("course_id", intent.getStringExtra("course_id"));
        map.put("module_id", intent.getStringExtra("module_id"));
        map.put("item_id", intent.getStringExtra("item_id"));
        map.put("duration", duration + "");
        MobclickAgent.onEvent(this, "video_play", map);


    }

    ;

}
