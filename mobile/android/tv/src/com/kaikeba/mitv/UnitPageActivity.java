package com.kaikeba.mitv;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.view.*;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.*;
import android.view.SurfaceHolder.Callback;
import android.widget.*;
import com.kaikeba.common.api.PagesAPI;
import com.kaikeba.common.api.VideoURLAPI;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.entity.TvHistoryInfo;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DataSource;
import com.kaikeba.common.util.NetworkUtil;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.lidroid.xutils.exception.DbException;
import com.umeng.analytics.MobclickAgent;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import java.util.List;

public class UnitPageActivity extends Activity {

    /**
     * state of media player
     */
    private final static int STATE_UNKNOW = 0;

    // ************************播放器相关****************************//
    private int mStateOfMediaPlayer = STATE_UNKNOW;
    private final static int STATE_IDLE = 1;
    private final static int STATE_PREPARED = 2;
    private final static int STATE_STARTED = 3;
    private final static int STATE_PAUSED = 4;
    private final static int STATE_PLAYBACK_COMPLETED = 5;
    private final static int STATE_STOPPED = 6;
    private final static int STATE_ERROR = 7;
    private final static int STATE_INITIALIZED = 8;
    private final static int SHOW_LOAD_VIDEO_FAIL = 1;
    private final static int SHOW_NOTHING = 2;
    private Handler mShowMessageHandler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SHOW_LOAD_VIDEO_FAIL:
                    Log.v("UnitPageActivity", "NetworkMonitor showMessageHandler");
                    Toast.makeText(UnitPageActivity.this, "断开网络连接", Toast.LENGTH_LONG).show();
                    mPostDelayedHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            finish();
                        }
                    }, 1000);
                    break;
                case SHOW_NOTHING:
                    finish();
                    break;
                default:
                    Toast.makeText(UnitPageActivity.this, "未知信息", Toast.LENGTH_LONG).show();
            }

        }
    };
    /**
     * 视频播放地址
     */
    MediaPlayer mMediaPlayer;
    SurfaceView mSurfaceView;
    RelativeLayout mBottomStatusBar;
    ProgressBar mLoadingProgressBar;
    /**
     * 当前视频的位置
     */
    int mCurVideoPos = 0;
    /**
     * 播放的进度条
     */
    SeekBar mMediaPlayerSeekbar;
    /**
     * 用于是否显示其他按钮
     */
    boolean isDisplayButton;
    boolean isScaleTag = false;
    /**
     * 更新进度条显示的Thread
     */
    Runnable mMediaPlayerProgressRunnable;
    /**
     * 当前声音
     */
    int mVolume = -1;
    /**
     * 最大声音
     */
    int mMaxVolume;
    AudioManager mAudioManager;
    ImageView mVolumeBg;
    ImageView mOperationPercent;
    View mVolumeProgressLayout;
    FrameLayout mVideoFrameLayout;
    int windowWidth, windowHeight;
    int videoHeight;
    String videoUrl = null;

    boolean screenflag = false;
    Handler mUpdateMediaPlayerProgressHandler = new Handler() {
        public void handleMessage(Message msg) {
            updateMediaPlayerProgress();
        }
    };
    private Page page;
    // View v;
    private ImageButton iv_play;
    private ImageView iv_course_info_play;
    // ************************播放器相关****************************//
    private DisplayMetrics dm;
    private TextView mTotalTime;
    private TextView mPassTime;
    private boolean isFirst = true;
    private int LEFT = 1;
    private int RIGHT = 2;
    private int DIRECT;
    private int UP = 1;
    private int DOWN = 2;
    private int VOICE_DIRECT;
//    private AsyncTask mLastFrameTask;
//    private int mOffsetPos = 3000;
    private boolean IS_FIRST = true;
    private boolean isEnterLeftOrRight = false;
    private NetBroadcastReceiver mNetBroadcastReceiver;
    //    private MediaMetadataRetriever mMediaMetadataRetriever = new MediaMetadataRetriever();
//    private Bitmap mLastFrameImage;
    private RelativeLayout mLastFrameImageView;
    private CourseCardItem course;
    private Handler mPostDelayedHandler = new Handler();

    // **********************************************************************

    // ***************************************
    /**
     * 定时隐藏
     */
    private Handler mDismissHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            mVolumeProgressLayout.setVisibility(View.GONE);
        }
    };
    private NetworkMonitor mNetworkMonitor = new NetworkMonitor();

    private static String formatLongToTimeStr(int l) {
        int hour = 0;
        int minute = 0;
        int second = 0;

        second = l / 1000;

        if (second > 60) {
            minute = second / 60;
            second = second % 60;
        }
        if (minute > 60) {
            hour = minute / 60;
            minute = minute % 60;
        }
        return (getTwoLength(hour) + ":" + getTwoLength(minute) + ":" + getTwoLength(second));
    }

    private static String getTwoLength(final int data) {
        if (data < 10) {
            return "0" + data;
        } else {
            return "" + data;
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.unit_page);
        Display disp = getWindowManager().getDefaultDisplay();
        windowWidth = disp.getWidth();
        windowHeight = disp.getHeight();

        init(); // 初始化数据
        setListener(); // 绑定相关事件

        IntentFilter filter = new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mNetBroadcastReceiver = new NetBroadcastReceiver();
        registerReceiver(mNetBroadcastReceiver, filter);

        videoHeight = mVideoFrameLayout.getHeight();
        String url = getIntent().getStringExtra("url");
        mCurVideoPos = getIntent().getIntExtra("duation", 0);
        if (mCurVideoPos != 0) {
            updateMediaPlayerProgress();
        }
        course = (CourseCardItem) getIntent().getSerializableExtra("courseItem");
        // url = "http://kkb-768kb-720p.qiniudn.com/10000/1000091/e9994adb20ae07a76bebf9066c335112.mp4";
        if (url != null) {
            videoUrl = url;
//            mMediaMetadataRetriever.setDataSource(videoUrl, new HashMap<String, String>());
            mVideoFrameLayout.setVisibility(View.VISIBLE);
            return;
        }


        new Thread(new Runnable() {

            @Override
            public void run() {
                try {
                    String argument = getIntent().getStringExtra(
                            "courseID+pageURL");
                    final String courseID = argument.split("##")[0];
                    final String pageURL = argument.split("##")[1];
                    page = PagesAPI.getPage(courseID, pageURL);
                    mPostDelayedHandler.post(new Runnable() {
                        public void run() {

                            String data = page.getBody();
                            Document doc = Jsoup.parse(data);
                            Element a = doc.getElementById("embed_media_0");
                            if (a == null) {
                                mVideoFrameLayout.setVisibility(View.GONE);
                            } else {
                                videoUrl = VideoURLAPI.getVideoURL(
                                        a.text());
                                mVideoFrameLayout.setVisibility(View.VISIBLE);
                                // new PlayMovie(0).start();
                            }
                            // if (Constants.videoUrlIsNull) {
                            // Document doc = Jsoup.parse(data);
                            // Element a=doc.getElementById("embed_media_0");
                            //
                            // }
                            // else {
                            // wv_course_item_intro.loadDataWithBaseURL(null,
                            // data, "text/html", "utf-8", null);
                            // }
                        }

                        ;
                    });
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * 初始化数据
     */
    private void init() {
        mMediaPlayerSeekbar = (SeekBar) findViewById(R.id.seekbar);
        mLoadingProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mBottomStatusBar = (RelativeLayout) findViewById(R.id.rv_controll);
        mVolumeBg = (ImageView) findViewById(R.id.operation_bg);
        mOperationPercent = (ImageView) findViewById(R.id.operation_percent);
        iv_course_info_play = (ImageView) findViewById(R.id.iv_course_info_play);
        mVolumeProgressLayout = findViewById(R.id.operation_volume_brightness);
        mTotalTime = (TextView) findViewById(R.id.time_totle);
        mPassTime = (TextView) findViewById(R.id.time_play);
        mLastFrameImageView = (RelativeLayout) findViewById(R.id.image_view);

        mMediaPlayer = new MediaPlayer(); // 创建一个播放器对象
        mStateOfMediaPlayer = STATE_IDLE;

        mSurfaceView = (SurfaceView) findViewById(R.id.surfaceView);
        mSurfaceView.getHolder().setKeepScreenOn(true); // 保持屏幕高亮
        mSurfaceView.getHolder().addCallback(new surFaceView()); // 设置监听事件
        mAudioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        mMaxVolume = mAudioManager
                .getStreamMaxVolume(AudioManager.STREAM_MUSIC);

        mVideoFrameLayout = (FrameLayout) findViewById(R.id.surfaceView_framelayout);
        Display disp = getWindowManager().getDefaultDisplay();
        windowWidth = disp.getWidth();
        windowHeight = disp.getHeight();
        iv_play = (ImageButton) findViewById(R.id.iv_play);
        // TODO

        mMediaPlayerProgressRunnable = new UpdateMediaPlayerProgressRunnable();
    }

    private void setListener() {
        mMediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            public boolean onError(MediaPlayer mp, int what, int extra) {
                Log.v("UnitPageActivity", "onError " + what + " " + extra);
                Log.v("UnitPageActivity", "NetworkMonitor onError");
//                Toast.makeText(UnitPageActivity.this, "断开网络连接", Toast.LENGTH_LONG).show();
                int oldState = mStateOfMediaPlayer;
                mStateOfMediaPlayer = STATE_ERROR;
                if (oldState == STATE_STARTED) {
                    Log.v("UnitPageActivity", "disconnect by onError");
                    onKeyCenter();
                }
                return true;
            }

        });
        mMediaPlayer.setOnInfoListener(new MediaPlayer.OnInfoListener() {
            public boolean onInfo(MediaPlayer mp, int what, int extra) {
                Log.v("UnitPageActivity", "Buffer onInfo " + what + " " + extra);
                if (what == MediaPlayer.MEDIA_INFO_BUFFERING_END) {
                    mLoadingProgressBar.setVisibility(View.GONE);
                } else if (what == MediaPlayer.MEDIA_INFO_BUFFERING_START) {
                    mLoadingProgressBar.setVisibility(View.VISIBLE);
                }

                return true;
            }

        });
        mMediaPlayer.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {

            @Override
            public void onSeekComplete(MediaPlayer mp) {
                Log.v("UnitPageActivity", "onSeekComplete ");
            }
        });
        mMediaPlayer
                .setOnCompletionListener(new MediaPlayer.OnCompletionListener() { // 视频播放完成
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        mStateOfMediaPlayer = STATE_PLAYBACK_COMPLETED;


                        finish();
                    }
                });

        mMediaPlayer
                .setOnBufferingUpdateListener(new MediaPlayer.OnBufferingUpdateListener() {
                    @Override
                    public void onBufferingUpdate(MediaPlayer mp, int percent) {
                        Log.v("UnitPageActivity", "Buffer Progress : " + percent + "% "
                                        + percent * mMediaPlayerSeekbar.getMax() / 100 + " "
                                        + mp.getCurrentPosition() + " "
                                        + mMediaPlayerSeekbar.getMax() + " "
                                        + mp.getDuration() + " "
                                        + mp.isPlaying()
                        );
                        mCurVideoPos = mMediaPlayer.getCurrentPosition();
                        if (mStateOfMediaPlayer == STATE_STARTED) {
                            mNetworkMonitor.updatePosition(mCurVideoPos);
                            if (mNetworkMonitor.isBroken()) {
                                Log.v("UnitPageActivity", "NetworkMonitor Broken");
                                Toast.makeText(UnitPageActivity.this, "断开网络连接", Toast.LENGTH_LONG).show();
                                onKeyCenter();
                            }
                        }
                        mMediaPlayerSeekbar.setSecondaryProgress(0);
                    }
                });
    }

    /**
     * 改变视频进度
     */
    private void onProgressSlide() {
        int max = mMediaPlayer.getDuration();
        int gap = 0;
        if (DIRECT == LEFT) {
            gap = -15000;
        } else {
            gap = 15000;
        }
        int pos = mMediaPlayer.getCurrentPosition() + gap;
        if (pos < 0) {
            pos = 0;
        } else if (pos > mMediaPlayer.getDuration()) {
            pos = max;
        }
        Log.e("test", "pos = " + pos);
        mMediaPlayer.seekTo(pos);
        Log.v("UnitPageActivity", "progress mCurVideoPos = " + mMediaPlayer.getCurrentPosition()
                        + "; progress = " + mMediaPlayerSeekbar.getProgress() + " right after seekTo " + pos
        );
        updateMediaPlayerProgress();

    }

    /**
     * 更新进度条的进度
     */
    private void updateMediaPlayerProgress() {
        if (mMediaPlayer == null) {
            mStateOfMediaPlayer = STATE_ERROR;
            mShowMessageHandler.sendEmptyMessage(SHOW_NOTHING);
            return;
        }

        if (mStateOfMediaPlayer == STATE_STARTED || mStateOfMediaPlayer == STATE_PAUSED) {
            mCurVideoPos = mMediaPlayer.getCurrentPosition();
            mMediaPlayerSeekbar.setProgress(
                    mCurVideoPos * mMediaPlayerSeekbar.getMax()
                            / mMediaPlayer.getDuration());

            if (mCurVideoPos > 0) {
                mLastFrameImageView.setVisibility(View.GONE);
            }
            mTotalTime.setText(formatLongToTimeStr(mMediaPlayer.getDuration()));
            mPassTime.setText(formatLongToTimeStr(mMediaPlayer
                    .getCurrentPosition()));

//            saveLastFrame(mCurVideoPos);
            Log.v("UnitPageActivity", "progress mCurVideoPos = " + mCurVideoPos
                            + "; progress = " + mMediaPlayerSeekbar.getProgress()
            );
            updateTvHistory();
        }
    }

    /**
     * 更新时间的Handler
     */
//	Handler mTimeHandler = new Handler() {
//		public void dispatchMessage(Message msg) {
////			if (mTotalTime.getText().equals(mPassTime.getText())) {
////				finish();
////			}
//			updateTime();
//		};
//	};

    /**
     * 滑动改变声音大小
     */
    private void onVolumeSlide() {
        if (mVolume == -1) {
            mVolume = mAudioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
            if (mVolume < 0) {
                mVolume = 0;
            }
        }
        mVolumeBg.setImageResource(R.drawable.video_volumn_bg);
        mVolumeProgressLayout.setVisibility(View.VISIBLE);
        int index = 0;
        if (VOICE_DIRECT == UP) {
            index = ++mVolume;
        } else {
            index = --mVolume;
        }
        if (index > mMaxVolume) {
            index = mMaxVolume;
        } else if (index < 0) {
            index = 0;
        }
        mAudioManager.setStreamVolume(AudioManager.STREAM_MUSIC, index, 0);
        // 变更进度条
        ViewGroup.LayoutParams lp = mOperationPercent.getLayoutParams();
        lp.width = findViewById(R.id.operation_full).getLayoutParams().width
                * index / mMaxVolume;
        mOperationPercent.setLayoutParams(lp);
    }

    /**
     * 手势结束
     */
    private void end() {
        // 隐藏
        mDismissHandler.removeMessages(0);
        mDismissHandler.sendEmptyMessageDelayed(0, 3000);
    }

    /**
     * 更新进度条
     */

    public void onDestroy() {
        Log.v("UnitPageActivity", "onDestroy begin");
        super.onDestroy();
        if (mMediaPlayer.isPlaying()) {
            mMediaPlayer.stop();
        }
        mMediaPlayer.release();
        mMediaPlayer = null;

//        if (mLastFrameTask != null) {
//            mLastFrameTask.cancel(true);
//            mLastFrameTask = null;
//        }
//        if (mMediaMetadataRetriever != null) {
//            mMediaMetadataRetriever.release();
//            mMediaMetadataRetriever = null;
//        }

        if (mNetBroadcastReceiver != null) {
            unregisterReceiver(mNetBroadcastReceiver);
            mNetBroadcastReceiver = null;
        }
        Log.v("UnitPageActivity", "onDestroy end");
    }

    @Override
    protected void onStop() {
        // TODO Auto-generated method stub
        super.onStop();
//		finish();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
//        updateTvHistory();
        if (keyCode == KeyEvent.KEYCODE_POWER) {
//			if (mMediaPlayer.isPlaying()) {
//				mMediaPlayer.pause();
//				iv_play.setVisibility(View.VISIBLE);
//				mBottomStatusBar.setVisibility(View.VISIBLE);
//				mCurVideoPos = mMediaPlayer.getCurrentPosition();
//			}
            return true;
        }


        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // TODO Auto-generated method stub

        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            switch (event.getKeyCode()) {

                case KeyEvent.KEYCODE_ENTER:
                    onKeyCenter();
                    break;
                case KeyEvent.KEYCODE_DPAD_CENTER:
                    onKeyCenter();
                    break;
                case KeyEvent.KEYCODE_DPAD_LEFT:
                    isEnterLeftOrRight = true;
                    mBottomStatusBar.setVisibility(View.VISIBLE);
                    DIRECT = LEFT;
                    onProgressSlide();
                    mDismissHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (!isEnterLeftOrRight) {
                                mBottomStatusBar.setVisibility(View.INVISIBLE);
                            }
                            isEnterLeftOrRight = false;
                        }
                    }, 2000);
                    break;
                case KeyEvent.KEYCODE_DPAD_RIGHT:
                    isEnterLeftOrRight = true;
                    mBottomStatusBar.setVisibility(View.VISIBLE);
                    DIRECT = RIGHT;
                    onProgressSlide();
                    mDismissHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (!isEnterLeftOrRight) {
                                mBottomStatusBar.setVisibility(View.INVISIBLE);
                            }
                            isEnterLeftOrRight = false;
                        }
                    }, 2000);
                    break;
                case KeyEvent.KEYCODE_DPAD_UP:
                    VOICE_DIRECT = UP;
                    onVolumeSlide();
                    end();
                    break;
                case KeyEvent.KEYCODE_DPAD_DOWN:
                    VOICE_DIRECT = DOWN;
                    onVolumeSlide();
                    end();
                    break;
                case KeyEvent.KEYCODE_VOLUME_DOWN:
                    VOICE_DIRECT = DOWN;
                    onVolumeSlide();
                    end();
                    break;
                case KeyEvent.KEYCODE_VOLUME_UP:
                    VOICE_DIRECT = UP;
                    onVolumeSlide();
                    end();
                    break;
                default:
                    break;
            }
        }

        if (event.getAction() == KeyEvent.ACTION_UP) {
            switch (event.getKeyCode()) {
                case KeyEvent.KEYCODE_DPAD_UP:
//				end();
                    break;
                case KeyEvent.KEYCODE_DPAD_DOWN:
//				end();
                    break;
                case KeyEvent.KEYCODE_BACK:
                    mLastFrameImageView.setVisibility(View.VISIBLE);
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            Log.v("UnitPageActivity", "Stop Playing begin");
                            if (mMediaPlayer.isPlaying()) {
                                mMediaPlayer.stop();
                                mStateOfMediaPlayer = STATE_STOPPED;
                            }
                            Log.v("UnitPageActivity", "Stop Playing end media player");

//                        if (mMediaMetadataRetriever != null) {
//                            mMediaMetadataRetriever.release();
//                            mMediaMetadataRetriever = null;
//                        }
                            Log.v("UnitPageActivity", "Stop Playing end");

                            mShowMessageHandler.sendEmptyMessage(SHOW_NOTHING);
                        }
                    }).start();
                    break;
                default:
                    break;
            }
        }
        return true;
    }

    private void updateUI(int state) {
        mLoadingProgressBar.setVisibility(View.GONE);
        iv_course_info_play.setVisibility(View.GONE);

        // switch to new state
        switch (state) {
            case STATE_PAUSED:
                iv_play.setVisibility(View.VISIBLE);
                mBottomStatusBar.setVisibility(View.VISIBLE);
                mLoadingProgressBar.setVisibility(View.GONE);
                break;
            case STATE_STARTED:
                iv_play.setVisibility(View.GONE);
                mPostDelayedHandler.post(mMediaPlayerProgressRunnable);
                mDismissHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mBottomStatusBar.setVisibility(View.INVISIBLE);
                    }
                }, 2000);
                break;
            default:
                iv_course_info_play.setVisibility(View.VISIBLE);
                break;
        }
    }

    private void onKeyCenter() {
        if (mStateOfMediaPlayer == STATE_STARTED) {
            mMediaPlayer.pause();
            mStateOfMediaPlayer = STATE_PAUSED;
            updateUI(STATE_PAUSED);
        } else if (mStateOfMediaPlayer == STATE_PREPARED || mStateOfMediaPlayer == STATE_PAUSED) {
            if (!NetworkUtil.isNetworkAvailable(UnitPageActivity.this)) {
                Log.v("UnitPageActivity", "NetworkMonitor onKeyCenter");
                Toast.makeText(UnitPageActivity.this, "断开网络连接", Toast.LENGTH_LONG).show();
                return;
            }
            mMediaPlayer.seekTo(mCurVideoPos); // 跳到postSize大小位置处进行播放
            mMediaPlayer.start();
            mStateOfMediaPlayer = STATE_STARTED;
            updateUI(STATE_STARTED);

        } else if (mStateOfMediaPlayer == STATE_IDLE) {
            if (!NetworkUtil.isNetworkAvailable(UnitPageActivity.this)) {
                Log.v("UnitPageActivity", "NetworkMonitor onKeyCenter 2");
                Toast.makeText(UnitPageActivity.this, "断开网络连接", Toast.LENGTH_LONG).show();
                return;
            }
            new PlayMovie(mCurVideoPos).start();
            mLoadingProgressBar.setVisibility(View.VISIBLE);
            iv_play.setVisibility(View.GONE);
        } else if (mStateOfMediaPlayer == STATE_ERROR || mStateOfMediaPlayer == STATE_STOPPED) {
            mMediaPlayer.reset();
            mStateOfMediaPlayer = STATE_IDLE;
            mLastFrameImageView.setVisibility(View.VISIBLE);
//            mShowMessageHandler.sendEmptyMessage(SHOW_LOAD_VIDEO_FAIL);
            updateUI(STATE_PAUSED);
        } else {

        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    private void updateTvHistory() {
        TvHistoryInfo info = null;
        try {
            List<TvHistoryInfo> list = DataSource.getDataSourse().findAllTvHistory();
            if (list != null && course != null) {
                for (TvHistoryInfo tvHistoryInfo : list) {
                    if (course.getId() == tvHistoryInfo.getCourseId()) {
                        info = tvHistoryInfo;
                        info.setLastTime(mCurVideoPos);
                        info.setDuationTime(mMediaPlayer.getDuration());
                        DataSource.getDataSourse().updateTvHistory(info);
                        break;
                    }
                }
            }
        } catch (DbException e) {
            Log.d("jack", "error");
            e.printStackTrace();
        }
    }

    private class surFaceView implements Callback { // 上面绑定的监听的事件

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width,
                                   int height) {
            // mSurfaceView.getHolder().setFixedSize(width, height);
            // mMediaPlayer.setDisplay(mSurfaceView.getHolder());
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) { // 创建完成后调用
            onKeyCenter();
//			if (mCurVideoPos > 0 && videoUrl != null) { // 说明，停止过activity调用过pase方法，跳到停止位置播放
//				new PlayMovie(mCurVideoPos).start();
//				int sMax = mMediaPlayerSeekbar.getMax();
//				int mMax = mMediaPlayer.getDuration();
//				mMediaPlayerSeekbar.setProgress(mCurVideoPos * sMax / mMax);
//				mCurVideoPos = 0;
//			} else {
//				new PlayMovie(0).start(); // 表明是第一次开始播放
//			}
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) { // activity调用过pause方法，保存当前播放位置
            if (mMediaPlayer != null && mMediaPlayer.isPlaying()) {
                mCurVideoPos = mMediaPlayer.getCurrentPosition();
                mMediaPlayer.stop();
                mStateOfMediaPlayer = STATE_STOPPED;
            }
        }
    }

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
                // mMediaPlayer.reset(); // 回复播放器默认
//                saveLastFrame(mCurVideoPos);
                mMediaPlayer.setDataSource(videoUrl); // 设置播放路径
                mStateOfMediaPlayer = STATE_INITIALIZED;
                mMediaPlayer.setDisplay(mSurfaceView.getHolder()); // 把视频显示在SurfaceView上
                mMediaPlayer.setOnPreparedListener(new mPreparedListener(
                        mCurVideoPos)); // 设置监听事件
                mMediaPlayer.prepareAsync(); // 准备播放
                mPostDelayedHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (mStateOfMediaPlayer == STATE_INITIALIZED) {
                            mMediaPlayer.reset();
                            mStateOfMediaPlayer = STATE_IDLE;
                            mLastFrameImageView.setVisibility(View.VISIBLE);
                            Toast.makeText(UnitPageActivity.this, "网络速度太慢，请重试！", Toast.LENGTH_LONG).show();
                            updateUI(STATE_PAUSED);
                        }
                    }
                }, 3000);
            } catch (Exception e) {
                e.printStackTrace();
                message.what = 2;
                mShowMessageHandler.sendEmptyMessage(SHOW_LOAD_VIDEO_FAIL);
            }
            super.run();
        }
    }

    class mPreparedListener implements OnPreparedListener {
        int curVideoPos;

        public mPreparedListener(int curVideoPos) {
            this.curVideoPos = curVideoPos;
        }

        @Override
        public void onPrepared(MediaPlayer mp) {
            mStateOfMediaPlayer = STATE_PREPARED;

            onKeyCenter();
//            mTimer.schedule(mTimerTask, 0, 1000);
//			mBottomStatusBar.setVisibility(View.GONE);
//			isDisplayButton = false;
//			if (mMediaPlayer != null) {
//				mMediaPlayer.start(); // 开始播放视频
//                mStateOfMediaPlayer = STATE_STARTED;
//			} else {
//				return;
//			}
//			if (curVideoPos > 0) { // 说明中途停止过（activity调用过pase方法，不是用户点击停止按钮），跳到停止时候位置开始播放
//				Log.i("hck", "seekTo ");
//				mMediaPlayer.seekTo(curVideoPos); // 跳到postSize大小位置处进行播放
//			}
//
//			int position = 0;
//
//			if (mCurVideoPos == 0) {
//				mMediaPlayerSeekbar.setProgress(0);
//			} else {
//				position = mMediaPlayer.getCurrentPosition();
//				int mMax = mMediaPlayer.getDuration();
//				int sMax = mMediaPlayerSeekbar.getMax();
//				mMediaPlayerSeekbar.setProgress(position * sMax / mMax);
//			}
//			mLoadingProgressBar.setVisibility(View.GONE);
//			iv_course_info_play.setVisibility(View.GONE);
        }
    }

//    private void saveLastFrame(final int currentPos) {
//        if (mLastFrameTask != null || mMediaMetadataRetriever == null) {
//            return;
//        }
//        final int preloadPos = currentPos + mOffsetPos;
//        mLastFrameTask = new AsyncTask<Void, Void, Bitmap>(){
//            protected Bitmap doInBackground(Void... urls) {
//                return mMediaMetadataRetriever.getFrameAtTime(preloadPos,
//                        MediaMetadataRetriever.OPTION_CLOSEST);
//            }
//
//
//            protected void onPostExecute(Bitmap result) {
//                if (result == null) {
//                    Log.v("UnitPageActivity", "NetworkStatus disconnect detected by loading frame");
//                    Toast.makeText(UnitPageActivity.this, "网络未连接", Toast.LENGTH_LONG).show();
//                    if (mStateOfMediaPlayer == STATE_STARTED) {
//                        Log.v("UnitPageActivity", "disconnect by loading frame fail");
//                        onKeyCenter();
//                    }
//                    return;
//                }
//                int diff = mCurVideoPos - preloadPos;
//                mOffsetPos += diff;
//                if (mOffsetPos < 1000) {
//                    mOffsetPos = 1000;
//                } else if (mOffsetPos > 8000) {
//                    mOffsetPos = 8000;
//                }
//                Log.v("UnitPageActivity", "LastFrame at " + (preloadPos) +
//                        " offset = " + mOffsetPos +
//                        " diff = " + diff);
//                mLastFrameImage = result;
//                mLastFrameTask = null;
//            }
//        }.execute();
//    }

    class UpdateMediaPlayerProgressRunnable implements Runnable {

        @Override
        public void run() {
            mUpdateMediaPlayerProgressHandler.sendMessage(Message.obtain());
            if (mStateOfMediaPlayer == STATE_STARTED) {
                mPostDelayedHandler.postDelayed(this, 1000);
            }
        }
    }

    private class NetworkMonitor {
        private final int THRESHOLD_REPEAT = 60;
        private int currentPos = 0;
        private int currentPosRepeat = 0;
        private long startTimeRepaet = 0;

        private long currentTime() {
            return System.currentTimeMillis() / 1000;
        }

        public void updatePosition(int pos) {
            if (pos == currentPos) {
                currentPosRepeat++;
            } else {
                currentPos = pos;
                currentPosRepeat = 1;
                startTimeRepaet = currentTime();
            }
        }

        public boolean isBroken() {
            boolean isBroken = (currentPosRepeat > THRESHOLD_REPEAT) && currentPos != 0 &&
                    (currentTime() - startTimeRepaet) > 6;
            if (isBroken) {
                currentPosRepeat = 0;
                startTimeRepaet = currentTime();
            }
            return isBroken;
        }
    }

    class NetBroadcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {


            // 获得网络连接服务
            ConnectivityManager connManager = (ConnectivityManager) context
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo.State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
                    .getState(); // 获取网络连接状态
            // 判断是否正在使用WIFI网络
            Log.v("NetBroadcastReceiver", "网络状态改变 " + state);
            if (NetworkUtil.isNetworkAvailable(context) &&
                    (mStateOfMediaPlayer == STATE_PAUSED)) {
                onKeyCenter();
            } else if (NetworkInfo.State.CONNECTED != state && mStateOfMediaPlayer == STATE_STARTED) {
                Toast.makeText(context, "网络未连接", Toast.LENGTH_LONG).show();
                Log.v("UnitPageActivity", "disconnect by NetworkInfo");
                onKeyCenter();
            }
        }
    }
}
