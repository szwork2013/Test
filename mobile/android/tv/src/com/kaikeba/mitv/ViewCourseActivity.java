package com.kaikeba.mitv;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CollectInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.TvHistoryInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.DataSource;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.widget.MyRatingBar;
import com.kaikeba.common.widget.NetImageView;
import com.kaikeba.mitv.adapter.VideoListAdapter;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.CourseCardView;
import com.kaikeba.mitv.objects.LargeCourseCardItem;
import com.kaikeba.mitv.utils.PretreatDataCache;
import com.kaikeba.mitv.utils.UrlManager;
import com.kaikeba.mitv.utils.ViewUtil;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.exception.DbException;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kkb on 8/7/14.
 */
public class ViewCourseActivity extends Activity implements View.OnClickListener {

    private static final int REQUESTCODE = 1000;
    public static boolean isHorizonEdgeLeft = true;
    public static boolean isHorizonEdgeRight = false;
    public static BitmapUtils bitmapUtils;
    public boolean isFirstIn = true;
    /**
     * **** grid view *******
     */
    List<CourseCardItem> coursesRecommanded;
    List<CourseCardItem> tempCourse;
    List<CourseCardItem> allCoursesList;
    //    GridView gridView;
//    CourseCardAdapter gridViewAdapter;
    CourseCardView selectedGridViewItem = null;
    /**
     * **** expandable list view *******
     */
    VideoListAdapter listAdapter;
    ListView videoListView;
    TextView selectedCourseTextView;
    TextView selectedWatchProgressTextView;
    /**
     * 筛选出 所有含视频的 module-item
     */
    List<CourseModel.Items> _videoListData = new ArrayList<CourseModel.Items>();
    private CourseCardItem course;
    private boolean hasCollect = false;
    private NetImageView courseImageView;
    private ImageView courseTypeImageView;
    private TextView teacherTextView;
    private TextView schoolTextView;
    private MyRatingBar rating;
    private TextView durationTextView;
    private TextView scoreTextView;
    private TextView courseTitleTextView;
    private TextView courseIntroTextView;
    private TextView playProgressTextView;
    private Button playButton;
    private Button favorButton;
    private ImageView icon_time;
    private LinearLayout courseRecommandLL;
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private RelativeLayout view_loading;
    private View previousSelectedCell;
    private boolean comesInFirstTime = true;

    public static void setHorizonEdge(boolean left, boolean right) {
        isHorizonEdgeLeft = left;
        isHorizonEdgeRight = right;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.view_course);
        bitmapUtils = BitmapHelp.getBitmapUtils(ViewCourseActivity.this);
        getCourseInfo();
        initView();
        initGridView();
        initGridViewData();

        loadVideoData(true);
        loadVideoData(false);
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();

        setPlayButtonStatue();
        setCollectStatue();

        isFirstIn = true;
        if (listAdapter != null) {
            listAdapter.notifyDataSetChanged();
        }
    }

    private void initData() {
        if (course != null) {
            courseImageView.setUrl(course.getCover_image());
//            bitmapUtils.display(courseImageView,course.getCover_image());
            if (course.getType().equals("InstructiveCourse")) {
                courseTypeImageView.setImageResource(R.drawable.instrutive);
                boolean zeroWeek = (course.getWeeks() == 0);
                durationTextView.setVisibility(zeroWeek ? View.INVISIBLE : View.VISIBLE);
                durationTextView.setText(course.getWeeks() + "周时长");
            } else {
                durationTextView.setText("共" + course.getTotal_amount() + "节视频");
                courseTypeImageView.setImageResource(R.drawable.public_course);
            }


            if (course.getTechInfo() != null && course.getTechInfo().size() > 0) {
                teacherTextView.setText("讲师:" + course.getTechInfo().get(0).getName());
                schoolTextView.setText("机构:" + course.getTechInfo().get(0).getIntro());
                rating.setRating(course.getRating() * 1.0f / 2);
                scoreTextView.setText(course.getRating() + "分");
            }
            courseTitleTextView.setText(course.getName());
            courseIntroTextView.setText(course.getIntro());

        }
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        KKDialog.getInstance().showNoDataDialog(ViewCourseActivity.this,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                        KKDialog.getInstance().dismiss();
                    }
                },
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        initGridViewData();
                        loadVideoData(true);
                        loadVideoData(false);
                        initData();
                        KKDialog.getInstance().dismiss();
                    }
                });
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void setPlayButtonStatue() {

        TvHistoryInfo info = getTvHistoryInfo();

        if (info != null) {
            icon_time.setVisibility(View.VISIBLE);
            playButton.setBackgroundResource(R.drawable.continue_play_selector);
            playProgressTextView.setVisibility(View.VISIBLE);
            playProgressTextView.setText("上次观看到: " + VideoListAdapter.formatLongToTimeStr(info.getLastTime()));
        } else {
            playButton.setBackgroundResource(R.drawable.play_selector);
            playProgressTextView.setVisibility(View.INVISIBLE);
            icon_time.setVisibility(View.INVISIBLE);
        }
    }

    private TvHistoryInfo getTvHistoryInfo() {
        TvHistoryInfo info = null;
        try {
            List<TvHistoryInfo> list = DataSource.getDataSourse().findAllTvHistory();
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    if (course.getId() == list.get(i).getCourseId()) {
                        info = list.get(i);
                        break;
                    }
                }
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return info;
    }

    private void setCollectStatue() {
        try {
            List<CollectInfo> list = DataSource.getDataSourse().findAllTvCollect();
            CollectInfo info = null;
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    if (course.getId() == list.get(i).getCourseId()) {
                        hasCollect = true;
                        break;
                    }
                }
            }
            setfavorType();
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private void setfavorType() {
        if (hasCollect) {
            favorButton.setBackgroundResource(R.drawable.collected_selector);
        } else {
            favorButton.setBackgroundResource(R.drawable.collect_selector);
        }
    }

    private void initView() {
        courseImageView = (NetImageView) findViewById(R.id.courseImageView);
        courseTypeImageView = (ImageView) findViewById(R.id.courseTypeImageView);
        teacherTextView = (TextView) findViewById(R.id.teacherTextView);
        schoolTextView = (TextView) findViewById(R.id.schoolTextView);
        rating = (MyRatingBar) findViewById(R.id.rating);
        durationTextView = (TextView) findViewById(R.id.durationTextView);
        scoreTextView = (TextView) findViewById(R.id.scoreTextView);
        courseTitleTextView = (TextView) findViewById(R.id.courseTitleTextView);
        courseIntroTextView = (TextView) findViewById(R.id.courseIntroTextView);
        playProgressTextView = (TextView) findViewById(R.id.playProgressTextView);
        playButton = (Button) findViewById(R.id.playButton);
        favorButton = (Button) findViewById(R.id.favorButton);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        icon_time = (ImageView) findViewById(R.id.imageView);
        courseRecommandLL = (LinearLayout) findViewById(R.id.courseRecommandGridView);

        playButton.setOnClickListener(this);
        favorButton.setOnClickListener(this);
        loading_fail.setOnClickListener(this);

        videoListView = (ListView) findViewById(R.id.listView);
        listAdapter = new VideoListAdapter(this, course, _videoListData);

        // setting list adapter
        videoListView.setAdapter(listAdapter);
    }

    private void selectLastWatchedVideoItem() {

        TvHistoryInfo info = getTvHistoryInfo();
        if (info != null) {
            int lastWatchedIndex = info.getIndex() - 1;

            if (lastWatchedIndex >= 0) {
                videoListView.setSelection(lastWatchedIndex);
            }
        } else {

            videoListView.setSelection(0);
        }

    }

    private void initGridViewData() {
        coursesRecommanded.clear();
        tempCourse.clear();
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object allCourseData) {

                if (allCourseData != null) {
                    allCoursesList = (List<CourseCardItem>) allCourseData;
                    List<Integer> courseIdList = course.getRecommen();
                    if (courseIdList != null && allCoursesList != null) {
                        for (Integer i : courseIdList) {
                            for (CourseCardItem item : allCoursesList) {
                                if (item.getId() == i && "online".equals(item.getStatus())) {
                                    tempCourse.add(item);
                                    break;
                                }
                            }
                        }
//                        gridViewAdapter.notifyDataSetChanged();
                        initRecommendView();

                    }
                }
            }
        });
    }

    private void initRecommendView() {
        courseRecommandLL.removeAllViews();
        if (tempCourse.size() > 4) {
            coursesRecommanded.addAll(tempCourse.subList(0, 4));
        } else {
            coursesRecommanded.addAll(tempCourse);
        }
        for (int i = 0; i < coursesRecommanded.size(); i++) {
            coursesRecommanded.get(i).setIsRecommend(true);
            final LinearLayout ll = new LinearLayout(this);
            ll.setLayoutParams(ViewUtil.getInstance().getLLParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1));
            ll.setGravity(Gravity.CENTER);
            final LargeCourseCardItem cardView = ViewUtil.getInstance().initLargeCourseCard(this, coursesRecommanded.get(i), Common.FROM_RECOMMEND);
            ll.addView(cardView);
            courseRecommandLL.addView(ll);
            final int finalI = i;
            cardView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean hasFocus) {
                    cardView.setBottomViewContainerHidden(!hasFocus);
                    if (hasFocus) {
                        if (view == cardView) {
                            if (finalI == 0) {
                                setHorizonEdge(true, false);
                            } else if (finalI == coursesRecommanded.size() - 1) {
                                setHorizonEdge(false, true);
                            } else {
                                setHorizonEdge(false, false);
                            }
                        }
                    }
                }
            });
            cardView.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View view, int i, KeyEvent keyEvent) {
                    if (keyEvent.getAction() == KeyEvent.ACTION_DOWN) {
                        int keyCode = keyEvent.getKeyCode();

                        if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                            Intent intent = new Intent(ViewCourseActivity.this, ViewCourseActivity.class);
                            CourseCardItem c = (CourseCardItem) cardView.getTag();
                            intent.putExtra("cardItem", c);
                            startActivity(intent);
                        }
                        switch (keyCode) {
                            case KeyEvent.KEYCODE_DPAD_LEFT:
                                if (isHorizonEdgeLeft) {
                                    return true;
                                }

                                break;
                            case KeyEvent.KEYCODE_DPAD_RIGHT:
                                if (isHorizonEdgeRight) {
                                    return true;
                                }
                                break;
                        }
                    }
                    return false;
                }
            });
        }

        if (coursesRecommanded.size() < 4) {
            for (int i = 0; i < 4 - coursesRecommanded.size(); i++) {
                LinearLayout ll = new LinearLayout(this);
                ll.setLayoutParams(ViewUtil.getInstance().getLLParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1));
                courseRecommandLL.addView(ll);
            }
        }
    }

    private void initGridView() {

        coursesRecommanded = new ArrayList<CourseCardItem>();
        tempCourse = new ArrayList<CourseCardItem>();
//        gridViewAdapter = new CourseCardAdapter(this, coursesRecommanded);
//        gridView = (GridView) findViewById(R.id.courseRecommandGridView);
        /*gridView.setAdapter(gridViewAdapter);
        gridView.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                CourseCardItem cardItem = coursesRecommanded.get(position);
                cardItem.setFocused(true);

                if (selectedGridViewItem != null){
                    selectedGridViewItem.setBottomViewContainerHidden(true);
                }

                CourseCardView cardView = (CourseCardView) view;
                cardView.setBottomViewContainerHidden(false);

                selectedGridViewItem = cardView;

                CourseCardAdapter adapter = (CourseCardAdapter)adapterView.getAdapter();
                adapter.enlargeView(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        gridView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocused) {

                if (selectedGridViewItem != null) {
                    selectedGridViewItem.setBottomViewContainerHidden(!hasFocused);
                }
            }
        });

        gridView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {

                if (event.getAction() == KeyEvent.ACTION_DOWN){
                    if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                        Intent intent = new Intent(ViewCourseActivity.this, ViewCourseActivity.class);
                        CourseCardItem c = (CourseCardItem) gridView.getSelectedItem();
                        intent.putExtra("cardItem", c);
                        startActivity(intent);
                    }
                }
                return false;
            }
        });*/
    }

    private void loadVideoData(final boolean fromCache) {
        String url = UrlManager.getInstance().getCOURSES_INFO() + course.getId();
        Type type = new TypeToken<CourseCardItem>() {
        }.getType();

        if (fromCache) {
            showLoading();
        }

        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    course = (CourseCardItem) data;
                    getAllVideoData(course);
                    showData();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    public void getAllVideoData(CourseCardItem course) {
        if (course.getLms_course_list() != null) {
            _videoListData.clear();
            CourseModel.GuidCourseLMS courseLMS = course.getLms_course_list().get(0);
            for (CourseModel.CourseArrange courseTitle : courseLMS.getCourse_arrange()) {
                for (CourseModel.Items item : courseTitle.getItems()) {
                    if (item.getType().equals("ExternalTool")) {
                        _videoListData.add(item);
                    }
                }
            }
            initVideoListView();
        }
    }

    private void initVideoListView() {
        // get the listview
        listAdapter.notifyDataSetChanged();
        videoListView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        videoListView.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {

                if (previousSelectedCell != null) {
                    // 将上一次的选中项标记为默认样式

                    // 将【课程名】文字变灰
                    TextView previousSelectedCourseNameTextView = (TextView) previousSelectedCell.findViewById(R.id.courseNameTextView);
                    previousSelectedCourseNameTextView.setTextColor(getResources().getColor(R.color.course_card_title_color));

                    // 将【上次观看记录】文字变灰
                    TextView previousSelectedWatchProgressTextView = (TextView) previousSelectedCell.findViewById(R.id.watchProgressTextView);
                    previousSelectedWatchProgressTextView.setTextColor(getResources().getColor(R.color.course_card_title_color));
                }


                if (comesInFirstTime) {

                    // 将【课程名】文字变灰色, 并去除荧光效果（如果有的话）
                    TextView courseNameTextView = (TextView) view.findViewById(R.id.courseNameTextView);
                    courseNameTextView.setTextColor(getResources().getColor(R.color.course_card_title_color));
                    courseNameTextView.setShadowLayer(0, 0, 0, getResources().getColor(R.color.color_bai));

                    // 将【上次观看记录】文字变灰色, 并去除荧光效果（如果有的话）
                    TextView watchProgressTextView = (TextView) view.findViewById(R.id.watchProgressTextView);
                    watchProgressTextView.setTextColor(getResources().getColor(R.color.course_card_title_color));
                    watchProgressTextView.setShadowLayer(0, 0, 0, getResources().getColor(R.color.color_bai));

                    comesInFirstTime = false;
                } else {

                    // 将【课程名】文字变白, 并去除荧光效果（如果有的话）
                    TextView courseNameTextView = (TextView) view.findViewById(R.id.courseNameTextView);
                    courseNameTextView.setTextColor(getResources().getColor(R.color.color_bai));
                    courseNameTextView.setShadowLayer(0, 0, 0, getResources().getColor(R.color.color_bai));

                    // 将【上次观看记录】文字变白, 并去除荧光效果（如果有的话）
                    TextView watchProgressTextView = (TextView) view.findViewById(R.id.watchProgressTextView);
                    watchProgressTextView.setTextColor(getResources().getColor(R.color.color_bai));
                    watchProgressTextView.setShadowLayer(0, 0, 0, getResources().getColor(R.color.color_bai));
                }

                previousSelectedCell = view;
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        videoListView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocused) {

                if (hasFocused) {

                } else {

                }
            }
        });

        videoListView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {

                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                        CourseModel.Items video = (CourseModel.Items) videoListView.getSelectedItem();
                        Intent it = new Intent();
                        it.setClass(ViewCourseActivity.this, UnitPageActivity.class);
                        it.putExtra("url", video.getUrl());
                        it.putExtra("courseItem", course);
                        addTvHistory(video, (int) video.getPosition() + 1);
                        startActivityForResult(it, REQUESTCODE);
                    }
                }

                if (event.getAction() == KeyEvent.ACTION_UP) {
                    if (keyCode == KeyEvent.KEYCODE_DPAD_RIGHT) {
                        // 处理【收藏】按钮的向右按键操作

                        selectLastWatchedVideoItem();

                        return true;
                    }
                }

                return false;
            }
        });

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUESTCODE) {
            if (listAdapter != null) {
                listAdapter.notifyDataSetChanged();
            }
//            setPlayButtonStatue();
        }
    }

    private void addTvHistory(CourseModel.Items video, int index) {
        String type = course.getType().equals("InstructiveCourse") ? "导学" : "公开";
        TvHistoryInfo info = new TvHistoryInfo();//course.getId(),"",video.getId(),0,type,index);
        info.setIndex(index);
        info.setCourseId(course.getId());
        info.setVideoId(video.getId());
        info.setType(type);
        info.setLastTime(0);
        try {
            List<TvHistoryInfo> list = DataSource.getDataSourse().findAllTvHistory();
            if (list != null) {
                for (TvHistoryInfo tvHistoryInfo : list) {
                    if (course.getId() == tvHistoryInfo.getCourseId()) {
                        DataSource.getDataSourse().deleteTvHistoryData(tvHistoryInfo);
                    }
                }
                DataSource.getDataSourse().addTvHistoryData(info);
            } else {
                DataSource.getDataSourse().addTvHistoryData(info);
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private void updateTvHistory(int index, CourseModel.Items itemVideo) {
        TvHistoryInfo info = findLastTvHistory();
        info.setIndex(index + 1);
        info.setVideoId(itemVideo.getId());
        info.setLastTime(0);
        try {
            DataSource.getDataSourse().updateTvHistory(info);
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private TvHistoryInfo findLastTvHistory() {

        try {
            List<TvHistoryInfo> list = DataSource.getDataSourse().findAllTvHistory();
            if (list != null) {
                for (TvHistoryInfo tvHistoryInfo : list) {
                    if (course.getId() == tvHistoryInfo.getCourseId()) {
                        return tvHistoryInfo;
                    }
                }

            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void getCourseInfo() {
        Bundle b = getIntent().getExtras();
        course = (CourseCardItem) b.getSerializable("cardItem");
    }

    @Override
    public void onClick(View v) {
        if (v.equals(playButton)) {
            Intent it = new Intent();
            it.setClass(ViewCourseActivity.this, UnitPageActivity.class);
            TvHistoryInfo info = findLastTvHistory();
            List<CourseModel.Items> itemses = new ArrayList<CourseModel.Items>();
            itemses.addAll(_videoListData);
            if (info != null) {
                String url = "";
                int index = 0;
                for (CourseModel.Items itemVideo : itemses) {
                    index++;
                    if (itemVideo.getId() == info.getVideoId()) {
                        url = itemVideo.getUrl();
                        break;
                    }
                }
                Log.d("jack", "index:" + index + "  size():" + itemses.size());
                if (Math.abs(info.getLastTime() - info.getDuationTime()) < 500 && info.getDuationTime() != 0) {
                    if (index <= itemses.size()) {
                        it.putExtra("url", itemses.get(index % itemses.size()).getUrl());
                        updateTvHistory(index % itemses.size(), itemses.get(index % itemses.size()));
                        info = findLastTvHistory();
                    }
                } else {
                    it.putExtra("url", url);
                }
                it.putExtra("duation", info.getLastTime());
            } else if (itemses != null && itemses.size() > 0) {
                it.putExtra("url", itemses.get(0).getUrl());
                addTvHistory(itemses.get(0), 1);
            } else {
                return;
            }
            it.putExtra("courseItem", course);
            startActivityForResult(it, REQUESTCODE);
        } else if (v.equals(favorButton)) {
            if (hasCollect) {
                cancleCollect();
                hasCollect = false;
                setfavorType();
            } else {
                addCollect();
                hasCollect = true;
                setfavorType();
            }
        } else if (v.equals(loading_fail)) {
            loadVideoData(true);
        }
    }

    private void addCollect() {
        CollectInfo info = new CollectInfo();
        info.setConllect(true);
        info.setCourseId(course.getId());
        try {
            DataSource.getDataSourse().addCollectData(info);
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private void cancleCollect() {
        try {
            List<CollectInfo> list = getCollectCourseList();
            CollectInfo cancelInfo = null;
            if (list != null) {
                for (int index = 0; index < list.size(); index++) {
                    if (course.getId() == list.get(index).getCourseId()) {
                        cancelInfo = list.get(index);
                    }
                }
            }
            DataSource.getDataSourse().deleteCollectData(cancelInfo);
        } catch (DbException e) {
            e.printStackTrace();
        }
    }


    private List<CollectInfo> getCollectCourseList() {
        try {

            return DataSource.getDataSourse().findAllTvCollect();

        } catch (DbException e) {
            e.printStackTrace();
        }
        return null;
    }
}
