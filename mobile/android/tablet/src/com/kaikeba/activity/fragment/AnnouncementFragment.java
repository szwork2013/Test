package com.kaikeba.activity.fragment;


import android.app.Fragment;
import android.app.FragmentTransaction;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.kaikeba.common.api.AnnouncementAPI;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import org.jsoup.Jsoup;

import java.util.ArrayList;


/**
 * 通告Fragment
 *
 * @author Super Man
 */
public class AnnouncementFragment extends Fragment {

    private ListView myCourseAnnceListView;
    private ArrayList<Announcement> annList;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    view_loading.setVisibility(View.GONE);
                    if (annList == null || annList.isEmpty()) {
                        Toast.makeText(getActivity(), "暂无通告", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    myCourseAnnceListView.setAdapter(new MyCourseAnnceAdapter(annList));
                    break;

                default:
                    break;
            }
        }

        ;
    };
    private String courseId;
    private OnItemClickListener listener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            Announcement ann = annList.get(position);
            AnnouncementDetailFragment courseAnnFragment = new AnnouncementDetailFragment();
            Bundle b = new Bundle();
            b.putSerializable(getResources().getString(R.string.announcement), ann);
            b.putSerializable(getResources().getString(R.string.announcements), annList);
            b.putString(getResources().getString(R.string.courseId), courseId);
            courseAnnFragment.setArguments(b);
            FragmentTransaction ft = getFragmentManager().beginTransaction();
            ft.replace(R.id.announcement_container, courseAnnFragment).addToBackStack("通告");
            ft.commit();
        }
    };
    private LinearLayout view_loading;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.my_course_announsement, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        myCourseAnnceListView = (ListView) v.findViewById(R.id.myCourseAnnceListView);
        myCourseAnnceListView.setOnItemClickListener(listener);
        return v;
    }

    @SuppressWarnings("unchecked")
    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
        annList = (ArrayList<Announcement>) getArguments().getSerializable(getResources().getString(R.string.announcement));
        if (annList == null) {
            ImgLoaderUtil.threadPool.submit(new Runnable() {

                @Override
                public void run() {
                    annList = AnnouncementAPI.getAllAnnouncement(courseId);
                    handler.sendEmptyMessage(0);
                }
            });
        }
    }

    class MyCourseAnnceAdapter extends BaseAdapter {

        private ArrayList<Announcement> annList;
        private LayoutInflater inflater;

        public MyCourseAnnceAdapter(ArrayList<Announcement> annList) {
            this.annList = annList;
            if (getActivity() == null) {
                return;
            }
            inflater = LayoutInflater.from(getActivity());
        }

        @Override
        public int getCount() {
            return annList.size();
        }

        @Override
        public Object getItem(int position) {
            return annList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            final Announcement ann = annList.get(position);
            final ViewHolder holder;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.my_course_anncement_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.title.setText(ann.getTitle());
            holder.post_at.setText(DateUtils.getCourseStartTime(ann.getPosted_at()));
            if ("0".equals(ann.getDiscussion_subentry_count())) {
                holder.discussion_subentry_count.setVisibility(View.GONE);
            } else {
                holder.discussion_subentry_count.setVisibility(View.VISIBLE);
                holder.discussion_subentry_count.setText(ann.getDiscussion_subentry_count());
            }
            holder.avatar_image_url.setImageBitmap(ImgLoaderUtil.getLoader()
                    .loadImg(ann.getAuthor().getAvatar_image_url(),
                            new ImgLoaderUtil.ImgCallback() {

                                @Override
                                public void refresh(Bitmap bitmap) {
                                    holder.avatar_image_url
                                            .setImageBitmap(bitmap);
                                }
                            }, handler));
            holder.message.setText(Jsoup.parse(ann.getMessage()).text());
            holder.display_name.setText(ann.getAuthor().getDisplay_name());
            if (ann.getAttachments() != null && !ann.getAttachments().isEmpty()) {
                holder.iv_load.setVisibility(View.VISIBLE);
            } else {
                holder.iv_load.setVisibility(View.GONE);
            }
            return convertView;
        }

        class ViewHolder {
            TextView title;
            TextView post_at;
            TextView discussion_subentry_count;
            TextView display_name;
            TextView message;
            ImageView avatar_image_url;
            ImageView iv_load;

            ViewHolder(View v) {
                title = (TextView) v.findViewById(R.id.title);
                post_at = (TextView) v.findViewById(R.id.posted_at);
                discussion_subentry_count = (TextView) v.findViewById(R.id.discussion_subentry_count);
                display_name = (TextView) v.findViewById(R.id.user_name);
                message = (TextView) v.findViewById(R.id.message);
                avatar_image_url = (ImageView) v.findViewById(R.id.iv_avatar);
                iv_load = (ImageView) v.findViewById(R.id.iv_load);
            }
        }
    }
}
