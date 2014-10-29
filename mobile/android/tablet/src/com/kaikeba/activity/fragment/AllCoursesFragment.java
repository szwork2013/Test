package com.kaikeba.activity.fragment;

import android.app.Fragment;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import com.kaikeba.activity.CourseInfomationActivity;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.adapter.AllCourseGridAdapter;
import com.kaikeba.adapter.PageAdapter;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.PromoInfo;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.common.widget.XDScrollView;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 全部课程Fragment
 *
 * @author Super Man
 */
public class AllCoursesFragment extends Fragment {


    /**
     * 全部课程卡片
     */
    private GridView gridView;

    /**
     * 轮播图图片路径
     */
    private List<String> urls = new ArrayList<String>();
    ;
    private ArrayList<PromoInfo> courseInfoList;
    private TextView pro_title;
    private TextView pro_content;
    private LinearLayout pointLinear;
    private RelativeLayout rl_layout;

    /**
     * 轮播图容器
     */
    private ViewPager viewPager; // android-support-v4中的滑动组件

    /**
     * 轮播图图片索引
     */
    private int currentItem = 0; // 当前图片的索引号
    // 切换当前显示的图片
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 1:
                    picAdapter.notifyDataSetChanged();
                    break;
                default:
                    viewPager.setCurrentItem(currentItem);// 切换当前显示的图片
                    break;
            }
        }

        ;
    };
    /**
     * 全部课程卡片适配器
     */
    private AllCourseGridAdapter picAdapter;
    /**
     * 轮播图自动滑动的 单线程任务
     */
    private ScheduledExecutorService scheduledExecutorService;
    private View v;
    private List<Course> invisibleAllCourses;
    private List<Course> visibleAllCourses;
    /**
     * 课程类型Spinner
     */
    private Spinner spinner;
    private ArrayAdapter<?> adapter;
    private TextView course_type_all;
    private TextView course_type_guide;
    private TextView course_type_open;
    private TextView all_course;
    private TextView tv_all_course;
    private TextView tv_all;
    private TextView tv_guide;
    private TextView tv_open;
    private RelativeLayout rv_out;
    private XDScrollView scrollView;
    private RelativeLayout type_bar;
    private ArrayList<String> courseCategories;
    private List<Course> courses = new ArrayList<Course>();
    private ImageButton btn_togo;
    private int clickFlag = 0;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            int id = v.getId();
            switch (id) {
                case R.id.course_type_open:
                    clickFlag = 3;
                    setBg(v);
                    setBackage(v);
                    if (picAdapter != null) {
                        pushCourse4Button();
                    }
                    break;
                case R.id.course_type_guide:
                    clickFlag = 2;
                    setBg(v);
                    setBackage(v);
                    if (picAdapter != null) {
                        pushCourse4Button();
                    }
                    break;
                case R.id.all_course:
                    clickFlag = 1;
                    setBg(v);
                    setBackage(v);
                    if (picAdapter != null) {
                        pushCourse4Button();
                    }
                    break;
                case R.id.course_type_all:
                    if (courseCategories == null) {
                        return;
                    }
                    spinner.performClick();
                    break;
                case R.id.tv_all_course:
                    all_course.performClick();
                    break;
                case R.id.tv_guide:
                    course_type_guide.performClick();
                    break;
                case R.id.tv_open:
                    course_type_open.performClick();
                    break;
                case R.id.tv_all:
                    course_type_all.performClick();
                    break;
                default:
                    break;
            }
        }
    };
    private boolean isFirst = true;
    private ArrayList<Long> ids;
    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(Constants.ACTION_IS_REFRESH)) {
//                if (courseInfoList == null && Constants.NET_IS_SUCCESS) {
//                	loadPromoInfo();
//                }
            }
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.all_courses, container, false);
        initView(v);
        setListener();
        IntentFilter myIntentFilter = new IntentFilter();
        myIntentFilter.addAction(Constants.ACTION_IS_REFRESH);
        //注册广播
        getActivity().registerReceiver(mBroadcastReceiver, myIntentFilter);
        return v;
    }

    private void initView(View v) {
        rl_layout = (RelativeLayout) v.findViewById(R.id.rl_layout);
        pointLinear = (LinearLayout) v.findViewById(R.id.gallery_point_linear);
        pro_title = (TextView) v.findViewById(R.id.pro_title);
        pro_content = (TextView) v.findViewById(R.id.pro_content);
        viewPager = (ViewPager) v.findViewById(R.id.vp);
        gridView = (GridView) v.findViewById(R.id.gridview);
        rv_out = (RelativeLayout) v.findViewById(R.id.rv_out);
        spinner = (Spinner) v.findViewById(R.id.spinner);
        course_type_all = (TextView) v.findViewById(R.id.course_type_all);
        scrollView = (XDScrollView) v.findViewById(R.id.scroll_view);
        type_bar = (RelativeLayout) v.findViewById(R.id.type_bar);
        scrollView.setFloatView(type_bar, rv_out);
        course_type_guide = (TextView) v.findViewById(R.id.course_type_guide);
        course_type_open = (TextView) v.findViewById(R.id.course_type_open);
        tv_all = (TextView) v.findViewById(R.id.tv_all);
        tv_guide = (TextView) v.findViewById(R.id.tv_guide);
        tv_open = (TextView) v.findViewById(R.id.tv_open);
        all_course = (TextView) v.findViewById(R.id.all_course);
        tv_all_course = (TextView) v.findViewById(R.id.tv_all_course);
        btn_togo = (ImageButton) v.findViewById(R.id.btn_togo);
        MainActivity.getMainActivity().getMslidingMenu().addIgnoredView(viewPager);
    }

    private void pushCourse4Button() {
        courses.clear();
        String category = (String) spinner.getSelectedItem();
        for (Course c : invisibleAllCourses) {
            if (category.equals(getResources().getString(R.string.all_course_type))) {
                pushCourse4Spinner(c);
            } else if (category.equals(c.getCourseCategory())) {
                pushCourse4Spinner(c);
            }

        }
        picAdapter.setDate(courses);
        picAdapter.notifyDataSetChanged();
        if (courses.isEmpty()) {
            String type = "";
            if (clickFlag == 2) {
                type = "导学课";
            } else if (clickFlag == 3) {
                type = "公开课";
            }
            Toast.makeText(getActivity(), "在" + spinner.getSelectedItem() + "下暂时没有" + type + "，课程很快就会充实起来了，先去看看其他类型的课程吧", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 设置背景
     *
     * @param v
     */
    private void setBg(View v) {
        TextView[] views = {course_type_guide, course_type_open, all_course, tv_guide, tv_open, tv_all_course};
        for (TextView tv : views) {
            tv.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
        }
        if (v == course_type_guide || v == tv_guide) {
            course_type_guide.setTextColor(getResources().getColor(R.color.activity_top_text_check));
            tv_guide.setTextColor(getResources().getColor(R.color.activity_top_text_check));
        } else if (v == course_type_open || v == tv_open) {
            course_type_open.setTextColor(getResources().getColor(R.color.activity_top_text_check));
            tv_open.setTextColor(getResources().getColor(R.color.activity_top_text_check));
        } else if (v == all_course || v == tv_all_course) {
            all_course.setTextColor(getResources().getColor(R.color.activity_top_text_check));
            tv_all_course.setTextColor(getResources().getColor(R.color.activity_top_text_check));
        }
    }

    private void setBackage(View v) {
        if (v == all_course) {
            all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_normal));
            course_type_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            course_type_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_selected));
            tv_all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_normal));
            tv_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        } else if (v == course_type_guide) {
            all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            course_type_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_normal));
            course_type_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_selected));

            tv_all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_normal));
            tv_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        } else if (v == course_type_open) {
            all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            course_type_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            course_type_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_normal));

            tv_all_course.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_guide.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_open.setBackgroundDrawable(getResources().getDrawable(
                    R.drawable.tab_right_normal));

        }
    }

    private void setListener() {
        tv_guide.setOnClickListener(listener);
        tv_open.setOnClickListener(listener);
        tv_all.setOnClickListener(listener);
        tv_all_course.setOnClickListener(listener);
        course_type_open.setOnClickListener(listener);
        course_type_guide.setOnClickListener(listener);
        course_type_all.setOnClickListener(listener);
        all_course.setOnClickListener(listener);
        viewPager.setOnPageChangeListener(new MyPageChangeListener());
        viewPager.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                viewPager.requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });
        gridView.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                transInfo2Drawer((Course) parent.getAdapter().getItem(position));
            }
        });
        scrollView.setOnScrollListener(new XDScrollView.OnScrollListener() {

            @Override
            public void onScrollChanged(XDScrollView scrollView, int x,
                                        int y, int oldx, int oldy) {
            }
        });

        spinner.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> arg0, View arg1,
                                       int arg2, long arg3) {
                // TODO Auto-generated method stub
                String category = (String) spinner.getSelectedItem();
                tv_all.setText(category);
                course_type_all.setText(category);
                if (isFirst) {
//					courses.addAll(invisibleAllCourses);
                    isFirst = false;
//					picAdapter.setDate(courses);
//					picAdapter.notifyDataSetChanged();
                    all_course.performClick();
                    return;
                }
                pushCourse4Button();
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {
                // TODO Auto-generated method stub
            }
        });
        btn_togo.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                MainActivity.getMainActivity().getMslidingMenu().showMenu();
            }
        });
    }

    private void pushCourse4Spinner(Course c) {
        switch (clickFlag) {
            case 1:
                courses.add(c);
                break;
            case 2:
                if (getResources().getString(R.string.course_guide).equals(c.getCourseType())) {
                    courses.add(c);
                }
                break;
            case 3:
                if (getResources().getString(R.string.course_open).equals(c.getCourseType())) {
                    courses.add(c);
                }
                break;
            default:
                break;
        }
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        Log.e("AllCoursesFragment", "----------------");
        loadPromoInfo();
    }

    private void loadPromoInfo() {
        ImgLoaderUtil.threadPool.submit(new Runnable() {
            @Override
            public void run() {
                Log.e("loadPromoInfo", "----------------");
                try {
                    courseInfoList = CoursesAPI.getPromoInfo(false);
                } catch (DibitsExceptionC e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return;
                }
                if (courseInfoList == null) {
                    return;
                }
                try {
                    LocalStorage.sharedInstance().setIds(CoursesAPI.getMyCoursesId(false));
                } catch (DibitsExceptionC e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                for (PromoInfo pro : courseInfoList) {
                    urls.add(pro.getSliderImage());
                }
                loadAllCourse();
                // 轮播图加载数据
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        initPointView();
                        PageAdapter adapter = new PageAdapter(rl_layout, v,
                                urls, getActivity(), new PagerListener());
                        viewPager.setAdapter(adapter);// 设置填充ViewPager页面的适配器
                    }
                });
            }
        });
    }

    /**
     * 加载全部课程
     */
    private void loadAllCourse() {
        try {
            courseCategories = CoursesAPI.getCourseCategory();
            courseCategories.add(0, getResources().getString(R.string.all_course_type));
            List<Course> allCourses = CoursesAPI.getAllCourses(false);
            if (API.getAPI().alreadySignin()) {
                ids = CoursesAPI.getMyCoursesId(false);
                MainActivity.getMainActivity().setIds(ids);
            }
            invisibleAllCourses = new ArrayList<Course>();
            for (Course c : allCourses) {
                if (c.isVisible()) {
                    invisibleAllCourses.add(c);
                }
            }
            visibleAllCourses = new ArrayList<Course>();
            visibleAllCourses.addAll(allCourses);

            allCourses.clear();
            allCourses = null;

            handler.post(new Runnable() {
                public void run() {
                    adapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_item, courseCategories);
                    adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    spinner.setAdapter(adapter);
                    fixedGridView();
                    if (picAdapter == null) {
                        picAdapter = new AllCourseGridAdapter(
                                new ArrayList<Course>(), getActivity());
                        gridView.setAdapter(picAdapter);
                    }
                    ((ScrollView) v.findViewById(R.id.scroll_view)).smoothScrollTo(0, 20);
                }

                ;
            });
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return;
        }

    }

    @Override
    public void onStart() {
        scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
        // 当Activity显示出来后，每两秒钟切换一次图片显示
        scheduledExecutorService.scheduleAtFixedRate(new ScrollTask(), 1, 5,
                TimeUnit.SECONDS);
        super.onStart();
    }

    @Override
    public void onStop() {
        // 当Activity不可见的时候停止切换
        scheduledExecutorService.shutdown();
        super.onStop();
    }

    /**
     * 传递信息到浮层
     *
     * @param c
     */

    private void transInfo2Drawer(Course c) {
        MainActivity curActivity = (MainActivity) this.getActivity();
        Intent mIntent = new Intent(curActivity, CourseInfomationActivity.class);
        Bundle mbBundle = new Bundle();
        mbBundle.putSerializable("course", c);
        mIntent.putExtras(mbBundle);
        startActivity(mIntent);
    }

    /**
     * 初始化轮播图下部小点
     */
    private void initPointView() {

        pointLinear.setBackgroundColor(Color.argb(0, 0, 0, 0));
        for (int i = 0; i < courseInfoList.size(); i++) {
            ImageView pointView = new ImageView(MainActivity.getMainActivity());


            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);  // , 1是可选写的
            lp.setMargins(5, 0, 5, 0);
            pointView.setLayoutParams(lp);


            if (i == 0) {
                pointView.setBackgroundResource(R.drawable.page_point_active);
                pro_title.setText(courseInfoList.get(0).getCourseTitle());
                pro_content.setText(courseInfoList.get(0).getCourseBrief());
            } else
                pointView.setBackgroundResource(R.drawable.page_point_dim);
            pointLinear.addView(pointView);
        }
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        gridView.setFocusable(false);
    }

    private void fixedGridView() {
        LayoutParams params = gridView.getLayoutParams();
        params.width = v.getWidth();
        gridView.setLayoutParams(params);
    }

    public List<Course> getAllCourse() {
        return visibleAllCourses;
    }

    public ArrayList<Long> getMyCourseId() {
        return ids;
    }

    public void onDestroyView() {
        super.onDestroyView();
        if (mBroadcastReceiver != null) {
            getActivity().unregisterReceiver(mBroadcastReceiver);
            mBroadcastReceiver = null;
        }
    }

    public class PagerListener implements OnClickListener {

        public void onClick(View v) {
            if (courseInfoList == null) {
                return;
            }
            for (Course c : visibleAllCourses) {
                if (courseInfoList.get(currentItem).getId().equals(c.getId())) {
                    transInfo2Drawer(c);
                }
            }
        }
    }

    /**
     * 当ViewPager中页面的状态发生改变时调用
     *
     * @author Administrator
     */
    private class MyPageChangeListener implements OnPageChangeListener {
        private int oldPosition = 0;

        /**
         * This method will be invoked when a new page becomes selected.
         * position: Position index of the new selected page.
         */
        public void onPageSelected(int position) {
            currentItem = position;

            View view = pointLinear.getChildAt(oldPosition);
            View curView = pointLinear.getChildAt(position);
            if (view != null && curView != null) {
                ImageView pointView = (ImageView) view;
                ImageView curPointView = (ImageView) curView;
                pointView.setBackgroundResource(R.drawable.page_point_dim);
                curPointView
                        .setBackgroundResource(R.drawable.page_point_active);
                pro_title.setText(courseInfoList.get(currentItem)
                        .getCourseTitle());
                pro_content.setText(courseInfoList.get(currentItem)
                        .getCourseBrief());
            }
            oldPosition = position;
        }

        public void onPageScrollStateChanged(int arg0) {

        }

        public void onPageScrolled(int arg0, float arg1, int arg2) {

        }
    }

    /**
     * 换行切换任务
     *
     * @author Administrator
     */
    private class ScrollTask implements Runnable {

        public void run() {
            synchronized (viewPager) {
                currentItem = (currentItem + 1) % urls.size();
                handler.obtainMessage().sendToTarget(); // 通过Handler切换图片
            }
        }
    }

    ;
}
