package com.kaikeba.adapter;

import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.widget.MyRatingBar;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.text.DecimalFormat;
import java.util.List;

public class CategoryCourseAdapter extends BaseAdapter {


    public BitmapUtils bitmapUtils;
    private LayoutInflater inflater;
    private List<? extends CourseModel> courses;
    private Context context;

    public CategoryCourseAdapter(Context context, List<? extends CourseModel> categoryCourses, Handler handler) {
        this.context = context;
        this.courses = categoryCourses;
        if (context == null) {
            return;
        }
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
        inflater = LayoutInflater.from(context);
    }

    @Override
    public int getCount() {
        if (courses != null) {
            return courses.size();
        }
        return 0;
    }

    @Override
    public Object getItem(int position) {
        if (courses != null) {
            return courses.get(position);
        }
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder viewHolder;
        final CourseModel course = courses.get(position);
        if (convertView == null) {
            viewHolder = new ViewHolder();
            convertView = inflater.inflate(R.layout.category_course_item, null);
            viewHolder.courseBg = (ImageView) convertView.findViewById(R.id.iv_courseBg);
            viewHolder.courseName = (TextView) convertView.findViewById(R.id.tv_course_name);
            viewHolder.courseType = (ImageView) convertView.findViewById(R.id.img_course_type);
            viewHolder.learNum = (TextView) convertView.findViewById(R.id.tv_num_learn);
            viewHolder.willBegin = (RelativeLayout) convertView.findViewById(R.id.rl_will_begin);
            viewHolder.rating = (MyRatingBar) convertView.findViewById(R.id.rating);
            viewHolder.people_portrait = (ImageView) convertView.findViewById(R.id.people_portrait);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
//        bitmapUtils.display(viewHolder.courseBg, course.getCover_image());
        bitmapUtils.display(viewHolder.courseBg, course.getCover_image(),BitmapHelp.getBitMapConfig(context,R.drawable.find_courses_default));
        Log.i("CategoryCourseAdapter", course.getCover_image());
        viewHolder.courseName.setText(course.getName());
        Log.i("CategoryCourseAdapter", course.getName());
        if (course.getType().equals("OpenCourse")) {
            viewHolder.courseType.setImageResource(R.drawable.public_card);
            viewHolder.people_portrait.setImageResource(R.drawable.public_people_portrait);
            viewHolder.rating.setFullStar(context.getResources().getDrawable(R.drawable.full_star_blue));
            viewHolder.rating.setHalfStar(context.getResources().getDrawable(R.drawable.half_star_blue));
        } else {
            viewHolder.courseType.setImageResource(R.drawable.guide_card);
            viewHolder.people_portrait.setImageResource(R.drawable.guide_people_portrait);
            viewHolder.rating.setFullStar(context.getResources().getDrawable(R.drawable.full_star_yellow));
            viewHolder.rating.setHalfStar(context.getResources().getDrawable(R.drawable.half_star_yellow));
        }
        viewHolder.rating.setRating((course.getRating()) * 1.0f / 2);
        /*if("online".equals(course.getStatus())){
            viewHolder.willBegin.setVisibility(View.GONE);
<<<<<<< HEAD
        }
        String view_count = null;
        if(course.getView_count()>=10000){
            DecimalFormat digits=new DecimalFormat("0.0");
            view_count = digits.format(course.getView_count()/10000)+"万";
        }else {
            view_count = course.getView_count() +"";
        }
        viewHolder.learNum.setText(view_count);
=======
        }*/
        String view_count = null;
        if (course.getView_count() >= 10000) {
            DecimalFormat digits = new DecimalFormat("0.0");
            view_count = digits.format((double) course.getView_count() / 10000) + "万";
        } else {
            view_count = course.getView_count() + "";
        }
        viewHolder.learNum.setText(view_count);


        return convertView;
    }

    static class ViewHolder {
        ImageView courseBg;
        TextView courseName;
        ImageView courseType;
        TextView learNum;
        RelativeLayout willBegin;
        MyRatingBar rating;
        ImageView people_portrait;
    }
}
