package com.kaikeba.activity.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.common.api.CourseUsersAPI;
import com.kaikeba.common.entity.CoursesUser;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;


/**
 * 人员Fragment
 *
 * @author Super Man
 */
public class ModuleUsersFragment extends Fragment {

    private GridView gridview_structor;
    private GridView gridview_student;
    private ScrollView scroll_view;
    private LinearLayout view_loading;
    private Handler handler = new Handler();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.my_course_users, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        gridview_structor = (GridView) v.findViewById(R.id.gridview_structor);
        gridview_student = (GridView) v.findViewById(R.id.gridview_student);
        scroll_view = (ScrollView) v.findViewById(R.id.scroll_view);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        final String courseId = getArguments().getString(getResources().getString(R.string.courseId));

        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub

                final ArrayList<CoursesUser> corUsers = new ArrayList<CoursesUser>();
                ArrayList<CoursesUser> structors = CourseUsersAPI.getCourseStructors(courseId);
                ArrayList<CoursesUser> ta = CourseUsersAPI.getCourseTa(courseId);
                final ArrayList<CoursesUser> students = CourseUsersAPI.getCourseStudents(courseId);
                corUsers.addAll(structors);
                corUsers.addAll(ta);
                handler.post(new Runnable() {

                    public void run() {
                        view_loading.setVisibility(View.GONE);
                        gridview_structor.setAdapter(new UsersAdapter(corUsers));
                        gridview_student.setAdapter(new UsersAdapter(students));
                        scroll_view.scrollTo(0, 0);
                    }
                });

            }
        });
    }

    class UsersAdapter extends BaseAdapter {

        public BitmapUtils bitmapUtils;
        private ArrayList<CoursesUser> corUsers;
        private LayoutInflater inflater;

        public UsersAdapter(ArrayList<CoursesUser> corUsers) {
            this.corUsers = corUsers;
            inflater = LayoutInflater.from(MainActivity.getMainActivity().getApplicationContext());
            bitmapUtils = BitmapHelp.getBitmapUtils(ContextUtil.getContext().getApplicationContext());
        }

        @Override
        public int getCount() {
            // TODO Auto-generated method stub
            return corUsers.size();
        }

        @Override
        public Object getItem(int position) {
            return corUsers.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // TODO Auto-generated method stub
            CoursesUser user = corUsers.get(position);
            final ViewHolder holder;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.my_course_users_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.tv_userName.setText(user.getName());
            holder.tv_shortName.setText(user.getShort_name());
            holder.tv_email.setText(user.getEmail());
            bitmapUtils.display(holder.iv_avatar, user.getAvatar_url());
            return convertView;
        }

        class ViewHolder {
            TextView tv_userName;
            TextView tv_shortName;
            TextView tv_email;
            ImageView iv_avatar;

            ViewHolder(View v) {
                tv_userName = (TextView) v.findViewById(R.id.tv_userName);
                tv_shortName = (TextView) v.findViewById(R.id.tv_shortName);
                tv_email = (TextView) v.findViewById(R.id.tv_email);
                iv_avatar = (ImageView) v.findViewById(R.id.iv_avatar);
            }
        }
    }
}

