package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.*;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.SurfaceHolder.Callback;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.View.OnTouchListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.*;
import com.kaikeba.common.api.PagesAPI;
import com.kaikeba.common.api.VideoURLAPI;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.phone.R;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.util.Timer;
import java.util.TimerTask;

/**
 * 加载我的课程Item中的内容
 *
 * @author Allen
 */
public class MyCourseItemFragment extends Fragment {

    public OnTouchListener mScrollListener = new OnTouchListener() {
        @Override
        public boolean onTouch(View view, MotionEvent event) {
            int x1 = (int) mSurfaceView.getX();
            int x2 = x1 + mSurfaceView.getWidth();
            int y1 = (int) mSurfaceView.getY();
            int y2 = y1 + mSurfaceView.getHeight();
            int y = (int) (event.getY() + view.getScrollY());
            if ((x1 <= event.getX() && event.getX() <= x2) && y1 <= y && y <= y2) {
                if (mGestureDetector.onTouchEvent(event))
                    return true;

                // 处理手势结束
                switch (event.getAction() & MotionEvent.ACTION_MASK) {
                    case MotionEvent.ACTION_UP:
                        endGesture();
                        break;
                }

                return true;
            } else {
                return false;
            }
        }
    };
    String videoUrl = null;
    /**
     * 视频播放地址
     */
    GestureDetector mGestureDetector;
    MediaPlayer mMediaPlayer;
    Button mPlayButton, mScaleButton;
    SurfaceView mSurfaceView;
    //************************播放器相关****************************//
    RelativeLayout rv_controll;
    ProgressBar progressBar;
    /**
     * 当前视频的位置
     */
    int mCurVideoPos;
    /**
     * 用于判断视频是否在播放中
     */
    boolean isPlayTag = true;
    /**
     * 更新进度条
     */
    Handler mHandler = new Handler() {
        public void handleMessage(Message msg) {
            if (mMediaPlayer == null) {
                isPlayTag = false;
            } else if (mMediaPlayer.isPlaying()) {
                isPlayTag = true;
                int position = mMediaPlayer.getCurrentPosition();
                int mMax = mMediaPlayer.getDuration();
                int sMax = mSeekbar.getMax();
                mSeekbar.setProgress(position * sMax / mMax);
            } else {
                return;
            }
        }

        ;
    };
    /**
     * 播放的进度条
     */
    SeekBar mSeekbar;
    /**
     * 用于是否显示其他按钮
     */
    boolean isDisplayButton;
    boolean isScaleTag = false;
    /**
     * 更新进度条显示的Thread
     */
    UpDateSeekBarThread mUpdateSeekBarThread;
    /**
     * 当前声音
     */
    int mVolume = -1;
    /**
     * 最大声音
     */
    int mMaxVolume;
    AudioManager mAudioManager;
    ImageView mOperationBg;
    ImageView mOperationPercent;
    View mVolumeProgressLayout;
    FrameLayout mVideoFrameLayout;
    int windowWidth, windowHeight;
    Timer mTimer;
    TimerTask mTimerTask;
    int videoHeight;
    View v;
    /**
     * 更新时间的Handler
     */
    Handler mTimeHandler = new Handler() {
        public void dispatchMessage(Message msg) {
            updateTime();
        }

        ;
    };
    private LinearLayout btn_back_normal;
    private WebView webView;
    private Page page;
    private RelativeLayout rv;
    private NetChangeReceiver netChangeReceiver;
    private ImageView iv_play;
    private ImageView iv_course_info_play;
    //************************播放器相关****************************//
    private ScrollView scroll_base;
    private TextView mTotalTime;
    private TextView mPassTime;
    private Handler handler = new Handler();
    /**
     * 定时隐藏
     */
    private Handler mDismissHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            mVolumeProgressLayout.setVisibility(View.GONE);
        }
    };
    /**
     * surfaceView的缩放
     */
    private Handler mScaleVideoHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            mSurfaceView.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
            mSurfaceView.notify();
        }
    };

    //***************************************

    public MyCourseItemFragment(String url) {
        if (Constants.DOWNLOAD_VIEW == 2) {
            this.videoUrl = url;
        }
    }

    public MyCourseItemFragment() {

    }

    private static String formatLongToTimeStr(int l) {
        int hour = 0;
        int minute = 0;
        int second = 0;

        second = l / 1000;

        if (second >= 60) {
            minute = second / 60;
            second = second % 60;
        }
        if (minute >= 60) {
            hour = minute / 60;
            minute = minute % 60;
        }
        return (getTwoLength(hour) + ":" + getTwoLength(minute) + ":" + getTwoLength(second));
    }

    //TODO
    private static String getTwoLength(final int data) {
        if (data < 10) {
            return "0" + data;
        } else {
            return "" + data;
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.my_course_item_content, container,
                false);
        btn_back_normal = (LinearLayout) v.findViewById(R.id.btn_back_normal);
        rv = (RelativeLayout) v.findViewById(R.id.rv);
//		scroll_base = (ScrollView)v.findViewById(R.id.scroll_base);
        webView = (WebView) v.findViewById(R.id.wv_course_item_intro_one);
        mTotalTime = (TextView) v.findViewById(R.id.time_totle);
        mPassTime = (TextView) v.findViewById(R.id.time_play);
        WebSettings setting = webView.getSettings();
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        setting.setLoadWithOverviewMode(true);
        webView.setWebViewClient(new WebViewClient());
        webView.setOnKeyListener(new OnKeyListener() {

            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                // TODO Auto-generated method stub
                return false;
            }
        });
        //************************播放器相关****************************//

        init(); // 初始化数据
        setListener(); // 绑定相关事件
        mGestureDetector = new GestureDetector(getActivity(), new MyGestureListener());
        videoHeight = mVideoFrameLayout.getHeight();

        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        //注册一个广播
        netChangeReceiver = new NetChangeReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(Constants.NOTICE_NET_3G);
        getActivity().registerReceiver(netChangeReceiver, filter);

        btn_back_normal.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                FragmentTransaction ft = getFragmentManager()
                        .beginTransaction();
                ft.show(getFragmentManager().findFragmentByTag("ModuleContentFragment"));
                ft.remove(MyCourseItemFragment.this);
                ft.commit();
            }
        });
        if (Constants.DOWNLOAD_VIEW == 2) {
            mVideoFrameLayout.setVisibility(View.VISIBLE);
            return;
        }
        if (Constants.DOWNLOAD_VIEW == 3) {
            mVideoFrameLayout.setVisibility(View.VISIBLE);
            videoUrl = getArguments().getString("url");
            return;
        }
        String argument = getArguments().getString("courseID+pageURL");
        final String courseID = argument.split("##")[0];
        final String pageURL = argument.split("##")[1];
        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                try {
                    page = PagesAPI.getPage(courseID, pageURL);
                    handler.post(new Runnable() {
                        public void run() {
                            webView.clearCache(true);
                            webView.getSettings().setDefaultTextEncodingName("utf-8");

                            String data = page.getBody();
                            if (Constants.videoUrlIsNull) {
                                Document doc = Jsoup.parse(data);
                                Element a = doc.getElementById("embed_media_0");

                                if (a == null) {
                                    mVideoFrameLayout.setVisibility(View.GONE);
                                    webView.loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
                                } else {
                                    videoUrl = VideoURLAPI.getVideoURL(a.text());
                                    mVideoFrameLayout.setVisibility(View.VISIBLE);
//									new PlayMovie(0).start();
                                }
                            } else {
                                webView.loadDataWithBaseURL(null, data, "text/html", "utf-8", null);
                                mVideoFrameLayout.setVisibility(View.GONE);
                            }
                        }

                        ;
                    });
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void play() {
        new PlayMovie(0).start();
        progressBar.setVisibility(View.VISIBLE);
        iv_play.setVisibility(View.GONE);// 表明是第一次开始播放
    }

    /**
     * 初始化数据
     */
    private void init() {
        mMediaPlayer = new MediaPlayer(); // 创建一个播放器对象
        mPlayButton = (Button) v.findViewById(R.id.play);
        mPlayButton.setBackgroundResource(R.drawable.movie_stop_bt);
        mScaleButton = (Button) v.findViewById(R.id.scale);
        mSeekbar = (SeekBar) v.findViewById(R.id.seekbar);
        mSurfaceView = (SurfaceView) v.findViewById(R.id.surfaceView);
        progressBar = (ProgressBar) v.findViewById(R.id.progressBar);
        mSurfaceView.getHolder().setKeepScreenOn(true); // 保持屏幕高亮
        mSurfaceView.getHolder().addCallback(new surFaceView()); // 设置监听事件
        rv_controll = (RelativeLayout) v.findViewById(R.id.rv_controll);
        mAudioManager = (AudioManager) getActivity().getSystemService(Context.AUDIO_SERVICE);
        mMaxVolume = mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        mOperationBg = (ImageView) v.findViewById(R.id.operation_bg);
        mOperationPercent = (ImageView) v.findViewById(R.id.operation_percent);
        iv_course_info_play = (ImageView) v.findViewById(R.id.iv_course_info_play);
        mVolumeProgressLayout = v.findViewById(R.id.operation_volume_brightness);

        mVideoFrameLayout = (FrameLayout) v.findViewById(R.id.surfaceView_framelayout);
        Display disp = getActivity().getWindowManager().getDefaultDisplay();
        windowWidth = disp.getWidth();
        windowHeight = disp.getHeight();
        iv_play = (ImageView) v.findViewById(R.id.iv_play);
        mVideoFrameLayout.setOnTouchListener(mScrollListener);
        mTimer = new Timer();
        mTimerTask = new TimerTask() {

            @Override
            public void run() {
                updateProgressBar();
                mTimeHandler.sendEmptyMessage(1);
            }
        };
        mTimer.schedule(mTimerTask, 0, 10);
    }

    private void setListener() {
        iv_play.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                if (!Constants.NET_IS_SUCCESS) {
                    KKDialog.getInstance().showNoNetToast(getActivity());
                } else {
                    if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                new OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        Constants.nowifi_doplay = false;
                                        KKDialog.getInstance().dismiss();
                                        play();
                                    }
                                },
                                new OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        KKDialog.getInstance().dismiss();
                                    }
                                });
                    } else {
                        play();
                    }

                }
            }
        });

        mMediaPlayer
                .setOnBufferingUpdateListener(new MediaPlayer.OnBufferingUpdateListener() {
                    @Override
                    public void onBufferingUpdate(MediaPlayer mp, int percent) {
                    }
                });

        mMediaPlayer
                .setOnCompletionListener(new MediaPlayer.OnCompletionListener() { // 视频播放完成
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        isPlayTag = false;
                        mPlayButton.setBackgroundResource(R.drawable.play);
                    }
                });

        mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {

            }
        });
        /**
         * 如果视频在播放，则调用mediaPlayer.pause();，停止播放视频，反之，mediaPlayer.start()
         * ，同时换按钮背景
         */
        mPlayButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoNetToast(getActivity());
                } else {
                    if (Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                new OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        KKDialog.getInstance().dismiss();
                                        toPlay();
                                    }
                                },
                                new OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        KKDialog.getInstance().dismiss();
                                        toPause();
                                    }
                                });
                    } else {
                        toPlayOrPause();
                    }
                }

            }
        });

        mSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

                int value = mSeekbar.getProgress() * mMediaPlayer.getDuration() // 计算进度条需要前进的位置数据大小
                        / mSeekbar.getMax();
                mMediaPlayer.seekTo(value);
                updateTime();
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress,
                                          boolean fromUser) {

            }
        });

        mScaleButton.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                View view = getActivity().findViewById(R.id.module_nav_container);
                if (isScaleTag) {
                    //缩小
                    rv.setVisibility(View.VISIBLE);
                    view.setVisibility(View.VISIBLE);
//					RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(tvCourseTopName.getWidth(), LinearLayout.LayoutParams.WRAP_CONTENT);
//					lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//					lp.addRule(RelativeLayout.BELOW, R.id.tv_course_top_name);
//					lp.addRule(RelativeLayout.ABOVE, R.id.in_view);
//					scroll_base.setLayoutParams(lp);
                    mVideoFrameLayout.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 565));
                    isScaleTag = false;
                } else {
                    //TODO 放大
                    rv.setVisibility(View.GONE);
                    view.setVisibility(View.GONE);
                    mVideoFrameLayout.setLayoutParams(new LinearLayout.LayoutParams(windowWidth, windowHeight - 30));
                    isScaleTag = true;
                }
            }
        });
    }

    private void toPlay() {
        if (isPlayTag == false) {
            isPlayTag = true;
            new Thread(mUpdateSeekBarThread).start();
        }
        mMediaPlayer.start();
        mPlayButton.setBackgroundResource(R.drawable.play);
    }

    private void toPause() {
        if (mMediaPlayer.isPlaying()) {
            mPlayButton.setBackgroundResource(R.drawable.stop);
            mMediaPlayer.pause();
            mCurVideoPos = mMediaPlayer.getCurrentPosition();
        }
    }

    private void toPlayOrPause() {
        if (mMediaPlayer.isPlaying()) {
            mPlayButton.setBackgroundResource(R.drawable.stop);
            mMediaPlayer.pause();
            mCurVideoPos = mMediaPlayer.getCurrentPosition();
        } else {
            if (isPlayTag == false) {
                isPlayTag = true;
                new Thread(mUpdateSeekBarThread).start();
            }
            mMediaPlayer.start();
            mPlayButton.setBackgroundResource(R.drawable.play);
        }
    }

    /**
     * 滑动改变视频进度
     *
     * @param percent
     */
    private void onProgressSlide(float percent) {
        int max = mMediaPlayer.getDuration();
        int gap = (int) (max * percent * 0.05);
        int pos = mMediaPlayer.getCurrentPosition() + gap;
        if (pos < 0) {
            pos = 0;
        } else if (pos > mMediaPlayer.getDuration()) {
            pos = max;
        }
        Log.e("test", "percent = " + percent);
        Log.e("test", "pos = " + pos);
        mMediaPlayer.seekTo(pos);
        updateProgressBar();
        updateTime();
    }

    /**
     * 更新进度条的进度
     */
    private void updateProgressBar() {
        if (mMediaPlayer != null) {
            int position = mMediaPlayer.getCurrentPosition();
            if (mMediaPlayer != null) {
                int mMax = mMediaPlayer.getDuration();
                int sMax = mSeekbar.getMax();
                mSeekbar.setProgress(position * sMax / mMax);
            }
        }
    }

    /**
     * 滑动改变声音大小
     *
     * @param percent
     */
    private void onVolumeSlide(float percent) {
        if (mVolume == -1) {
            mVolume = mAudioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
            if (mVolume < 0) {
                mVolume = 0;
            }
        }
        mOperationBg.setImageResource(R.drawable.video_volumn_bg);
        mVolumeProgressLayout.setVisibility(View.VISIBLE);

        int index = (int) (percent * mMaxVolume) + mVolume;
        if (index > mMaxVolume) {
            index = mMaxVolume;
        } else if (index < 0) {
            index = 0;
        }
        mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, index, 0);
        // 变更进度条
        ViewGroup.LayoutParams lp = mOperationPercent.getLayoutParams();
        lp.width = v.findViewById(R.id.operation_full).getLayoutParams().width * index / mMaxVolume;
        mOperationPercent.setLayoutParams(lp);
    }

    /**
     * 手势结束
     */
    private void endGesture() {
        mVolume = -1;

        // 隐藏
        mDismissHandler.removeMessages(0);
        mDismissHandler.sendEmptyMessageDelayed(0, 500);
    }

    public void onDestroyView() {
        super.onDestroyView();
        if (mTimer != null) {
            mTimer.cancel();
        }
        if (mMediaPlayer.isPlaying()) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
        }
        mMediaPlayer = null;
    }

    public void onDestroy() {
        super.onDestroy();
        getActivity().unregisterReceiver(netChangeReceiver);
    }

    //TODO
    private void updateTime() {
        if (mMediaPlayer != null) {
            mTotalTime.setText(formatLongToTimeStr(mMediaPlayer.getDuration()));
            mPassTime.setText(formatLongToTimeStr(mMediaPlayer.getCurrentPosition()));
        }
    }

    private class NetChangeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Constants.NOTICE_NET_3G) && mMediaPlayer.isPlaying()) {
                toPause();
                KKDialog.getInstance().showNoWifi2Play(getActivity(),
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                                toPlayOrPause();
                            }
                        },
                        new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                            }
                        });

            }
        }
    }

    ;

    private class surFaceView implements Callback { // 上面绑定的监听的事件

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width,
                                   int height) {
//			mSurfaceView.getHolder().setFixedSize(width, height);
//			mMediaPlayer.setDisplay(mSurfaceView.getHolder());
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) { // 创建完成后调用
            if (mCurVideoPos > 0 && videoUrl != null) { // 说明，停止过activity调用过pase方法，跳到停止位置播放
                new PlayMovie(mCurVideoPos).start();
                isPlayTag = true;
                int sMax = mSeekbar.getMax();
                int mMax = mMediaPlayer.getDuration();
                mSeekbar.setProgress(mCurVideoPos * sMax / mMax);
                mCurVideoPos = 0;
            }
//			else {
//				new PlayMovie(0).start(); // 表明是第一次开始播放
//			}
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) { // activity调用过pase方法，保存当前播放位置
            if (mMediaPlayer != null && mMediaPlayer.isPlaying()) {
                mCurVideoPos = mMediaPlayer.getCurrentPosition();
                mMediaPlayer.stop();
                isPlayTag = false;
            }
        }
    }

    ;

    /**
     * 播放视频的线程
     *
     * @author JinChao
     */
    class PlayMovie extends Thread {
        int mCurVideoPos = 0;

        public PlayMovie(int mCurVideoPos) {
            this.mCurVideoPos = mCurVideoPos;

        }

        @Override
        public void run() {
            Message message = Message.obtain();
            try {
                Log.i("hck", "runrun  " + videoUrl);
                mMediaPlayer.reset(); // 回复播放器默认
                mMediaPlayer.setDataSource(videoUrl); // 设置播放路径
                mMediaPlayer.setDisplay(mSurfaceView.getHolder()); // 把视频显示在SurfaceView上
                mMediaPlayer.setOnPreparedListener(new mPreparedListener(mCurVideoPos)); // 设置监听事件
                mMediaPlayer.prepare(); // 准备播放
            } catch (Exception e) {
                message.what = 2;
            }
            super.run();
        }
    }

    //TODO

    class mPreparedListener implements OnPreparedListener {
        int curVideoPos;

        public mPreparedListener(int curVideoPos) {
            this.curVideoPos = curVideoPos;
        }

        @Override
        public void onPrepared(MediaPlayer mp) {
            rv_controll.setVisibility(View.GONE);
//			mPlayButton.setVisibility(View.GONE);
            mPlayButton.setEnabled(true);
            isDisplayButton = false;
            if (mMediaPlayer != null) {
                mMediaPlayer.start(); // 开始播放视频
            } else {
                return;
            }
            if (curVideoPos > 0) { // 说明中途停止过（activity调用过pase方法，不是用户点击停止按钮），跳到停止时候位置开始播放
                Log.i("hck", "seekTo ");
                mMediaPlayer.seekTo(curVideoPos); // 跳到postSize大小位置处进行播放
            }

            int position = mMediaPlayer.getCurrentPosition();
            int mMax = mMediaPlayer.getDuration();
            int sMax = mSeekbar.getMax();
            progressBar.setVisibility(View.GONE);
            iv_course_info_play.setVisibility(View.GONE);
            mSeekbar.setProgress(position * sMax / mMax);
        }
    }

    private class MyGestureListener extends SimpleOnGestureListener {

        /**
         * 双击
         */
        @Override
        public boolean onDoubleTap(MotionEvent e) {
            Log.e("Test", "双击");
            return true;
        }

        /**
         * 单击
         */
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            Log.e("Test", "单击");
            if (isDisplayButton) {
                rv_controll.setVisibility(View.GONE);
                isDisplayButton = false;
            } else {
                rv_controll.setVisibility(View.VISIBLE);
                mSurfaceView.setVisibility(View.VISIBLE);
                isDisplayButton = true;
            }
            return super.onSingleTapConfirmed(e);
        }

        /**
         * 滑动
         */
        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2,
                                float distanceX, float distanceY) {
            if (e1 != null && e2 != null) {
                float x1 = e1.getX();
                float y1 = e1.getY();
                float x2 = e2.getX();
                float y2 = e2.getY();
                float disX = x2 - x1;
                float disY = y2 - y1;
                //TODO
                if (Math.abs(disX) > 50 && Math.abs(disY) < 50) {
                    Log.e("Test", "左右滑动");
                    onProgressSlide((x2 - x1) / windowWidth);
                } else if (Math.abs(disY) > 50 && Math.abs(disX) < 50) {
                    Log.e("Test", "上下滑动");
                    onVolumeSlide((y1 - y2) / windowHeight);
                }
                return super.onScroll(e1, e2, distanceX, distanceY);
            } else {
                return true;
            }
        }
    }

    class UpDateSeekBarThread implements Runnable {

        @Override
        public void run() {
            mHandler.sendMessage(Message.obtain());
            if (isPlayTag) {
                mHandler.postDelayed(mUpdateSeekBarThread, 1000);
            }
        }
    }


}
