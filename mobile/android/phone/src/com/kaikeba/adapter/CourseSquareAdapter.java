package com.kaikeba.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.BitmapManager;
import com.kaikeba.common.util.CommonUtils;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

public class CourseSquareAdapter extends BaseAdapter {

    public BitmapUtils bitmapUtils;
    Context context;
    private LayoutInflater inflater;
    private List<CourseModel> courses;
    private BitmapManager bmpManager;
    private Handler handler;
    private List<Badge> badges;
    private ListView lv;

    public CourseSquareAdapter(List<CourseModel> allCourses, Context context, Handler handler, BitmapManager bmpManager, List<Badge> badges, ListView lv) {
        super();
        this.lv = lv;
        this.context = context;
        this.courses = allCourses;
        this.badges = badges;
        this.handler = handler;
        this.bmpManager = bmpManager;
        if (context == null) {
            return;
        }
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
        inflater = LayoutInflater.from(context);
    }

    public void addCourseDate(List<CourseModel> courses) {
        this.courses.addAll(courses);
        handler.sendEmptyMessage(1);
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

    @SuppressLint("NewApi")
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder viewHolder;
        final CourseModel course = courses.get(position);
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.all_course_item, null);
            int height = (int) (Constants.COVER_HEIGHT * (CommonUtils.getScreenWidth(context) - 10 * Constants.SCREEN_DENSITY) / Constants.COVER_WIDTH + 0.5);
            convertView.findViewById(R.id.relativeLayout1).setLayoutParams(new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height));
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
//		if (null != course.getStartDate()) {
//			if (DateUtils.getDateprice(DateUtils.StringToDate(course
//					.getStartDate()))) {
//				viewHolder.applyTime.setText("报名结束");
//				viewHolder.leanImgView
//						.setBackgroundResource(R.drawable.ribbon_gray);
//			} else {
//				viewHolder.applyTime.setText(course.getStartDate());
//				viewHolder.leanImgView
//						.setBackgroundResource(R.drawable.ribbon_red);
//			}
//		} else {
//			viewHolder.applyTime.setText("待定");
//			viewHolder.leanImgView
//					.setBackgroundResource(R.drawable.ribbon_yellow);
//		}
//		viewHolder.instuctorTitle.setText(course.getInstructorTitle());
//		viewHolder.instructorName.setText(course.getInstructorName());
        viewHolder.courseName.setText(course.getName());
//		if (("　" + course.getSchoolName()).length() == 13) {
//			viewHolder.colledgeName.setText("　" + course.getSchoolName());
//		} else {
//			viewHolder.colledgeName.setText("　" + course.getSchoolName()
//					+ "　");
//		}
        bitmapUtils.display(viewHolder.iv_courseBg, course.getCover_image());
//		
//		bitmapUtils.display(viewHolder.instructorImg, course.getInstructorAvatar());

        viewHolder.course_intro.setText(course.getIntro());
        viewHolder.instructor_declarer.setText(course.getSlogan());
        if (course.getType().equals("InstructiveCourse")) {
            viewHolder.courseType.setText("[导学课] ");
        } else {
            viewHolder.courseType.setText("[公开课] ");
        }
//		int count = 0;
//		int size = course.getCourseBadges().size();
//		for (int i = 0; i < size; i++) {
//			for (Badge badge : badges) {
//				if (course.getCourseBadges().get(i) == badge.getId()) {
//					if (count > 3) {
//						return convertView;
//					}
//
//					bitmapUtils.display(viewHolder.ivs[i], badge.getImage4small());
//					count++;
//				}
//			}
//		}
        return convertView;
    }

    /**
     * 缓存View
     *
     * @author Allen
     */
    class ViewHolder {
        //		public TextView instuctorTitle;
//		public TextView instructorName;
//		public ImageView instructorImg;
//		public TextView applyTime;
        public TextView courseName;
        public TextView colledgeName;
        public ImageView iv_courseBg;
        //		public ImageView leanImgView;
        public TextView course_intro;
        public TextView instructor_declarer;
        public TextView courseType;
//		public ImageView iv_1;
//		public ImageView iv_2;
//		public ImageView iv_3;
//		public ImageView iv_4;
//		public ImageView[] ivs;

        public ViewHolder(View convertView) {
            courseType = (TextView) convertView
                    .findViewById(R.id.courseType);
//			instuctorTitle = (TextView) convertView
//					.findViewById(R.id.instuctorTitle);
//			instructorName = (TextView) convertView
//					.findViewById(R.id.instructorName);
//			instructorImg = (ImageView) convertView
//					.findViewById(R.id.instructorImg);
//			applyTime = (TextView) convertView.findViewById(R.id.applyTime);
            courseName = (TextView) convertView
                    .findViewById(R.id.courseName);
            colledgeName = (TextView) convertView
                    .findViewById(R.id.colledgeName);
            iv_courseBg = (ImageView) convertView
                    .findViewById(R.id.iv_courseBg);
//			leanImgView = (ImageView) convertView
//					.findViewById(R.id.leanImgView);
            course_intro = (TextView) convertView
                    .findViewById(R.id.course_intro);
            instructor_declarer = (TextView) convertView
                    .findViewById(R.id.instructor_declarer);
//			iv_1 = (ImageView) convertView.findViewById(R.id.iv_1);
//			iv_2 = (ImageView) convertView.findViewById(R.id.iv_2);
//			iv_3 = (ImageView) convertView.findViewById(R.id.iv_3);
//			iv_4 = (ImageView) convertView.findViewById(R.id.iv_4);
//			ivs = new ImageView[4];
//			ivs[0] = iv_1;
//			ivs[1] = iv_2;
//			ivs[2] = iv_3;
//			ivs[3] = iv_4;
        }
    }
}
