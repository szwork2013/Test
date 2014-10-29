package com.kaikeba.activity.fragment;

import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.CourseInfomationActivity;
import com.kaikeba.activity.LoginActivity;
import com.kaikeba.activity.UnitPageActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CoursesAPI;
import com.kaikeba.common.api.EnrollCourseAPI;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.storage.LocalStorage;
import com.kaikeba.common.util.*;
import com.kaikeba.common.widget.AllCoursesGridView;
import com.kaikeba.common.widget.VideoPlayerView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

public class CourseInfomationFragment extends Fragment {

    //	private BitmapManager manager;
    public BitmapUtils bitmapUtils;
    private ImageView iv_course_info_play;
    private TextView tv_course_price;
    private TextView tv_course_old_price;
    private TextView tv_go_pay;
    private TextView tv_course_type;
    private TextView tv_course_name;
    private TextView tv_school_name;
    private TextView tv_instructor_name;
    private TextView tv_course_time;
    private TextView tv_course_time_about;
    private TextView tv_course_number;
    private TextView tv_course_key;
    private TextView tv_course_key_info;
    private CourseModel c;
    private AllCoursesGridView gridView;
    private LayoutInflater inflater;
    private List<Badge> badges;
    private List<Badge> newBadges;
    private RelativeLayout course_info_base_detail;

    private RelativeLayout ll_video_player;
    private VideoPlayerView video_palyer;
    private int height;
    private int width;
    private int bar_height;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case Constants.COURSE_TIME_OUT:
                    Toast.makeText(tv_go_pay.getContext(), "该课程已结课不能学习", Toast.LENGTH_SHORT).show();
                    break;
                case Constants.THERE_IS_NONET:
//                    Toast.makeText(tv_go_pay.getContext(), "网络未连接",Toast.LENGTH_SHORT).show();
                    KKDialog.getInstance().showNoNetToast(tv_go_pay.getContext());
                    break;
            }

        }
    };

    @SuppressWarnings("unchecked")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        bar_height = CommonUtils.getStatusBarHeight(getActivity());
        width = CommonUtils.getScreenWidth(getActivity());
        View v = inflater.inflate(R.layout.course_info_base, container, false);
        height = (int) (Constants.COVER_HEIGHT * (CommonUtils.getScreenWidth(getActivity()) - 10 * Constants.SCREEN_DENSITY) / Constants.COVER_WIDTH + 0.5);
        ll_video_player = (RelativeLayout) v.findViewById(R.id.rl_video_player);
        ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        video_palyer = new VideoPlayerView(getActivity());
        c = (CourseModel) getArguments().getSerializable(ContextUtil.CATEGORY_COURSE);
        Constants.FULL_SCREEN_NO_CLICK = false;
//        video_palyer.setUrl(c.getPromotional_video_url());
//        video_palyer.setImgUrl(c.getCover_image());
        ll_video_player.addView(video_palyer.makeControllerView());
        badges = (ArrayList<Badge>) getArguments().getSerializable("badge");
        newBadges = new ArrayList<Badge>();
//		List<Long> ids = c.getCourseBadges();
//		for (Long id : ids) {
//			for (Badge b : badges) {
//				if (id.equals(b.getId())) {
//					newBadges.add(b);
//				}
//			}
//		}
//		manager = new BitmapManager();
        bitmapUtils = BitmapHelp.getBitmapUtils(getActivity().getApplicationContext());
//		iv_course_info_play = (ImageView)v.findViewById(R.id.iv_course_info_play);
//		iv_course_info_play.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//                int currentNetSate = NetUtil.getNetType(getActivity());
//                if( Constants.NO_NET != currentNetSate){
//                    if(Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate ){
//
//                        KKDialog.getInstance().showNoWifi2Play(getActivity(),
//                                new OnClickListener() {
//                                    @Override
//                                    public void onClick(View v) {
//                                        KKDialog.getInstance().dismiss();
//                                        Constants.nowifi_doplay = false;
//                                        toPlay();
//                                    }
//                                },
//                                new OnClickListener() {
//                                    @Override
//                                    public void onClick(View v) {
//                                        KKDialog.getInstance().dismiss();
//                                    }
//                                });
//                    }else{
//                        toPlay();
//                    }
//                }else{
//
//                    KKDialog.getInstance().showNoNetPlayDialog(getActivity());
//                }
//			}
//		});

        gridView = (AllCoursesGridView) v.findViewById(R.id.gridview);
        gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        tv_course_price = (TextView) v.findViewById(R.id.tv_course_price);
        tv_course_old_price = (TextView) v.findViewById(R.id.tv_course_old_price);
        tv_course_old_price.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);

        tv_go_pay = (TextView) v.findViewById(R.id.tv_go_pay);
        course_info_base_detail = (RelativeLayout) v.findViewById(R.id.course_info_base_detail);
        tv_course_type = (TextView) v.findViewById(R.id.tv_course_type);
        tv_course_name = (TextView) v.findViewById(R.id.tv_course_name);
        tv_school_name = (TextView) v.findViewById(R.id.tv_school_name);
        tv_instructor_name = (TextView) v.findViewById(R.id.tv_instructor_name);
        tv_course_time = (TextView) v.findViewById(R.id.tv_course_time);
        tv_course_time_about = (TextView) v.findViewById(R.id.tv_course_time_about);
        tv_course_number = (TextView) v.findViewById(R.id.tv_course_number);
        tv_course_key = (TextView) v.findViewById(R.id.tv_course_key);
        tv_course_key_info = (TextView) v.findViewById(R.id.tv_course_key_info);
//		bitmapUtils.display(iv_course_info_play, c.getCoverImage());
//		setText();
        return v;
    }

    public void release() {
        if (video_palyer != null) {
            video_palyer.onDestroy();
        }
    }

//	private void setText() {
//		if (c.getPrice().equals("0")) {
//			tv_course_price.setText("￥" + "免费");
//		}
//		else {
//			tv_course_price.setText("￥" + c.getPrice());
//		}
//		if (c.getPrice4Phone().equals("0")) {
//			tv_course_old_price.setVisibility(View.GONE);
//		}
//		else {
//			tv_course_old_price.setText("￥" + c.getPrice4Phone());
//		}
//		if (c.getCourseType().equals("guide")) {
//			tv_course_type.setText("导学课");
//		}
//		else {
//			tv_course_type.setText("公开课");
//		}
//		tv_school_name.setText(c.getSchoolName());
//		tv_instructor_name.setText(c.getInstructorName());
//		tv_course_time.setText(c.getStartDate());
//		tv_course_time_about.setText(c.getEstimate());
//		tv_course_name.setText(c.getCourseName());
//		tv_course_number.setText(c.getCourseNum());
//		tv_course_key.setText("课程关键字：  " + c.getCourseKeywords());
//		tv_course_key_info.setText(c.getCourseIntro());
//
////		tv_go_pay.setText("学习此课程");
//	}

    public void toPlay() {
        /*Intent it = new Intent("com.cooliris.media.MovieView");
        it.setAction(Intent.ACTION_VIEW);
        it.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        Uri data = Uri.parse(c.getPromoVideo());
        it.setDataAndType(data, "video/mp4");
        startActivity(it);*/

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
    public void onResume() {
        super.onResume();
        Constants.FULL_SCREEN_NO_CLICK = false;
        tv_go_pay.setClickable(true);
        MobclickAgent.onPageStart("course_detail_basic"); //统计页面
        CourseInfomationActivity ca = (CourseInfomationActivity) getActivity();
        if (API.getAPI().alreadySignin()) {
            ArrayList<Long> ids = LocalStorage.sharedInstance().getIds();
            for (Long id : ids) {
                if (c.getId() == id) {
                    tv_go_pay.setText("继续学习");
                    ca.ll_go_to_study.setVisibility(View.GONE);
                    tv_go_pay.setVisibility(View.VISIBLE);
                    break;
                }
            }
        }
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        tv_go_pay.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                if (!API.getAPI().alreadySignin()) {
                    Constants.LOGIN_FROM = Constants.FROM_PAY;
                    Intent intent = new Intent(getActivity(), LoginActivity.class);
                    intent.putExtra(Constants.ACTIVITY_NAME_KEY, ContextUtil.CATEGORY_COURSE);
                    intent.putExtra(ContextUtil.CATEGORY_COURSE, c);
                    startActivity(intent);
                    return;
                } else {
                    if (tv_go_pay.getText().toString().equals("继续学习")) {
//                        if(Constants.NO_NET == NetUtil.getNetType(getActivity())){
////                            handler.sendEmptyMessage(Constants.THERE_IS_NONET);
//                            KKDialog.getInstance().showNoNetToast(getActivity());
//                        }else{
                        goUnit();
//                        }
                    } else {
                        Toast.makeText(getActivity(), "正在进入课程", Toast.LENGTH_SHORT).show();
                        if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                            handler.sendEmptyMessage(Constants.THERE_IS_NONET);
                            return;
                        }
                        new Thread() {
                            public void run() {
                                Constants.isFreshMyCourse = true;
                                tv_go_pay.setClickable(false);
                                try {
                                    if (null == EnrollCourseAPI.entrollCourse(c.getId())) {
                                        handler.sendEmptyMessage(Constants.COURSE_TIME_OUT);
                                    } else {
                                        try {
                                            LocalStorage.sharedInstance().setIds(CoursesAPI.getMyCoursesId(false));
                                        } catch (DibitsExceptionC e) {
                                            // TODO Auto-generated catch block
                                            e.printStackTrace();
                                        }
                                        handler.post(new Runnable() {
                                            @Override
                                            public void run() {
                                                goUnit();
                                            }
                                        });
                                    }
                                } catch (DibitsExceptionC e) {
                                    e.printStackTrace();
                                }
                            }

                            ;
                        }.start();
                    }
                }
            }
        });
//		gridView.setAdapter(new BadgeAdapter());
    }

    private void goUnit() {
        API.VIEW_INTO = 2;
        /*Intent mIntent = new Intent();
		Bundle bundle1 = new Bundle();
		bundle1.putSerializable("course", c);
        bundle1.putString("courseID",c.getId()+"");
        bundle1.putString("courseName",c.getCourseName());
        bundle1.putString("bgUrl",c.getCoverImage());
		mIntent.putExtras(bundle1);
		mIntent.setClass(getActivity(), UnitActivity.class);
		startActivity(mIntent);*/
        ((CourseInfomationActivity) getActivity()).stepIntoCourseArrange();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        if (video_palyer != null) {
            video_palyer.screenChange(newConfig, height);
        }
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (API.getAPI().alreadySignin()) {
                if (!CourseInfomationActivity.getCourseInfoActivity().isFromMyCourse) {
                    CourseInfomationActivity.getCourseInfoActivity().setTv_go_studyGone();
                }
                tv_go_pay.setVisibility(View.GONE);

            } else {
                CourseInfomationActivity.getCourseInfoActivity().setTv_go_studyGone();
            }
            gridView.setVisibility(View.GONE);
            course_info_base_detail.setVisibility(View.GONE);
            CourseInfomationActivity.getCourseInfoActivity().setGone();
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, width));
        } else if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            if (API.getAPI().alreadySignin()) {
                if (!CourseInfomationActivity.getCourseInfoActivity().isFromMyCourse) {
                    CourseInfomationActivity.getCourseInfoActivity().setTv_go_studyVis();
                } else {
                    tv_go_pay.setVisibility(View.VISIBLE);
                }
            } else {
                CourseInfomationActivity.getCourseInfoActivity().setTv_go_studyVis();
            }
            gridView.setVisibility(View.VISIBLE);
            course_info_base_detail.setVisibility(View.VISIBLE);
            CourseInfomationActivity.getCourseInfoActivity().setVisible();
            ll_video_player.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height));
        }
        super.onConfigurationChanged(newConfig);
    }

    public void onBackPressed() {
        if (!video_palyer.isScaleTag) {
            getActivity().finish();
        } else {
            video_palyer.onBackPressed();
            CourseInfomationActivity.getCourseInfoActivity().setVisible();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (video_palyer != null) {
            video_palyer.onDestroy();
        }
        MobclickAgent.onPageEnd("course_detail_basic");
    }

    class BadgeAdapter extends BaseAdapter {

        @Override
        public int getCount() {
            // TODO Auto-generated method stub
            return newBadges.size();
        }

        @Override
        public Object getItem(int position) {
            // TODO Auto-generated method stub
            return newBadges.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // TODO Auto-generated method stub
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.badge_child, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            holder.tv.setText(newBadges.get(position).getBadgeTitle());
            bitmapUtils.display(holder.iv, newBadges.get(position).getImage4big());
//			manager.loadBitmap(newBadges.get(position).getImage4big(), holder.iv);
            return convertView;
        }

        class ViewHolder {
            ImageView iv;
            TextView tv;

            public ViewHolder(View v) {
                iv = (ImageView) v.findViewById(R.id.iv_courseinfo_badge);
                tv = (TextView) v.findViewById(R.id.tv_courseinfo_badge);
            }
        }

    }


}
