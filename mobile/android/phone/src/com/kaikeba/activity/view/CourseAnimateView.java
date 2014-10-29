package com.kaikeba.activity.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.activity.MicroCourseActivity;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.watcher.Watched;
import com.kaikeba.common.watcher.Watcher;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;

/**
 * Created by chris on 14-7-9.
 */
public class CourseAnimateView implements View.OnClickListener, Watched {
    private final int DUATIONTIME = 300;
    public BitmapUtils bitmapUtils;
    ArrayList<LinearLayout> microCourseList = new ArrayList<LinearLayout>();
    private LinearLayout majorCourse;
    private FrameLayout courseItemBg;
    private TextView majorName;
    private ImageView majorCourseImg;
    private TextView courseTitle;
    private LinearLayout courseLayout;
    private TextView courseIntro;
    private boolean isCloseAnimationFinish = true;
    AnimatorListenerAdapter closeAnimatorListenerAdapter = new AnimatorListenerAdapter() {
        @Override
        public void onAnimationStart(Animator animation) {
            super.onAnimationStart(animation);
            isCloseAnimationFinish = false;
        }

        @Override
        public void onAnimationEnd(Animator animation) {
            super.onAnimationEnd(animation);
            isCloseAnimationFinish = true;
        }
    };
    private boolean isOpenAnimationFinish = true;
    AnimatorListenerAdapter openAnimatorListenerAdapter = new AnimatorListenerAdapter() {
        @Override
        public void onAnimationStart(Animator animation) {
            super.onAnimationStart(animation);
            isOpenAnimationFinish = false;
        }

        @Override
        public void onAnimationEnd(Animator animation) {
            super.onAnimationEnd(animation);
            isOpenAnimationFinish = true;
        }
    };
    private int courseBgHeight = 0;//记录原始的每一块高度
    private int majorCourseWidth = 0; //记录主要课程原始的宽度
    private int majorCourseTop = 0;//记录主课程原始的顶部距离
    private int majorCourseBottom = 0;//记录主课程原始的底部距离
    private int majorCourseNameHeight = 0;
    private int majorCourseHeight = 0;
    private int microCourseTop = 0; //记录一个模块中第一个微课程的的顶部距离
    private int microCourseBottom = 0;//记录一个模块中最后一个微课程的原始的底部距离
    private int microCourseWidth = 0;//记录微课程原始的宽度
    private int microCourseLeft = 0;//记录微课程原始的左边距
    private int microCourseHeight = 0;
    private int microLayoutItemHeight = 55;
//    private ArrayList<TextView> microNameTvList;
    private Context mContext;
    private CourseInfo courseInfo;

    public CourseAnimateView(Context context, CourseInfo course) {
        this.mContext = context;
        this.courseInfo = course;
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
        init();
    }

    private void init() {
        LayoutInflater inflater = LayoutInflater.from(mContext);
        View view = inflater.inflate(R.layout.course_item_bg, null);
        courseItemBg = (FrameLayout) view.findViewById(R.id.course_item_bg);
        courseItemBg.setOnClickListener(this);
        for (int i = 0; i < courseInfo.getMicro_specialties().size(); i++) {
            addMicroCourse(i);
        }

        addMajorCourse();

        majorCourseNameHeight = mContext.getResources().getDimensionPixelOffset(R.dimen.major_course_name_height);

        majorCourseHeight = mContext.getResources().getDimensionPixelOffset(R.dimen.major_course_height);

        courseBgHeight = mContext.getResources().getDimensionPixelOffset(R.dimen.course_bg_height);
    }

    public FrameLayout getLayout() {
        return courseItemBg;
    }

    private void addMajorCourse() {
        LayoutInflater inflater = LayoutInflater.from(mContext);
        View view = inflater.inflate(R.layout.major_course, null);
        majorCourse = (LinearLayout) view.findViewById(R.id.major_course);
        majorName = (TextView) view.findViewById(R.id.major_name);
        courseTitle = (TextView) view.findViewById(R.id.course_title);
        courseIntro = (TextView) view.findViewById(R.id.course_intro);
        courseLayout = (LinearLayout) view.findViewById(R.id.course_intro_layout);
        majorCourseImg = (ImageView) view.findViewById(R.id.major_course_img);
//        bitmapUtils.display(majorCourseImg, courseInfo.getImg_url());
        bitmapUtils.display(majorCourseImg, courseInfo.getImg_url(),BitmapHelp.getBitMapConfig(mContext,R.drawable.default_224_140));
        majorName.setText(courseInfo.getName());
        courseTitle.setText(courseInfo.getName());
        courseIntro.setText(courseInfo.getIntro());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.LEFT | Gravity.TOP;
        courseItemBg.addView(majorCourse, params);
    }

    private void addMicroCourse(int index) {
        LayoutInflater inflater = LayoutInflater.from(mContext);
        View view = inflater.inflate(R.layout.micro_course, null);
        LinearLayout miroCourse = (LinearLayout) view.findViewById(R.id.micro_course);
        TextView microName = (TextView) view.findViewById(R.id.micro_name);
        TextView micro_items = (TextView) view.findViewById(R.id.micro_items);
        CourseInfo.MicroSpecialties microCourses = courseInfo.getMicro_specialties().get(index);
        if (microCourses != null) {
            String courses = "";
            microName.setText(microCourses.getName());
            for (int i = 0; i < microCourses.getCourses().size(); i++) {
                CourseModel info = microCourses.getCourses().get(i);
                if (i == microCourses.getCourses().size() - 1) {
                    courses += "《" + info.getName() + "》";
                } else {
                    courses += "《" + info.getName() + "》、";
                }
            }
            micro_items.setText(courses);
        }
        miroCourse.setTag(microCourses.getId());
//        microName.setTag(microCourses.getId());
//        microNameTvList.add(microName);
        microCourseList.add(miroCourse);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.RIGHT;

        params.topMargin = mContext.getResources().getDimensionPixelOffset(R.dimen.micro_course_height) * index + 5 * index;
        params.leftMargin = mContext.getResources().getDimensionPixelOffset(R.dimen.major_course_width);//majorCourseTemp.getMeasuredWidth() + 10;
        courseItemBg.addView(miroCourse, params);
    }

    private void setMajorNameAnimation(boolean isopen, View view) {
        Animation animation;
        if (isopen) {
            animation = AnimationUtils.loadAnimation(mContext, R.anim.gradually_out);
        } else {
            animation = AnimationUtils.loadAnimation(mContext, R.anim.gradually_in);
        }
        animation.setFillAfter(true);
        view.startAnimation(animation);
    }

    private void openAnimateForMajor() {
        ViewWrapper viewWrapper = new ViewWrapper(majorCourse);
        majorCourseTop = majorCourse.getTop();
        majorCourseBottom = majorCourse.getBottom();
        microCourseBottom = microCourseList.get(microCourseList.size() - 1).getBottom();
        microCourseTop = microCourseList.get(0).getTop();
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofFloat(majorCourse, "y", 0, 0),
                ObjectAnimator.ofInt(viewWrapper, "height", majorCourseHeight, majorCourseHeight - majorCourseNameHeight)
//                ObjectAnimator.ofInt(viewWrapper, "width", majorCourseWidth, courseItemBg.getMeasuredWidth())
        );
        //动画周期为1000ms
        set.setDuration(1 * DUATIONTIME).start();

        setMajorNameAnimation(true, majorName);
        setMajorNameAnimation(false, courseIntro);
        setMajorNameAnimation(false, courseTitle);
        courseLayout.setVisibility(View.VISIBLE);
    }

    private void openAnimateForItemBg() {
        ViewWrapper viewWrapper = new ViewWrapper(courseItemBg);
        AnimatorSet set = new AnimatorSet();
//        set.addListener(courseItemBgAnimatorListerAdapter);
        set.addListener(openAnimatorListenerAdapter);
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "height", courseBgHeight, majorCourseBottom + microCourseBottom + microLayoutItemHeight * (microCourseList.size() - 1))
        );
        //动画周期为1000ms
        set.setDuration(1 * DUATIONTIME).start();
    }

    private void openAnimateForMicro(int index, LinearLayout miroCourse) {
        microCourseLeft = miroCourse.getLeft();
        microCourseWidth = miroCourse.getWidth();
        microCourseHeight = miroCourse.getHeight();
        TextView micro_items = (TextView) miroCourse.findViewById(R.id.micro_items);
        LinearLayout ll_micro_act = (LinearLayout) miroCourse.findViewById(R.id.ll_micro_act);
        ImageView goMicroCrouseImg = (ImageView) miroCourse.findViewById(R.id.go_to_micor_course_img);
        View courseSplit = miroCourse.findViewById(R.id.course_split);
        TextView micro_course_name = (TextView) miroCourse.findViewById(R.id.micro_name);
        micro_course_name.setTextColor(0xff17171a);
        micro_course_name.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));//加粗
        courseSplit.setVisibility(View.VISIBLE);
        ll_micro_act.setPadding(32, 32, 0, 24);
        if (index != 0) {
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) courseSplit.getLayoutParams();
            layoutParams.setMargins(32, 0, 0, 0);
            courseSplit.setLayoutParams(layoutParams);
        }
        AnimatorSet set = new AnimatorSet();
        //包含平移
        set.playTogether(
                ObjectAnimator.ofFloat(miroCourse, "x", microCourseLeft, 0),
                ObjectAnimator.ofFloat(miroCourse, "y", miroCourse.getTop(), miroCourse.getTop() + majorCourse.getBottom() - majorCourseNameHeight + index * 60)
        );
        //动画周期为1000ms
        set.setDuration(1 * DUATIONTIME).start();

        ViewWrapper viewWrapper = new ViewWrapper(miroCourse);
        ObjectAnimator.ofInt(viewWrapper, "width", microCourseWidth, courseItemBg.getMeasuredWidth()).setDuration(1 * DUATIONTIME).start();
        ObjectAnimator.ofInt(viewWrapper, "height", microCourseHeight, microCourseHeight + 70).setDuration(1 * DUATIONTIME).start();
        micro_items.setVisibility(View.VISIBLE);
        goMicroCrouseImg.setVisibility(View.VISIBLE);
        setMajorNameAnimation(false, micro_items);
        setMajorNameAnimation(false, goMicroCrouseImg);
        setMajorNameAnimation(false, courseSplit);

    }

    private void closeAnimateForMajor() {
        ViewWrapper viewWrapper = new ViewWrapper(majorCourse);
        //包含平移
        AnimatorSet set = new AnimatorSet();
        set.playTogether(
                ObjectAnimator.ofFloat(majorCourse, "y", 0, 0),
//                ObjectAnimator.ofInt(viewWrapper, "width", courseItemBg.getMeasuredWidth(), majorCourseWidth),
                ObjectAnimator.ofInt(viewWrapper, "height", majorCourseHeight - majorCourseNameHeight, majorCourseHeight)
        );
        set.setDuration(DUATIONTIME).start();

        setMajorNameAnimation(false, majorName);
        setMajorNameAnimation(true, courseIntro);
        setMajorNameAnimation(true, courseTitle);
        courseLayout.setVisibility(View.GONE);
    }

    private void closeAnimateForItemBg() {
        ViewWrapper viewWrapper = new ViewWrapper(courseItemBg);
        AnimatorSet set = new AnimatorSet();
//        set.addListener(courseItemBgAnimatorListerAdapter);
        set.addListener(closeAnimatorListenerAdapter);
        set.playTogether(
                ObjectAnimator.ofInt(viewWrapper, "height", majorCourseBottom + microCourseBottom + microLayoutItemHeight * (microCourseList.size() - 1), courseBgHeight)
        );
        //动画周期为1000ms
        set.setDuration(1 * DUATIONTIME).start();
    }

    private void closeAnimateForMicro(int index, LinearLayout miroCourse) {

        TextView micro_items = (TextView) miroCourse.findViewById(R.id.micro_items);
        ImageView goMicroCrouseImg = (ImageView) miroCourse.findViewById(R.id.go_to_micor_course_img);
        View courseSplit = miroCourse.findViewById(R.id.course_split);
        LinearLayout ll_micro_act = (LinearLayout) miroCourse.findViewById(R.id.ll_micro_act);
        TextView micro_course_name = (TextView) miroCourse.findViewById(R.id.micro_name);
        micro_course_name.setTextColor(0xff737380);
        micro_course_name.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));//正常
        courseSplit.setVisibility(View.GONE);
        setMajorNameAnimation(true, courseSplit);
        AnimatorSet set = new AnimatorSet();
        ll_micro_act.setPadding(0, 32, 0, 0);
        //包含平移
        set.playTogether(
                ObjectAnimator.ofFloat(miroCourse, "x", 0, microCourseLeft),
                ObjectAnimator.ofFloat(miroCourse, "y", majorCourseBottom + miroCourse.getTop() - majorCourseNameHeight + index * 60, miroCourse.getTop())
        );
        //动画周期为1000ms
        set.setDuration(1 * DUATIONTIME).start();
        ViewWrapper viewWrapper = new ViewWrapper(miroCourse);
        ObjectAnimator.ofInt(viewWrapper, "width", courseItemBg.getMeasuredWidth(), microCourseWidth).setDuration(1 * DUATIONTIME).start();
        ObjectAnimator.ofInt(viewWrapper, "height", microCourseHeight + 70, microCourseHeight).setDuration(1 * DUATIONTIME).start();

        setMajorNameAnimation(true, micro_items);
        setMajorNameAnimation(true, goMicroCrouseImg);
        goMicroCrouseImg.setVisibility(View.GONE);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.course_item_bg:
                if (isCloseAnimationFinish && isOpenAnimationFinish) {
                    notifyWatchers(CourseAnimateView.this);
                }
                break;
            case R.id.micro_course:
                Intent it = new Intent(mContext, MicroCourseActivity.class);
                Bundle b = new Bundle();
                for (int i = 0; i < courseInfo.getMicro_specialties().size(); i++) {
                    CourseInfo.MicroSpecialties micro = courseInfo.getMicro_specialties().get(i);
                    if (micro.getId() == (Integer) v.getTag()) {
                        b.putSerializable("microcourseinfo", micro);
                    }
                }
                it.putExtras(b);
                mContext.startActivity(it);
                break;
        }
//        if (v.equals(courseItemBg)) {
//            if(isCloseAnimationFinish && isOpenAnimationFinish){
//                notifyWatchers(CourseAnimateView.this);
//            }
//        }else if(v.equals(microName)){
//            Intent it = new Intent(mContext, MicroCourseActivity.class);
//            mContext.startActivity(it);
//        }
    }

    public void closeAnimate() {
        closeAnimateForMajor();
        for (int i = 0; i < microCourseList.size(); i++) {
            closeAnimateForMicro(i, microCourseList.get(i));
            microCourseList.get(i).setClickable(false);
        }
        closeAnimateForItemBg();

//        for(int i = 0 ;i < microCourseList.size();i++){
//            microCourseList.get(i).setClickable(false);
//        }
    }

    public void openAnimate() {
        openAnimateForMajor();
        for (int i = 0; i < microCourseList.size(); i++) {
            openAnimateForMicro(i, microCourseList.get(i));
            microCourseList.get(i).setOnClickListener(this);
        }
        openAnimateForItemBg();

//        for(int i = 0 ;i < microNameTvList.size();i++){
//            microNameTvList.get(i).setOnClickListener(this);
//        }
    }

    @Override
    public void addWatcher(Watcher watcher) {

    }

    @Override
    public void removeWatcher(Watcher watcher) {

    }

    @Override
    public void notifyWatchers(Object obj) {
        ((Watcher) mContext).update(obj);
    }

    class ViewWrapper {
        private View mTarget;

        public ViewWrapper(View target) {
            mTarget = target;
        }

        public int getWidth() {
            return mTarget.getLayoutParams().width;
        }

        public void setWidth(int width) {
            mTarget.getLayoutParams().width = width;
            mTarget.requestLayout();
        }

        public int getHeight() {
            return mTarget.getLayoutParams().height;
        }

        private void setHeight(int height) {
            mTarget.getLayoutParams().height = height;
            mTarget.requestLayout();
        }
    }
}
