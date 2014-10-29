package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.CourseInfomationActivity;
import com.kaikeba.activity.CourseSquareActivity;
import com.kaikeba.adapter.MyCourseAdapter;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.Course4My;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.common.widget.LoadMoreListView;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class MyCourseFragment extends Fragment {

    MyCourseAdapter myCourseAdapter;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    showData();
                    lvMyList.setVisibility(View.GONE);
                    ll_no_course.setVisibility(View.VISIBLE);
                    break;
                case 3:
                    lvMyList.setVisibility(View.VISIBLE);
                    ll_no_course.setVisibility(View.GONE);
                    if (myCourseAdapter == null) {
                        myCourseAdapter = new MyCourseAdapter(new ArrayList<CourseModel>(), getActivity());
                        lvMyList.setAdapter(myCourseAdapter);
                    }
                    break;
                default:
                    break;
            }
        }

        ;
    };
    private RelativeLayout viewLoading;
    private LoadMoreListView lvMyList;
    private ImageView loading_fail;
    private CourseSquareActivity activity;
    private Runnable runnable;
    private RelativeLayout ll_no_course;
    private TextView tv_more_course;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            int id = v.getId();
            switch (id) {
                case R.id.tv_more_course:
                    ((CourseSquareActivity) getActivity()).showAllCourse();
                    break;
                case R.id.loading_fail:
                    if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoNetToast(getActivity());
                    } else {
                        showLoading();
                        loadMyCourseIds(true);
                    }
                    break;
                default:
                    break;
            }
        }
    };
    private OnItemClickListener listViewListener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            Course c = (Course) parent.getAdapter().getItem(position);
            /*Intent mIntent = new Intent();
			Bundle bundle1 = new Bundle();
			bundle1.putSerializable("course", c);
			mIntent.putExtras(bundle1);
			mIntent.setClass(getActivity(), UnitActivity.class);
			startActivity(mIntent);*/

            Intent mIntent = new Intent(getActivity(), CourseInfomationActivity.class);
            mIntent.putExtra(ContextUtil.CATEGORY_COURSE, c);
            mIntent.putExtra("badge", (ArrayList<Badge>) activity.getBadges());
            mIntent.putExtra(Constants.ACTIVITY_NAME_KEY, Constants.MY_COURSE);
            startActivity(mIntent);
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.my_course, container, false);
        viewLoading = (RelativeLayout) v.findViewById(R.id.view_loading);
        loading_fail = (ImageView) v.findViewById(R.id.loading_fail);
        lvMyList = (LoadMoreListView) v.findViewById(R.id.lv_all_course);
        ll_no_course = (RelativeLayout) v.findViewById(R.id.ll_no_course);
        tv_more_course = (TextView) v.findViewById(R.id.tv_more_course);
        tv_more_course.setOnClickListener(listener);
        loading_fail.setOnClickListener(listener);
        lvMyList.setOnItemClickListener(listViewListener);
        lvMyList.setPullLoadEnable(false);
        lvMyList.setPullRefreshEnable(false);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        activity = (CourseSquareActivity) getActivity();
        loadMyCourseIds(true);
//		new Thread() {
//			@Override
//			public void run() {
//				try {
//					final List<Course> curlist = new ArrayList<Course>();
//					ArrayList<Long> ids = LocalStorage.sharedInstance().getIds();
//					if (ids == null) {
//						ids = CoursesAPI.getMyCoursesId(true);
//                        LocalStorage.sharedInstance().setIds(ids);
//					}
//					if (ids.isEmpty()) {
//						handler.sendEmptyMessage(0);
//						return;
//					}
//					else {
//						List<Course> list = activity.getAllCourse();
//						for (Course c : list) {
//							for (Long id : ids) {
//								if (id.equals(c.getId())) {
//									curlist.add(c);
//								}
//							}
//						}
//					}
//					runnable = new Runnable() {
//
//						@Override
//						public void run() {
//							myCourseAdapter = new MyCourseAdapter(curlist, getActivity());
//							lvMyList.setAdapter(myCourseAdapter);
//							showData();
//						}
//					};
//					handler.post(runnable);
//				} catch (Exception e) {
//                    e.printStackTrace();
//                    handler.sendEmptyMessage(0);
//					return;
//				}
//
//			}
//		}.start();
    }

    private void showData() {
        viewLoading.setVisibility(View.GONE);
    }

    private void showLoading() {
        viewLoading.setVisibility(View.VISIBLE);
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("my_course"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("my_course");
    }

    public void loadMyCourseIds(final boolean fromCache) {
        final ArrayList<Long> ids = new ArrayList<Long>();
        Type type = new TypeToken<ArrayList<Course4My>>() {
        }.getType();

        ServerDataCache.getInstance().dataWithURL(CoursesAPI.buildMyCoursesURL(), null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    ArrayList<Course4My> myCourses = (ArrayList<Course4My>) data;

                    for (Course4My c : myCourses) {
                        ids.add(c.getId());
                    }
                    final List<CourseModel> curlist = new ArrayList<CourseModel>();
                    LocalStorage.sharedInstance().setIds(ids);

                    if (ids.isEmpty()) {
                        handler.sendEmptyMessage(0);
                        return;
                    } else {
                        handler.sendEmptyMessage(3);
                        List<CourseModel> list = activity.getAllCourse();
                        if (list != null) {
                            for (CourseModel c : list) {
                                for (Long id : ids) {
                                    if (id.equals(c.getId())) {
                                        curlist.add(c);
                                    }
                                }
                            }
                        }

                    }
                    if (myCourseAdapter != null) {
                        myCourseAdapter.setDate(curlist);
                    }
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            myCourseAdapter = new MyCourseAdapter(curlist, getActivity());
                            lvMyList.setAdapter(myCourseAdapter);
                            showData();
                        }
                    });
                }
//                            catch (Exception e) {
//                                handler.sendEmptyMessage(0);
//                            }
                else {
                    handler.sendEmptyMessage(0);
                }
            }
        });
        if (Constants.NET_IS_SUCCESS && fromCache) {
            loadMyCourseIds(false);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnable);
    }
}
