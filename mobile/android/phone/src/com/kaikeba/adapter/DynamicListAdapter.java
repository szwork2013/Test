package com.kaikeba.adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.GuideCourseAcitvity;
import com.kaikeba.activity.GuideCourseLearnActivity;
import com.kaikeba.activity.OpenCourseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.DynamicFirstPageInfo;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.*;

/**
 * Created by chris on 14-7-15.
 */
public class DynamicListAdapter extends BaseAdapter {

    private Context mContext;
    private LayoutInflater inflate;
    private BitmapUtils bitmapUtils;
    private int progress_width;
    private ArrayList<DynamicFirstPageInfo> dynamicInfoList;
    private ArrayList<CourseModel> allCourseList;
    private View.OnClickListener clickTaskListener = new View.OnClickListener() {

        @Override
        public void onClick(View v) {
            int currentNetSate = NetUtil.getNetType(mContext);
            if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == currentNetSate) {

                KKDialog.getInstance().showNoWifi2Play(mContext,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                                Constants.nowifi_doplay = false;
                                learnVideos(v);
                            }
                        },
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                            }
                        });
            } else {
                learnVideos(v);
            }
        }
    };

    private void learnVideos(View v) {
        HashMap<String, String> taskInfo = null;
        long taskTime = (long) 0.0;
        String status = "t";
        String key = "";

        DynamicFirstPageInfo info = null;
        int viewCount = 0;

        if (v.getTag(R.string.task_type) != null && v.getTag(R.string.task_infos) != null) {
            key = (String) v.getTag(R.string.task_type);
            taskInfo = (HashMap<String, String>) v.getTag(R.string.task_infos);
            try {
                taskTime = DateUtils.parseDate(taskInfo.get("due_at")).getTime();
                status = taskInfo.get("status");
            } catch (Exception e) {
                e.printStackTrace();
            }

        } else if (v.getTag(R.string.position_in_videos) != null) {
            info = (DynamicFirstPageInfo) v.getTag(R.string.position_in_videos);
            if (v.getTag(R.string.watched_view_count) != null)
                viewCount = (Integer) v.getTag(R.string.watched_view_count);
        }

        switch (v.getId()) {
            case R.id.learning_course_layout:
            case R.id.video_task:
                openInstructiveCourse(info, viewCount);
                break;
            case R.id.rl_task:
                taskNotice(taskInfo, taskTime, key, status);
                break;
            case R.id.dynamic_collect_card:
                if (v.getTag(R.string.update_tag) != null) {
                    info = (DynamicFirstPageInfo) v.getTag(R.string.update_tag);
                    openUpdateCourse(info);
                }
                break;
            default:
                break;
        }

    }

    private Toast myToast;

    public DynamicListAdapter(Context mContext, ArrayList<DynamicFirstPageInfo> dynamicList) {
//        dynamicInfoList = new  ArrayList<DynamicFirstPageInfo>();
//        dynamicInfoList.addAll(dynamicList);
        dynamicInfoList = dynamicList;
        inflate = LayoutInflater.from(mContext);
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext.getApplicationContext());
        this.mContext = mContext;
        myToast = Toast.makeText(mContext, "", Toast.LENGTH_SHORT);
        loadAllCourseData();
    }

    protected void loadAllCourseData() {
        allCourseList = new ArrayList<CourseModel>();
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    allCourseList = (ArrayList<CourseModel>) data;
                } else {
                    loadAllCourseData();
                }
            }
        });
    }

    @Override
    public int getCount() {
        return dynamicInfoList == null ? 0 : dynamicInfoList.size();
    }

    @Override
    public Object getItem(int position) {
        return dynamicInfoList == null ? null : dynamicInfoList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = inflate.inflate(R.layout.dynamic_list_card, null);
            holder = new ViewHolder();
            holder.dynamic_learning_card = (LinearLayout) convertView.findViewById(R.id.dynamic_learning_card);
            holder.learning_course_img = (ImageView) convertView.findViewById(R.id.learning_course_img);
            holder.learning_course_txt = (TextView) convertView.findViewById(R.id.learning_course_txt);
            holder.learning_course_video_progress = (SeekBar) convertView.findViewById(R.id.learning_course_video_progress);
            holder.course_video_flag_img = (ImageView) convertView.findViewById(R.id.course_video_flag);
            holder.video_ratio = (TextView) convertView.findViewById(R.id.video_ratio);
            holder.witch_week_txt = (TextView) convertView.findViewById(R.id.witch_week);
            holder.course_video_layout = (RelativeLayout) convertView.findViewById(R.id.course_video_layout);
            holder.learning_course_layout = (LinearLayout) convertView.findViewById(R.id.learning_course_layout);
            holder.learn_task_txv = (TextView) convertView.findViewById(R.id.learn_task_txv);
            holder.learn_task_txv.setTypeface(Typeface.MONOSPACE, Typeface.BOLD_ITALIC);
            holder.learn_task = (LinearLayout) convertView.findViewById(R.id.learn_task);
            holder.video_task = (RelativeLayout) convertView.findViewById(R.id.video_task);

            holder.dynamic_collect_card = (LinearLayout) convertView.findViewById(R.id.dynamic_collect_card);
            holder.update_course_type_img = (ImageView) convertView.findViewById(R.id.update_course_type_img);
            holder.updateNameTxt = (TextView) convertView.findViewById(R.id.update_name);
            holder.update_intro_txt = (TextView) convertView.findViewById(R.id.update_intro);
            holder.update_img = (ImageView) convertView.findViewById(R.id.update_img);
            holder.collect_course_time = (TextView) convertView.findViewById(R.id.time);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        DynamicFirstPageInfo info = dynamicInfoList.get(position);
        if (info.getCardtype().equals("update")) {
            String type = "";
            if (info.getType().equals("OpenCourse")) {
                type = "公开课";
                holder.update_intro_txt.setText("《" + info.getName() + "》的老师又往里面加了些干货呦，快来看看吧");
            } else {
                type = "导学课";
                holder.update_intro_txt.setText(type + "《" + info.getName() + "》开了新的班次，让我们一起开课吧");
            }
            holder.updateNameTxt.setText(info.getName());
            holder.collect_course_time.setText(info.getDate());
            if (info.getType().equals("OpenCourse")) {
                holder.update_course_type_img.setImageResource(R.drawable.public_class_button_link_def);
            } else {
                holder.update_course_type_img.setImageResource(R.drawable.teachers_button_link_def);
            }
//            bitmapUtils.display(holder.update_img, info.getCover_image());
            bitmapUtils.display(holder.update_img, info.getCover_image(),BitmapHelp.getBitMapConfig(mContext,R.drawable.default_160_100));

            justiceShowCollectOrLearn(holder, false);
            holder.dynamic_collect_card.setTag(R.string.update_tag, info);
            holder.dynamic_collect_card.setOnClickListener(clickTaskListener);
        } else {
            int view_count = 0;
            holder.learning_course_txt.setText(info.getName());
//            bitmapUtils.display(holder.learning_course_img, info.getCover_image());
            bitmapUtils.display(holder.learning_course_img, info.getCover_image(),BitmapHelp.getBitMapConfig(mContext,R.drawable.default_128_80));

            holder.witch_week_txt.setText("第" + info.getWeek() + "周");
            List<Map<String, String>> mapList = (List<Map<String, String>>) info.getInfo().get("video");
            Map<String, String> map = new HashMap<String, String>();
            if (mapList != null && mapList.size() > 0) {
                holder.video_task.setVisibility(View.VISIBLE);
                map = mapList.get(0);
                view_count = Integer.parseInt(map.get("view_count"));
                int maxprogress = Integer.parseInt(map.get("video_count"));
                holder.video_ratio.setText(view_count + "/" + maxprogress);
                holder.learning_course_video_progress.setSecondaryProgress(view_count);
                holder.learning_course_video_progress.setProgress(view_count);
                holder.learning_course_video_progress.setMax(maxprogress);
                setVideoFlag(view_count, maxprogress, holder);
            } else {
                view_count = 0;
                holder.video_task.setVisibility(View.GONE);
                holder.video_ratio.setText(0 + "/" + 0);
                holder.learning_course_video_progress.setSecondaryProgress(0);
                holder.learning_course_video_progress.setProgress(0);
                holder.learning_course_video_progress.setMax(0);
                setVideoFlag(0, 0, holder);
            }

            justiceShowCollectOrLearn(holder, true);
            addTask(holder, info.getInfo());
            holder.video_task.setTag(R.string.position_in_videos, info);
            holder.video_task.setTag(R.string.watched_view_count, view_count);
            holder.video_task.setOnClickListener(clickTaskListener);
            holder.learning_course_layout.setTag(R.string.position_in_videos, info);
            holder.learning_course_layout.setOnClickListener(clickTaskListener);
        }
        return convertView;
    }

    private void openInstructiveCourse(DynamicFirstPageInfo info, int viewCount) {
        if (info == null) {
            return;
        }
        Constants.FROM_WHERE = Constants.FROM_DYNAMIC;
        Intent it = new Intent();
        it.setClass(mContext, GuideCourseLearnActivity.class);
        Bundle b = new Bundle();
        b.putInt("weeks", info.getWeek());
        b.putInt("lms_course_id", info.getLms_course_id());
        b.putInt("number", viewCount);
        CourseModel course = getCourseInfoById(info.getCourse_id());
        if (course == null) {
            course = new CourseModel();
            course.setId(info.getCourse_id());
            course.setName(info.getName());
        }
        b.putSerializable(ContextUtil.CATEGORY_COURSE, course);
        it.putExtras(b);
        mContext.startActivity(it);
    }

    private void openUpdateCourse(DynamicFirstPageInfo info) {
        if (info == null) {
            return;
        }
        Intent it = new Intent();
        if (info.getType().equals("InstructiveCourse")) {
            it.setClass(mContext, GuideCourseAcitvity.class);

        } else {
            it.setClass(mContext, OpenCourseActivity.class);
        }
        Constants.FROM_WHERE = Constants.FROM_DYNAMIC;
        Bundle b = new Bundle();
        CourseModel course = getCourseInfoById(info.getCourse_id());
        if (course == null) {
            course = new CourseModel();
            course.setId(info.getCourse_id());
            course.setName(info.getName());
        }
        b.putSerializable(ContextUtil.CATEGORY_COURSE, course);
        it.putExtras(b);
        mContext.startActivity(it);
    }

    private void taskNotice(HashMap<String, String> taskInfo, long taskTime, String key, String status) {
        String toastInfo = "";
        if (System.currentTimeMillis() - taskTime > 0) {
            toastInfo = "程序猿施工中，请先到开课吧官网进行" + key;
        } else {
            if (taskInfo != null && taskInfo.get("statue").equals("n")) {
                toastInfo = "程序猿施工中，请先到开课吧官网进行" + key;
            } else {
                toastInfo = "程序猿施工中，请先到开课吧官网进行" + key;
            }
        }
        myToast.setText(toastInfo);
        myToast.show();
    }

    public int getWidth(final View imageView) {
        ViewTreeObserver vto2 = imageView.getViewTreeObserver();
        vto2.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                imageView.getViewTreeObserver().removeGlobalOnLayoutListener(this);
                progress_width = imageView.getWidth();
            }
        });
        return progress_width;
    }

    private void setVideoFlag(int progress, int maxprogress, ViewHolder holder) {
        int width = getWidth(holder.learning_course_video_progress);
        int off;
        if (progress == 0) {
            off = 0;
        } else {
            off = (int) (width * (progress * 1.0 / maxprogress)) - 2;
        }
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) holder.course_video_flag_img.getLayoutParams();
        layoutParams.setMargins(off, 0, 0, 0);
        holder.course_video_flag_img.setLayoutParams(layoutParams);
    }

    private void justiceShowCollectOrLearn(ViewHolder holder, boolean isShowLearn) {
        if (isShowLearn) {
            holder.dynamic_learning_card.setVisibility(View.VISIBLE);
            holder.dynamic_collect_card.setVisibility(View.GONE);
        } else {
            holder.dynamic_learning_card.setVisibility(View.GONE);
            holder.dynamic_collect_card.setVisibility(View.VISIBLE);
        }
    }

    private boolean isTaskVideoFlag = true;//判断一个item中如果没有video时去掉分割线
    private void addTask(ViewHolder holder, Map<String, List<Map<String, String>>> info) {
        holder.learn_task.removeAllViews();
        LearnTask task = new LearnTask();
        isTaskVideoFlag = true;
        Iterator iter = info.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry entry = (Map.Entry) iter.next();
            String key = (String) entry.getKey();
            List<Map<String, String>> taskList = (List<Map<String, String>>) entry.getValue();

            if (key.equals("discuss")) {
                setTaskItem("讨论", task, taskList, holder);
//                for(int i = 0;i < taskList.size();i++){
//                    map = (HashMap<String, String>) taskList.get(i);
//                    View view = inflate.inflate(R.layout.dynamic_learn_task,null);
//                    task.learning_course_discuss_name = (TextView) view.findViewById(R.id.learning_course_discuss_name);
//                    task.learning_course_discuss_score = (TextView) view.findViewById(R.id.learning_course_discuss_score);
//                    task.learning_course_discuss_time = (TextView) view.findViewById(R.id.learning_course_discuss_time);
//                    task.task_done = (TextView) view.findViewById(R.id.task_done);
//
//                    task.learning_course_discuss_name.setText("讨论");
//                    task.learning_course_discuss_score.setText(map.get("point"));
//
//                    String to_time = map.get("due_at");
//                    if(to_time != null){
//                        to_time = to_time.substring(0,10);
//                    }else {
//                        to_time = "2014-07-08";
//                    }
//                    task.learning_course_discuss_time.setText(to_time);
//
//
//                    if (map.get("statue").equals("n")){
//                        task.task_done.setBackgroundResource(R.drawable.task_button_unfinished1_def);
//                    } else {
//                        task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction3_disab);
//                        task.learning_course_discuss_time.setTextColor(0xff8cca07);
//                        task.task_done.setBackgroundResource(R.drawable.task_button_finish_def);
//                    }
//
//                    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
//                    learnTask.addView(view,params);
//                }
            } else if (key.equals("homework")) {
                setTaskItem("作业", task, taskList, holder);
//                for(int i = 0;i < taskList.size();i++){
//                    map = (HashMap<String, String>) taskList.get(i);
//                    View view = inflate.inflate(R.layout.dynamic_learn_task,null);
//                    task.learning_course_discuss_name = (TextView) view.findViewById(R.id.learning_course_discuss_name);
//                    task.learning_course_discuss_score = (TextView) view.findViewById(R.id.learning_course_discuss_score);
//                    task.learning_course_discuss_time = (TextView) view.findViewById(R.id.learning_course_discuss_time);
//                    task.task_done = (TextView) view.findViewById(R.id.task_done);
//
//                    task.learning_course_discuss_name.setText("作业");
//                    task.learning_course_discuss_score.setText(map.get("point"));
//
//                    String to_time = map.get("due_at");
//                    if(to_time != null){
//                        to_time = to_time.substring(0,10);
//                    }else {
//                        to_time = "2014-07-08";
//                    }
//                    task.learning_course_discuss_time.setText(to_time);
//
//                    if (map.get("statue").equals("n")){
//                        task.task_done.setBackgroundResource(R.drawable.task_button_unfinished1_def);
//                    } else {
//                        task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction3_disab);
//                        task.learning_course_discuss_time.setTextColor(0xff8cca07);
//                        task.task_done.setBackgroundResource(R.drawable.task_button_finish_def);
//                    }
//
//                    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
//                    learnTask.addView(view,params);
//                }
            } else if (key.equals("test")) {
                setTaskItem("测验", task, taskList, holder);
//                for(int i = 0;i < taskList.size();i++){
//                    map = (HashMap<String, String>) taskList.get(i);
//                    View view = inflate.inflate(R.layout.dynamic_learn_task,null);
//                    task.learning_course_discuss_name = (TextView) view.findViewById(R.id.learning_course_discuss_name);
//                    task.learning_course_discuss_score = (TextView) view.findViewById(R.id.learning_course_discuss_score);
//                    task.learning_course_discuss_time = (TextView) view.findViewById(R.id.learning_course_discuss_time);
//                    task.task_done = (TextView) view.findViewById(R.id.task_done);
//
//                    task.learning_course_discuss_name.setText("测验");
//                    task.learning_course_discuss_score.setText(map.get("point"));
//
//                    String to_time = map.get("due_at");
//                    if(to_time != null){
//                        to_time = to_time.substring(0,10);
//                    }else {
//                        to_time = "2014-07-08";
//                    }
//                    task.learning_course_discuss_time.setText(to_time);
//
//                    if (map.get("statue").equals("n")){
//                        task.task_done.setBackgroundResource(R.drawable.task_button_unfinished1_def);
//                    } else {
//                        task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction3_disab);
//                        task.learning_course_discuss_time.setTextColor(0xff8cca07);
//                        task.task_done.setBackgroundResource(R.drawable.task_button_finish_def);
//                    }
//
//
//                    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
//                    learnTask.addView(view,params);
//                }
            }
        }
    }

    private void setTaskItem(String key, LearnTask task, List<Map<String, String>> taskList, ViewHolder holder) {

        HashMap<String, String> map = new HashMap<String, String>();
        for (int i = 0; i < taskList.size(); i++) {
            map = (HashMap<String, String>) taskList.get(i);
            View view = inflate.inflate(R.layout.dynamic_learn_task, null);
            task.learning_course_discuss_name = (TextView) view.findViewById(R.id.learning_course_discuss_name);
            task.learning_course_discuss_score = (TextView) view.findViewById(R.id.learning_course_discuss_score);
            task.learning_course_discuss_time = (TextView) view.findViewById(R.id.learning_course_discuss_time);
            task.task_done = (TextView) view.findViewById(R.id.task_done);
            task.learning_course_discuss_img = (ImageView) view.findViewById(R.id.learning_course_discuss_img);
            task.dynamic_split = view.findViewById(R.id.dynamic_split);
            task.learning_course_discuss_name.setText(key);
            task.learning_course_discuss_score.setText(map.get("point") + "分");

            if(holder.video_task.getVisibility() == View.GONE && isTaskVideoFlag){
                task.dynamic_split.setVisibility(View.GONE);
                isTaskVideoFlag = false;
            } else {
                task.dynamic_split.setVisibility(View.VISIBLE);
            }

            if (key.equals("测验")) {
                task.learning_course_discuss_img.setImageResource(R.drawable.unit_icon_quiz_gray);
            } else if (key.equals("讨论")) {
                task.learning_course_discuss_img.setImageResource(R.drawable.unit_icon_dis_gray);
            } else if (key.equals("作业")) {
                task.learning_course_discuss_img.setImageResource(R.drawable.unit_icon_assignment_gray);
            }

            String to_time = map.get("due_at");
            if (to_time != null) {
                to_time = getTime(to_time, map.get("statue"));
            } else {
                to_time = "已截止";
            }

            if (map.get("statue").equals("n")) {
                if (to_time.contains("月")) {
                    task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction1_disab);
                    task.learning_course_discuss_time.setTextColor(mContext.getResources().getColor(R.color.task_unfinished1));
                    task.task_done.setBackgroundResource(R.drawable.task_button_unfinished1_def);
                } else {
                    task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction2_disab);
                    task.learning_course_discuss_time.setTextColor(mContext.getResources().getColor(R.color.task_unfinished2));
                    task.task_done.setBackgroundResource(R.drawable.task_button_unfinished2_def);
                }
                task.learning_course_discuss_time.setText(to_time);
            } else {
                task.learning_course_discuss_score.setBackgroundResource(R.drawable.task_button_fraction3_disab);
                task.learning_course_discuss_time.setTextColor(mContext.getResources().getColor(R.color.task_finish));
                task.task_done.setBackgroundResource(R.drawable.task_button_finish_def);
                task.learning_course_discuss_time.setText(to_time);
            }

            view.setTag(R.string.task_type, key);
            view.setTag(R.string.task_infos, map);
            view.setOnClickListener(clickTaskListener);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            holder.learn_task.addView(view, params);
        }
    }

    private String getTime(String to_time, String statue) {

        Long distance = System.currentTimeMillis() - DateUtils.StringToDate(to_time, DateUtils.pattens[1]).getTime();
        if (distance > 0) {
            return "已截止";
        } else {
            if (Math.abs(distance) > DateUtils.DAY_SECONDS_MILLI) {
                String[] calendar = to_time.split("-");
                return Integer.parseInt(calendar[1]) + "月" + calendar[2].split(" ")[0] + "日截止";
            } else {
                int hours = (int) (distance / 1000 / 60 / 60);
                return "还有" + hours + "个小时";
            }
        }
    }

    private CourseModel getCourseInfoById(int id) {
        CourseModel info = null;
        if (allCourseList != null && allCourseList.size() > 0) {
            for (int i = 0; i < allCourseList.size(); i++) {
                if (allCourseList.get(i).getId() == id) {
                    info = allCourseList.get(i);
                    break;
                }
            }
        }
        return info;
    }

    class ViewHolder {
        LinearLayout dynamic_learning_card;
        ImageView learning_course_img;
        TextView learning_course_txt;
        SeekBar learning_course_video_progress;
        ImageView course_video_flag_img;
        TextView video_ratio;
        TextView witch_week_txt;
        LinearLayout learning_course_layout;
        TextView learn_task_txv;
        RelativeLayout video_task;


        LinearLayout learn_task;

        LinearLayout dynamic_collect_card;
        TextView collect_course_time;
        TextView updateNameTxt;
        ImageView update_course_type_img;
        ImageView update_img;
        TextView update_intro_txt;
        RelativeLayout course_video_layout;
    }

    class LearnTask {
        TextView learning_course_discuss_name;
        TextView learning_course_discuss_score;
        TextView learning_course_discuss_time;
        TextView task_done;
        ImageView learning_course_discuss_img;
        View dynamic_split;
    }
}
