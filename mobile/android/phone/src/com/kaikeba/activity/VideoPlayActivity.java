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

public class VideoPlayActivity extends Activity {

    RelativeLayout mVideoFrameLayout;
    String videoUrl = null;
    private VideoPlayerView video_palyer;




    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_play);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mVideoFrameLayout = (RelativeLayout) findViewById(R.id.surfaceView_framelayout);
        String url = getIntent().getStringExtra("url");
        int lms_courseId = getIntent().getIntExtra("lms_courseId",0);
        int lastVideoId = getIntent().getIntExtra("lastVideoId",0);
        if (url != null) {
            videoUrl = url;
            Constants.PLAY_VIDEO_FROM_LOCAL = true;
            Constants.FULL_SCREEN_ONLY = true;
            video_palyer = new VideoPlayerView(this);
            video_palyer.preparePlayData(videoUrl,null,0,lms_courseId,lastVideoId);
            mVideoFrameLayout.addView(video_palyer.makeControllerView());
        }



    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageStart("dodwnload_video_play");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onResume() {
        super.onResume();
        MobclickAgent.onPageEnd("dodwnload_video_play");
        MobclickAgent.onResume(this);
    }

    @Override
    public void onStop() {
        super.onStop();
        if (video_palyer != null) {
            video_palyer.onDestroy();
        }
        Constants.PLAY_VIDEO_FROM_LOCAL = false;
        Constants.FULL_SCREEN_ONLY = false;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
//        int duration = 0;
        if (video_palyer != null) {
            video_palyer.onDestroy();
            Constants.PLAY_VIDEO_FROM_LOCAL = false;
            Constants.FULL_SCREEN_ONLY = false;
            //友盟统计
//            duration = video_palyer.getDuration(); //开发者需要自己计算音乐播放时长
        }

//        HashMap<String, String> map = new HashMap<String, String>();
//        Intent intent = getIntent();
//        map.put("type", "");
//        if (intent.getStringExtra("user_id") != null)
//            map.put("user_id", intent.getStringExtra("user_id"));
//        map.put("course_id", intent.getStringExtra("course_id"));
//        map.put("module_id", intent.getStringExtra("module_id"));
//        map.put("item_id", intent.getStringExtra("item_id"));
//        map.put("duration", duration + "");
//        MobclickAgent.onEvent(this, "video_play", map);


    }

    ;

}
