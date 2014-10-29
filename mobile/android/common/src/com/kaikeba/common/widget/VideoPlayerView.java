package com.kaikeba.common.widget;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.*;
import android.widget.*;
import com.kaikeba.common.R;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.PostVideoPlayHistory;
import com.kaikeba.common.entity.VideoPlayHistory;
import com.kaikeba.common.listeners.OrientationSensorListener;
import com.kaikeba.common.util.*;
import com.kaikeba.common.watcher.Watched;
import com.kaikeba.common.watcher.Watcher;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.exception.DbException;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by cwang on 14-7-14.
 */
public class VideoPlayerView extends FrameLayout implements Watched {
    public static final int VIDEO_LAYOUT_ORIGIN = 0;
    public static final int VIDEO_LAYOUT_SCALE = 1;
    private int mVideoLayouts = VIDEO_LAYOUT_SCALE;
    public static final int VIDEO_LAYOUT_STRETCH = 2;
    private static final String TAG = "VideoPlayerView";
    private static final String VIEW = "view";
    private static final String SEEKTO = "seekto";
    private static final String SEEKFROM = "seekfrom";
    public boolean isScaleTag = false;
    public BitmapUtils bitmapUtils;
    public OnTouchListener onTouchListener = new OnTouchListener() {
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
    /**
     * 视频播放地址
     */
    String url;
    GestureDetector mGestureDetector;
    MediaPlayer mMediaPlayer;
    Button mPlayButton, mScaleButton;
    SurfaceView mSurfaceView;
    RelativeLayout rv_controll;
    ProgressBar progressBar;
    RelativeLayout rel_loading;
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
    boolean has_play = false;
    /**
     * 播放的进度条
     */
    SeekBar mSeekbar;
    /**
     * 用于是否显示其他按钮
     */
    boolean isDisplayButton;
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
    //	LinearLayout mLeftLL;
    FrameLayout mVideoFrameLayout;
    int windowWidth, windowHeight;
    //	ScrollView mScrollView;
    Timer mTimer;
    TimerTask mTimerTask;
    int videoHeight;
    int videoWith;
    PlayMovie playMovieThread;
    /**
     * 更新时间的Handler
     */
    Handler mTimeHandler = new Handler() {
        public void dispatchMessage(Message msg) {
            updateTime();
        }

        ;
    };
    private Context mContext;
    private RelativeLayout rel_iv_course_info_play;
    private ImageView iv_course_info_play;
    private ImageView iv_play;
    private View mRoot;
    //***********************************播放器相关**************************************//
    private TextView mTotalTime;
    private TextView mPassTime;
    private List<CourseModel.Items> videoInfos = null;
    private int position;
    private String imgUrl;
    private TextView loading_info;
    //***********************************播放器相关**************************************//
    private VideoPlayHistory videoPlayHistory;
    private PostVideoPlayHistory postVideoPlayHistory;
    private int lms_courseId;
    private int lastVideoId;
    private ArrayList<PostVideoPlayHistory.ViewPeriod> viewPeriods;
    private PostVideoPlayHistory.ViewPeriod viewPeriod;
    private int totalVideoLen;
    //    重力传感用
    private OrientationSensorListener listener;
    private SensorManager sm;
    private Sensor sensor;
    private VideoBrodcastReceiver videoBrodcastReceiver;

    //***********************************播放器相关**************************************//
    private boolean isEnterLeftOrRight = false;
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
    private int mVideoWidth;
    private int mVideoHeight;
    private float mVideoAspectRatio;
    private int mSurfaceWidth;
    private int mSurfaceHeight;
    private float mAspectRatio = 0;
    private boolean isZoomIn = false;
    private boolean isZoomOut = false;
    private boolean isChanged = false;
    private Watcher watcher;
    private boolean isPause = false;
    Handler changeOrientationHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == Constants.GRIVITY_INTERACTION) {
                int orientation = msg.arg1;
                if (!isPause) {
                    if (orientation > 45 && orientation < 135) {
                        if (isZoomOut) {
                            zoomOppositeIn();
                            isZoomOut = false;
                        }
                        isZoomIn = true;
                    } else if (orientation > 135 && orientation < 225) {
                        if (isZoomIn) {
                            zoomOut();
                            isZoomIn = false;
                        }
                        isZoomOut = true;
                    } else if (orientation > 225 && orientation < 315) {
                        if (isZoomOut) {
                            zoomIn();
                            isZoomOut = false;
                        }
                        isZoomIn = true;
                    } else if ((orientation > 315 && orientation < 360) || (orientation > 0 && orientation < 45)) {
                        if (isZoomIn) {
                            zoomOut();
                            isZoomIn = false;
                        }
                        isZoomOut = true;
                    }
                }
            }
            super.handleMessage(msg);
        }
    };
    private OnClickListener playClickListener;

    public VideoPlayerView(Context context) {
        super(context);
        this.mContext = context;
//        makeControllerView(context);
        setBroadcastReceiver();
    }

    public VideoPlayerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mContext = context;
//        makeControllerView(context);
    }

    public VideoPlayerView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.mContext = context;
//        makeControllerView(context);
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

    private void setBroadcastReceiver() {
        if(!Constants.PLAY_VIDEO_FROM_LOCAL){
            videoBrodcastReceiver = new VideoBrodcastReceiver();
            IntentFilter filter = new IntentFilter();
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
            mContext.registerReceiver(videoBrodcastReceiver, filter);
        }
    }

    public View makeControllerView() {
        ((Activity) mContext).getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        LayoutInflater inflate = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mRoot = inflate.inflate(R.layout.video_player_controller, null);
        videoPlayHistory = new VideoPlayHistory();
        postVideoPlayHistory = new PostVideoPlayHistory();
        viewPeriods = new ArrayList<PostVideoPlayHistory.ViewPeriod>();
        viewPeriod = new PostVideoPlayHistory.ViewPeriod();
//***********************************播放器相关**************************************//
        init(mRoot); // 初始化数据
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        mVideoFrameLayout.measure(w, h);
        videoHeight = mVideoFrameLayout.getMeasuredHeight();
        videoWith = windowWidth;
        mGestureDetector = new GestureDetector(mContext, new MyGestureListener());
        setListener();
        return mRoot;
    }

    /**
     * 播放时需准备的参数
     *
     * @param url          视频链接
     * @param imgUrl       视频介绍图片
     * @param mCurVideoPos 视频播放位置
     * @param lms_courseId 班次ID
     * @param lastVideoId  视频ID
     *                     每次播放视频调用play()前  需设置各种参数
     *                     从动态页等跳转单品页时，需传这几个参数直接播放
     */
    public void preparePlayData(String url, String imgUrl, int mCurVideoPos, int lms_courseId, int lastVideoId) {
        this.url = url;
        this.imgUrl = imgUrl;
        this.mCurVideoPos = mCurVideoPos;
        this.lms_courseId = lms_courseId;
        this.lastVideoId = lastVideoId;
    }

    public void preparePlayData(List<CourseModel.Items> videoInfos, int position, String imgUrl, int mCurVideoPos, int lms_courseId) {
        this.videoInfos = videoInfos;
        this.position = position;
        this.url = videoInfos.get(position).getUrl();
        this.imgUrl = imgUrl;
        this.mCurVideoPos = mCurVideoPos;
        this.lms_courseId = lms_courseId;
        this.lastVideoId = videoInfos.get(position).getId();
    }

    /**
     * 初始化数据
     */
    private void init(View v) {
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext.getApplicationContext());
        mMediaPlayer = new MediaPlayer(); // 创建一个播放器对象
        rel_iv_course_info_play = (RelativeLayout) v.findViewById(R.id.rel_iv_course_info_play);
        iv_course_info_play = (ImageView) v.findViewById(R.id.iv_course_info_play);
        mPlayButton = (Button) v.findViewById(R.id.play);
        mPlayButton.setBackgroundResource(R.drawable.play);
        mScaleButton = (Button) v.findViewById(R.id.scale);
        mSeekbar = (SeekBar) v.findViewById(R.id.seekbar);
        mSurfaceView = (SurfaceView) v.findViewById(R.id.surfaceView);
        rel_loading = (RelativeLayout) v.findViewById(R.id.rel_loading);
        progressBar = (ProgressBar) v.findViewById(R.id.progressBar);
        iv_play = (ImageView) v.findViewById(R.id.iv_play);
        mTotalTime = (TextView) v.findViewById(R.id.time_totle);
        mPassTime = (TextView) v.findViewById(R.id.time_play);
        loading_info = (TextView) v.findViewById(R.id.loading_info);
        mSurfaceView.getHolder().setKeepScreenOn(true); // 保持屏幕高亮
        mSurfaceView.getHolder().addCallback(new surFaceView()); // 设置监听事件
        rv_controll = (RelativeLayout) v.findViewById(R.id.rv_controll);
        mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
        mMaxVolume = mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        mOperationBg = (ImageView) v.findViewById(R.id.operation_bg);
        mOperationPercent = (ImageView) v.findViewById(R.id.operation_percent);
        mVolumeProgressLayout = v.findViewById(R.id.operation_volume_brightness);

        mVideoFrameLayout = (FrameLayout) v.findViewById(R.id.surfaceView_framelayout);
        Display disp = ((Activity) mContext).getWindowManager().getDefaultDisplay();
        windowWidth = disp.getWidth();
        windowHeight = disp.getHeight();
        rv_controll.setVisibility(View.GONE);
        bitmapUtils.display(iv_course_info_play, imgUrl);
    }

    private void setLoadingListener() {
        //拖动进度条到最后时,由于视频进度与实际进度不等,导致mMediaPlayer为空
        //当为空时处理为直接return
        if (null != mMediaPlayer) {
            mMediaPlayer.setOnInfoListener(new MediaPlayer.OnInfoListener() {
                public boolean onInfo(MediaPlayer mp, int what, int extra) {
                    Log.v("UnitPageActivity", "Buffer onInfo " + what + " " + extra);
                    if (what == MediaPlayer.MEDIA_INFO_BUFFERING_END) {
                        rel_loading.setVisibility(View.GONE);
                        rv_controll.setVisibility(View.VISIBLE);
                    } else if (what == MediaPlayer.MEDIA_INFO_BUFFERING_START || what == MediaPlayer.MEDIA_INFO_METADATA_UPDATE || what == 703) {
                        rel_loading.setVisibility(View.VISIBLE);
                        rv_controll.setVisibility(View.GONE);
                    }
                    return true;
                }

            });
        } else {
            return;
        }
    }

    private void setListener() {
        mVideoFrameLayout.setOnTouchListener(onTouchListener);
        mMediaPlayer
                .setOnBufferingUpdateListener(new MediaPlayer.OnBufferingUpdateListener() {
                    @Override
                    public void onBufferingUpdate(MediaPlayer mp, int percent) {
                        Log.d("sjyin","player is updating");
                    }
                });

        mMediaPlayer
                .setOnCompletionListener(new MediaPlayer.OnCompletionListener() { // 视频播放完成
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        isPlayTag = false;
                        mPlayButton.setBackgroundResource(R.drawable.play);
                        Log.d("jack", "mediaplayer:" + "ok");
                    }
                });

        mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                Log.d("jack", "mediaplayer:" + "ing");
            }
        });
        setLoadingListener();
        mMediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                iv_play.setVisibility(View.VISIBLE);
                progressBar.setVisibility(View.GONE);
                rel_loading.setVisibility(View.VISIBLE);
                rv_controll.setVisibility(View.GONE);
                loading_info.setText("数据加载错误,点击重新播放");
                return true;
            }
        });
        /**
         * 如果视频在播放，则调用mediaPlayer.pause();，停止播放视频，反之，mediaPlayer.start()
         * ，同时换按钮背景
         */
        mPlayButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                playOrPause();
            }
        });
        mSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (mMediaPlayer != null) {
                    int value = mSeekbar.getProgress() * mMediaPlayer.getDuration() // 计算进度条需要前进的位置数据大小
                            / mSeekbar.getMax();
                    mMediaPlayer.seekTo(value);
                    viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                    viewPeriod.setAction(SEEKTO);
                    viewPeriod.setVtime(getDuration());
                    viewPeriods.add(viewPeriod);
                    updateTime();
//                    setLoadingListener();
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(VIEW);
                viewPeriod.setVtime(getDuration());
                viewPeriods.add(viewPeriod);
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(SEEKFROM);
                viewPeriod.setVtime(getDuration());
                viewPeriods.add(viewPeriod);
            }

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress,
                                          boolean fromUser) {

            }
        });
        if (!Constants.FULL_SCREEN_ONLY) {
            mScaleButton.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View arg0) {
                    if (isScaleTag) {
                        zoomOut();
                    } else {
                        zoomIn();
                    }
                }
            });
        } else {
            mScaleButton.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View arg0) {
                    ((Activity) mContext).finish();
                }
            });
        }
        iv_play.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(final View view) {
                if (!Constants.PLAY_VIDEO_FROM_LOCAL) {
                    if (NetUtil.getNetType(mContext) == Constants.NO_NET) {
                        KKDialog.getInstance().showNoNetPlayDialog(mContext);
                    } else {
                        if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(mContext)) {
                            KKDialog.getInstance().showNoWifi2Play(mContext,
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            Constants.nowifi_doplay = false;
                                            KKDialog.getInstance().dismiss();
                                            if (videoInfos != null && watcher != null) {
                                                watcher.update(0);
                                            }
                                            play(mCurVideoPos);
                                            playBtnClick(view);
                                            isChanged = true;
                                        }
                                    },
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            isChanged = false;
                                        }
                                    });
                        } else if (has_play) {
                            playOrPause();
                        } else {
                            if (videoInfos != null && watcher != null) {
                                watcher.update(0);
                            }
                            play(mCurVideoPos);
                            playBtnClick(view);
                        }
                    }
                } else {
                    if (has_play) {
                        playOrPause();
                    } else {
                        play(mCurVideoPos);
                    }
                }
            }
        });
    }

    public void playOrPause() {
        if (mMediaPlayer != null) {
            if (mMediaPlayer.isPlaying()) {
                mPlayButton.setBackgroundResource(R.drawable.stop);
                mMediaPlayer.pause();
                mCurVideoPos = mMediaPlayer.getCurrentPosition();
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(VIEW);
                viewPeriod.setVtime(getDuration());
                viewPeriods.add(viewPeriod);
                iv_play.setVisibility(View.VISIBLE);
                rel_iv_course_info_play.setVisibility(View.VISIBLE);
                iv_course_info_play.setVisibility(View.GONE);
                mDismissRV_Controll(10);
                has_play = true;
            } else {
                if (isPlayTag == false) {
                    isPlayTag = true;
                    new Thread(mUpdateSeekBarThread).start();
                }
                has_play = false;
                mMediaPlayer.start();
                mPlayButton.setBackgroundResource(R.drawable.play);
                iv_play.setVisibility(View.GONE);
                rel_iv_course_info_play.setVisibility(View.GONE);
                rv_controll.setVisibility(View.VISIBLE);
                isPause = false;
            }
        }
    }

    public void pauseMediaPlayer() {
        if (mMediaPlayer != null) {
            if (mMediaPlayer.isPlaying()) {
                mPlayButton.setBackgroundResource(R.drawable.stop);
                mMediaPlayer.pause();
                mCurVideoPos = mMediaPlayer.getCurrentPosition();
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(VIEW);
                viewPeriod.setVtime(getDuration());
                viewPeriods.add(viewPeriod);
                iv_play.setVisibility(View.VISIBLE);
                rel_iv_course_info_play.setVisibility(View.VISIBLE);
                iv_course_info_play.setVisibility(View.GONE);
                mDismissRV_Controll(10);
                has_play = true;
                isPause = true;
            }
        }
    }

    private void stopMediaPlayer() {
        if (mMediaPlayer.isPlaying()) {
            mPlayButton.setBackgroundResource(R.drawable.stop);
            mMediaPlayer.pause();
            mCurVideoPos = mMediaPlayer.getCurrentPosition();
        }
    }

    /**
     * 公开课播放课程简介enroll课程
     * @param v
     */
    private void playBtnClick(View v){
        if(playClickListener != null){
            playClickListener.onClick(v);
            playClickListener = null;
        }
    }

    public void play(int mCurVideoPos) {
        onDestroy();
        playMovie(mCurVideoPos);
        rel_loading.setVisibility(View.VISIBLE);
        rv_controll.setVisibility(View.GONE);
        rel_iv_course_info_play.setVisibility(View.GONE);
        iv_play.setVisibility(View.GONE);// 表明是第一次开始播放
    }

    public void playMovie(int mCurVideoPos) {
        unregisterReceiver();
        setBroadcastReceiver();
        isPlayTag = true;
        has_play = false;
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setDisplay(mSurfaceView.getHolder()); // 把视频显示在SurfaceView上
        //重力感应
        if (!Constants.FULL_SCREEN_ONLY) {
            sm = (SensorManager) ((Activity) mContext).getSystemService(Context.SENSOR_SERVICE);
            sensor = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            listener = new OrientationSensorListener(changeOrientationHandler);
            sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_UI);
        }
        mTimer = new Timer();
        mTimerTask = new TimerTask() {

            @Override
            public void run() {
                updateProgressBar();
                mTimeHandler.sendEmptyMessage(1);
            }
        };
        mTimer.schedule(mTimerTask, 0, 10);
        try {
//            mMediaPlayer.reset(); // 回复播放器默认
            mMediaPlayer.setDataSource(url); // 设置播放路径
            mMediaPlayer.prepareAsync(); // 准备播放
            setLoadingListener();
            mMediaPlayer.setOnPreparedListener(new mPreparedListener(mCurVideoPos)); // 设置监听事件
        } catch (Exception e) {

            e.printStackTrace();
        }

    }

    /**
     * 滑动改变视频进度
     *
     * @param percent
     */
    private void onProgressSlide(float percent) {
        if (mMediaPlayer != null) {
            if (rv_controll.getVisibility() == View.GONE && rel_iv_course_info_play.getVisibility() != VISIBLE) {
                rv_controll.setVisibility(View.VISIBLE);
                isDisplayButton = true;
            }
            int max = mMediaPlayer.getDuration();
            int gap = (int) (max * percent * 0.05);
            int pos = mMediaPlayer.getCurrentPosition() + gap;
            if (pos < 0) {
                pos = 0;
            } else if (pos > mMediaPlayer.getDuration()) {
                pos = max;
            }
            viewPeriod = new PostVideoPlayHistory.ViewPeriod();
            viewPeriod.setAction(VIEW);
            viewPeriod.setVtime(getDuration());
            viewPeriods.add(viewPeriod);
            viewPeriod = new PostVideoPlayHistory.ViewPeriod();
            viewPeriod.setAction(SEEKFROM);
            viewPeriod.setVtime(getDuration());
            viewPeriods.add(viewPeriod);
            viewPeriod = new PostVideoPlayHistory.ViewPeriod();
            viewPeriod.setAction(SEEKTO);
            viewPeriod.setVtime(pos / 1000);
            viewPeriods.add(viewPeriod);
            Log.e("test", "percent = " + percent);
            Log.e("test", "pos = " + pos);
            mMediaPlayer.seekTo(pos);
            updateProgressBar();
            updateTime();
//            setLoadingListener();
        }

    }

    public int getDuration() {
        int duration = 0;
        if (mMediaPlayer != null) {
            duration = mMediaPlayer.getCurrentPosition() / 1000;
        }
        return duration;
    }

    public int getTotalDuration() {
        int duration = 0;
        if (mMediaPlayer != null) {
            duration = mMediaPlayer.getDuration() / 1000;
        }
        return duration;
    }

    /**
     * 更新进度条的进度
     */
    private void updateProgressBar() {
        if (null != mMediaPlayer) {
            if (!mMediaPlayer.isPlaying()) {
                return;
            }
            int position = mMediaPlayer.getCurrentPosition();
            if (mMediaPlayer != null) {
                int mMax = mMediaPlayer.getDuration();
                int sMax = mSeekbar.getMax();
                if (sMax > 0) {
                    mSeekbar.setProgress(position * sMax / mMax);
                }
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
        lp.width = mRoot.findViewById(R.id.operation_full).getLayoutParams().width * index / mMaxVolume;
        mOperationPercent.setLayoutParams(lp);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        return super.dispatchKeyEvent(event);
    }

    //    @Override
//    public boolean dispatchKeyEvent(KeyEvent event) {
//        // TODO Auto-generated method stub
//
//        if (event.getAction() == KeyEvent.ACTION_DOWN) {
//            switch (event.getKeyCode()) {
//
//                case KeyEvent.KEYCODE_DPAD_LEFT:
//                    isEnterLeftOrRight = true;
//                    rv_controll.setVisibility(View.VISIBLE);
//                    DIRECT = LEFT;
//                    mDismissHandler.postDelayed(new Runnable() {
//                        @Override
//                        public void run() {
//                            if (!isEnterLeftOrRight) {
//                                rv_controll.setVisibility(View.INVISIBLE);
//                            }
//                            isEnterLeftOrRight = false;
//                        }
//                    }, 2000);
//                    break;
//                case KeyEvent.KEYCODE_DPAD_RIGHT:
//                    isEnterLeftOrRight = true;
//                    rv_controll.setVisibility(View.VISIBLE);
//                    DIRECT = RIGHT;
//                    mDismissHandler.postDelayed(new Runnable() {
//                        @Override
//                        public void run() {
//                            if (!isEnterLeftOrRight) {
//                                rv_controll.setVisibility(View.INVISIBLE);
//                            }
//                            isEnterLeftOrRight = false;
//                        }
//                    }, 2000);
//                    break;
//            }
//        }
//
//        if (event.getAction() == KeyEvent.ACTION_UP) {
//            switch (event.getKeyCode()) {
//                case KeyEvent.KEYCODE_DPAD_UP:
////				end();
//                    break;
//                case KeyEvent.KEYCODE_DPAD_DOWN:
////				end();
//                    break;
//                case KeyEvent.KEYCODE_BACK:
//                    new Thread(new Runnable() {
//                        @Override
//                        public void run() {
//                            Log.v("UnitPageActivity", "Stop Playing begin");
//                            if (mMediaPlayer.isPlaying()) {
//                                mMediaPlayer.stop();
//                            }
//                            Log.v("UnitPageActivity", "Stop Playing end media player");
//
////                        if (mMediaMetadataRetriever != null) {
////                            mMediaMetadataRetriever.release();
////                            mMediaMetadataRetriever = null;
////                        }
//                            Log.v("UnitPageActivity", "Stop Playing end");
//
//                        }
//                    }).start();
//                    break;
//                default:
//                    break;
//            }
//        }
//        return true;
//    }
    private void mDismissRV_Controll(long time) {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                rv_controll.setVisibility(View.GONE);
                isDisplayButton = false;
            }
        }, time);
    }

    /**
     * 手势结束
     */
    private void endGesture() {
        mVolume = -1;

        // 隐藏
        mDismissHandler.removeMessages(0);
        mDismissHandler.sendEmptyMessageDelayed(0, 500);
        mDismissRV_Controll(8000);
    }

    public void unregisterReceiver() {
        if (videoBrodcastReceiver != null) {
            mContext.unregisterReceiver(videoBrodcastReceiver);
            videoBrodcastReceiver = null;
        }
        if (sm != null) {
            sm.unregisterListener(listener);
        }
    }

    public void onDestroy() {
        rel_iv_course_info_play.setVisibility(VISIBLE);
        rel_loading.setVisibility(View.GONE);
        iv_play.setVisibility(View.VISIBLE);
        if (mTimer != null) {
            mTimer.cancel();
        }
        if (mMediaPlayer != null) {
            isPlayTag = false;
            if (mMediaPlayer.isPlaying()) {
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(VIEW);
                viewPeriod.setVtime(getDuration());
                viewPeriods.add(viewPeriod);
                totalVideoLen = getTotalDuration();
                mMediaPlayer.stop();
                if (API.getAPI().alreadySignin()) {
                    if (lms_courseId != 0 && lastVideoId != 0) {
                        videoPlayHistory.setUserId(API.getAPI().getUserObject().getId());
                        videoPlayHistory.setCourseId(lms_courseId);
                        videoPlayHistory.setLastVideoId(lastVideoId);
                        videoPlayHistory.setDuration(getDuration());
                        postVideoPlayHistory = new PostVideoPlayHistory(API.getAPI().getUserObject().getEmail(), lms_courseId, lastVideoId, totalVideoLen, viewPeriods);
                        new Thread(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    UploadData.getInstance().addDbData(mContext, postVideoPlayHistory, "playRecord");
                                    UploadData.getInstance().upload(mContext);
                                    if (viewPeriods != null) {
                                        viewPeriods.clear();
                                    }
                                    if (DataSource.getDataSourse().IsExistAtVideoPlayHistory(videoPlayHistory)) {
                                        if (getDuration() != getTotalDuration()) {
                                            DataSource.getDataSourse().updateVideoPlayHistory(videoPlayHistory);
                                        } else {
                                            DataSource.getDataSourse().deleteVideoPlayHistory(videoPlayHistory);
                                        }
                                    }
                                } catch (DbException e) {

                                }
                            }
                        }).start();
                    }
                }
            }
            mMediaPlayer.reset();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
    }

    private void updateTime() {
        if (mMediaPlayer != null) {
            mTotalTime.setText(formatLongToTimeStr(mMediaPlayer.getDuration()));
            mPassTime.setText(formatLongToTimeStr(mMediaPlayer.getCurrentPosition()));
            if (getDuration() == getTotalDuration() && getTotalDuration() != 0) {
                if (videoInfos != null && videoInfos.size() - 1 > position) {
                    position = position + 1;
                    url = videoInfos.get(position).getUrl();
                    notifyWatchers(videoInfos.get(position).getId());
                    play(0);
                } else {
                    onDestroy();
                }
                Log.d("jack", "destory");
            }
        }
    }

    private void zoomOut() {
        //缩小
        ((Activity) mContext).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);//竖屏

        Log.i(TAG, "设置成竖屏");
        WindowManager.LayoutParams attrs = ((Activity) mContext).getWindow().getAttributes();
        attrs.flags &= (~WindowManager.LayoutParams.FLAG_FULLSCREEN);
        ((Activity) mContext).getWindow().setAttributes(attrs);
        ((Activity) mContext).getWindow().clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);

        isScaleTag = false;
    }

    private void zoomIn() {
        //TODO 放大
        ((Activity) mContext).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);//横屏
        Log.i(TAG, "设置成横屏");
        WindowManager.LayoutParams attrs = ((Activity) mContext).getWindow().getAttributes();
        attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
        ((Activity) mContext).getWindow().setAttributes(attrs);
        ((Activity) mContext).getWindow().addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        isScaleTag = true;
    }

    private void zoomOppositeIn() {
        //TODO 相反放大
        ((Activity) mContext).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);//横屏
        Log.i(TAG, "设置成相反横屏");
        WindowManager.LayoutParams attrs = ((Activity) mContext).getWindow().getAttributes();
        attrs.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
        ((Activity) mContext).getWindow().setAttributes(attrs);
        ((Activity) mContext).getWindow().addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        isScaleTag = true;
    }

    public void onBackPressed() {
        if (isScaleTag) {
            zoomOut();
        }
    }

    public void setVideoLayout(int layout, float aspectRatio, int height) {
        int stateHeight = CommonUtils.getStatusBarHeight(mContext);
        ViewGroup.LayoutParams lp = mSurfaceView.getLayoutParams();
        ViewGroup.LayoutParams frameLp = mVideoFrameLayout.getLayoutParams();
        DisplayMetrics disp = mContext.getResources().getDisplayMetrics();
        int windowWidth = disp.widthPixels, windowHeight = disp.heightPixels;
        float windowRatio = windowWidth / (float) windowHeight;
        float videoRatio = aspectRatio <= 0.01f ? mVideoAspectRatio : aspectRatio;
        if (VIDEO_LAYOUT_ORIGIN == layout) {
            lp.width = videoWith;
            lp.height = height;
            frameLp.width = videoWith;
            frameLp.height = height;
            mSurfaceWidth = videoWith;
            mSurfaceHeight = height;
        } else {
            boolean full = layout == VIDEO_LAYOUT_STRETCH;
            lp.width = (full || windowRatio < videoRatio) ? windowWidth : (int) (videoRatio * windowHeight);
            lp.height = (full || windowRatio > videoRatio) ? windowHeight : (int) (windowWidth / videoRatio);
            frameLp.width = lp.width;
            frameLp.height = lp.height;
            mSurfaceHeight = mVideoHeight;
            mSurfaceWidth = mVideoWidth;
        }
        mSurfaceView.setLayoutParams(lp);
        mSurfaceView.getHolder().setFixedSize(mSurfaceWidth, mSurfaceHeight);
        mVideoLayouts = layout;
        mAspectRatio = aspectRatio;
        mVideoFrameLayout.setLayoutParams(frameLp);
    }

    public void screenChange(Configuration newConfig, int height) {
        if (mContext.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setVideoLayout(VideoPlayerView.VIDEO_LAYOUT_STRETCH, 0, height);
        } else if (mContext.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            setVideoLayout(VideoPlayerView.VIDEO_LAYOUT_ORIGIN, 0, height);
        }
    }

    @Override
    public void addWatcher(Watcher watcher) {
        this.watcher = watcher;
    }

    @Override
    public void removeWatcher(Watcher watcher) {
    }

    @Override
    public void notifyWatchers(Object obj) {
        if (watcher != null) {
            watcher.update(obj);
        }
    }

    public void setOnPlayClickListener( OnClickListener playClickListener) {
        this.playClickListener = playClickListener;
    }

    private class surFaceView implements SurfaceHolder.Callback { // 上面绑定的监听的事件

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width,
                                   int height) {
//			mSurfaceView.getHolder().setFixedSize(width, height);
//			mMediaPlayer.setDisplay(mSurfaceView.getHolder());
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) { // 创建完成后调用
            onDestroy();
            if (Constants.isFromDynamicTop || (mCurVideoPos > 0 && url != null)) { // 说明，停止过activity调用过pase方法，跳到停止位置播放
                Constants.isFromDynamicTop = false;
                play(mCurVideoPos);
                isPlayTag = true;
                int sMax = mSeekbar.getMax();
                int mMax = mMediaPlayer.getDuration();
                mSeekbar.setProgress(mCurVideoPos * sMax / mMax);
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(SEEKFROM);
                viewPeriod.setVtime(0);
                viewPeriods.add(viewPeriod);
                viewPeriod = new PostVideoPlayHistory.ViewPeriod();
                viewPeriod.setAction(SEEKTO);
                viewPeriod.setVtime(mCurVideoPos);
                viewPeriods.add(viewPeriod);
            } else if (API.getAPI().alreadySignin() && !Constants.PLAY_VIDEO_FROM_LOCAL) {
                if (lms_courseId != 0 && lastVideoId != 0) {
                    try {
                        videoPlayHistory.setUserId(API.getAPI().getUserObject().getId());
                        videoPlayHistory.setCourseId(lms_courseId);
                        videoPlayHistory.setLastVideoId(lastVideoId);
                        videoPlayHistory.setDuration(getDuration());
                        if (!DataSource.getDataSourse().IsExistAtVideoPlayHistory(videoPlayHistory)) {
                            DataSource.getDataSourse().saveVideoPlayHistory(videoPlayHistory);
                        } else {
                            videoPlayHistory = DataSource.getDataSourse().selectVideoPlayHistory(lastVideoId);
                            if (videoPlayHistory != null && videoPlayHistory.getDuration() != 0) {
                                isPlayTag = true;
                                play(videoPlayHistory.getDuration() * 1000);
                            }
                        }
                    } catch (DbException e) {
                    }
                }
            } else if (Constants.PLAY_VIDEO_FROM_LOCAL) {
                play(mCurVideoPos);
                isPlayTag = true;
            }
//			else {
//				play(0); // 表明是第一次开始播放
//			}
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) { // activity调用过pase方法，保存当前播放位置
            Log.e("sssssssss", "surfaceDestroyed");
            if (mMediaPlayer != null && mMediaPlayer.isPlaying()) {
                mCurVideoPos = mMediaPlayer.getCurrentPosition();
            }
            onDestroy();
            rel_iv_course_info_play.setVisibility(VISIBLE);
            rel_loading.setVisibility(View.GONE);
            rv_controll.setVisibility(View.GONE);
            iv_play.setVisibility(View.VISIBLE);
        }

    }

    /**
     * 播放视频的线程
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
                Log.i("hck", "runrun  " + url);
//                mMediaPlayer.reset(); // 回复播放器默认
                mMediaPlayer.setDisplay(mSurfaceView.getHolder()); // 把视频显示在SurfaceView上
                mMediaPlayer.setDataSource(url); // 设置播放路径
                mMediaPlayer.prepareAsync(); // 准备播放
                mMediaPlayer.setOnPreparedListener(new mPreparedListener(mCurVideoPos)); // 设置监听事件
            } catch (Exception e) {
                e.printStackTrace();
                message.what = 2;
                play(mCurVideoPos);
            }
            super.run();
        }
    }

    class mPreparedListener implements MediaPlayer.OnPreparedListener {
        int curVideoPos;

        public mPreparedListener(int curVideoPos) {
            this.curVideoPos = curVideoPos;

        }

        @Override
        public void onPrepared(MediaPlayer mp) {
//            rv_controll.setVisibility(View.GONE);
//			mPlayButton.setVisibility(View.GONE);
            mPlayButton.setEnabled(true);
            isDisplayButton = false;
            if (mMediaPlayer == null)
                return;
            if (curVideoPos > 0) { // 说明中途停止过（activity调用过pause方法，不是用户点击停止按钮），跳到停止时候位置开始播放
                Log.e("ssss", "begin Position = " + curVideoPos);
                mMediaPlayer.seekTo(curVideoPos); // 跳到postSize大小位置处进行播放
            }
            mMediaPlayer.start(); // 开始播放视频

            int position = mMediaPlayer.getCurrentPosition();
            Log.e("ssss", "curVideoPos = " + curVideoPos);
            int mMax = mMediaPlayer.getDuration();
            int sMax = mSeekbar.getMax();
            if (mMax != 0) {
                mSeekbar.setProgress(position * sMax / mMax);
            }
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    rel_iv_course_info_play.setVisibility(View.GONE);
                    rel_loading.setVisibility(View.GONE);
                    rv_controll.setVisibility(View.VISIBLE);
                }
            }, 500);
            mDismissRV_Controll(10000);
            mVideoWidth = mp.getVideoWidth();
            mVideoHeight = mp.getVideoHeight();
            if (mVideoHeight != 0) {
                mVideoAspectRatio = mVideoWidth / mVideoHeight;
            }
        }
    }

    private class MyGestureListener extends GestureDetector.SimpleOnGestureListener {

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
//				mPlayButton.setVisibility(View.GONE);
                rv_controll.setVisibility(View.GONE);
//				mScaleButton.setVisibility(View.GONE);
                isDisplayButton = false;
            } else {
//				mPlayButton.setVisibility(View.VISIBLE);
                if (rel_loading.getVisibility() != View.VISIBLE) {
                    if (rel_iv_course_info_play.getVisibility() != View.VISIBLE) {
                        rv_controll.setVisibility(View.VISIBLE);
                        mSurfaceView.setVisibility(View.VISIBLE);
//				mScaleButton.setVisibility(View.VISIBLE);
                        isDisplayButton = true;
                    }
                }
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
                if (!has_play) {
                    if (Math.abs(disX) > 50 && Math.abs(disY) < 50) {
                        Log.e("Test", "左右滑动");
                        onProgressSlide((x2 - x1) / windowWidth);
                        endGesture();
                    } else if (Math.abs(disY) > 50 && Math.abs(disX) < 50) {
                        Log.e("Test", "上下滑动");
                        onVolumeSlide((y1 - y2) / windowHeight);
                        endGesture();
                    }
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

    public class VideoBrodcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            // 获得网络连接服务
            ConnectivityManager connManager = (ConnectivityManager) context
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            if (!Constants.PLAY_VIDEO_FROM_LOCAL) {
                if (mMediaPlayer != null && mMediaPlayer.isPlaying()) {
                    NetworkInfo info = connManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
                    if (info != null && !isChanged && Constants.nowifi_doplay) {
                        if (NetworkInfo.State.CONNECTED == info.getState()) { // 判断是否正在使用GPRS网络
                            playOrPause();
                            KKDialog.getInstance().showNoWifi2Play(mContext,
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            Constants.nowifi_doplay = false;
                                            KKDialog.getInstance().dismiss();
                                            playOrPause();
                                            isChanged = true;
                                        }
                                    },
                                    new OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            isChanged = false;
                                        }
                                    });
                        }
                    }
                }
            }
        }
    }
}
