package com.kaikeba.mitv.adapter;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.objects.CourseListItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kkb on 8/5/14.
 */
public class MainAdapter extends ArrayAdapter<CourseListItem> {
    private Context context;
    private List<CourseListItem> courses;

    public MainAdapter(Context context, ArrayList<CourseListItem> courses) {
        super(context, R.layout.item_course, courses);

        this.context = context;
        this.courses = courses;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View row = convertView;
        ViewHolder viewHolder = null;

        if (row == null) {
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            row = inflater.inflate(R.layout.item_course, parent, false);

            viewHolder = new ViewHolder();
            viewHolder.courseTitleLabel = (TextView) row.findViewById(R.id.courseTitleTextView);

            row.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) row.getTag();
        }

//        row.setBackgroundResource(R.drawable.course_list_item_selector);

        CourseListItem aCourse = courses.get(position);
        viewHolder.courseTitleLabel.setText(aCourse.getName());

        return row;
    }

    protected static class ViewHolder {
        protected TextView courseTitleLabel;
    }
}












