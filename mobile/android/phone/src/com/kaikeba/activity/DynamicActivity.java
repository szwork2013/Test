package com.kaikeba.activity;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.google.gson.reflect.TypeToken;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.adapter.DynamicListAdapter;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.DynamicFirstPageInfo;
import com.kaikeba.common.entity.DynamicTitleInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by cwang on 14-7-18.
 */
public class DynamicActivity extends Activity {
    public static final String fromHere = "DYNAMIC_ACTIVITY";
    private Context mContext;
    private LinearLayout dynamic_top_view;
    private TextView dynamic_top_txt;
    private ImageView dynamic_top_img;
    private PullToRefreshListView dynamic_list_view;
    private Drawable loadingDraw;
    private DynamicListAdapter adapter;
    private ObjectAnimator fadeAnim;
    private FrameLayout frmlayout_dynamic;
    private int top_view_height;
    private DynamicTitleInfo titleInfo;
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;
    private LinearLayout ll_no_dynamic;
    private List<CourseModel> allCourseInfo = new ArrayList<CourseModel>();
    private ArrayList<DynamicFirstPageInfo> dynamicList;
    private CourseModel dynamicTop = null;
    private long exitTime = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dynamic);
        mContext = this;
        ininView();
        initData(true);
        initData(false);
    }

    private void showSuccessData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showloading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void initData(boolean fromCache) {
        String url = HttpUrlUtil.DYNAMIC;//"https://api.kaikeba.com/v1/userapply/dynamic";
        String urltitle = HttpUrlUtil.PLAY_RECORDS;//"https://api.kaikeba.com/v1/play_records";
        if (fromCache) {
            showloading();
        }
        if (API.getAPI().alreadySignin()) {
            loadData(urltitle, url, fromCache);
        }
    }

    /**
     * 获取导学课的所有视频集合
     *
     * @param courseModel
     * @param lms_list_id
     * @param video_id
     * @return
     */
    private List<CourseModel.Items> getVideos(CourseModel courseModel, int lms_list_id, int video_id) {
        List<CourseModel.GuidCourseLMS> lmsCourses = courseModel.getLms_course_list();
        for (CourseModel.GuidCourseLMS lms : lmsCourses) {
            if (lms.getLms_course_id() == lms_list_id) {
                List<CourseModel.CourseArrange> courseArranges = lms.getCourse_arrange();
                for (CourseModel.CourseArrange arrange : courseArranges) {
                    List<CourseModel.Items> items = arrange.getItems();
                    for (CourseModel.Items item : items) {
                        if (item.getId() == video_id) {
                            return items;
                        }
                    }
                }
            }
        }
        return null;
    }

    private String getVideoUrl(List<CourseModel.Items> info) {
        String url = "";
        if (info == null) {
            return "";
        }
        for (int i = 0; i < info.size(); i++) {
            if (titleInfo.getLast_video_id() == info.get(i).getId()) {
                url = info.get(i).getUrl();
            }
        }

        return url;
    }

    private void loadData(String urltitle, String url, final boolean fromCache) {
        Type type = new TypeToken<ArrayList<DynamicFirstPageInfo>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    ArrayList<DynamicFirstPageInfo> cacheData = (ArrayList<DynamicFirstPageInfo>) data;
                    dynamicList.clear();
                    dynamicList.addAll(cacheData);
                    if (cacheData.size() == 0) {
                        ll_no_dynamic.setVisibility(View.VISIBLE);
                    } else {
                        ll_no_dynamic.setVisibility(View.GONE);
                    }
                    adapter.notifyDataSetChanged();
                    showSuccessData();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
        ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
            @Override
            public void onAuthenticationFail() {
                Intent i = new Intent(mContext, AllCourseActivity.class);
                mContext.startActivity(i);
                ((Activity) mContext).finish();
            }
        });
        Type typetitle = new TypeToken<DynamicTitleInfo>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(urltitle, null, fromCache, typetitle, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    titleInfo = (DynamicTitleInfo) data;
                    setTitle(titleInfo);
                    getCourseByID(titleInfo.getCourse_id(), fromCache);
                    if (fromCache) {
                        judgeOpenTop();
                    }
                }
            }
        });
    }

    protected void getCourseByID(int courseId, boolean fromCache) {

        Type type = new TypeToken<CourseModel>() {
        }.getType();
        String url = "https://api.kaikeba.com/v1/courses/" + courseId;
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(final Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    dynamicTop = (CourseModel) data;
                }
            }
        });
    }

    private void setTitle(DynamicTitleInfo info) {
        String type = "";
        if (info.getType().equals("OpenCourse")) {
            type = "公开课";
            dynamic_top_txt.setText("上次观看公开课" + "《" + info.getCourse_name() + "》");
        } else {
            type = "导学课";
            dynamic_top_txt.setText("上次学习导学课" + "《" + info.getCourse_name() + "》");
        }
    }

    public void ininView() {
        frmlayout_dynamic = (FrameLayout) findViewById(R.id.frmlayout_dynamic);
        dynamic_top_view = (LinearLayout) findViewById(R.id.dynamic_top_view);
        dynamic_top_txt = (TextView) findViewById(R.id.dynamic_top_txt);
        dynamic_top_img = (ImageView) findViewById(R.id.dynamic_top_img);
        dynamic_list_view = (PullToRefreshListView) findViewById(R.id.dynamic_list_view);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        ll_no_dynamic = (LinearLayout) findViewById(R.id.ll_no_dynamic);
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        dynamic_top_view.measure(w, h);
        top_view_height = dynamic_top_view.getMeasuredHeight();
        setListener();
        dynamicList = new ArrayList<DynamicFirstPageInfo>();
        adapter = new DynamicListAdapter(mContext, dynamicList);
        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        dynamic_list_view.setMode(PullToRefreshBase.Mode.PULL_FROM_START);
        dynamic_list_view.setReleaseLabel("放手刷新");
        dynamic_list_view.setRefreshingLabel("正在刷新...");
        dynamic_list_view.setPullLabel("下拉刷新");
        dynamic_list_view.setLoadingDrawable(loadingDraw);
        dynamic_list_view.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener<ListView>() {
            @Override
            public void onRefresh(PullToRefreshBase<ListView> refreshView) {
                // Do work to refresh the list here.
                new GetDataTask().execute();
            }
        });
        dynamic_list_view.setAdapter(adapter);
    }

    private void judgeOpenTop() {
        boolean isopenTop = true;
        if (titleInfo != null) {
            CourseModel info = dynamicTop;
            List<CourseModel.Items> videos = null;
            if (info != null) {
                videos = getVideos(info, titleInfo.getLms_course_id(), titleInfo.getLast_video_id());
            }
            if (videos != null) {
                for (int i = 0; i < videos.size(); i++) {
                    CourseModel.Items video = videos.get(i);  //如果视频已经播放完 就不显示
                    if (video.getId() == titleInfo.getLast_video_id() && (i == videos.size() - 1) && titleInfo.getVideolen().equals(titleInfo.getDuration() + "")) {
                        isopenTop = false;
                    }
                }
            }
        } else {
            isopenTop = false;
        }

        if (isopenTop) {
            openTop();
        }
    }

    public void setListener() {
        view_loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initData(true);
            }
        });

        dynamic_top_img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                closeTop();
            }
        });

        dynamic_top_view.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (titleInfo != null) {
                    if(Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(DynamicActivity.this)){
                        show3gPlayDialog();
                    }else{
                        startCousrsePageActivity();
                    }
                }
            }
        });
    }

    private void show3gPlayDialog(){
        KKDialog.getInstance().showNoWifi2Play(DynamicActivity.this,new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startCousrsePageActivity();
                        KKDialog.getInstance().dismiss();
                    }
                },
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        KKDialog.getInstance().dismiss();
                    }
                });
    }

    private void startCousrsePageActivity(){
        Intent it = new Intent();
        Bundle b = new Bundle();
        CourseModel info = dynamicTop;
        String videoUrl = getVideoUrl(getVideos(info, titleInfo.getLms_course_id(), titleInfo.getLast_video_id()));
        b.putInt("videoID", titleInfo.getLast_video_id());
        b.putInt("duation", titleInfo.getDuration() * 1000);
        Log.i("GuideCourseLearnActivity", "from dynamic getDuration = " + titleInfo.getDuration());
        b.putString("videoUrl", videoUrl);
        b.putInt("lms_course_id", titleInfo.getLms_course_id());
        b.putSerializable(ContextUtil.CATEGORY_COURSE, info);
        it.putExtras(b);
        if (titleInfo.getType().equals("OpenCourse")) {
            it.setClass(DynamicActivity.this, OpenCourseActivity.class);
        } else {
            it.setClass(DynamicActivity.this, GuideCourseLearnActivity.class);
            Constants.isFromDynamicTop = true;
        }
        Constants.FROM_WHERE = Constants.FROM_DYNAMIC;
        startActivity(it);
        closeTop();
    }

    public void openTop() {
        dynamic_top_view.setVisibility(View.VISIBLE);
        fadeAnim = ObjectAnimator.ofFloat(dynamic_top_view, "y", -top_view_height, 0).setDuration(1000);
        fadeAnim.start();
        ObjectAnimator.ofFloat(dynamic_list_view, "y", 0, top_view_height - 60/* + CommonUtils.getStatusBarHeight(mContext)*/).setDuration(800).start();
        ViewGroup.LayoutParams params = dynamic_list_view.getLayoutParams();
        params.width = CommonUtils.getScreenWidth(mContext);
        params.height = CommonUtils.getScreenHeight(mContext) - top_view_height - CommonUtils.getStatusBarHeight(mContext) - TabCourseActivity.getTabHeight4Dynamic();
        dynamic_list_view.setLayoutParams(params);

    }

    public void closeTop() {
        fadeAnim = ObjectAnimator.ofFloat(dynamic_top_view, "y", 0, -top_view_height/*-CommonUtils.getStatusBarHeight(mContext)*/ - 60).setDuration(500);
        fadeAnim.start();
        fadeAnim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animator) {

            }

            @Override
            public void onAnimationEnd(Animator animator) {
                dynamic_top_view.setVisibility(View.GONE);
            }

            @Override
            public void onAnimationCancel(Animator animator) {

            }

            @Override
            public void onAnimationRepeat(Animator animator) {

            }
        });
        ViewGroup.LayoutParams params = dynamic_list_view.getLayoutParams();
        params.width = CommonUtils.getScreenWidth(mContext);
        params.height = frmlayout_dynamic.getMeasuredHeight();
        dynamic_list_view.setLayoutParams(params);
        ObjectAnimator.ofFloat(dynamic_list_view, "y", top_view_height /*+CommonUtils.getStatusBarHeight(mContext)*/, 0).setDuration(300).start();

    }

    @Override
    public void onBackPressed() {
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            finish();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("Dynamic"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("Dynamic");
        MobclickAgent.onPause(this);
    }

    private class GetDataTask extends AsyncTask<Void, Void, String[]> {

        @Override
        protected String[] doInBackground(Void... params) {
            initData(false);
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String[] result) {
            // Call onRefreshComplete when the list has been refreshed.
            super.onPostExecute(result);
            dynamic_list_view.onRefreshComplete();
            dynamic_list_view.setLoadingDrawable(loadingDraw);
            dynamic_list_view.setReleaseLabel("放手刷新");
            dynamic_list_view.setRefreshingLabel("正在刷新...");
            dynamic_list_view.setPullLabel("下拉刷新");

        }
    }

}
