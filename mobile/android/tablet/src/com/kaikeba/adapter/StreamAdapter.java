package com.kaikeba.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.UserActivity;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;

public class StreamAdapter extends BaseAdapter {

    private List<UserActivity> activitys = new ArrayList<UserActivity>();
    private LayoutInflater inflater;
    private MainActivity mainActivity;

    public StreamAdapter(MainActivity c) {
        inflater = LayoutInflater.from(c);
        this.mainActivity = c;
    }

    public void setDate(List<UserActivity> _activitys) {
        activitys.clear();
        activitys.addAll(_activitys);
    }

    public void clearDate() {
        activitys.clear();
    }

    @Override
    public int getCount() {
        return activitys.size();
    }

    @Override
    public Object getItem(int position) {
        return activitys.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        final UserActivity c = activitys.get(position);
        Course course = mainActivity.getCourse(c.getCourse_id());
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.activity_child, null);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (course != null && c != null) {
            holder.name.setText(course.getCourseName() + "  " + c.getTitle());
        }
        holder.posted_at.setText(DateUtils.getCourseStartTime(c.getCreated_at()));
        return convertView;
    }

    class ViewHolder {
        TextView name;
        TextView posted_at;

        public ViewHolder(View v) {
            name = (TextView) v.findViewById(R.id.name);
            posted_at = (TextView) v.findViewById(R.id.posted_at);
        }
    }

}
