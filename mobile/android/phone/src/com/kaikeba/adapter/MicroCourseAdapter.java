package com.kaikeba.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;

/**
 * Created by chris on 14-7-15.
 */
public class MicroCourseAdapter extends BaseAdapter {

    public BitmapUtils bitmapUtils;
    private ArrayList<CourseInfo.MicroSpecialties.Courses> list;
    private Context mContext;
    private LayoutInflater inflate;

    public MicroCourseAdapter(Context context, ArrayList<CourseInfo.MicroSpecialties.Courses> listCourse) {
        this.list = listCourse;
        this.mContext = context;
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
        inflate = LayoutInflater.from(mContext);
    }

    @Override
    public int getCount() {
        return list == null ? 0 : list.size();
    }

    @Override
    public Object getItem(int position) {
        return list == null ? null : list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean isEnabled(int position) {
        if (((CourseInfo.MicroSpecialties.Courses) getItem(position)).getStatus().equals("online")) {
            return true;
        } else {
            return false;
        }
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final CourseInfo.MicroSpecialties.Courses courseItem;
        ViewHolder holder = null;
        if (convertView == null) {
            convertView = inflate.inflate(R.layout.micro_course_item, null);
            holder = new ViewHolder();
            holder.microName = (TextView) convertView.findViewById(R.id.micro_name);
            holder.microGo = (ImageView) convertView.findViewById(R.id.micro_go);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        courseItem = list.get(position);

        holder.microName.setText(courseItem.getName());
        if (courseItem.getStatus().equals("online")) {
            holder.microGo.setImageResource(R.drawable.micpro_button_jointclass_def);
        } else {
            holder.microGo.setImageResource(R.drawable.micpro_button_finish_def);
        }
        return convertView;
    }

    class ViewHolder {
        TextView microName;
        ImageView microGo;
    }
}
