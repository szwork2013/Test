package com.kaikeba.activity;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.*;
import android.view.animation.AlphaAnimation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.entity.Certificate;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by sjyin on 14-10-16.
 */
public class MyCertificate extends BaseActivity implements View.OnClickListener {

    private static final int SCROLL_OUT_DURATION = 333;//滚出屏幕动画时间
    private static final int SCROLL_IN_DURATION = 500;//滚进屏幕动画时间
    private static final int ROLL_BACK_DURATION = 250;//抖动动画时间
    private static final int SCROLL_TO_RIGHT_FLAG = 10;//屏幕向右滚动标记
    private static final int ZOOM_IN_FLAG = 100;//进入当前页面的标记

    private ImageView iv_back;
    private TextView tv_text;
    private ImageView iv_arrow_l;
    private ImageView iv_arrow_r;
    private ImageView iv_certificate;
    private TextView tv_score;
    private TextView tv_cur_position;
    private TextView tv_total_position;
    private RelativeLayout rl_score;
    private LinearLayout ll_name;
    private LinearLayout ll_progress;
    private RelativeLayout rl_progress_bg;
    private TextView tv_name;
    private TextView tv_date;
    private String tag = "sjyin";

    private int screen_width;
    private LinearLayout.LayoutParams name_layout_params;
    private boolean scroll_flag = true;//其他动画是否开始的标记
    private int progress_position = 1;
    private int progress_total = 6;
    private int scrollToRightStartCnt = 0;
    private int scrollToLeftStartCnt = 0;
    private int zoomInCnt = 0;
    private float progress_margin_left;
    private RelativeLayout.LayoutParams progress_params;
    private int progress_width;
    private int name_left_margin;
    private int name_right_margin;
    private AlphaAnimation certificate_appear;
    private AlphaAnimation certificate_disappear;

    private ArrayList<Certificate> certificates;
    private ArrayList<String> certificate_images = new ArrayList<String>();
    private ArrayList<Float>  scores = new ArrayList<Float>();
    private ArrayList<Certificate> discribes = new ArrayList<Certificate>();

    private BitmapUtils bitmapUtils;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case 1:
                    scrollToLeft(rl_score, rl_score.getX());
                    break;
                case 2:
                    scrollToLeft(ll_name, ll_name.getX());
                    break;
                case 3:
                    progressScrollToRight();
                    break;
                case 10:
                    scrollToRight(rl_score, rl_score.getX());
                    break;
                case 20:
                    scrollToRight(ll_name, ll_name.getX());
                    break;
                case 30:
                    progressScrollToLeft();
                    break;
                case 100:
                    ZoomIn(rl_score, rl_score.getX());
                    break;
                case 200:
                    ZoomIn(ll_name, ll_name.getX());
                    break;
                case 300:
                    ZoomIn(rl_progress_bg, rl_progress_bg.getX());
                    break;
                default:
                    break;
            }
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.my_certificate);
        initView();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
        hide();
        updateData();
        ZoomIn(iv_certificate,iv_certificate.getX());
    }

    private void initView() {
        iv_back = (ImageView) findViewById(R.id.iv_back);
        tv_text = (TextView) findViewById(R.id.tv_text);
        iv_arrow_l = (ImageView) findViewById(R.id.iv_arrow_l);
        iv_arrow_r = (ImageView) findViewById(R.id.iv_arrow_r);
        iv_certificate = (ImageView) findViewById(R.id.iv_certificate);
        tv_score = (TextView) findViewById(R.id.tv_score);
        tv_cur_position = (TextView) findViewById(R.id.tv_cur_position);
        tv_total_position = (TextView) findViewById(R.id.tv_total_position);
        rl_score = (RelativeLayout) findViewById(R.id.rl_score);
        ll_name = (LinearLayout) findViewById(R.id.ll_name);
        tv_name = (TextView) findViewById(R.id.tv_name);
        tv_date = (TextView) findViewById(R.id.tv_date);
        ll_progress = (LinearLayout) findViewById(R.id.ll_progress);
        rl_progress_bg = (RelativeLayout) findViewById(R.id.rl_progress_bg);

        tv_text.setText("我的证书");
        setListener();
    }

    private void initData() {
        WindowManager wm = getWindowManager();
        Display display = wm.getDefaultDisplay();
        screen_width = display.getWidth();
        certificates = (ArrayList<Certificate>) getIntent().getSerializableExtra("my_certificate_data");
        if(certificates != null && certificates.size()>0){
            certificate_images.clear();
            scores.clear();
            discribes.clear();
            for(Certificate certificate : certificates){
                certificate_images.add(certificate.getImage_url());
                scores.add(certificate.getScore());
                discribes.add(certificate);
            }
            progress_total = certificates.size();
            Log.i(tag,"certificates.size() = " + certificates.size());
        }
        bitmapUtils = BitmapHelp.getBitmapUtils(this);

        certificate_appear = (AlphaAnimation) AnimationUtils.loadAnimation(this,R.anim.certificate_appear);
        certificate_appear.setFillAfter(true);
        certificate_disappear = (AlphaAnimation) AnimationUtils.loadAnimation(this,R.anim.certificate_disappear);
        initMarginValue();
        initProgress();
    }

    private void initMarginValue() {
        name_layout_params = (LinearLayout.LayoutParams) ll_name.getLayoutParams();
        name_left_margin = name_layout_params.leftMargin;
        name_right_margin = name_layout_params.rightMargin;
    }

    private void initProgress() {
        tv_cur_position.setText(progress_position + "");
        tv_total_position.setText(progress_total + "");
        LinearLayout.LayoutParams progress_bg_layoutparams = (LinearLayout.LayoutParams) rl_progress_bg.getLayoutParams();
        progress_margin_left = progress_bg_layoutparams.leftMargin;
        progress_width = (int) ((screen_width - 2 * progress_margin_left) / progress_total);
        progress_params = new RelativeLayout.LayoutParams(progress_width, RelativeLayout.LayoutParams.WRAP_CONTENT);
        progress_params.leftMargin = (int) ((progress_position - 1) * progress_width);
        ll_progress.setLayoutParams(progress_params);
        ll_progress.requestLayout();
    }

    private void setListener() {
        iv_back.setOnClickListener(this);
        iv_arrow_l.setOnClickListener(this);
        iv_arrow_r.setOnClickListener(this);

        final GestureDetector gestureDetector = new GestureDetector(this, new MySimpleGesture());
        gestureDetector.setIsLongpressEnabled(true);
        ll_name.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                gestureDetector.onTouchEvent(event);
                // 一定要返回true，不然获取不到完整的事件
                return true;
            }
        });
        iv_certificate.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                gestureDetector.onTouchEvent(event);
                // 一定要返回true，不然获取不到完整的事件
                return true;
            }
        });

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_back:
                finish();
                break;
            case R.id.iv_arrow_l:
                if (scroll_flag) {
                    scroll_flag = false;
                    allScrollToLeft();
                }
                break;
            case R.id.iv_arrow_r:
                if (scroll_flag) {
                    scroll_flag = false;
                    allScrollToRight();
                }
                break;
        }
    }

    private void ZoomIn(final View target ,final float coordinate_x) {
        ObjectAnimator anim_step_two = ObjectAnimator.ofFloat(target, "x", screen_width, coordinate_x - 100);
        anim_step_two.setDuration(1000);
        anim_step_two.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

                switch (zoomInCnt){
                    case 0:
                        iv_certificate.setVisibility(View.VISIBLE);
                        break;
                    case 1:
                        rl_score.setVisibility(View.VISIBLE);
                        break;
                    case 2:
                        ll_name.setVisibility(View.VISIBLE);
                        break;
                    case 3:
                        rl_progress_bg.setVisibility(View.VISIBLE);
                        break;
                    default:
                        break;
                }
                zoomInCnt++;
                if(zoomInCnt > 4){
                    zoomInCnt = 0;
                }
                target.startAnimation(certificate_appear);
                handler.sendEmptyMessageDelayed(zoomInCnt * ZOOM_IN_FLAG ,166);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                ObjectAnimator anim_step_three = ObjectAnimator.ofFloat(target, "x", coordinate_x - 100, coordinate_x);
                anim_step_three.setDuration(ROLL_BACK_DURATION).start();
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        anim_step_two.start();
    }

    private void hide(){
        iv_certificate.setVisibility(View.INVISIBLE);
        rl_score.setVisibility(View.INVISIBLE);
        ll_name.setVisibility(View.INVISIBLE);
        rl_progress_bg.setVisibility(View.INVISIBLE);
    }

    private void allScrollToRight() {
        scrollToRight(iv_certificate, iv_certificate.getX());
    }

    private void allScrollToLeft() {
        scrollToLeft(iv_certificate, iv_certificate.getX());
    }

    private void scrollToRight(final View target, final float coordinate_x) {
        ObjectAnimator anim_step_one = ObjectAnimator.ofFloat(target, "x", coordinate_x, screen_width);
        anim_step_one.setDuration(SCROLL_OUT_DURATION);
        anim_step_one.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                if(scrollToRightStartCnt >= 3){
                    scrollToRightStartCnt = 1;
                }else{
                    scrollToRightStartCnt ++;
                }
                handler.sendEmptyMessageDelayed(scrollToRightStartCnt * SCROLL_TO_RIGHT_FLAG, 166);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                //更新当前的进度
                if (progress_position <= 1) {
                    progress_position = progress_total;
                }else{
                    progress_position --;
                }
                updateData();

                ObjectAnimator anim_step_two = ObjectAnimator.ofFloat(target, "x", -screen_width, 100 + coordinate_x);
                anim_step_two.setDuration(SCROLL_IN_DURATION);
                anim_step_two.addListener(new Animator.AnimatorListener() {
                    @Override
                    public void onAnimationStart(Animator animation) {
                        target.startAnimation(certificate_appear);
                    }

                    @Override
                    public void onAnimationEnd(Animator animation) {
                        ObjectAnimator anim_step_three = ObjectAnimator.ofFloat(target, "x", 100 + coordinate_x, coordinate_x);
                        anim_step_three.setDuration(ROLL_BACK_DURATION).start();
                        anim_step_three.addListener(new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {

                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {

                            }

                            @Override
                            public void onAnimationCancel(Animator animation) {

                            }

                            @Override
                            public void onAnimationRepeat(Animator animation) {

                            }
                        });
                    }

                    @Override
                    public void onAnimationCancel(Animator animation) {

                    }

                    @Override
                    public void onAnimationRepeat(Animator animation) {

                    }
                });
                anim_step_two.start();
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        anim_step_one.start();
    }

    private void scrollToLeft(final View target, final float coordinate_x) {
        ObjectAnimator anim_step_one = ObjectAnimator.ofFloat(target, "x", coordinate_x, -screen_width);
        anim_step_one.setDuration(SCROLL_OUT_DURATION);
        anim_step_one.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                if(scrollToLeftStartCnt >= 3){
                    scrollToLeftStartCnt = 1;
                }else{
                    scrollToLeftStartCnt ++;
                }
                handler.sendEmptyMessageDelayed(scrollToLeftStartCnt , 166);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                ObjectAnimator anim_step_two = ObjectAnimator.ofFloat(target, "x", screen_width, coordinate_x - 100);
                anim_step_two.setDuration(SCROLL_IN_DURATION);
                anim_step_two.addListener(new Animator.AnimatorListener() {
                    @Override
                    public void onAnimationStart(Animator animation) {
                        target.startAnimation(certificate_appear);
                    }

                    @Override
                    public void onAnimationEnd(Animator animation) {
                        //更新当前的进度
                        if (progress_position >= progress_total) {
                            progress_position = 1;
                        }else{
                            progress_position++;
                        }
                        updateData();

                        ObjectAnimator anim_step_three = ObjectAnimator.ofFloat(target, "x", coordinate_x - 100, coordinate_x);
                        anim_step_three.setDuration(ROLL_BACK_DURATION).start();
                        anim_step_three.addListener(new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {

                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {

                            }

                            @Override
                            public void onAnimationCancel(Animator animation) {

                            }

                            @Override
                            public void onAnimationRepeat(Animator animation) {

                            }
                        });
                    }

                    @Override
                    public void onAnimationCancel(Animator animation) {

                    }

                    @Override
                    public void onAnimationRepeat(Animator animation) {

                    }
                });
                anim_step_two.start();
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        anim_step_one.start();
    }

    private class MySimpleGesture extends GestureDetector.SimpleOnGestureListener {

        // 双击的第二下Touch down时触发
        public boolean onDoubleTap(MotionEvent e) {
            return super.onDoubleTap(e);
        }

        // 双击的第二下Touch down和up都会触发，可用e.getAction()区分
        public boolean onDoubleTapEvent(MotionEvent e) {
            return super.onDoubleTapEvent(e);
        }

        // Touch down时触发
        public boolean onDown(MotionEvent e) {
            return super.onDown(e);
        }

        // Touch了滑动一点距离后，up时触发
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
                               float velocityY) {
            if (scroll_flag) {
                scroll_flag = false;
                float startX = e1.getRawX();
                float endX = e2.getRawX();
                slide(new Float(endX - startX).intValue());
            }
            return super.onFling(e1, e2, velocityX, velocityY);
        }

        // Touch了不移动一直Touch down时触发
        public void onLongPress(MotionEvent e) {
            super.onLongPress(e);
        }

        // Touch了滑动时触发
        public boolean onScroll(MotionEvent e1, MotionEvent e2,
                                float distanceX, float distanceY) {
//            slideName(new Float(endX - startX).intValue());
            return super.onScroll(e1, e2, distanceX, distanceY);
        }

        /*
         * Touch了还没有滑动时触发
         * (1)onDown只要Touch Down一定立刻触发
         * (2)Touch Down后过一会没有滑动先触发onShowPress再触发onLongPress So: Touch Down后一直不滑动，
         * onDown -> onShowPress -> onLongPress这个顺序触发。
         */
        public void onShowPress(MotionEvent e) {
            super.onShowPress(e);
        }

        /*
         * 两个函数都是在Touch Down后又没有滑动(onScroll)，又没有长按(onLongPress)，然后Touch Up时触发
         * 点击一下非常快的(不滑动)Touch Up: onDown->onSingleTapUp->onSingleTapConfirmed
         * 点击一下稍微慢点的(不滑动)Touch Up://确认是单击事件触发
         * onDown->onShowPress->onSingleTapUp->onSingleTapConfirmed
         */
        public boolean onSingleTapConfirmed(MotionEvent e) {
            return super.onSingleTapConfirmed(e);
        }

        public boolean onSingleTapUp(MotionEvent e) {
            return super.onSingleTapUp(e);
        }
    }

    private boolean slide(int distance) {
        if (distance > 100) {
            allScrollToRight();
            return false;
        } else if (distance < -100) {
            allScrollToLeft();
            return false;
        }
        return true;
    }

    private void progressScrollToRight() {
        ObjectAnimator progress_animation = null;
        if (progress_position >= progress_total) {
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", -progress_width, 0);
        } else {
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", ll_progress.getX(), ll_progress.getX() + progress_width);
        }
        Log.i(tag,"right ll_progress.getX() = " +ll_progress.getX());
        progress_animation.setDuration(SCROLL_IN_DURATION).start();
        progress_animation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                Log.i(tag, "progress scroll to right end");
                tv_cur_position.setText(progress_position + "");
                scroll_flag = true;
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

    private void progressScrollToLeft() {
        ObjectAnimator progress_animation = null;
        if (progress_position <= 1) {
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", screen_width, screen_width - progress_width - 2 * progress_margin_left);
        } else {
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", ll_progress.getX(), ll_progress.getX() - progress_width);
        }
        Log.i(tag,"left ll_progress.getX() = " +ll_progress.getX());
        progress_animation.setDuration(SCROLL_IN_DURATION).start();
        progress_animation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                tv_cur_position.setText(progress_position + "");
                scroll_flag = true;
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

    private void slideName(int distance) {
        if (distance > 0) {
            name_layout_params.leftMargin = distance + name_left_margin;
            name_layout_params.rightMargin = name_right_margin - distance;
        } else {
            name_layout_params.leftMargin = name_left_margin + distance;
            name_layout_params.rightMargin = name_right_margin - distance;
        }
        ll_name.setLayoutParams(name_layout_params);
        ll_name.requestLayout();// 重绘Layout
    }

    private void updateData(){
        int position = progress_position - 1;
//        bitmapUtils.display(iv_certificate,certificate_images.get(position));
        tv_score.setText(scores.get(position).intValue()+"");
        tv_name.setText(discribes.get(position).getName());
        tv_date.setText(getDate(discribes.get(position).getAwarded_at()));
    }

    private String getDate(long l){
        Date date = new Date(l);
        return new SimpleDateFormat("yyyy.MM.dd").format(date);
    }
}


