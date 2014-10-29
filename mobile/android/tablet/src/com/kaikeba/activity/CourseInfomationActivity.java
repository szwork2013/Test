package com.kaikeba.activity;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.*;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.SurfaceHolder.Callback;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.*;
import com.kaikeba.activity.fragment.CourseArrangeFragment;
import com.kaikeba.activity.fragment.CourseInfomationFragment;
import com.kaikeba.activity.fragment.CourseIntroduceFragment;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.common.widget.InnerScrollView;
import com.kaikeba.phone.R;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class CourseInfomationActivity extends FragmentActivity {

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
    //	LinearLayout mLeftLL;
    FrameLayout mVideoFrameLayout;
    LinearLayout mBigLL;
    int windowWidth, windowHeight;
    //	ScrollView mScrollView;
    Timer mTimer;
    TimerTask mTimerTask;
    int videoHeight;
    int scrollY;
    /**
     * 更新时间的Handler
     */
    Handler mTimeHandler = new Handler() {
        public void dispatchMessage(Message msg) {
            updateTime();
        }

        ;
    };
    private ImageView iv_course_info_play;
    private TextView tvCourseTopName;
    private TextView tvCourseInfo;
    private TextView tvInstructorInfo;
    private TextView tvCourseArrange;
    private TextView courseInfo;
    private TextView instructorInfo;
    private TextView courseArrange;
    private FragmentManager fm;
    private CourseArrangeFragment caf;
    private CourseIntroduceFragment cif;
    private CourseInfomationFragment ciif;
    private Course c;
    private Bundle b;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            int id = v.getId();
            switch (id) {
                case R.id.tv_course_info:
                    Constants.INFO_TAB = Constants.INFO_ONE;
                    hideView(R.id.tv_course_info);
                    scroll_base.smoothScrollTo(0, scrollY);
                    changeBg(v);
                    change_Bg(viewMap.get(v));
                    if (ciif == null) {
                        FragmentTransaction ft1 = fm.beginTransaction();
                        ciif = new CourseInfomationFragment();
                        ciif.setArguments(b);
                        ft1.add(R.id.sv_info_container, ciif);
                        ft1.commit();
                    }
                    break;
                case R.id.tv_instructor_info:
                    hideView(R.id.tv_instructor_info);
                    Constants.INFO_TAB = Constants.INFO_TWO;
                    scroll_base.smoothScrollTo(0, scrollY);
                    changeBg(v);
                    change_Bg(viewMap.get(v));
                    Constants.which = 2;
                    if (cif == null) {
                        FragmentTransaction ft2 = fm.beginTransaction();
                        cif = new CourseIntroduceFragment();
                        cif.setArguments(b);
                        ft2.add(R.id.ll_course_info_container, cif);
                        ft2.commit();
                    }
                    break;
                case R.id.tv_course_arrange:
                    Constants.INFO_TAB = Constants.INFO_THREE;
                    Constants.VIEW_INTO = 1;
                    hideView(R.id.tv_course_arrange);
                    scroll_base.smoothScrollTo(0, scrollY);
                    changeBg(v);
                    change_Bg(viewMap.get(v));
                    if (caf == null) {
                        FragmentTransaction ft3 = fm.beginTransaction();
                        caf = new CourseArrangeFragment();
                        caf.setArguments(b);
                        ft3.add(R.id.ll_course_arrange_container, caf);
                        ft3.commit();
                    }
                    break;
//			case R.id.iv_course_info_play:
//				Intent it = new Intent("com.cooliris.media.MovieView");
//				it.setAction(Intent.ACTION_VIEW);
//				it.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//				Uri data = Uri.parse(c.getPromoVideo());
//				it.setDataAndType(data, "video/mp4");
//				startActivity(it);
//				break;
                case R.id.btn_blank:
                    finish();
                    break;
                case R.id.iv_play:
                    if (!Constants.NET_IS_SUCCESS) {
                        KKDialog.getInstance().showNoNetPlayDialog(CourseInfomationActivity.this);
                    } else {
                        if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(CourseInfomationActivity.this)) {
                            KKDialog.getInstance().showNoWifi2Play(CourseInfomationActivity.this,
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
                    break;
                case R.id.course_info:
                    tvCourseInfo.performClick();
                    change_Bg(v);
                    break;
                case R.id.nstructor_info:
                    tvInstructorInfo.performClick();
                    change_Bg(v);
                    break;
                case R.id.course_arrange:
                    tvCourseArrange.performClick();
                    change_Bg(v);
                    break;
                default:
                    break;
            }
        }
    };
    private LinearLayout ll_course_info_container;
    private LinearLayout ll_course_arrange_container;
    private InnerScrollView sv;
    private View btn_blank;
    //***********************************播放器相关**************************************//
    private ScrollView scroll_base;
    private Map<View, View> viewMap;
    private ImageView iv_play;
    //***********************************播放器相关**************************************//
    private TextView mTotalTime;
    private TextView mPassTime;
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.course_info);
        initView();
        viewMap = new HashMap<View, View>();
        viewMap.put(tvCourseInfo, courseInfo);
        viewMap.put(tvInstructorInfo, instructorInfo);
        viewMap.put(tvCourseArrange, courseArrange);
        setViewListener();
        initClass();
        getCourseInfo();
        setText();
        BitmapHelp.getBitmapUtils(getApplicationContext()).display(iv_course_info_play, c.getCoverImage());


        //***********************************播放器相关**************************************//
        init(); // 初始化数据
        setListener(); // 绑定相关事件
        mGestureDetector = new GestureDetector(this, new MyGestureListener());
        videoHeight = mVideoFrameLayout.getHeight();
    }

    private void initView() {
        iv_course_info_play = (ImageView) findViewById(R.id.iv_course_info_play);
        tvCourseTopName = (TextView) findViewById(R.id.tv_course_top_name);
        tvCourseInfo = (TextView) findViewById(R.id.tv_course_info);
        tvInstructorInfo = (TextView) findViewById(R.id.tv_instructor_info);
        tvCourseArrange = (TextView) findViewById(R.id.tv_course_arrange);
        ll_course_info_container = (LinearLayout) findViewById(R.id.ll_course_info_container);
        ll_course_arrange_container = (LinearLayout) findViewById(R.id.ll_course_arrange_container);
        sv = (InnerScrollView) findViewById(R.id.sv_info_container);
        btn_blank = (View) findViewById(R.id.btn_blank);
        scroll_base = (ScrollView) findViewById(R.id.scroll_base);
        courseInfo = (TextView) findViewById(R.id.course_info);
        instructorInfo = (TextView) findViewById(R.id.nstructor_info);
        courseArrange = (TextView) findViewById(R.id.course_arrange);
        iv_play = (ImageView) findViewById(R.id.iv_play);
        mTotalTime = (TextView) findViewById(R.id.time_totle);
        mPassTime = (TextView) findViewById(R.id.time_play);
    }

    private void setViewListener() {
        tvCourseInfo.setOnClickListener(listener);
        tvInstructorInfo.setOnClickListener(listener);
        tvCourseArrange.setOnClickListener(listener);
        btn_blank.setOnClickListener(listener);
        courseInfo.setOnClickListener(listener);
        instructorInfo.setOnClickListener(listener);
        courseArrange.setOnClickListener(listener);
        iv_play.setOnClickListener(listener);
        scroll_base.setOnTouchListener(new ScrollOnTouchListener());
    }

    private void setText() {
        tvCourseTopName.setText(c.getCourseName());
    }

    private void initClass() {
        fm = getSupportFragmentManager();
    }

    //***********************************播放器相关**************************************//

    private void getCourseInfo() {
        c = (Course) getIntent().getSerializableExtra("course");
        b = new Bundle();
        b.putString(getResources().getString(R.string.courseId), c.getId() + "");
        b.putSerializable("course", c);
        b.putSerializable("badge", getIntent().getSerializableExtra("badge"));
//		manager = new BitmapManager();
        tvCourseInfo.performClick();
    }

    private void play() {
        new PlayMovie(0).start();
        progressBar.setVisibility(View.VISIBLE);
        iv_play.setVisibility(View.GONE);// 表明是第一次开始播放
    }

    private void hideView(int id) {
        switch (id) {
            case R.id.tv_course_info:
                sv.setVisibility(View.VISIBLE);
                ll_course_info_container.setVisibility(View.GONE);
                ll_course_arrange_container.setVisibility(View.GONE);
                break;
            case R.id.tv_instructor_info:
                sv.setVisibility(View.GONE);
                ll_course_info_container.setVisibility(View.VISIBLE);
                ll_course_arrange_container.setVisibility(View.GONE);
                break;
            case R.id.tv_course_arrange:
                sv.setVisibility(View.GONE);
                ll_course_info_container.setVisibility(View.GONE);
                ll_course_arrange_container.setVisibility(View.VISIBLE);
                break;
            default:
                break;
        }
    }

    private void changeBg(View v) {
        TextView[] vs = {tvCourseInfo, tvInstructorInfo, tvCourseArrange};
        for (TextView view : vs) {
            if (v == view) {
                view.setTextColor(getResources().getColor(
                        R.color.course_type_check));
            } else {
                view.setTextColor(getResources().getColor(
                        R.color.course_type_normal));
            }
        }
    }

    private void change_Bg(View v) {
        TextView[] vs = {courseInfo, instructorInfo, courseArrange};
        for (TextView view : vs) {
            if (v == view) {
                view.setTextColor(getResources().getColor(
                        R.color.course_type_check));
            } else {
                view.setTextColor(getResources().getColor(
                        R.color.course_type_normal));
            }
        }
    }

    public ScrollView getBaseView() {
        return scroll_base;
    }

    /**
     * 初始化数据
     */
    private void init() {
        url = c.getPromoVideo();
        mMediaPlayer = new MediaPlayer(); // 创建一个播放器对象
        mPlayButton = (Button) findViewById(R.id.play);
        mPlayButton.setBackgroundResource(R.drawable.movie_stop_bt);
        mScaleButton = (Button) findViewById(R.id.scale);
        mSeekbar = (SeekBar) findViewById(R.id.seekbar);
        mSurfaceView = (SurfaceView) findViewById(R.id.surfaceView);
        progressBar = (ProgressBar) findViewById(R.id.progressBar);
//		Canvas canvas = mSurfaceView.getHolder().lockCanvas(null);
//        canvas.drawColor(Color.BLACK);
//        mSurfaceView.getHolder().unlockCanvasAndPost(canvas);


//		mSurfaceView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS); // 不缓冲
        mSurfaceView.getHolder().setKeepScreenOn(true); // 保持屏幕高亮
        mSurfaceView.getHolder().addCallback(new surFaceView()); // 设置监听事件
        rv_controll = (RelativeLayout) findViewById(R.id.rv_controll);
        mAudioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        mMaxVolume = mAudioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        mOperationBg = (ImageView) findViewById(R.id.operation_bg);
        mOperationPercent = (ImageView) findViewById(R.id.operation_percent);
        mVolumeProgressLayout = findViewById(R.id.operation_volume_brightness);

        mBigLL = (LinearLayout) findViewById(R.id.big_ll);
        mVideoFrameLayout = (FrameLayout) findViewById(R.id.surfaceView_framelayout);
        Display disp = getWindowManager().getDefaultDisplay();
        windowWidth = disp.getWidth();
        windowHeight = disp.getHeight();

        scroll_base.setOnTouchListener(mScrollListener);

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
                if (isScaleTag) {
                    zoomOut();
                } else {
                    zoomIn();
                }
            }
        });
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
        lp.width = findViewById(R.id.operation_full).getLayoutParams().width * index / mMaxVolume;
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

    protected void onDestroy() {
        super.onDestroy();
        if (mMediaPlayer.isPlaying()) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
        }
        mMediaPlayer = null;
        if (mTimer != null) {
            mTimer.cancel();
        }
    }

    private void updateTime() {
        if (mMediaPlayer != null) {
            mTotalTime.setText(formatLongToTimeStr(mMediaPlayer.getDuration()));
            mPassTime.setText(formatLongToTimeStr(mMediaPlayer.getCurrentPosition()));
        }
    }

    private void zoomOut() {
        //缩小
        btn_blank.setVisibility(View.VISIBLE);
        tvCourseTopName.setVisibility(View.VISIBLE);
        mBigLL.setLayoutParams(new LinearLayout.LayoutParams(550, LinearLayout.LayoutParams.MATCH_PARENT));
//					RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(tvCourseTopName.getWidth(), LinearLayout.LayoutParams.WRAP_CONTENT);
//					lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//					lp.addRule(RelativeLayout.BELOW, R.id.tv_course_top_name);
//					lp.addRule(RelativeLayout.ABOVE, R.id.in_view);
//					scroll_base.setLayoutParams(lp);
        mVideoFrameLayout.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 300));
        scroll_base.smoothScrollTo(0, 0);
        if (Constants.INFO_TAB == Constants.INFO_ONE) {
            sv.setVisibility(View.VISIBLE);
        } else if (Constants.INFO_TAB == Constants.INFO_TWO) {
            ll_course_info_container.setVisibility(View.VISIBLE);
        } else {
            ll_course_arrange_container.setVisibility(View.VISIBLE);
        }
        isScaleTag = false;
    }

    private void zoomIn() {
        //TODO 放大
        scroll_base.smoothScrollTo(0, 0);
        if (Constants.INFO_TAB == Constants.INFO_ONE) {
            sv.setVisibility(View.GONE);
        } else if (Constants.INFO_TAB == Constants.INFO_TWO) {
            ll_course_info_container.setVisibility(View.GONE);
        } else {
            ll_course_arrange_container.setVisibility(View.GONE);
        }
        btn_blank.setVisibility(View.GONE);
        tvCourseTopName.setVisibility(View.GONE);
        mBigLL.setLayoutParams(new LinearLayout.LayoutParams(windowWidth, windowHeight + 90));
        mVideoFrameLayout.setLayoutParams(new LinearLayout.LayoutParams(windowWidth, windowHeight - 30));
        isScaleTag = true;
    }

    ;

    @Override
    public void onBackPressed() {
        if (isScaleTag) {
            zoomOut();
        } else {
            super.onBackPressed();
        }
    }

    class ScrollOnTouchListener implements OnTouchListener {

        @Override
        public boolean onTouch(View v, MotionEvent event) {

            int action = event.getAction();
            switch (action) {
                case MotionEvent.ACTION_DOWN:
                case MotionEvent.ACTION_MOVE:
                    break;
                case MotionEvent.ACTION_UP:
                    scrollY = scroll_base.getScrollY();
                    break;
            }
            return false;
        }
    }

    private class surFaceView implements Callback { // 上面绑定的监听的事件

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width,
                                   int height) {
//			mSurfaceView.getHolder().setFixedSize(width, height);
//			mMediaPlayer.setDisplay(mSurfaceView.getHolder());
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) { // 创建完成后调用
            if (mCurVideoPos > 0 && url != null) { // 说明，停止过activity调用过pase方法，跳到停止位置播放
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
                Log.i("hck", "runrun  " + url);
                mMediaPlayer.reset(); // 回复播放器默认
                mMediaPlayer.setDataSource(url); // 设置播放路径
                mMediaPlayer.setDisplay(mSurfaceView.getHolder()); // 把视频显示在SurfaceView上
                mMediaPlayer.setOnPreparedListener(new mPreparedListener(mCurVideoPos)); // 设置监听事件
                mMediaPlayer.prepare(); // 准备播放
            } catch (Exception e) {
                message.what = 2;
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
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    iv_course_info_play.setVisibility(View.GONE);
                    progressBar.setVisibility(View.GONE);
                }
            }, 500);
            mSeekbar.setProgress(position * sMax / mMax);
//			mHandler.post(new Runnable(){
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					iv_course_info_play.setVisibility(View.GONE);
//					iv_play.setVisibility(View.GONE);
//				}
//			});
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
//				mPlayButton.setVisibility(View.GONE);
                rv_controll.setVisibility(View.GONE);
//				mScaleButton.setVisibility(View.GONE);
                isDisplayButton = false;
            } else {
//				mPlayButton.setVisibility(View.VISIBLE);
                rv_controll.setVisibility(View.VISIBLE);
                mSurfaceView.setVisibility(View.VISIBLE);
//				mScaleButton.setVisibility(View.VISIBLE);
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
