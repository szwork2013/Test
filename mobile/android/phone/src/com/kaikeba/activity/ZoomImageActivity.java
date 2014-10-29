package com.kaikeba.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.FrameLayout;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;
import uk.co.senab.photoview.PhotoView;
import uk.co.senab.photoview.PhotoViewAttacher;

/**
 * Created by mjliu on 14-7-30.
 */
public class ZoomImageActivity extends Activity implements View.OnClickListener {

    private PhotoView zoomImg;
    private String url;
    private BitmapUtils bitmapUtil;
    private PhotoViewAttacher mAttacher;
    private FrameLayout fl_outside_image;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.prize_image_view);
        url = getIntent().getStringExtra("zoom_img_url");
        bitmapUtil = BitmapHelp.getBitmapUtils(ZoomImageActivity.this);
        initView();
        initData();
        mAttacher = new PhotoViewAttacher(zoomImg);
        mAttacher.setOnPhotoTapListener(new PhotoViewAttacher.OnPhotoTapListener() {
            @Override
            public void onPhotoTap(View view, float x, float y) {
                finish();
            }
        });
        mAttacher.setOnViewTapListener(new PhotoViewAttacher.OnViewTapListener() {
            @Override
            public void onViewTap(View view, float v, float v2) {
                finish();
            }
        });
        fl_outside_image.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    private void initData() {
        bitmapUtil.display(zoomImg, url,BitmapHelp.getBitMapConfig(ZoomImageActivity.this,R.drawable.certificate_default));
    }

    private void initView() {
        zoomImg = (PhotoView) findViewById(R.id.prize_img);
        fl_outside_image = (FrameLayout) findViewById(R.id.fl_outside_image);
        zoomImg.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(zoomImg)) {

        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mAttacher != null) {
            mAttacher.cleanup();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("ZoomImage"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("ZoomImage");
        MobclickAgent.onPause(this);
    }
}
