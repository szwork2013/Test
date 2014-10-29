package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
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
import android.widget.ExpandableListView.OnChildClickListener;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.CourseSquareActivity;
import com.kaikeba.activity.UnitPageActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.ModulesAPI;
import com.kaikeba.common.download.DownloadInfo;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.Item;
import com.kaikeba.common.entity.Module;
import com.kaikeba.common.entity.ModuleVideo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.common.widget.XDListView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.umeng.analytics.MobclickAgent;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.Type;
import java.util.*;
import java.util.concurrent.Semaphore;

/**
 * 课程安排Activity
 *
 * @author Allen
 */
public class CourseArrangeFragment extends Fragment {
    private final static String tag = "CourseArrangeFragment";
    final Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
                    adapter.notifyDataSetChanged();
                    break;
                case 2:
                    if (getActivity() == null) {
                        showNoData();
                        return;
                    }
//				Toast.makeText(getActivity(), "无数据", Toast.LENGTH_SHORT).show();
                    showNoData();
                    break;
                case 3:
                    adapter.notifyDataSetChanged();
                    int groupCount = exList.getCount();
                    for (int i = 0; i < groupCount; i++) {
                        exList.expandGroup(i);
                    }
                    if (Constants.isFreshMyCourse) {
                        Toast.makeText(getActivity(), "您已加入此课程，可以开始学习啦！", Toast.LENGTH_SHORT).show();
                    }
                    showData();
                    break;
            }
//			super.handleMessage(msg);
        }
    };
    private IAdapter adapter;
    private String courseID;
    private LayoutInflater inflater;
    private RelativeLayout view_loading;
    private ImageView loading_fail;
    private RelativeLayout rl_video_player;
    private LinearLayout view_loading_fail;
    private XDListView exList;
    private String pageURL;
    private Activity context;
    private Item item;
    private List<ModuleVideo> moduleVideos;
    private ArrayList<Module> modules;
    private ArrayList<ArrayList<Item>> olditemLists;
    private ArrayList<Item> items = new ArrayList<Item>();
    private List<String> modulesIds = new ArrayList<String>();
    private List<String> itemIds = new ArrayList<String>();
    private Map<String, String> urlMap = new HashMap<String, String>();
    private ImageView iv_course_info_play;
    private DownloadManager downloadManager;
    private String splitStr = "_";
    private String courseName;
    private String bgUrl;
    private CourseModel c;
    private VideoPlayerView video_palyer;
    private BitmapUtils bitmapUtils;
    private int height;
    private int width;
    private int bar_height;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        bitmapUtils = BitmapHelp.getBitmapUtils(getActivity());
        View v = inflater.inflate(R.layout.course_arrange, container, false);
        view_loading = (RelativeLayout) v.findViewById(R.id.view_loading);
        loading_fail = (ImageView) v.findViewById(R.id.loading_fail);
        loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoNetToast(getActivity());
                } else {
                    showLoading();
                    loadModuleData(true);
                }
            }
        });
        view_loading_fail = (LinearLayout) v.findViewById(R.id.view_loading_fail);
        bar_height = CommonUtils.getStatusBarHeight(getActivity());
        width = CommonUtils.getScreenWidth(getActivity());
        height = (int) (Constants.COVER_HEIGHT * (CommonUtils.getScreenWidth(getActivity()) - 10 * Constants.SCREEN_DENSITY) / Constants.COVER_WIDTH + 0.5);
        rl_video_player = (RelativeLayout) v.findViewById(R.id.rl_video_player);
        rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        exList = (XDListView) v.findViewById(R.id.expandableCourseInfo);
        View headerView = inflater.inflate(R.layout.course_group, exList, false);
        exList.setHeaderView(headerView);
        modules = new ArrayList<Module>();
        olditemLists = new ArrayList<ArrayList<Item>>();
        adapter = new IAdapter(modules, olditemLists);
        exList.setAdapter(adapter);
        downloadManager = CourseSquareActivity.getMainActivity().getDownloadManager();
        if (API.VIEW_INTO == 2 || API.VIEW_INTO == 1) {
            setOnChildClickListener();
        }
        context = getActivity();
        Bundle b = getArguments();
        c = (CourseModel) b.getSerializable(ContextUtil.CATEGORY_COURSE);
        courseID = b.getString("courseID");
        courseName = b.getString("courseName");
        bgUrl = b.getString("bgUrl");
        Constants.FULL_SCREEN_NO_CLICK = false;
        video_palyer = new VideoPlayerView(context);
//        video_palyer.setUrl(c.getPromotional_video_url());
//        video_palyer.setImgUrl(c.getCover_image());
        rl_video_player.addView(video_palyer.makeControllerView());


        return v;
    }

    public void release() {
        if (video_palyer != null) {
            video_palyer.onDestroy();
        }
    }

    private void toPlay() {

        Intent intent = new Intent();
        intent.putExtra("url", c.getPromotional_video_url());
        if (API.getAPI().getUserObject() != null) {
            intent.putExtra("user_id", +API.getAPI().getUserObject().getId() + "");
        }
        intent.putExtra("course_id", c.getId() + "");
        intent.setClass(getActivity(), UnitPageActivity.class);
        startActivity(intent);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        loadModuleData(true);

    }

    public void onResume() {
        super.onResume();
        Constants.FULL_SCREEN_NO_CLICK = false;
        MobclickAgent.onPageStart("course_detail_arrangement"); //统计页面
    }

    private void setOnChildClickListener() {
        exList.setOnChildClickListener(new OnChildClickListener() {

            @Override
            public boolean onChildClick(ExpandableListView parent, View v,
                                        final int groupPosition, final int childPosition, long id) {
                // TODO Auto-generated method stub
                int currentNetSate = NetUtil.getNetType(getActivity());
                item = adapter.getChild(groupPosition, childPosition);
                if (item.getType() != null && item.getType().equals("Page")) {
                    if (item.getUrl() != null) {
                        String[] pageStr = item.getUrl().split("/");
                        pageURL = pageStr[pageStr.length - 1];
                        Intent intent = new Intent();
                        intent.putExtra("courseID+pageURL", courseID + "##"
                                + pageURL);
                        intent.putExtra("title", item.getTitle());
//						intent.putExtra("url", item.getUrl());
                        intent.setClass(context, UnitPageActivity.class);
                        context.startActivity(intent);
                    }
                } else if (item.getType() != null && "ExternalTool".equals(item.getType())) {
                    DownloadInfo downloadInfo = downloadManager.getDownloadInfoByCourseId(courseID, item.getId());
                    Log.i(tag, "courseID:" + courseID + "item.getId()：" + item.getId());
                    if (downloadInfo != null) {
                        if (downloadInfo.getState().equals(HttpHandler.State.SUCCESS)) {
                            if (new File(downloadInfo.getLocalURL()).exists()) {
                                video_palyer.onDestroy();
                                Intent intent = new Intent();
                                intent.putExtra("url", downloadInfo.getLocalURL());
                                intent.setClass(context, UnitPageActivity.class);
                                context.startActivity(intent);
                            }
                        } else if (item.getVideoUrl() != null) {
                            if (Constants.NO_NET != currentNetSate) {
                                if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) {
                                    KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                            new View.OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    KKDialog.getInstance().dismiss();
                                                    toPlayNoPos();
                                                    Constants.nowifi_doplay = false;
                                                }
                                            },
                                            new View.OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    KKDialog.getInstance().dismiss();
                                                }
                                            });
                                } else {
                                    toPlayNoPos();
                                }
                            } else {
                                KKDialog.getInstance().showNoNetToast(getActivity());
                            }
                        }
                    } else if (item.getVideoUrl() != null) {
                        if (Constants.NO_NET != currentNetSate) {
                            if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) {

                                KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                                toPlay(groupPosition, childPosition);
                                                Constants.nowifi_doplay = false;
                                            }
                                        },
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                            }
                                        });
                            } else {
                                toPlay(groupPosition, childPosition);
                            }
                        } else {
                            KKDialog.getInstance().showNoNetToast(getActivity());
                        }
                    }
                } else {
                    Toast.makeText(getActivity(),
                            "下个版本即将支持，敬请期待", Toast.LENGTH_SHORT).show();
                }
                return true;
            }
        });
    }

    private void toPlayNoPos() {
        Intent intent = new Intent();
        intent.putExtra("url", item.getVideoUrl());
        intent.setClass(context, UnitPageActivity.class);
        context.startActivity(intent);
    }

    private void toPlay(int groupPosition, int childPosition) {
        Intent intent = new Intent();
        intent.putExtra("url", item.getVideoUrl());
        intent.putExtra("user_id", API.getAPI().getUserObject().getId() + "");
        intent.putExtra("course_id", courseID);
        intent.putExtra("module_id", adapter.getGroup(groupPosition).getId() + "");
        intent.putExtra("item_id", adapter.getChild(groupPosition, childPosition).getId() + "");
        intent.setClass(context, UnitPageActivity.class);
        context.startActivity(intent);
    }

    protected void loadModuleData(final boolean fromCache) {
        if (API.getAPI().alreadySignin()) {
            Type type = new TypeToken<ArrayList<ModuleVideo>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModuleVideosURL(courseID), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    if (data != null) {
                        moduleVideos = (List<ModuleVideo>) data;
                        if (moduleVideos != null && !moduleVideos.isEmpty()) {
                            Constants.videoUrlIsNull = false;
                        }
                        for (ModuleVideo mVideo : moduleVideos) {
                            modulesIds.add("" + mVideo.getModuleID());
                            for (ModuleVideo.ItemVideo item : mVideo.getVideoList()) {
                                itemIds.add(mVideo.getModuleID() + "#" + item.getItemID());
                                urlMap.put(mVideo.getModuleID() + "#" + item.getItemID(), item.getVideoURL());
                            }
                        }
                    }
                }
            });
        }
        Type type = new TypeToken<ArrayList<Module>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModulesURL(courseID), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(final Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    if (modules != null) {
                        modules.clear();
                    }
                    ArrayList<Module> module = (ArrayList<Module>) data;
                    modules.addAll(module);
                    if (modules == null || modules.size() == 0) {
                        handler.sendEmptyMessage(2);
                        return;
                    }
                    final Semaphore semaphore = new Semaphore(0);
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                for (final Module m : modules) {
                                    Type type = new TypeToken<ArrayList<Item>>() {
                                    }.getType();
                                    ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModuleItemsURL(courseID, m.getId() + ""), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {

                                        @Override
                                        public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                                            if (data != null) {
                                                items = (ArrayList<Item>) data;
                                                olditemLists.add(items);
                                                for (Item item : items) {
                                                    if (itemIds.contains(m.getId() + "#" + item.getId())) {
                                                        item.setVideoUrl(urlMap.get(m.getId() + "#" + item.getId()));
                                                    }
                                                }
//                                          adapter.setData(modules, olditemLists);
                                                handler.sendEmptyMessage(3);

                                                semaphore.release();
                                            }
                                        }
                                    });
                                    try {
                                        semaphore.acquire();
                                    } catch (InterruptedException e) {
                                        e.printStackTrace();
                                    }
                                }
                            } catch (ConcurrentModificationException e) {
                                e.printStackTrace();
                            }
                        }
                    }).start();
                    if (Constants.NET_IS_SUCCESS && fromCache) {
                        loadModuleData(false);
                    }
                } else if (modules == null || modules.size() == 0) {
                    handler.sendEmptyMessage(2);
                }
            }
        });
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
        rl_video_player.setVisibility(View.VISIBLE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
        rl_video_player.setVisibility(View.GONE);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (video_palyer != null) {
            video_palyer.screenChange(newConfig, height);
        }
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            exList.setVisibility(View.GONE);
//            CourseInfomationActivity.getCourseInfoActivity().setGone();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            exList.setVisibility(View.VISIBLE);
//            CourseInfomationActivity.getCourseInfoActivity().setVisible();
            rl_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    public void onBackPressed() {
        if (!video_palyer.isScaleTag) {
            getActivity().finish();
        } else {
            video_palyer.onBackPressed();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("course_detail_arrangement");
        if (video_palyer != null) {
            video_palyer.onDestroy();
            video_palyer.unregisterReceiver();
        }
    }

    /**
     * 自定义Module-Item二级菜单数据适配器
     *
     * @author Allen
     */
    class IAdapter extends BaseExpandableListAdapter implements XDListView.XDHeaderAdapter {

        private ArrayList<Module> mGroupArray;
        private ArrayList<ArrayList<Item>> mArrayArray;
        @SuppressLint("UseSparseArrays")
        private HashMap<Integer, Integer> groupStatusMap = new HashMap<Integer, Integer>();

        public IAdapter(ArrayList<Module> groupArray,
                        ArrayList<ArrayList<Item>> arrayArray) {
            super();
            this.mGroupArray = groupArray;
            this.mArrayArray = arrayArray;
        }

        public void setData(ArrayList<Module> groupArray,
                            ArrayList<ArrayList<Item>> arrayArray) {
            if (mGroupArray != null) {
                mGroupArray.clear();
            }
            if (mArrayArray != null) {
                mArrayArray.clear();
            }
            mGroupArray.addAll(groupArray);
            mArrayArray.addAll(arrayArray);
        }

        @Override
        public int getGroupCount() {
            if (mGroupArray.isEmpty()) {
                return 0;
            }
            return this.mGroupArray.size();
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (mArrayArray.isEmpty() || mArrayArray.size() == 0) {
                return 0;
            }
//            Log.e("xxx", this.mGroupArray.size() + " " + mArrayArray.size() + " " + groupPosition);
            if (groupPosition >= mArrayArray.size()) return 0;
            return mArrayArray.get(groupPosition).size();
//            return groupPosition >= 0 ? mArrayArray.get(groupPosition).size():0;

        }

        @Override
        public Module getGroup(int groupPosition) {
            if (mGroupArray.isEmpty()) {
                return null;
            }
            return mGroupArray.get(groupPosition);
        }

        @Override
        public Item getChild(int groupPosition, int childPosition) {
            if (mArrayArray.isEmpty()) {
                return null;
            }
            return mArrayArray.get(groupPosition).get(childPosition);
        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return groupPosition + childPosition;
        }

        @Override
        public boolean hasStableIds() {
            return false;
        }

        @Override
        public View getGroupView(int groupPosition, boolean isExpanded,
                                 View convertView, ViewGroup parent) {
            GroupViewHolder groupViewHolder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.course_group, null);
                groupViewHolder = new GroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GroupViewHolder) convertView.getTag();
            }
            groupViewHolder.module_name.setText(mGroupArray.get(groupPosition)
                    .getName());
            return convertView;
        }

        @Override
        public View getChildView(int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            ChildViewHolder childHolder = null;
            Item item = mArrayArray.get(groupPosition).get(childPosition);
            DownloadInfo downloadInfo = downloadManager.getDownloadInfoByCourseId(courseID, item.getId());
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.course_child, null);
                childHolder = new ChildViewHolder(convertView, downloadInfo);
                convertView.setTag(childHolder);
                childHolder.refresh();
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
                childHolder.update(downloadInfo);
            }
            childHolder.course_name.setText(mArrayArray.get(groupPosition)
                    .get(childPosition).getTitle());
            String type = mArrayArray.get(groupPosition).get(childPosition)
                    .getType();
//			childHolder.courseSpec.setText(type);

            if (!itemIds.isEmpty() && itemIds.contains(mGroupArray.get(groupPosition).getId() + "#" + item.getId())) {
                childHolder.load_video.setOnClickListener(new ClickListener(downloadInfo, mArrayArray.get(groupPosition), mGroupArray.get(groupPosition).getId() + "", item, "Child", mGroupArray.get(groupPosition)));
                childHolder.load_video.setVisibility(View.VISIBLE);
                childHolder.load_video.setImageResource(R.drawable.course_button_download);
//               childHolder.load_progress.setVisibility(View.GONE);
//                childHolder.load_progress.setText(0+"%");
            } else {
                childHolder.load_video.setVisibility(View.GONE);
//                childHolder.load_progress.setVisibility(View.GONE);
            }
            if (downloadInfo != null) {
                HttpHandler<File> handler = downloadInfo.getHandler();
                if (handler != null) {
                    RequestCallBack callBack = handler.getRequestCallBack();
                    if (callBack instanceof DownloadManager.ManagerCallBack) {
                        DownloadManager.ManagerCallBack managerCallBack = (DownloadManager.ManagerCallBack) callBack;
                        if (managerCallBack.getBaseCallBack() == null) {
                            managerCallBack.setBaseCallBack(new DownloadRequestCallBack());
                        }
                    }
                    callBack.setUserTag(new WeakReference<CourseArrangeFragment.ChildViewHolder>(childHolder));
                }
                long fileLength = downloadInfo.getFileLength();
//                if (fileLength > 0) {
//                    childHolder.load_progress.setText((int) (downloadInfo.getProgress() * 100 / fileLength)+"%");
//                    childHolder.load_progress.setVisibility(View.VISIBLE);
//                } else {
//                    childHolder.load_progress.setText(0+"%");
//                    childHolder.load_progress.setVisibility(View.GONE);
//                }
                HttpHandler.State state = downloadInfo.getState();
                switch (state) {
                    case WAITING:
                        childHolder.load_video.setImageResource(R.drawable.download_stop);
                        break;
                    case STARTED:
                        childHolder.load_video.setImageResource(R.drawable.download_stop);
                        break;
                    case LOADING:
                        childHolder.load_video.setImageResource(R.drawable.download_stop);
                        break;
                    case CANCELLED:
                        childHolder.load_video.setImageResource(R.drawable.course_button_download);
                        break;
                    case SUCCESS:
                        childHolder.load_video.setImageResource(R.drawable.download_done);
                        break;
                    case FAILURE:
                        childHolder.load_video.setImageResource(R.drawable.course_button_download);
                        break;
                }
//                    notifyDataSetChanged();
            }
            if ("Page".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_page_gray);
            } else if ("Quiz".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_quiz_gray);
            } else if ("Discussion".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            } else if ("Assignment".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_assignment_gray);
            } else if ("File".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            } else if ("ExternalUrl".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_link_gray);
            } else if ("ExternalTool".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_video_active_gray);
            }
            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

        @Override
        public int getXDHeaderState(int groupPosition, int childPosition) {
            // TODO Auto-generated method stub
            final int childCount = getChildrenCount(groupPosition);
            if (childPosition == childCount - 1) {
                return PINNED_HEADER_PUSHED_UP;
            } else if (childPosition == -1 && !exList.isGroupExpanded(groupPosition)) {
                return PINNED_HEADER_GONE;
            } else {
                return PINNED_HEADER_VISIBLE;
            }
        }

        @Override
        public void configureXDHeader(View header, int groupPosition,
                                      int childPosition, int alpha) {
            // TODO Auto-generated method stub
            Module groupData = (Module) this.getGroup(groupPosition);
            ((TextView) header.findViewById(R.id.course_module)).setText(groupData.getName());
        }

        @Override
        public void setGroupClickStatus(int groupPosition, int status) {
            // TODO Auto-generated method stub
            groupStatusMap.put(groupPosition, status);
        }

        @Override
        public int getGroupClickStatus(int groupPosition) {
            // TODO Auto-generated method stub
            if (groupStatusMap.containsKey(groupPosition)) {
                return groupStatusMap.get(groupPosition);
            } else {
                return 0;
            }
        }

        class ClickListener implements View.OnClickListener {
            List<Item> items;
            private DownloadInfo downloadInfo;
            private String moduleId;
            private Item item;
            private String type;
            private Module module;

            public ClickListener(DownloadInfo downloadInfo, List<Item> items, String moduleId, Item item, String type, Module module) {
                this.downloadInfo = downloadInfo;
                this.moduleId = moduleId;
                this.item = item;
                this.type = type;
                this.items = items;
                this.module = module;
            }

            @Override
            public void onClick(View v) {
                if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoNetToast(getActivity());
                } else {
                    if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoWifi2Doload(getActivity(),
                                new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        KKDialog.getInstance().dismiss();
                                        download();
                                        Constants.nowifi_doload = false;
                                    }
                                },
                                new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        KKDialog.getInstance().dismiss();
                                    }
                                });
                    } else {
                        download();
                    }
                }

            }

            private void download() {
                for (ModuleVideo moduleVideo : moduleVideos) {
                    if (moduleId.equals(moduleVideo.getModuleID() + "")) {
                        for (ModuleVideo.ItemVideo video : moduleVideo.getVideoList()) {
                            if (type.equals("Child") && (item.getId() + "").equals(video.getItemID() + "")) {
                                try {
                                    downloadManager.addNewDownload(API.getAPI().getUserObject().getId() + splitStr + courseID + splitStr + moduleId + splitStr + item.getId(),
                                            courseName,
                                            video.getVideoURL(),
                                            bgUrl,
                                            video.getItemTitle(),
                                            FileUtils.getVideoFilePath(API.getAPI().getUserObject().getId(), courseID, moduleId, item.getId() + "") + video.getItemTitle() + ".mp4",
                                            true,
                                            false,
                                            null);
                                } catch (DbException e) {
                                    LogUtils.e(e.getMessage(), e);
                                }
                                if (item != null && !"已完成".equals(item.getDownloadState())) {
                                    item.setDownloadState("下载中");
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
                if (downloadInfo != null) {
                    HttpHandler.State state = downloadInfo.getState();
                    Log.i(tag, "" + "state:" + state);
                    switch (state) {
                        case STARTED:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case WAITING:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case LOADING:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case CANCELLED:
                            try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case FAILURE:
                            try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        default:
                            try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                    }
                }
                adapter.notifyDataSetChanged();
            }
        }
    }

    public class GroupViewHolder {
        TextView module_name;

        public GroupViewHolder(View v) {
//				number = (TextView) v.findViewById(R.id.number);
            module_name = (TextView) v.findViewById(R.id.course_module);
        }
    }

    public class ChildViewHolder {
        //        TextView courseSpec;
        TextView course_name;
        ImageView course_ImView;
        ImageView load_video;
        //        TextView load_progress;
        private DownloadInfo downloadInfo;

        public ChildViewHolder(View v, DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
//            courseSpec = (TextView) v.findViewById(R.id.courseSpec);
            course_name = (TextView) v.findViewById(R.id.course_name);
            course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
            load_video = (ImageView) v.findViewById(R.id.load_video);
//            load_progress=(TextView)v.findViewById(R.id.load_progress);
        }

        public void update(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
            refresh();
        }

        public void refresh() {
            //TODO
            adapter.notifyDataSetChanged();
        }
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {

        @SuppressWarnings("unchecked")
        private void refreshListItem() {
            if (userTag == null) return;
            try {
                WeakReference<CourseArrangeFragment.ChildViewHolder> tag = (WeakReference<CourseArrangeFragment.ChildViewHolder>) userTag;
                CourseArrangeFragment.ChildViewHolder holder = tag.get();
                if (holder != null) {
                    holder.refresh();
                }
            } catch (ClassCastException e) {
                WeakReference<LoadMangerFragment.ChildViewHolder> tag = (WeakReference<LoadMangerFragment.ChildViewHolder>) userTag;
                LoadMangerFragment.ChildViewHolder holder = tag.get();
                if (holder != null) {
                    holder.refresh();
                }
            }

        }

        @Override
        public void onStart() {
            refreshListItem();
        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            refreshListItem();
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            refreshListItem();
        }

        @Override
        public void onFailure(HttpException error, String msg) {
            refreshListItem();
        }

        @Override
        public void onCancelled() {
            refreshListItem();
        }
    }

}
