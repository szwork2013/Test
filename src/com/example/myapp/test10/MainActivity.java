package com.example.myapp.test10;

/**
 * Created by sjyin on 14-10-17.
 */
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ViewFlipper;
import com.example.myapp.R;

public class MainActivity extends Activity {
    //定义控件ViewFlipper
    private ViewFlipper viewFlipper;
    //定义手指开始触点屏幕的横坐标
    private float startX;
    //从左向右进入动画
    private Animation enter_lefttoright;
    //从左向右退出动画
    private Animation exit_lefttoright;
    //从右向左进入动画
    private Animation enter_righttoleft;
    //从右向左退出动画
    private Animation exit_righttoleft;


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main2);
        //加载动画效果
        enter_lefttoright = AnimationUtils.loadAnimation(this, R.anim.enter_lefttoright);
        exit_lefttoright = AnimationUtils.loadAnimation(this, R.anim.exit_lefttoright);
        enter_righttoleft = AnimationUtils.loadAnimation(this, R.anim.enter_righttoleft);
        exit_righttoleft = AnimationUtils.loadAnimation(this, R.anim.exit_righttoleft);

        viewFlipper = (ViewFlipper)findViewById(R.id.viewFlipper);
    }


    /**
     * <p>功能:屏幕触屏事件</p>
     * @author 周枫
     * @date 2012-5-30
     */
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //点击屏幕，MotionEvent.ACTION_DOWN 为手指点击屏幕事件
        if(event.getAction() == MotionEvent.ACTION_DOWN) {
            //获取手指开始触点横坐标
            startX = event.getX();
            //手指抬起，结束滑屏
        } else if(event.getAction() == MotionEvent.ACTION_UP) {
            //获取手指抬起，结束点横坐标
            float endX = event.getX();
            //结束点横坐标大于起始点横坐标，说明手指是向右滑动
            if(endX > startX) {
                //控件进入动画效果
                viewFlipper.setInAnimation(enter_lefttoright);
                //控件退出动画效果
                viewFlipper.setOutAnimation(exit_lefttoright);
                //显示下一页
                viewFlipper.showNext();
                //结束点横坐标小于起始点横坐标，说明手指是向左滑动
            } else if (endX < startX) {
                viewFlipper.setInAnimation(enter_righttoleft);
                viewFlipper.setOutAnimation(exit_righttoleft);
                //显示前一页
                viewFlipper.showPrevious();
            }
            return true;
        }
        return super.onTouchEvent(event);
    }



    /**
     * <p>功能:打开新的Activity</p>
     * @author 周枫
     * @date 2012-5-30
     * @param
     * @return void
     */
    public void openActivity(View v){
        Intent intent = new Intent(this, com.example.myapp.test2.MainActivity.class);
        startActivity(intent);
        //屏幕动画淡入淡出效果切换，调用anim文件夹中创建的enteralpha（进入动画）和exitalpha（淡出动画）两个动画（注意：两个xml文件命名不能有大写字母）
        //如果想定义其他动画效果，只需要改变enteralpha和exitalpha两个文件
//        this.overridePendingTransition(R.anim.enteralpha,R.anim.exitalpha);
    }
}