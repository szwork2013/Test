package com.kaikeba.activity.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.util.List;

/**
 * Created by mjliu on 14-7-30.
 */
public class OutLineCourseFragment extends Fragment {
    private final static String tag = "CourseArrangeFragment";
    List<CourseModel.CourseOutLine> outlineList;
    private IAdapter adapter;
    private LayoutInflater inflater;
    private ExpandableListView exList;
    private CourseModel c;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.course_outline, container, false);
        exList = (ExpandableListView) v.findViewById(R.id.course_outline_expandable);
        View headerView = inflater.inflate(R.layout.course_outline_group, exList, false);
//        exList.setHeaderView(headerView);
        c = (CourseModel) getArguments().getSerializable(ContextUtil.CATEGORY_COURSE);
        outlineList = c.getCourse_outline();
        adapter = new IAdapter();
        exList.setAdapter(adapter);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);

    }

    public void onResume() {
        super.onResume();
        Constants.FULL_SCREEN_NO_CLICK = false;
        MobclickAgent.onPageStart("course_detail_arrangement"); //统计页面
    }

    /**
     * 自定义Module-Item二级菜单数据适配器
     *
     * @author Allen
     */
    class IAdapter extends BaseExpandableListAdapter {

        public IAdapter() {
            super();
        }

        @Override
        public int getGroupCount() {
            if (outlineList == null) {
                return 0;
            }
            return outlineList.size();
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (outlineList == null || outlineList.get(groupPosition).getItems() == null) {
                return 0;
            }
            return outlineList.get(groupPosition).getItems().size();

        }

        @Override
        public CourseModel.CourseOutLine getGroup(int groupPosition) {
            if (outlineList.isEmpty()) {
                return null;
            }
            return outlineList.get(groupPosition);
        }

        @Override
        public CourseModel.Item getChild(int groupPosition, int childPosition) {
            if (outlineList.isEmpty() || outlineList.get(groupPosition).getItems() == null) {
                return null;
            }
            return outlineList.get(groupPosition).getItems().get(childPosition);
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
                convertView = inflater.inflate(R.layout.course_outline_group, null);
                groupViewHolder = new GroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GroupViewHolder) convertView.getTag();
            }
            if (isExpanded) {
                groupViewHolder.narrow.setImageResource(R.drawable.drop_menu_up);
            } else {
                groupViewHolder.narrow.setImageResource(R.drawable.drop_menu_down);
            }
            groupViewHolder.module_name.setText(outlineList.get(groupPosition).getName());
            return convertView;
        }

        @Override
        public View getChildView(int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {

            ChildViewHolder childViewHolder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.course_outline_child, null);
                childViewHolder = new ChildViewHolder(convertView);
                convertView.setTag(childViewHolder);
            } else {
                childViewHolder = (ChildViewHolder) convertView.getTag();
            }
            childViewHolder.course_name.setText(outlineList.get(groupPosition).getItems().get(childPosition).getTitle());
            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

//        @Override
//        public int getXDHeaderState(int groupPosition, int childPosition) {
//            // TODO Auto-generated method stub
//            final int childCount = getChildrenCount(groupPosition);
//            if(childPosition == childCount - 1){
//                return PINNED_HEADER_PUSHED_UP;
//            }
////            else if(childPosition == -1 && !exList.isGroupExpanded(groupPosition)){
////                return PINNED_HEADER_GONE;
////            }
//            else{
//                return PINNED_HEADER_VISIBLE;
//            }
//        }

//        @Override
//        public void configureXDHeader(View header, int groupPosition,
//                                      int childPosition, int alpha) {
//            // TODO Auto-generated method stub
//            String name = outlineList.get(groupPosition).getName();
//            ((TextView)header.findViewById(R.id.tv_course_outline)).setText(name);
//        }
//
//        @SuppressLint("UseSparseArrays")
//        private HashMap<Integer,Integer> groupStatusMap = new HashMap<Integer, Integer>();
//
//        @Override
//        public void setGroupClickStatus(int groupPosition, int status) {
//            // TODO Auto-generated method stub
//            groupStatusMap.put(groupPosition, status);
//        }

//        @Override
//        public int getGroupClickStatus(int groupPosition) {
//            // TODO Auto-generated method stub
//            if(groupStatusMap.containsKey(groupPosition)){
//                return groupStatusMap.get(groupPosition);
//            }
//            else{
//                return 0;
//            }
//        }
    }

    public class GroupViewHolder {
        TextView module_name;
        ImageView narrow;

        public GroupViewHolder(View v) {
            module_name = (TextView) v.findViewById(R.id.tv_course_outline);
            narrow = (ImageView) v.findViewById(R.id.course_outline_img);
        }
    }

    public class ChildViewHolder {
        TextView course_name;
        ImageView course_ImView;
        ImageView load_video;

        public ChildViewHolder(View v) {
            course_name = (TextView) v.findViewById(R.id.course_name);
            course_ImView = (ImageView) v.findViewById(R.id.course_ImView);
            load_video = (ImageView) v.findViewById(R.id.load_video);
        }

    }

}