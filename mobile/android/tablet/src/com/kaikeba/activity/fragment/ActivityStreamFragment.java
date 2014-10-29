package com.kaikeba.activity.fragment;

import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.kaikeba.activity.ActiveAssigmentActivity;
import com.kaikeba.activity.ActiveDisscussActivity;
import com.kaikeba.activity.ActiveModuleActivity;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.adapter.StreamAdapter;
import com.kaikeba.common.api.ActivityAPI;
import com.kaikeba.common.api.AnnouncementAPI;
import com.kaikeba.common.api.AssignmentAPI;
import com.kaikeba.common.api.DiscusstionAPI;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.entity.Assignment;
import com.kaikeba.common.entity.UserActivity;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;

/**
 * 最近活动Fragment
 *
 * @author Super Man
 */
public class ActivityStreamFragment extends Fragment {

    private ListView lvActivity;
    private List<UserActivity> annoncements = new ArrayList<UserActivity>();
    private List<UserActivity> messages = new ArrayList<UserActivity>();
    private List<UserActivity> disscussions = new ArrayList<UserActivity>();
    private StreamAdapter adapter;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            setBackage(v);
            setTextColor(v);
            switch (v.getId()) {
                case R.id.tv1:
                    if (annoncements.isEmpty()) {
                        Toast.makeText(getActivity(), "暂无通告", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setDate(annoncements);
                        handler.sendEmptyMessage(0);
                    }
                    break;
                case R.id.tv2:
                    if (messages.isEmpty()) {
                        Toast.makeText(getActivity(), "暂无作业通知", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setDate(messages);
                        handler.sendEmptyMessage(0);
                    }
                    break;
                case R.id.tv3:
                    if (disscussions.isEmpty()) {
                        Toast.makeText(getActivity(), "暂无讨论", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setDate(disscussions);
                        handler.sendEmptyMessage(0);
                    }
                    break;
                default:
                    break;
            }
        }
    };
    private TextView tv_ann_no;
    private TextView tv_ass_no;
    private TextView tv_dis_no;
    private LinearLayout view_loading;
    private Announcement mAnn;
    private Assignment mAss;
    private ArrayList<Assignment> mAssignmentList = new ArrayList<Assignment>();
    private Announcement dis;
    private boolean isLoading = false;
    private OnItemClickListener itemListener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            // TODO Auto-generated method stub
            if (!isLoading) {
                isLoading = true;
            } else {
                return;
            }
            Constants.isFirst = true;
            Constants.ACTIVITY_VIEW = 2;
            final UserActivity activity = (UserActivity) parent.getAdapter()
                    .getItem(position);
            if (activity == null) {
                return;
            }
            Toast.makeText(getActivity(), "正在加载", Toast.LENGTH_SHORT).show();
            // view_loading.setVisibility(View.VISIBLE);
            if (activity.getType().equals("Announcement")) {
                showAnnouncement(activity);
            } else if (activity.getType().equals("DiscussionTopic")) {
                showDiscuss(activity);
            } else if (activity.getType().equals("Message")) {
                showMessage(activity);
            }
        }
    };
    private ImageButton btn_togo;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    adapter.notifyDataSetChanged();
                    break;

                default:
                    break;
            }
        }

        ;
    };
    private boolean annIsNull = false;
    private boolean messageIsNull = false;
    private boolean disIsNull = false;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View inflaterView = inflater.inflate(R.layout.activity, container,
                false);
        initView(inflaterView);
        setListener();
        return inflaterView;
    }

    private void initView(View v) {
        tv_ann_no = (TextView) v.findViewById(R.id.tv1);
        tv_ass_no = (TextView) v.findViewById(R.id.tv2);
        tv_dis_no = (TextView) v.findViewById(R.id.tv3);
        lvActivity = (ListView) v.findViewById(R.id.lv_activity);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        btn_togo = (ImageButton) v.findViewById(R.id.btn_togo);
    }

    private void setListener() {
        tv_ann_no.setOnClickListener(listener);
        tv_ass_no.setOnClickListener(listener);
        tv_dis_no.setOnClickListener(listener);
        lvActivity.setOnItemClickListener(itemListener);
        btn_togo.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                MainActivity.getMainActivity().getMslidingMenu().showMenu();
            }
        });
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        final MainActivity mainActivity = (MainActivity) getActivity();
        disscussions.clear();
        annoncements.clear();
        messages.clear();
        ImgLoaderUtil.threadPool.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    ArrayList<UserActivity> activitys = ActivityAPI
                            .getAllActivity();
                    for (UserActivity one : activitys) {
                        if (mainActivity.getCourse(one.getCourse_id()) != null) {
                            if (one.getType().equals("DiscussionTopic")) {
                                disscussions.add(one);
                            } else if (one.getType().equals("Announcement")) {
                                annoncements.add(one);
                            } else if (one.getType().equals("Message")) {
                                messages.add(one);
                            }
                        }
                    }
                    adapter = new StreamAdapter((MainActivity) getActivity());
                    handler.post(new Runnable() {

                        @Override
                        public void run() {
                            view_loading.setVisibility(View.GONE);
                            lvActivity.setVisibility(View.VISIBLE);
                            lvActivity.setAdapter(adapter);
                            tv_ann_no.performClick();
                        }
                    });
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void setBackage(View v) {
        if (v == tv_ann_no) {
            tv_ann_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_normal));
            tv_ass_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_dis_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        }
        if (v == tv_ass_no) {
            tv_ann_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_ass_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_normal));
            tv_dis_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        }
        if (v == tv_dis_no) {
            tv_ann_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_ass_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_dis_no.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_normal));
        }
    }

    private void setTextColor(View v) {
        TextView[] views = {tv_ann_no, tv_ass_no, tv_dis_no};
        for (TextView view : views) {
            if (view == v) {
                view.setTextColor(getResources().getColor(
                        R.color.activity_top_text_check));
            } else {
                view.setTextColor(getResources().getColor(
                        R.color.activity_top_text_normal));
            }
        }
    }

    private void showAnnouncement(final UserActivity activity) {
        ImgLoaderUtil.threadPool.submit(new Runnable() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                final ArrayList<Announcement> annList = AnnouncementAPI
                        .getAllAnnouncement(activity.getCourse_id() + "");
                for (Announcement ann : annList) {
                    if (ann.getId().equals(activity.getAnnouncement_id() + "")) {
                        mAnn = ann;
                        annIsNull = true;
                        break;
                    }
                }
                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        if (mAnn == null || !annIsNull) {
                            Toast.makeText(getActivity(), "无信息",
                                    Toast.LENGTH_SHORT).show();
                            return;
                        }
                        MainActivity mainActivity = (MainActivity) getActivity();
                        if (mainActivity.getCourse(activity.getCourse_id()) == null) {
                            Toast.makeText(getActivity(), "课程已锁定",
                                    Toast.LENGTH_SHORT).show();
                            isLoading = false;
                            return;
                        }
                        Intent intent = new Intent(mainActivity,
                                ActiveModuleActivity.class);
                        intent.putExtra("course",
                                mainActivity.getCourse(activity.getCourse_id()));
                        intent.putExtra("announcement", mAnn);
                        intent.putExtra("announcements", annList);
                        getActivity().startActivity(intent);
                        annIsNull = false;
                        isLoading = false;
                    }
                });
            }
        });
    }

    private void showMessage(final UserActivity activity) {

        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                ArrayList<Assignment> assignmentList = AssignmentAPI
                        .getAllAssignment(activity.getCourse_id() + "");
                String[] strs = activity.getUrl().split("/");
                String id = strs[strs.length - 1];
                for (Assignment ass : assignmentList) {
                    if (ass.getId().equals(id)) {
                        mAss = ass;
                        messageIsNull = true;
                        break;
                    }
                }
                mAssignmentList.clear();
                for (UserActivity ua : messages) {
                    String[] mtrs = ua.getUrl().split("/");
                    String mId = mtrs[mtrs.length - 1];
                    for (Assignment as : assignmentList) {
                        if (as.getId().equals(mId)) {
                            mAssignmentList.add(as);
                            break;
                        }
                    }
                }
                final int index = mAssignmentList.indexOf(mAss);
                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        // view_loading.setVisibility(View.GONE);
//						toast.cancel();
                        if (mAss == null || !messageIsNull) {
                            Toast.makeText(getActivity(), "无信息",
                                    Toast.LENGTH_SHORT).show();
                            return;
                        }
                        MainActivity mainActivity = (MainActivity) getActivity();
                        if (mainActivity.getCourse(activity.getCourse_id()) == null) {
                            Toast.makeText(getActivity(), "课程已锁定",
                                    Toast.LENGTH_SHORT).show();
                            isLoading = false;
                            return;
                        }
                        Intent intent = new Intent(mainActivity,
                                ActiveAssigmentActivity.class);
                        intent.putExtra("course",
                                mainActivity.getCourse(activity.getCourse_id()));
                        intent.putExtra("assignments", mAssignmentList);
                        intent.putExtra("index", index);
                        getActivity().startActivity(intent);
                        messageIsNull = false;
                        isLoading = false;
                    }
                });
            }
        });

    }

    private void showDiscuss(final UserActivity activity) {

        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                final ArrayList<Announcement> disList = DiscusstionAPI
                        .getAllDiscussion(activity.getCourse_id() + "");
                for (Announcement d : disList) {
                    if (d.getId()
                            .equals(activity.getDiscussion_topic_id() + "")) {
                        dis = d;
                        disIsNull = true;
                        break;
                    }
                }
                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        // view_loading.setVisibility(View.GONE);
//						toast.cancel();
                        if (dis == null || !disIsNull) {
                            Toast.makeText(getActivity(), "讨论已锁定",
                                    Toast.LENGTH_SHORT).show();
                            isLoading = false;
                            return;
                        }
                        MainActivity mainActivity = (MainActivity) getActivity();
                        if (mainActivity.getCourse(activity.getCourse_id()) == null) {
                            Toast.makeText(getActivity(), "课程已锁定",
                                    Toast.LENGTH_SHORT).show();
                            isLoading = false;
                            return;
                        }
                        Intent intent = new Intent(mainActivity,
                                ActiveDisscussActivity.class);
                        intent.putExtra("course",
                                mainActivity.getCourse(activity.getCourse_id()));
                        intent.putExtra(getResources().getString(R.string.announcement), dis);
                        intent.putExtra(getResources().getString(R.string.announcements), disList);
                        getActivity().startActivity(intent);
                        disIsNull = false;
                        isLoading = false;
                    }
                });
            }
        });
    }

}
