package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.ExpandableListView.OnGroupCollapseListener;
import android.widget.ExpandableListView.OnGroupExpandListener;
import com.kaikeba.activity.CourseInfomationActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.api.ModulesAPI;
import com.kaikeba.common.entity.Item;
import com.kaikeba.common.entity.Module;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;

import java.util.ArrayList;

/**
 * 课程安排Activity
 *
 * @author Allen
 */
public class CourseArrangeFragment extends Fragment {

    private IAdapter adapter;
    private String courseID;
    private LayoutInflater inflater;
    private LinearLayout view_loading;
    private ExpandableListView exList;
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
                    setListViewHeightBasedOnChildren(exList);
                    view_loading.setVisibility(View.GONE);
                    break;
            }
            super.handleMessage(msg);
        }
    };
    private String pageURL;
    private CourseInfomationActivity context;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.coursearrange, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        exList = (ExpandableListView) v.findViewById(R.id.expandableCourseInfo);
        adapter = new IAdapter(new ArrayList<Module>(),
                new ArrayList<ArrayList<Item>>());
        exList.setAdapter(adapter);
        if (Constants.VIEW_INTO == 2) {
            setOnChildClickListener();
        }
        if (Constants.VIEW_INTO == 1) {
            exList.setOnGroupCollapseListener(new OnGroupCollapseListener() {

                @Override
                public void onGroupCollapse(int groupPosition) {
                    // TODO Auto-generated method stub
                    setListViewHeightBasedOnChildren(exList);
                }
            });
            exList.setOnGroupExpandListener(new OnGroupExpandListener() {

                @Override
                public void onGroupExpand(int groupPosition) {
                    // TODO Auto-generated method stub
                    setListViewHeightBasedOnChildren(exList);
                }
            });
        }
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        courseID = getArguments().getString(
                getResources().getString(R.string.courseId));
        loadModuleData();
    }

    private void setOnChildClickListener() {
        exList.setOnChildClickListener(new OnChildClickListener() {

            @Override
            public boolean onChildClick(ExpandableListView parent, View v,
                                        int groupPosition, int childPosition, long id) {
                // TODO Auto-generated method stub
                Item item = adapter.getChild(groupPosition, childPosition);
                if (item.getType() != null && item.getType().equals("Page")) {
                    if (item.getUrl() != null) {
                        String[] pageStr = item.getUrl().split("/");
                        pageURL = pageStr[pageStr.length - 1];
                        Intent intent = new Intent();
                        intent.putExtra("courseID+pageURL", courseID + "##"
                                + pageURL);
                        intent.putExtra("title", item.getTitle());
                        // intent.putExtra("url", item.getUrl());
                        intent.setClass(context, ModuleActivity.class);
                        context.startActivity(intent);
                    }
                } else {
                    Toast.makeText(getActivity(), "下个版本即将支持，敬请期待",
                            Toast.LENGTH_SHORT).show();
                }
                return true;
            }
        });
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
    }

    protected void loadModuleData() {
        Thread loadThread = new Thread(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                try {
                    final ArrayList<Module> modules = ModulesAPI
                            .getModulesInPublic(courseID);
                    if (modules == null || modules.size() == 0) {
                        handler.sendEmptyMessage(2);
                        return;
                    }
                    final ArrayList<ArrayList<Item>> olditemLists = new ArrayList<ArrayList<Item>>();
                    for (final Module m : modules) {
                        ArrayList<Item> items = null;
                        try {
                            items = ModulesAPI.getModuleItmesInPublic(courseID,
                                    m.getId() + "");
                            olditemLists.add(items);

                        } catch (DibitsExceptionC e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                            return;
                        }
                    }
                    adapter.setData(modules, olditemLists);
                    handler.sendEmptyMessage(3);
                } catch (DibitsExceptionC e) {
                    // TODO Auto-generated catch block
                    handler.sendEmptyMessage(2);
                    e.printStackTrace();
                    return;
                }
            }
        });
        loadThread.setDaemon(true);
        loadThread.start();
    }

    public void setListViewHeightBasedOnChildren(ExpandableListView listView) {
        ListAdapter listAdapter = listView.getAdapter();
        if (listAdapter == null) {
            return;
        }

        int totalHeight = 0;
        for (int i = 0; i < listAdapter.getCount(); i++) {
            View listItem = listAdapter.getView(i, null, listView);
            listItem.measure(0, 0);
            totalHeight += listItem.getMeasuredHeight();
        }

        ViewGroup.LayoutParams params = listView.getLayoutParams();
        params.height = totalHeight
                + (listView.getDividerHeight() * (listAdapter.getCount() - 1));
        listView.setLayoutParams(params);
    }

    /**
     * 自定义Module-Item二级菜单数据适配器
     *
     * @author Allen
     */
    class IAdapter extends BaseExpandableListAdapter {

        private ArrayList<Module> mGroupArray;
        private ArrayList<ArrayList<Item>> mArrayArray;

        public IAdapter(ArrayList<Module> groupArray,
                        ArrayList<ArrayList<Item>> arrayArray) {
            super();
            this.mGroupArray = groupArray;
            this.mArrayArray = arrayArray;
        }

        public void setData(ArrayList<Module> groupArray,
                            ArrayList<ArrayList<Item>> arrayArray) {
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
            if (mArrayArray.isEmpty()) {
                return 0;
            }
            return mArrayArray.get(groupPosition).size();
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
            // groupViewHolder.number.setText(mGroupArray.get(groupPosition)
            // // .getPosition() + "");
            // if (API.VIEW_INTO == 1) {
            // groupViewHolder.module_name.setTextColor(getResources().getColor(R.color.white));
            // }
            // else {
            // groupViewHolder.module_name.setTextColor(getResources().getColor(R.color.black));
            // }
            groupViewHolder.module_name.setText(mGroupArray.get(groupPosition)
                    .getName());
            return convertView;
        }

        @Override
        public View getChildView(int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            ChildViewHolder childHolder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.course_child, null);
                childHolder = new ChildViewHolder(convertView);
                convertView.setTag(childHolder);
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
            }
            childHolder.course_name.setText(mArrayArray.get(groupPosition)
                    .get(childPosition).getTitle());
            String type = mArrayArray.get(groupPosition).get(childPosition)
                    .getType();
            childHolder.courseSpec.setText(type);
            if ("Page".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_page_gray);
            }
            if ("Quiz".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_quiz_gray);
            }
            if ("Discussion".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            }
            if ("Assignment".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_assignment_gray);
            }
            if ("File".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_dis_gray);
            }
            if ("ExternalUrl".equals(type)) {
                childHolder.course_ImView
                        .setImageResource(R.drawable.unit_icon_link_gray);
            }

            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

        class GroupViewHolder {
            TextView module_name;

            public GroupViewHolder(View v) {
                // number = (TextView) v.findViewById(R.id.number);
                module_name = (TextView) v.findViewById(R.id.course_module);
            }
        }

        class ChildViewHolder {
            TextView courseSpec;
            TextView course_name;
            ImageView course_ImView;

            public ChildViewHolder(View v) {
                courseSpec = (TextView) v.findViewById(R.id.courseSpec);
                course_name = (TextView) v.findViewById(R.id.course_name);
                course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
            }
        }
    }
}
