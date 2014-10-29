package com.example.myapp.test7;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.*;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-10-16.
 */
public class MyCertificate extends Activity implements View.OnClickListener {

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
    private String tag = "sjyin";

    private int screen_width;
    private LinearLayout.LayoutParams name_layout_params;
    private boolean scroll_flag = true;
    private int progress_position = 1;
    private int progress_total = 6;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.my_certificate);
        initView();
        initData();
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
        ll_progress = (LinearLayout) findViewById(R.id.ll_progress);
        rl_progress_bg = (RelativeLayout) findViewById(R.id.rl_progress_bg);

        tv_text.setText("我的证书");
        setListener();
    }

    private float progress_margin_left;
    private RelativeLayout.LayoutParams progress_params;
    private int progress_width;

    private int name_left_margin;
    private int name_right_margin;

    private void initData() {
        WindowManager wm = getWindowManager();
        Display display = wm.getDefaultDisplay();
        screen_width = display.getWidth();
        Log.i(tag, "  screen width = " + screen_width);
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
        progress_params.leftMargin = (int) ((progress_position - 1)* progress_width);
        ll_progress.setLayoutParams(progress_params);
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

    private void allScrollToRight() {
        scrollToRight(iv_certificate, iv_certificate.getX());
        scrollToRight(ll_name, ll_name.getX());
        scrollToRight(rl_score, rl_score.getX());
        progressScrollToRight();
    }

    private void ZoomIn(){
        scrollToRight(iv_certificate, iv_certificate.getX());
        scrollToRight(ll_name, ll_name.getX());
        scrollToRight(rl_progress_bg, rl_progress_bg.getX());
        scrollToRight(rl_score, rl_score.getX());
    }

    private void allScrollToLeft() {
        scrollToLeft(iv_certificate, iv_certificate.getX());
        scrollToLeft(ll_name, ll_name.getX());
        scrollToLeft(rl_score, rl_score.getX());
        progressScrollToLeft();
    }

    private void scrollToRight(final View target, final float coordinate_x) {
        ObjectAnimator anim_step_one = ObjectAnimator.ofFloat(target, "x", coordinate_x, screen_width);
        anim_step_one.setDuration(1500).start();
        anim_step_one.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                ObjectAnimator anim_step_two = ObjectAnimator.ofFloat(target, "x", -screen_width, 100 + coordinate_x);
                anim_step_two.setDuration(1500).start();
                anim_step_two.addListener(new Animator.AnimatorListener() {
                    @Override
                    public void onAnimationStart(Animator animation) {

                    }

                    @Override
                    public void onAnimationEnd(Animator animation) {
                        ObjectAnimator anim_step_three = ObjectAnimator.ofFloat(target, "x", 100 + coordinate_x, coordinate_x);
                        anim_step_three.setDuration(1500).start();
                        anim_step_three.addListener(new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {

                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {
                                Log.i(tag, target.toString() + " scroll to right end");
                                scrollToRightCnt ++;
                                if( scrollToRightCnt >= 3){
                                    scroll_flag = true;
                                    scrollToRightCnt = 0;
                                }
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
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }
    private int scrollToLeftCnt;
    private int scrollToRightCnt;
    private void scrollToLeft(final View target, final float coordinate_x) {
        ObjectAnimator anim_step_one = ObjectAnimator.ofFloat(target, "x", coordinate_x, -screen_width);
        anim_step_one.setDuration(1500).start();
        anim_step_one.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                ObjectAnimator anim_step_two = ObjectAnimator.ofFloat(target, "x", screen_width, coordinate_x - 100);
                anim_step_two.setDuration(1500).start();
                anim_step_two.addListener(new Animator.AnimatorListener() {
                    @Override
                    public void onAnimationStart(Animator animation) {

                    }

                    @Override
                    public void onAnimationEnd(Animator animation) {
                        ObjectAnimator anim_step_three = ObjectAnimator.ofFloat(target, "x", coordinate_x - 100, coordinate_x);
                        anim_step_three.setDuration(1500).start();
                        anim_step_three.addListener(new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {

                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {
                                Log.i(tag, target.toString() + " scroll to left end");
                                scrollToLeftCnt++;
                                if( scrollToLeftCnt >= 3){
                                    scroll_flag = true;
                                    scrollToLeftCnt = 0;
                                }
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
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

    private class MySimpleGesture extends GestureDetector.SimpleOnGestureListener {

        // 双击的第二下Touch down时触发
        public boolean onDoubleTap(MotionEvent e) {
            Log.i(tag, "onDoubleTap");
            return super.onDoubleTap(e);
        }

        // 双击的第二下Touch down和up都会触发，可用e.getAction()区分
        public boolean onDoubleTapEvent(MotionEvent e) {
            Log.i(tag, "onDoubleTapEvent");
            return super.onDoubleTapEvent(e);
        }

        // Touch down时触发
        public boolean onDown(MotionEvent e) {
            Log.i(tag, "onDown");
            return super.onDown(e);
        }

        // Touch了滑动一点距离后，up时触发
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
                               float velocityY) {
            if(scroll_flag){
                scroll_flag = false;
                float startX = e1.getRawX();
                float endX = e2.getRawX();
                Log.i(tag, "onfling startx = " + startX +" endX = " + endX);
                slide(new Float(endX - startX).intValue());
            }
            return super.onFling(e1, e2, velocityX, velocityY);
        }

        // Touch了不移动一直Touch down时触发
        public void onLongPress(MotionEvent e) {
            Log.i(tag, "onLongPress");
            super.onLongPress(e);
        }

        // Touch了滑动时触发
        public boolean onScroll(MotionEvent e1, MotionEvent e2,
                                float distanceX, float distanceY) {
//            slideName(new Float(endX - startX).intValue());
            return super.onScroll(e1,e2,distanceX,distanceY);
        }

        /*
         * Touch了还没有滑动时触发
         * (1)onDown只要Touch Down一定立刻触发
         * (2)Touch Down后过一会没有滑动先触发onShowPress再触发onLongPress So: Touch Down后一直不滑动，
         * onDown -> onShowPress -> onLongPress这个顺序触发。
         */
        public void onShowPress(MotionEvent e) {
            Log.i(tag, "onShowPress");
            super.onShowPress(e);
        }

        /*
         * 两个函数都是在Touch Down后又没有滑动(onScroll)，又没有长按(onLongPress)，然后Touch Up时触发
         * 点击一下非常快的(不滑动)Touch Up: onDown->onSingleTapUp->onSingleTapConfirmed
         * 点击一下稍微慢点的(不滑动)Touch Up://确认是单击事件触发
         * onDown->onShowPress->onSingleTapUp->onSingleTapConfirmed
         */
        public boolean onSingleTapConfirmed(MotionEvent e) {
            Log.i(tag, "onSingleTapConfirmed");
            return super.onSingleTapConfirmed(e);
        }

        public boolean onSingleTapUp(MotionEvent e) {
            Log.i(tag, "onSingleTapUp");
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
        if (progress_position >= progress_total){
            progress_position = 1;
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", - progress_width, 0);
        }else{
            progress_position++;
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", ll_progress.getX(), ll_progress.getX() + progress_width);
        }
        Log.i(tag,"progress_position = " + progress_position);
        progress_animation.setDuration(500).start();
        progress_animation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                tv_cur_position.setText(progress_position + "");
                Log.i(tag,"progress scroll to right end");
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
        if (progress_position <= 1){
            progress_position = progress_total;
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", screen_width, screen_width - progress_width - 2*progress_margin_left);
        }else{
            progress_position--;
            progress_animation = ObjectAnimator.ofFloat(ll_progress, "x", ll_progress.getX(), ll_progress.getX() - progress_width);
        }
        progress_animation.setDuration(500).start();
        progress_animation.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                tv_cur_position.setText(progress_position + "");
                Log.i(tag,"progress scroll to left end");
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
}
