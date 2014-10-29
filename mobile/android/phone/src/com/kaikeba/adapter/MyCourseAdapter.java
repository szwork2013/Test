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
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

public class MyCourseAdapter extends BaseAdapter {
    public BitmapUtils bitmapUtils;
    private List<CourseModel> courses;
    private LayoutInflater inflater;
    private Context context;

    public MyCourseAdapter(List<CourseModel> courses, Context c) {
        this.context = c;
        this.courses = courses;
        inflater = LayoutInflater.from(c);
        bitmapUtils = BitmapHelp.getBitmapUtils(c.getApplicationContext());
    }

    public void setDate(List<CourseModel> newCourses) {
        if (courses != null) {
            courses.clear();
            courses.addAll(newCourses);
        }
    }

    @Override
    public int getCount() {
        return courses.size();
    }

    @Override
    public Object getItem(int position) {
        return courses.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        final CourseModel c = courses.get(position);
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.my_course_item, null);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        bitmapUtils.display(holder.gridCourseBg, c.getCover_image() + "!cc.www");
        bitmapUtils.display(holder.gridCourseBg, c.getCover_image() + "!cc.www",BitmapHelp.getBitMapConfig(context,R.drawable.default_224_140));
//		holder.colledgeName.setText("　" + c.getSchoolName() + "　");
        if ("InstructiveCourse".equals(c.getType())) {
            holder.courseType.setText(" 导学课 ");
            holder.courseType.setBackgroundColor(context.getResources().getColor(R.color.unknow_apply));
        } else {
            holder.courseType.setText(" 公开课 ");
        }
        holder.courseName.setText(c.getName());
        /*bitmapUtils.display(holder.instructorImg, c.getInstructorAvatar());
		holder.instructorName.setText(c.getInstructorName());
		holder.instuctorTitle.setText(c.getInstructorTitle());*/
        holder.courseIntro.setText(c.getSlogan());
        if (c.getCreated_at() != null) {
            if (DateUtils.getDateprice(DateUtils.StringToDate(c
                    .getCreated_at()))) {
//				holder.applyTime.setText("报名结束");
            } else {
//				holder.applyTime.setText(c.getStartDate());
            }
        } else {
            holder.applyTime.setText("待定");
        }
        return convertView;
    }

    class ViewHolder {
        ImageView gridCourseBg;
        TextView colledgeName;
        TextView courseType;
        TextView courseName;
        ImageView instructorImg;
        TextView instructorName;
        TextView instuctorTitle;
        TextView courseIntro;
        TextView applyTime;

        public ViewHolder(View v) {
            gridCourseBg = (ImageView) v.findViewById(R.id.iv_mycourse_cover);
            colledgeName = (TextView) v.findViewById(R.id.colledgeName);
            courseType = (TextView) v.findViewById(R.id.courseType);
            courseName = (TextView) v.findViewById(R.id.courseName);
			/*instructorImg = (ImageView) v.findViewById(R.id.instructorImg);
			instructorName = (TextView) v.findViewById(R.id.instructorName);
			instuctorTitle = (TextView) v.findViewById(R.id.instuctorTitle);*/
            courseIntro = (TextView) v.findViewById(R.id.courseIntro);
//			applyTime = (TextView) v.findViewById(R.id.tv_course_time);
        }
    }

}
