package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.GuideCourseAcitvity;
import com.kaikeba.activity.OpenCourseActivity;
import com.kaikeba.adapter.CategoryCourseAdapter;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mjliu on 14-7-30.
 */
public class CourseRecommendFragment extends Fragment {
    private final static String tag = "CourseArrangeFragment";
    private LayoutInflater inflater;
    private ListView recommendListView;
    private Drawable loadingDraw;
    private CategoryCourseAdapter cateAdapter;
    private LinearLayout ll_no_recommend;

    private List<CourseModel> list;
    private List<CourseModel> allList;
    private List<CourseModel> tempList;

    private List<CourseModel> loadAllCourses = new ArrayList<CourseModel>();
    private CourseModel c;
    private AdapterView.OnItemClickListener listViewListener = new AdapterView.OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            Intent it = new Intent();
            Bundle b = new Bundle();
            if (list.get(position).getType().equals("OpenCourse")) {
                it.setClass(getActivity(), OpenCourseActivity.class);
            } else {
                it.setClass(getActivity(), GuideCourseAcitvity.class);
            }
            b.putSerializable(ContextUtil.CATEGORY_COURSE, list.get(position));
            it.putExtras(b);
            startActivity(it);
        }
    };
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    };
    private boolean flag;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.course_recommend, container, false);
        c = (CourseModel) getArguments().getSerializable(ContextUtil.CATEGORY_COURSE);
        recommendListView = (ListView) v.findViewById(R.id.course_recommend_listview);
        ll_no_recommend = (LinearLayout) v.findViewById(R.id.ll_no_recommend);
        loadingDraw = getResources().getDrawable(R.drawable.default_ptr_rotate);
        list = new ArrayList<CourseModel>();
        allList = new ArrayList<CourseModel>();
        tempList = new ArrayList<CourseModel>();
        cateAdapter = new CategoryCourseAdapter(getActivity(), list, handler);
        recommendListView.setAdapter(cateAdapter);
        recommendListView.setOnItemClickListener(listViewListener);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        loadAllCourse();
    }

    private void loadAllCourse() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object allCourseData) {
                if (allCourseData != null) {
                    loadAllCourses = (List<CourseModel>) allCourseData;
                }
                List<Integer> recommon = c.getRecommen();
                if (recommon != null) {
                    list.clear();
                    for (int i = 0; i < recommon.size(); i++) {
                        for (int j = 0; j < loadAllCourses.size(); j++) {
                            if (loadAllCourses.get(j).getId() == recommon.get(i)) {
                                list.add(loadAllCourses.get(j));
                                break;
                            }
                        }
                    }
                }

                if (list.size() > 0) {
                    ll_no_recommend.setVisibility(View.GONE);
                } else {
                    ll_no_recommend.setVisibility(View.VISIBLE);
                }

                cateAdapter.notifyDataSetChanged();
            }
        });

    }

    public void onResume() {
        super.onResume();
    }

    private class GetDataTask extends AsyncTask<Void, Void, String[]> {

        @Override
        protected String[] doInBackground(Void... params) {
            // Simulates a background job.
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
            }

            return null;
        }

        @Override
        protected void onPostExecute(String[] result) {
            // Call onRefreshComplete when the list has been refreshed.
            super.onPostExecute(result);
            tempList.clear();
            if (allList.size() > 10) {
                tempList.addAll(allList.subList(0, 10));
                flag = false;
            } else {
                tempList.addAll(allList);
                flag = true;
            }
            list.addAll(tempList);
            allList.removeAll(tempList);

        }
    }

}