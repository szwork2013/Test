package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.GuideCourseAcitvity;
import com.kaikeba.activity.TabCourseActivity;
import com.kaikeba.activity.ZoomImageActivity;
import com.kaikeba.adapter.TeacherAdapter;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.CommonUtils;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.widget.CollapsibleTextView;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

/**
 * Created by mjliu on 14-7-29.
 */
public class BaseCouseFragment extends Fragment {

    //	private BitmapManager manager;
    public BitmapUtils bitmapUtils;
    private TextView tv_go_pay;
    private TextView tv_course_circle;
    private TextView tv_course_time;
    private TextView tv_course_easy;
    //    private TextView tv_course_keyword;
    private TextView course_name;
    private CollapsibleTextView tv_course_introduce;
    private ListView teacherListView;
    private TeacherAdapter adapter;
    private ScrollView base_scroll;
    private ImageView img_certificate;
    private CourseModel c;
    private LayoutInflater inflater;
    private RelativeLayout course_info_base_detail;

    private RelativeLayout ll_video_player;
    private VideoPlayerView video_palyer;
    private int height;
    private int width;
    private int bar_height;
    private int mCurVideoPos;

    private TextView coc_txt;
    private LinearLayout ll_coc_standard;
    private LinearLayout ll_difficulty_level;

    private RelativeLayout rel_guide_time;
    private LinearLayout ll_guide_content;
    private String TAG = "BaseCouseFragment";
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case Constants.COURSE_TIME_OUT:
                    Toast.makeText(tv_go_pay.getContext(), "该课程已结课不能学习", Toast.LENGTH_SHORT).show();
                    break;
                case Constants.THERE_IS_NONET:
//                    Toast.makeText(tv_go_pay.getContext(), "网络未连接",Toast.LENGTH_SHORT).show();
                    KKDialog.getInstance().showNoNetToast(tv_go_pay.getContext());
                    break;
            }

        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;

        //播放器的操作
        bar_height = CommonUtils.getStatusBarHeight(getActivity());
        width = CommonUtils.getScreenWidth(getActivity());
        View v = inflater.inflate(R.layout.base_course_info, container, false);
//        height = (int) (Constants.COVER_HEIGHT * (Constants.SCREEN_WIDTH - 10 * Constants.SCREEN_DENSITY) / Constants.COVER_WIDTH + 0.5);
        height = (CommonUtils.getScreenWidth(getActivity()) * 9) / 16;
        ll_video_player = (RelativeLayout) v.findViewById(R.id.rl_video_player);
        ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        video_palyer = new VideoPlayerView(getActivity());
        c = (CourseModel) getArguments().getSerializable(ContextUtil.CATEGORY_COURSE);
        Constants.FULL_SCREEN_NO_CLICK = false;
        video_palyer.preparePlayData(c.getPromotional_video_url(), c.getCover_image(), mCurVideoPos, 0, 0);
        ll_video_player.addView(video_palyer.makeControllerView());
        bitmapUtils = BitmapHelp.getBitmapUtils(getActivity().getApplicationContext());

        course_info_base_detail = (RelativeLayout) v.findViewById(R.id.course_info_base_detail);
        tv_course_circle = (TextView) v.findViewById(R.id.tv_coure_circle);
        tv_course_time = (TextView) v.findViewById(R.id.tv_course_time);
        tv_course_easy = (TextView) v.findViewById(R.id.tv_course_easy);
//        tv_course_keyword = (TextView) v.findViewById(R.id.course_keyword);
        course_name = (TextView) v.findViewById(R.id.course_name);
        tv_course_introduce = (CollapsibleTextView) v.findViewById(R.id.collapsible_textview);
        img_certificate = (ImageView) v.findViewById(R.id.certificate_img);

        teacherListView = (ListView) v.findViewById(R.id.teacher_listview);
        adapter = new TeacherAdapter(getActivity(), c.getTechInfo());
        teacherListView.setAdapter(adapter);
        base_scroll = (ScrollView) v.findViewById(R.id.base_scroll);
        ll_difficulty_level = (LinearLayout) v.findViewById(R.id.ll_difficulty_level);
        rel_guide_time = (RelativeLayout) v.findViewById(R.id.rel_guide_time);
        ll_guide_content = (LinearLayout) v.findViewById(R.id.ll_guide_content);
        coc_txt = (TextView) v.findViewById(R.id.coc_txt);
        ll_coc_standard = (LinearLayout) v.findViewById(R.id.ll_coc_standard);
        return v;
    }
    public void pauseVideoPlayer(){
        video_palyer.pauseMediaPlayer();
    }
    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        setTextViewData();
    }

    private void setTextViewData() {
        course_name.setText(c.getName());
        tv_course_circle.setText(c.getWeeks() + "周");
        if (c.getMin_duration() == c.getMax_duration()) {
            tv_course_time.setText(c.getMin_duration() + "小时");
        } else {
            tv_course_time.setText(c.getMin_duration() + "-" + c.getMax_duration() + "小时");
        }
        tv_course_easy.setText(getLevel(c.getLevel()));
        tv_course_introduce.setDesc(c.getIntro(), TextView.BufferType.NORMAL);
        if (c.getCertificate_img() != null && !c.getCertificate_img().equals("")) {
            // 证书根据实际图片大小设置
            double picHeight = (1275 / 1620.0) * (CommonUtils.getScreenWidth(getActivity()) - CommonUtils.dip2px(getActivity(), 40)) + 0.5;
            int height = (int) picHeight;
            Log.i("picHeight", picHeight + "");
            img_certificate.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, height));

//            bitmapUtils.display(img_certificate, c.getCertificate_img());
            bitmapUtils.display(img_certificate, c.getCertificate_img(),BitmapHelp.getBitMapConfig(getActivity(),R.drawable.certificate_default));
            coc_txt.setVisibility(View.VISIBLE);
            ll_coc_standard.setVisibility(View.VISIBLE);
            img_certificate.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent it = new Intent();
                    it.putExtra("zoom_img_url", c.getCertificate_img());
                    it.setClass(getActivity(), ZoomImageActivity.class);
                    getActivity().startActivity(it, null);
                }
            });
        } else {
            coc_txt.setVisibility(View.GONE);
            ll_coc_standard.setVisibility(View.GONE);
        }

    }

    private String getLevel(String l) {
        String level = "";
        if (l == null) {
            setLevelImg(2);
            return "中";
        }
        if (l.equals("low")) {
            level = "低";
            setLevelImg(1);
        } else if (l.equals("medium")) {
            setLevelImg(2);
            level = "中";
        } else {
            setLevelImg(3);
            level = "高";
        }
        return level;
    }

    private void setLevelImg(int level) {
        for (int i = 0; i < 3; i++) {
            View child = ll_difficulty_level.getChildAt(i);
            if (child instanceof ImageView) {
                if (i < level) {
                    ((ImageView) child).setImageResource(R.drawable.difficulty_true);
                } else {
                    ((ImageView) child).setImageResource(R.drawable.difficulty_false);
                }
            }
        }
    }

    private String getKeyWord() {
        String keyword = "";
        List<String> keys = c.getCourse_key();
        if (keys == null) {
            return "";
        }
        for (int i = 0; i < keys.size(); i++) {
            keyword += keys.get(i) + "  ";
        }
        return keyword;
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (video_palyer != null) {
            video_palyer.screenChange(newConfig, height);
        }
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setGuideVisiable(false);
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            setGuideVisiable(true);
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    public void setGuideVisiable(boolean visiable) {
        if (visiable) {
            getActivity().findViewById(R.id.ll_course_guide_info).setVisibility(View.VISIBLE);
            getActivity().findViewById(R.id.ll_course_info_title).setVisibility(View.VISIBLE);
            getActivity().findViewById(R.id.study_layout).setVisibility(View.VISIBLE);
            getActivity().findViewById(R.id.top_line).setVisibility(View.VISIBLE);
            ll_guide_content.setVisibility(View.VISIBLE);
            rel_guide_time.setVisibility(View.VISIBLE);
        } else {
            getActivity().findViewById(R.id.ll_course_guide_info).setVisibility(View.GONE);
            getActivity().findViewById(R.id.ll_course_info_title).setVisibility(View.GONE);
            getActivity().findViewById(R.id.top_line).setVisibility(View.GONE);
            getActivity().findViewById(R.id.study_layout).setVisibility(View.GONE);
            ll_guide_content.setVisibility(View.GONE);
            rel_guide_time.setVisibility(View.GONE);
        }
    }

    public void onBackPressed() {
        if (!video_palyer.isScaleTag) {
            GuideCourseAcitvity.getGuideCourseAcitvity().disMissLms_pop();
            if (getActivity() != null) {
//                getActivity().finish();
                GuideCourseAcitvity.getGuideCourseAcitvity().appointSkip();
            }
        } else {
            video_palyer.onBackPressed();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (video_palyer != null) {
            video_palyer.onDestroy();
            video_palyer.unregisterReceiver();
        }
    }

}