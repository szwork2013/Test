package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;

import java.util.ArrayList;

public class AnnouncementDetailActivity extends Activity {

    TextView tv_reply_user;
    LayoutInflater inflater;
    private ImageView iv_avatar;
    private TextView title;
    private TextView posted_at;
    private TextView user_name;
    private Announcement anncement;
    private WebView wvMsg;
    private LinearLayout ll_loadfile;
    private Handler handler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dialog_ann_detail);
        findViews();
        anncement = (Announcement) getIntent().getSerializableExtra(getResources().getString(R.string.announcement));
        inflater = LayoutInflater.from(this);
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void findViews() {
        wvMsg = (WebView) findViewById(R.id.wv_msg);
        WebSettings setting = wvMsg.getSettings();
        setting.setUseWideViewPort(true);
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        wvMsg.setWebViewClient(new WebViewClient());

        iv_avatar = (ImageView) findViewById(R.id.iv_avatar);
        title = (TextView) findViewById(R.id.title);
        posted_at = (TextView) findViewById(R.id.posted_at);
        user_name = (TextView) findViewById(R.id.user_name);
        ll_loadfile = (LinearLayout) findViewById(R.id.ll_loadfile);
    }

    @Override
    protected void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        if (anncement.getAttachments() == null
                || anncement.getAttachments().isEmpty()) {
            ll_loadfile.setVisibility(View.GONE);
        } else {
            int fileSize = anncement.getAttachments().size();
            for (int i = 0; i < fileSize; i++) {
                TextView tv_load_file = (TextView) inflater.inflate(
                        R.layout.load_file, null);
                ll_loadfile.addView(tv_load_file);
                tv_load_file.setText(anncement.getAttachments().get(i)
                        .getFilename());
                tv_load_file.setOnClickListener(new LoadFileListener(i,
                        anncement.getAttachments()));
            }
        }
        Bitmap bit = ImgLoaderUtil.getLoader().loadImg(
                anncement.getAuthor().getAvatar_image_url(), new ImgLoaderUtil.ImgCallback() {

                    @Override
                    public void refresh(Bitmap bitmap) {
                        if (bitmap == null) {
                            iv_avatar
                                    .setBackgroundResource(R.drawable.avatar_default);
                        } else {
                            iv_avatar.setBackground(new BitmapDrawable(
                                    getResources(), bitmap));
                        }
                    }
                }, handler);
        if (bit == null) {
            iv_avatar.setBackgroundResource(R.drawable.avatar_default);
        } else {
            iv_avatar.setBackground(new BitmapDrawable(getResources(), bit));
        }
        title.setText(anncement.getTitle());
        posted_at
                .setText(DateUtils.getCourseStartTime(anncement.getPosted_at()));
        user_name.setText(anncement.getAuthor().getDisplay_name());
        wvMsg.loadDataWithBaseURL(null, anncement.getMessage(), "text/html",
                "utf-8", null);
    }

    class LoadFileListener implements OnClickListener {

        private int index;
        private ArrayList<Announcement.Attachment> attList;

        public LoadFileListener(int index, ArrayList<Announcement.Attachment> attList) {
            this.index = index;
            this.attList = attList;
        }

        public Integer getViewIndex() {
            return index;
        }

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(attList
                    .get(index).getUrl()));
            System.out.println();
            startActivity(intent);
        }

    }

}




