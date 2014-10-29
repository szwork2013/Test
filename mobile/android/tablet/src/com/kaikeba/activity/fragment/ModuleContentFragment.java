package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.ExpandableListView.OnChildClickListener;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.ModulesAPI;
import com.kaikeba.common.download.DownloadInfo;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.entity.Item;
import com.kaikeba.common.entity.Module;
import com.kaikeba.common.entity.ModuleVideo;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.XDListView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.util.LogUtils;

import java.util.*;

/**
 * 加载单元内容
 *
 * @author Allen
 */
public class ModuleContentFragment extends Fragment {

    final Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 1:
                    adapter.notifyDataSetChanged();
                    break;
                case 2:
                    if (getActivity() == null) {
                        return;
                    }
                    Toast.makeText(getActivity(), "无数据", Toast.LENGTH_SHORT).show();
                    view_loading.setVisibility(View.GONE);
                    break;
                case 3:
                    adapter.notifyDataSetChanged();
                    int groupCount = exList.getCount();
                    for (int i = 0; i < groupCount; i++) {

                        exList.expandGroup(i);
                    }
                    view_loading.setVisibility(View.GONE);
                    break;
            }
            super.handleMessage(msg);
        }
    };
    ArrayList<ArrayList<Item>> olditemLists;
    ArrayList<Module> modules;
    boolean isOk = false;
    private IAdapter adapter;
    private String courseID;
    private String courseName;
    private String bgUrl;
    private LayoutInflater inflater;
    private LinearLayout view_loading;
    private XDListView exList;
    private String pageURL;
    private MyCourseItemFragment fragment;
    private List<String> modulesIds = new ArrayList<String>();
    private List<String> itemIds = new ArrayList<String>();
    private Map<String, String> urlMap = new HashMap<String, String>();
    private DownloadManager downloadManager;
    private List<ModuleVideo> moduleVideos;
    private ModuleNavFragment moduleNavFragment;
    private int loaded;
    private int unload;
    private String splitStr = "_";

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.unit_course_arrange, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        exList = (XDListView) v.findViewById(R.id.expandableCourseInfo);
        View headerView = inflater.inflate(R.layout.unit_course_group, exList, false);
        exList.setHeaderView(headerView);
        adapter = new IAdapter(new ArrayList<Module>(), new ArrayList<ArrayList<Item>>());
        exList.setAdapter(adapter);
        setOnChildClickListener();
        downloadManager = MainActivity.getMainActivity().getDownloadManager();
        Constants.videoUrlIsNull = true;
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        moduleNavFragment = (ModuleNavFragment) getFragmentManager().findFragmentByTag("ModuleNavFragment");
        courseID = getArguments().getString(getResources().getString(R.string.courseId));
        courseName = getArguments().getString("courseName");
        bgUrl = getArguments().getString("bgUrl");
        loadModuleData();
        if (Constants.DOWNLOAD_VIEW == 2) {
            FragmentTransaction ft = getFragmentManager()
                    .beginTransaction();
            fragment = new MyCourseItemFragment(((ModuleActivity) getActivity()).getString());
            ft.add(R.id.module_content_container, fragment, "单元条");
            ft.show(fragment);
            ft.hide(ModuleContentFragment.this);
            ft.commit();
        }
        ;
    }

    private void setOnChildClickListener() {
        exList.setOnChildClickListener(new OnChildClickListener() {

            private Item item;

            @Override
            public boolean onChildClick(ExpandableListView parent, View v,
                                        int groupPosition, int childPosition, long id) {
                Module module = adapter.getGroup(groupPosition);
                if (module != null) {
                    Date startDate = module.getUnlockAt();
                    if (startDate != null && !DateUtils.getDateprice(startDate)) {
                        Toast.makeText(getActivity(), "未解锁", Toast.LENGTH_SHORT).show();
                        return false;
                    }
                } else {
                    return false;
                }
                item = adapter.getChild(groupPosition, childPosition);
                if (item.getType().equals("Page") || item.getType().equals("ExternalTool")) {
                    if (item.getUrl() != null) {
                        Constants.DOWNLOAD_VIEW = 1;
                        String[] pageStr = item.getUrl().split("/");
                        pageURL = pageStr[pageStr.length - 1];
                        fragment = new MyCourseItemFragment();
                        FragmentTransaction ft = getFragmentManager()
                                .beginTransaction();

                        Bundle b = new Bundle();
                        b.putString("courseID+pageURL", courseID + "##"
                                + pageURL);
                        fragment.setArguments(b);

                        ft.add(R.id.module_content_container, fragment, "单元条");
                        ft.show(fragment);
                        ft.hide(ModuleContentFragment.this);
                        ft.commit();
                    } else {
                        if (item.getVideoUrl() != null) {
                            //添加网络判断
                            if (!Constants.NET_IS_SUCCESS) {
                                KKDialog.getInstance().showNoNetPlayDialog(getActivity());
                            } else {
                                if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                                    KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                            new OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    Constants.nowifi_doplay = false;
                                                    KKDialog.getInstance().dismiss();
                                                    play(item);
                                                }
                                            },
                                            new OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    KKDialog.getInstance().dismiss();
                                                }
                                            });
                                } else {
                                    play(item);
                                }
                            }

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

    private void play(Item item) {
        Constants.DOWNLOAD_VIEW = 3;

        fragment = new MyCourseItemFragment();
        FragmentTransaction ft = getFragmentManager()
                .beginTransaction();

        Bundle b = new Bundle();
        b.putString("url", item.getVideoUrl());
        fragment.setArguments(b);

        ft.add(R.id.module_content_container, fragment, "单元条");
        ft.show(fragment);
        ft.hide(ModuleContentFragment.this);
        ft.commit();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    protected void loadModuleData() {
        Thread loadThread = new Thread(new Runnable() {

            @Override
            public void run() {
                try {
                    modules = ModulesAPI.getModulesInPublic(courseID);
                    moduleVideos = ModulesAPI.getModuleVideos(courseID, API.getAPI().getUserObject().getAccessToken());
                    if (moduleVideos != null && !moduleVideos.isEmpty()) {
                        Constants.videoUrlIsNull = false;
                    }
                    for (ModuleVideo mVideo : moduleVideos) {
                        modulesIds.add("" + mVideo.getModuleID());
                        for (ModuleVideo.ItemVideo item : mVideo.getVideoList()) {
                            itemIds.add(mVideo.getModuleID() + "#" + item.getItemID());
                            urlMap.put(mVideo.getModuleID() + "#" + item.getItemID(), item.getVideoURL());
                            unload++;
                        }
                    }
                    if (modules == null || modules.size() == 0) {
                        handler.sendEmptyMessage(2);
                        return;
                    }
                    olditemLists = new ArrayList<ArrayList<Item>>();
                    for (final Module m : modules) {
                        try {
                            ArrayList<Item> items = ModulesAPI.getModuleItmesInPublic(courseID,
                                    m.getId() + "");
                            olditemLists.add(items);
                            Date startDate = m.getUnlockAt();
                            if (startDate == null || DateUtils.getDateprice(FormatDate.getDateAfterDay(startDate, 1))) {
                                for (Item item : items) {
                                    if (itemIds.contains(m.getId() + "#" + item.getId())) {
                                        item.setVideoUrl(urlMap.get(m.getId() + "#" + item.getId()));
                                    }
                                }
                                if (downloadManager.getDownloadInfoList() != null) {
                                    for (DownloadInfo info : downloadManager.getDownloadInfoList()) {
                                        for (Item item : items) {
                                            if ((API.getAPI().getUserObject().getId() + splitStr + courseID + splitStr + m.getId() + splitStr + item.getId()).equals(info.getDownloadOnlyId())) {
                                                if (info.getItemId().equals("" + item.getId())) {
                                                    String state = null;
                                                    loaded++;
                                                    if (HttpHandler.State.LOADING.equals(info.getState()) || HttpHandler.State.CANCELLED.equals(info.getState()) || HttpHandler.State.STARTED.equals(info.getState()) || HttpHandler.State.WAITING.equals(info.getState())) {
                                                        state = "下载中";
                                                    } else if (HttpHandler.State.SUCCESS.equals(info.getState())) {
                                                        state = "已完成";
                                                    } else {
                                                        state = "__";
                                                    }
                                                    item.setDownloadState(state);
                                                } else {
                                                    item.setDownloadState("__");
                                                }
                                            } else {

                                            }
                                        }
                                    }
                                }
                            }
                            handler.post(new Runnable() {
                                public void run() {
                                    moduleNavFragment.setVideoCount(loaded, unload - loaded);
                                }

                                ;
                            });
                        } catch (DibitsExceptionC e) {
                            e.printStackTrace();
                            return;
                        }
                    }
                    handler.post(new Runnable() {
                        public void run() {
                            moduleNavFragment.setVideoCount(loaded, unload - loaded);
                        }

                        ;
                    });
                    adapter.setData(modules, olditemLists);
                    handler.sendEmptyMessage(3);
                } catch (DibitsExceptionC e) {
                    handler.sendEmptyMessage(2);
                    e.printStackTrace();
                    return;
                }
                isOk = true;
            }
        });
        loadThread.setDaemon(true);
        loadThread.start();
    }

    public void loadAllModule() {
        if (!isOk) return;
        for (int i = 0; i < olditemLists.size(); i++) {
            Date startDate = modules.get(i).getUnlockAt();
            if (startDate != null && !DateUtils.getDateprice(FormatDate.getDateAfterDay(startDate, 1))) {
                Toast.makeText(getActivity(), "包含未解锁视频，不能下载全部", Toast.LENGTH_SHORT).show();
                return;
            }
            for (Item item : olditemLists.get(i)) {
                for (ModuleVideo video : moduleVideos) {
                    for (ModuleVideo.ItemVideo itm : video.getVideoList()) {
                        if (modules.get(i).getId().toString().equals(video.getModuleID() + "") && item.getId().toString().equals(itm.getItemID() + "")) {
                            try {
                                downloadManager.addNewDownload(API.getAPI().getUserObject().getId() + splitStr + courseID + splitStr + video.getModuleID() + splitStr + itm.getItemID(),
                                        courseName,
                                        itm.getVideoURL(),
                                        bgUrl,
                                        itm.getItemTitle(),
                                        FileUtils.getVideoFilePath(API.getAPI().getUserObject().getId(), courseID, video.getModuleID() + "", itm.getItemID() + "") + itm.getItemTitle() + ".mp4",
                                        true,
                                        false,
                                        null);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            if (!"已完成".equals(item.getDownloadState())) {
                                item.setDownloadState("下载中");
                                loaded++;
                            }
                        }
                    }
                }
            }
        }
        adapter.notifyDataSetChanged();
        moduleNavFragment.setVideoCount(unload, 0);
    }

    /**
     * 自定义Module-Item二级菜单数据适配器
     *
     * @author Allen
     */
    class IAdapter extends BaseExpandableListAdapter implements XDListView.XDHeaderAdapter {

        private ArrayList<Module> moduleList;
        private ArrayList<ArrayList<Item>> itemList;
        @SuppressLint("UseSparseArrays")
        private HashMap<Integer, Integer> groupStatusMap = new HashMap<Integer, Integer>();

        public IAdapter(ArrayList<Module> moduleList,
                        ArrayList<ArrayList<Item>> itemList) {
            super();
            this.moduleList = moduleList;
            this.itemList = itemList;
        }

        public void setData(ArrayList<Module> groupArray,
                            ArrayList<ArrayList<Item>> iteList) {
            moduleList.addAll(groupArray);
            itemList.addAll(iteList);
        }

        @Override
        public int getGroupCount() {
            if (moduleList.isEmpty()) {
                return 0;
            }
            return this.moduleList.size();
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (groupPosition == -1) {
                return 0;
            }
            if (itemList.isEmpty()) {
                return 0;
            }
            return itemList.get(groupPosition).size();
        }

        @Override
        public Module getGroup(int groupPosition) {
            if (moduleList.isEmpty()) {
                return null;
            }
            return moduleList.get(groupPosition);
        }

        @Override
        public Item getChild(int groupPosition, int childPosition) {
            if (itemList.isEmpty()) {
                return null;
            }
            return itemList.get(groupPosition).get(childPosition);
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
            boolean isClick = false;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.unit_course_group, null);
                groupViewHolder = new GroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GroupViewHolder) convertView.getTag();
            }
            groupViewHolder.module_name.setText(moduleList.get(groupPosition).getName());
            Date startDate = moduleList.get(groupPosition).getUnlockAt();
            isClick = (startDate != null && !DateUtils.getDateprice(FormatDate.getDateAfterDay(startDate, 1)));
            if (isClick) {
                groupViewHolder.start_date.setVisibility(View.VISIBLE);
                groupViewHolder.start_date.setText("开启时间: " + DateUtils.getCourseStartTime(FormatDate.getDateAfterDay(startDate, 1)));
                groupViewHolder.img_lock.setVisibility(View.VISIBLE);
            } else {
                groupViewHolder.start_date.setVisibility(View.GONE);
                groupViewHolder.img_lock.setVisibility(View.GONE);
            }
            if (!modulesIds.isEmpty() && modulesIds.contains("" + moduleList.get(groupPosition).getId())) {
                groupViewHolder.load_all_video.setVisibility(View.VISIBLE);
                if (!isClick)
                    groupViewHolder.load_all_video.setOnClickListener(new ClickListener(itemList.get(groupPosition), moduleList.get(groupPosition).getId() + "", null, "Group_", moduleList.get(groupPosition)));
            } else {
                groupViewHolder.load_all_video.setVisibility(View.INVISIBLE);
            }
            return convertView;
        }

        @Override
        public View getChildView(int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            ChildViewHolder childHolder = null;
            Item item = itemList.get(groupPosition).get(childPosition);
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.unit_course_child, null);
                childHolder = new ChildViewHolder(convertView);
                convertView.setTag(childHolder);
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
            }
            Date startDate = moduleList.get(groupPosition).getUnlockAt();
            childHolder.course_name.setText(item.getTitle());
            String type = item.getType();
            childHolder.load_state.setText(item.getDownloadState());
            if (!itemIds.isEmpty() && itemIds.contains(moduleList.get(groupPosition).getId() + "#" + item.getId())) {
//				childHolder.load_all_video.setVisibility(View.VISIBLE);
                if ("下载中".equals(item.getDownloadState())) {
                    childHolder.load_all_video.setVisibility(View.GONE);
                    childHolder.load_state.setVisibility(View.VISIBLE);
                } else if ("已完成".equals(item.getDownloadState())) {
                    childHolder.load_all_video.setVisibility(View.GONE);
                    childHolder.load_state.setVisibility(View.VISIBLE);
                } else {
                    childHolder.load_all_video.setOnClickListener(new ClickListener(itemList.get(groupPosition), moduleList.get(groupPosition).getId() + "", item, "Child", moduleList.get(groupPosition)));
                    childHolder.load_all_video.setVisibility(View.VISIBLE);
                    childHolder.load_state.setVisibility(View.GONE);
                }
            } else {
                childHolder.load_all_video.setVisibility(View.GONE);
                childHolder.load_state.setVisibility(View.GONE);
            }

            if (startDate != null && !DateUtils.getDateprice(FormatDate.getDateAfterDay(startDate, 1))) {
                childHolder.course_name.setTextColor(getResources().getColor(R.color.unit_child_lock));
                childHolder.iv_in.setVisibility(View.INVISIBLE);
                childHolder.load_all_video.setVisibility(View.GONE);
                childHolder.load_state.setVisibility(View.GONE);
//				childHolder.course_ImView.setVisibility(View.VISIBLE);
                if ("Page".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_page_active_grey);
                } else if ("Quiz".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_quiz_active_grey);
                } else if ("Discussion".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_dis_active_grey);
                } else if ("Assignment".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_assignment_active_grey);
                } else if ("File".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_dis_active_grey);
                } else if ("ExternalUrl".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_link_active_grey);
                } else if ("ExternalTool".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_video_active_gray);
                }
//				else {
//					childHolder.course_ImView.setVisibility(View.GONE);
//				}
            } else {
                childHolder.course_name.setTextColor(getResources().getColor(R.color.module_child_text));
                childHolder.iv_in.setVisibility(View.VISIBLE);
                if ("Page".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_page_active_dark);
                } else if ("Quiz".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_quiz_active_dark);
                } else if ("Discussion".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_dis_active_dark);
                } else if ("Assignment".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_assignment_active_dark);
                } else if ("File".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_dis_active_dark);
                } else if ("ExternalUrl".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_link_active_dark);
                } else if ("ExternalTool".equals(type)) {
                    childHolder.course_ImView
                            .setImageResource(R.drawable.unit_icon_video_active_dark);
                }
//				else {
//					childHolder.course_ImView.setVisibility(View.GONE);
//				}
            }
            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

        private void download(String moduleId, Item item, String type, List<Item> items, Module module) {
            if (type.equals("Group_")) {
                if (module.isDownLoad()) {
                    return;
                }
                module.setDownLoad(true);
            }
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
                            loaded++;
                            moduleNavFragment.setVideoCount(loaded, unload - loaded);
                            break;
                        } else if (type.equals("Group_")) {
                            for (Item itm : items) {
                                if ((itm.getId() + "").equals(video.getItemID() + "")) {
                                    if (!"已完成".equals(itm.getDownloadState())) {
                                        if (!"下载中".equals(itm.getDownloadState())) {
                                            loaded++;
                                            moduleNavFragment.setVideoCount(loaded, unload - loaded);
                                        }
                                        itm.setDownloadState("下载中");
                                    } else {
                                        itm.setDownloadState("已完成");
                                    }
                                }
                            }
                            try {
                                downloadManager.addNewDownload(API.getAPI().getUserObject().getId() + splitStr + courseID + splitStr + moduleId + splitStr + video.getItemID(),
                                        courseName,
                                        video.getVideoURL(),
                                        bgUrl,
                                        video.getItemTitle(),
                                        FileUtils.getVideoFilePath(API.getAPI().getUserObject().getId(), courseID, moduleId, video.getItemID() + "") + video.getItemTitle() + ".mp4",
                                        true,
                                        false,
                                        null);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                        }
                    }
                    break;
                }
            }
            adapter.notifyDataSetChanged();
        }

        @Override
        public int getXDHeaderState(int groupPosition, int childPosition) {
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
            Module groupData = (Module) this.getGroup(groupPosition);
            Date startDate = groupData.getUnlockAt();
            ((TextView) header.findViewById(R.id.course_module)).setText(groupData.getName());
            Button load_all_video = (Button) header.findViewById(R.id.load_all_video);
            TextView tv_date = (TextView) header.findViewById(R.id.start_date);
            boolean isClick = (startDate != null && !DateUtils.getDateprice(FormatDate.getDateAfterDay(startDate, 1)));
            if (isClick) {
                tv_date.setVisibility(View.VISIBLE);
                tv_date.setText("开启时间: " + DateUtils.getCourseStartTime(FormatDate.getDateAfterDay(startDate, 1)));
                header.findViewById(R.id.img_lock).setVisibility(View.VISIBLE);
            } else {
                tv_date.setVisibility(View.GONE);
                header.findViewById(R.id.img_lock).setVisibility(View.GONE);
            }

            if (!modulesIds.isEmpty() && modulesIds.contains("" + groupData.getId())) {
                load_all_video.setVisibility(View.VISIBLE);
                if (!isClick)
                    load_all_video.setOnClickListener(new ClickListener(itemList.get(groupPosition), moduleList.get(groupPosition).getId() + "", null, "Group_", moduleList.get(groupPosition)));
            } else {
                load_all_video.setVisibility(View.INVISIBLE);
            }
        }

        @Override
        public void setGroupClickStatus(int groupPosition, int status) {
            groupStatusMap.put(groupPosition, status);
        }

        @Override
        public int getGroupClickStatus(int groupPosition) {
            if (groupStatusMap.containsKey(groupPosition)) {
                return groupStatusMap.get(groupPosition);
            } else {
                return 0;
            }
        }

        class ClickListener implements OnClickListener {

            List<Item> items;
            private String moduleId;
            private Item item;
            private String type;
            private Module module;

            public ClickListener(List<Item> items, String moduleId, Item item, String type, Module module) {
                this.moduleId = moduleId;
                this.item = item;
                this.type = type;
                this.items = items;
                this.module = module;
            }

            @Override
            public void onClick(View v) {
                if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoWifi2Doload(getActivity(),
                            new OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    KKDialog.getInstance().dismiss();
                                    Constants.nowifi_doload = false;
                                    download(moduleId, item, type, items, module);
                                }
                            },
                            new OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    KKDialog.getInstance().dismiss();
                                }
                            });
                } else {
                    download(moduleId, item, type, items, module);
                }

            }
        }

        class GroupViewHolder {
            TextView module_name;
            Button load_all_video;
            TextView start_date;
            ImageView img_lock;

            public GroupViewHolder(View v) {
                module_name = (TextView) v.findViewById(R.id.course_module);
                load_all_video = (Button) v.findViewById(R.id.load_all_video);
                start_date = (TextView) v.findViewById(R.id.start_date);
                img_lock = (ImageView) v.findViewById(R.id.img_lock);
            }
        }

        class ChildViewHolder {
            TextView course_name;
            TextView load_all_video;
            TextView load_state;
            ImageView course_ImView;
            ImageView iv_in;

            public ChildViewHolder(View v) {
                load_all_video = (TextView) v.findViewById(R.id.load_all_video);
                load_state = (TextView) v.findViewById(R.id.load_state);
                course_name = (TextView) v.findViewById(R.id.course_name);
                course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
                iv_in = (ImageView) v.findViewById(R.id.iv_in);
            }
        }
    }
}
