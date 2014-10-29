package com.kaikeba.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 自定义适配器适配课程信息
 *
 * @author Allen
 */
public class AllCourseGridAdapter extends BaseAdapter {

    public static BitmapUtils bitmapUtils;
    private LayoutInflater inflater;
    private List<Course> courses = new ArrayList<Course>();

    public AllCourseGridAdapter(List<Course> allCourses, Context context) {
        super();
        this.courses = allCourses;
        if (context == null) {
            return;
        }
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
//        bitmapUtils.configDefaultLoadingImage(R.drawable.scollerimg_default2);
//        bitmapUtils.configDefaultBitmapConfig(Bitmap.Config.RGB_565);
        inflater = LayoutInflater.from(context);
    }

    public void setDate(List<Course> allCourses) {
        courses.clear();
        courses.addAll(allCourses);
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

    @SuppressLint("NewApi")
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Log.d("AllCourseGridAdapter", "----------------" + position);
        final ViewHolder viewHolder;
        final Course course = courses.get(position);
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.gridchild, null);
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
        viewHolder.applyTime.setText(DateUtils.getDate(course.getCourseType(), course.getEstimate(), course.getStartDate()));
        viewHolder.courseName.setText(course.getCourseName());
        viewHolder.colledgeName.setText(course.getSchoolName());
        viewHolder.courseInfo.setText(course.getCourseIntro());
        bitmapUtils.display(viewHolder.gridCourseBg, course.getCoverImage());
//		viewHolder.gridCourseBg.setImageBitmap(ImgLoaderUtil.getLoader()
//				.loadImg(course.getCoverImage(),
//						new ImgCallback() {
//
//							@Override
//							public void refresh(Bitmap bitmap) {
//								// TODO Auto-generated method stub
//								viewHolder.gridCourseBg
//										.setImageBitmap(bitmap);
//							}
//						}, handler));
        return convertView;
    }

    /**
     * 缓存View
     *
     * @author Allen
     */
    class ViewHolder {
        public TextView applyTime;
        public TextView courseName;
        public TextView colledgeName;
        public ImageView gridCourseBg;
        public TextView courseInfo;

        public ViewHolder(View v) {
            applyTime = (TextView) v.findViewById(R.id.applyTime);
            courseName = (TextView) v.findViewById(R.id.courseName);
            colledgeName = (TextView) v.findViewById(R.id.colledgeName);
            gridCourseBg = (ImageView) v.findViewById(R.id.gridCourseBg);
            courseInfo = (TextView) v.findViewById(R.id.courseBreaf);
        }
    }
}
