package com.kaikeba.adapter;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.common.entity.LmsCourseInfo;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;

import java.text.ParseException;
import java.util.Date;
import java.util.List;

/**
 * Created by mjliu on 14-7-31.
 */
public class StudyAdapter extends BaseAdapter {

    private List<LmsCourseInfo.Lms_Course_List> lms_course_list;
    private Context mContext;

    public StudyAdapter(Context context, List<LmsCourseInfo.Lms_Course_List> lms_course_list) {
        this.lms_course_list = lms_course_list;
        mContext = context;
    }

    @Override
    public int getCount() {
        return lms_course_list == null ? 0 : lms_course_list.size();
    }

    @Override
    public Object getItem(int position) {
        return lms_course_list == null ? null : lms_course_list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = ((Activity) mContext).getLayoutInflater().inflate(R.layout.lms_course_item, null);
            holder = new ViewHolder();
            holder.lms_course_time = (TextView) convertView.findViewById(R.id.lms_course_time);
            holder.lms_course_join = (ImageView) convertView.findViewById(R.id.lms_course_join);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        String status = lms_course_list.get(position).getStatus();
        String start_at = null;
        String end_at = null;
        start_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(lms_course_list.get(position).getStart_at())));
        end_at = DateUtils.getCourseStartTime(new Date(Long.parseLong(lms_course_list.get(position).getConclude_at())));
        try {
            start_at = DateUtils.getYR(start_at);
            end_at = DateUtils.getYR(end_at);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        holder.lms_course_time.setText(start_at + "-" + end_at);
        if (status.equals("close")) {
            holder.lms_course_join.setImageResource(R.drawable.close_course);
        } else if (status.equals("enrolled")) {
            holder.lms_course_join.setImageResource(R.drawable.continue_learn);
        } else {
            holder.lms_course_join.setImageResource(R.drawable.join_course);
        }
        return convertView;
    }

    class ViewHolder {
        TextView lms_course_time;
        ImageView lms_course_join;
    }
}
