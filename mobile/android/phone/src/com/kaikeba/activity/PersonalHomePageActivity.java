package com.kaikeba.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.PersionalCenterInfo;
import com.kaikeba.phone.R;

import java.util.ArrayList;

/**
 * Created by chris on 14-7-22.
 */
public class PersonalHomePageActivity extends FragmentActivity implements View.OnClickListener {

    private FrameLayout iconBg;
    private ImageView headIcon;
    private TextView userName;
    private LinearLayout whereMe;
    private TextView location;
    private TextView lable;

    private LinearLayout personalContainer;

    private PersionalCenterInfo list = new PersionalCenterInfo();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.person_center);
        initData();
        initView();
        addContainer();
    }

    private void initData() {
        list.setUser("北京");
        list.setLable("我的签名");
        list.setLocation("北京市海淀区");
        ArrayList<PersionalCenterInfo.Certificate> list1 = new ArrayList<PersionalCenterInfo.Certificate>();
        ArrayList<PersionalCenterInfo.GuideCourse> list2 = new ArrayList<PersionalCenterInfo.GuideCourse>();
        ArrayList<PersionalCenterInfo.OpenCourse> list3 = new ArrayList<PersionalCenterInfo.OpenCourse>();
        for (int i = 0; i < 3; i++) {
            PersionalCenterInfo.Certificate cate = new PersionalCenterInfo.Certificate();
            cate.setName("微专业课程名称");
            cate.setType("微专业证书");
            cate.setTime("2014.7.23");
            list1.add(cate);
        }
        list.setCertificateList(list1);

        for (int i = 0; i < 8; i++) {
            PersionalCenterInfo.GuideCourse cate = new PersionalCenterInfo.GuideCourse();
            cate.setName("导学课名称");
            cate.setWeeks(6);
            cate.setHours(3);
            cate.setPercent(60);
            cate.setWhichWeek(5);
            cate.setType("导学课");
            list2.add(cate);
        }
        list.setGuideList(list2);

        for (int i = 0; i < 10; i++) {
            PersionalCenterInfo.OpenCourse cate = new PersionalCenterInfo.OpenCourse();
            cate.setName("公开课名称");
            cate.setWitch(5);
            cate.setType("公开课");
            list3.add(cate);
        }
        list.setOpenList(list3);
    }

    private void initView() {
        iconBg = (FrameLayout) findViewById(R.id.icon_gb);
        headIcon = (ImageView) findViewById(R.id.head_icon);
        userName = (TextView) findViewById(R.id.user_name);
        whereMe = (LinearLayout) findViewById(R.id.where_me);
        location = (TextView) findViewById(R.id.location);
        lable = (TextView) findViewById(R.id.lable);


        userName.setText(list.getUser());
        location.setText(list.getLocation());
        lable.setText(list.getLable());


        personalContainer = (LinearLayout) findViewById(R.id.personal_container);

        iconBg.setOnClickListener(this);
        headIcon.setOnClickListener(this);

    }

    private void addContainer() {
        if (list.getCertificateList().size() > 0) {
            addCertificateView();
        }
        if (list.getGuideList().size() > 0) {
            addGuideCourseView();
        }
        if (list.getOpenList().size() > 0) {
            addOpenCourseView();
        }
    }

    private LinearLayout.LayoutParams getParam() {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        params.setMargins(0, 20, 0, 20);
        return params;
    }

    private void addCertificateView() {
        personalContainer.addView(getCertificateView(), getParam());
    }

    private View getCertificateView() {
        View view = getLayoutInflater().inflate(R.layout.persional_part, null);
        LinearLayout partInfo = (LinearLayout) view.findViewById(R.id.prize);
        TextView partNum = (TextView) view.findViewById(R.id.prize_num);
        TextView partLookMore = (TextView) view.findViewById(R.id.look_more);
        partLookMore.setVisibility(View.GONE);
        partNum.setText("获得的证书（" + list.getCertificateList().size() + "）");
        LinearLayout partItemLayout = (LinearLayout) view.findViewById(R.id.prize_layout);
        for (int i = 0; i < list.getCertificateList().size(); i++) {
            PersionalCenterInfo.Certificate info = list.getCertificateList().get(i);
            initCertificateView(info, partItemLayout);
        }
        return view;
    }

    private void initCertificateView(PersionalCenterInfo.Certificate info, LinearLayout partItemLayout) {
        View view = getLayoutInflater().inflate(R.layout.open_course_item, null);
        ImageView myImage = (ImageView) view.findViewById(R.id.my_image);
        TextView majorname = (TextView) view.findViewById(R.id.major_name);
        TextView majorprize = (TextView) view.findViewById(R.id.major_prize);
        TextView majortime = (TextView) view.findViewById(R.id.major_time);
        majorname.setText(info.getName());
        majorprize.setText(info.getType());
        majortime.setText(info.getTime());
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        params.setMargins(0, 20, 0, 20);
        partItemLayout.addView(view, params);
    }


    private void addGuideCourseView() {
        personalContainer.addView(getGuideCourseView(), getParam());
    }

    private View getGuideCourseView() {
        View partView = getLayoutInflater().inflate(R.layout.persional_part, null);
        LinearLayout partInfo = (LinearLayout) partView.findViewById(R.id.prize);
        TextView partNum = (TextView) partView.findViewById(R.id.prize_num);
        TextView partLookMore = (TextView) partView.findViewById(R.id.look_more);
        partLookMore.setTag("guide");
        partLookMore.setOnClickListener(this);

        partNum.setText("学习的导修课（" + list.getGuideList().size() + "）");
        LinearLayout partItemLayout = (LinearLayout) partView.findViewById(R.id.prize_layout);
        int sum = 0;
        if (list.getGuideList().size() > 2) {
            sum = 2;
        } else {
            sum = list.getGuideList().size();
        }
        for (int i = 0; i < sum; i++) {
            PersionalCenterInfo.GuideCourse info = list.getGuideList().get(i);
            initGuideCourseView(info, partItemLayout);
        }
        return partView;
    }

    private void initGuideCourseView(PersionalCenterInfo.GuideCourse info, LinearLayout partItemLayout) {
        View view = getLayoutInflater().inflate(R.layout.guide_course_item, null);
        LinearLayout guideItem = (LinearLayout) view.findViewById(R.id.guide_item);
        ImageView myImage = (ImageView) view.findViewById(R.id.my_image);
        TextView guidename = (TextView) view.findViewById(R.id.guide_name);
        TextView guidetask = (TextView) view.findViewById(R.id.guide_task);
        TextView guidelearn = (TextView) view.findViewById(R.id.guide_learn);
        guideItem.setOnClickListener(this);

        guidename.setText(info.getName());
        guidetask.setText("共" + info.getWeeks() + "周 " + " 每周" + info.getHours() + "小时");
        guidelearn.setText("学至第" + info.getWhichWeek() + "周  " + " 完成" + info.getPercent() + "%");
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        params.setMargins(0, 20, 0, 20);
        partItemLayout.addView(view, params);
    }

    private void addOpenCourseView() {
        personalContainer.addView(getOpenCourseView(), getParam());
    }


    private View getOpenCourseView() {
        View partView = getLayoutInflater().inflate(R.layout.persional_part, null);
        LinearLayout partInfo = (LinearLayout) partView.findViewById(R.id.prize);
        TextView partNum = (TextView) partView.findViewById(R.id.prize_num);
        TextView partLookMore = (TextView) partView.findViewById(R.id.look_more);
        partLookMore.setTag("open");
        partLookMore.setOnClickListener(this);
        partNum.setText("学习的公开课(" + list.getOpenList().size() + ")");
        LinearLayout partItemLayout = (LinearLayout) partView.findViewById(R.id.prize_layout);

        int sum = 0;
        if (list.getOpenList().size() > 2) {
            sum = 2;
        } else {
            sum = list.getOpenList().size();
        }
        for (int i = 0; i < sum; i++) {
            PersionalCenterInfo.OpenCourse info = list.getOpenList().get(i);
            initOpenCourseView(info, partItemLayout);
        }
        return partView;
    }

    private void initOpenCourseView(PersionalCenterInfo.OpenCourse info, LinearLayout partItemLayout) {
        View view = getLayoutInflater().inflate(R.layout.open_course_item, null);
        LinearLayout openItem = (LinearLayout) view.findViewById(R.id.open_item);
        ImageView myImage = (ImageView) view.findViewById(R.id.my_image);
        TextView majorname = (TextView) view.findViewById(R.id.major_name);
        TextView majortype = (TextView) view.findViewById(R.id.major_prize);
        TextView majortime = (TextView) view.findViewById(R.id.major_time);
        openItem.setOnClickListener(this);
        majorname.setText(info.getName());
        majortype.setText(info.getType());
        majortime.setText("观看至第" + info.getWitch() + "节视频");
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        params.setMargins(0, 20, 0, 20);
        partItemLayout.addView(view, params);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.icon_gb:
                break;
            case R.id.head_icon:
                break;
            case R.id.look_more:
                if (v.getTag().equals("open")) {

                } else if (v.getTag().equals("guide")) {

                }
                break;
            case R.id.guide_item:

                break;
            case R.id.open_item:
                break;
        }
    }

    private void transInfo2Drawer(Course c) {
        Intent mIntent = new Intent(this, CourseInfomationActivity.class);
        Bundle mbBundle = new Bundle();
        mbBundle.putSerializable(ContextUtil.CATEGORY_COURSE, c);
        mIntent.putExtras(mbBundle);
        startActivity(mIntent);
    }
}
