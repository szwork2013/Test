package com.kaikeba.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

/**
 * Created by mjliu on 14-8-7.
 */
public class TeacherAdapter extends BaseAdapter {

    private List<CourseModel.TechInfo> techInfoList;
    private Context mContext;
    private LayoutInflater inflater;
    private BitmapUtils bitmapUtils;

    public TeacherAdapter(Context context, List<CourseModel.TechInfo> list) {
        mContext = context;
        techInfoList = list;
        inflater = LayoutInflater.from(context);
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext.getApplicationContext());
    }

    @Override
    public int getCount() {
        return techInfoList == null ? 0 : techInfoList.size();
    }

    @Override
    public Object getItem(int position) {
        return techInfoList == null ? null : techInfoList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.teacher_intro_layout, null);
            holder = new ViewHolder();
            holder.course_title = (TextView) convertView.findViewById(R.id.course_title);
            holder.teacherImg = (ImageView) convertView.findViewById(R.id.teacher_img);
            holder.teacherName = (TextView) convertView.findViewById(R.id.teacher_name);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        CourseModel.TechInfo info = techInfoList.get(position);
        holder.course_title.setText(info.getIntro());
        holder.teacherName.setText(info.getName());
        bitmapUtils.display(holder.teacherImg, info.getTech_img());
//        bitmapUtils.display(holder.teacherImg, info.getTech_img(),BitmapHelp.getBitMapConfig(mContext,R.drawable.head_teacher));
        return convertView;
    }


    class ViewHolder {
        ImageView teacherImg;
        TextView teacherName;
        TextView course_title;
    }
}
