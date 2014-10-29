package com.kaikeba.mitv.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.TvHistoryInfo;
import com.kaikeba.common.util.DataSource;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.ViewCourseActivity;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.lidroid.xutils.exception.DbException;

import java.util.List;

/**
 * Created by kkb on 8/7/14.
 */
public class VideoListAdapter extends BaseAdapter {

    List<CourseModel.Items> _videoListData;
    private Context _context;
    private CourseCardItem _courseCardItem;

    public VideoListAdapter(ViewCourseActivity context, CourseCardItem courseCardItem, List<CourseModel.Items> _videoListData) {
        this._videoListData = _videoListData;
        this._context = context;
        _courseCardItem = courseCardItem;
    }

    public static String formatLongToTimeStr(int l) {
        int hour = 0;
        int minute = 0;
        int second = 0;

        second = l / 1000;

        if (second >= 60) {
            minute = second / 60;
            second = second % 60;
        }
        if (minute >= 60) {
            hour = minute / 60;
            minute = minute % 60;
        }
        return (getTwoLength(hour) + ":" + getTwoLength(minute) + ":" + getTwoLength(second));
    }

    //TODO
    private static String getTwoLength(final int data) {
        if (data < 10) {
            return "0" + data;
        } else {
            return "" + data;
        }
    }

    @Override
    public int getCount() {
        return _videoListData == null ? 0 : _videoListData.size();
    }

    @Override
    public Object getItem(int position) {
        return _videoListData == null ? null : _videoListData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        final CourseModel.Items listItem = (CourseModel.Items) getItem(position);

        if (convertView == null) {
            LayoutInflater inflater = (LayoutInflater) this._context
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.exp_list_item, null);
        }

        /****************/
        TextView courseNameTextView = (TextView) convertView.findViewById(R.id.courseNameTextView);
        TextView watchProgressTextView = (TextView) convertView.findViewById(R.id.watchProgressTextView);
        TextView courseDurationTextView = (TextView) convertView.findViewById(R.id.courseDurationTextView);

        convertView.setBackgroundResource(R.drawable.course_list_item_selector);

        courseNameTextView.setText(listItem.getTitle());
        if (getLastTime(listItem, position) != -1) {
            String time = formatLongToTimeStr(getLastTime(listItem, position));
            watchProgressTextView.setText("上次观看到：" + time);
            watchProgressTextView.setVisibility(View.VISIBLE);


            courseNameTextView.setShadowLayer(5.0f, 1f, 1f, _context.getResources().getColor(R.color.item_shadow_color));
            watchProgressTextView.setShadowLayer(5.0f, 1f, 1f, _context.getResources().getColor(R.color.item_shadow_color));

        } else {
            watchProgressTextView.setVisibility(View.GONE);
            courseNameTextView.setShadowLayer(0f, 0f, 0f, _context.getResources().getColor(R.color.item_shadow_color));
            watchProgressTextView.setShadowLayer(0f, 0f, 0f, _context.getResources().getColor(R.color.item_shadow_color));
        }

//        courseDurationTextView.setText(listItem.get);

        return convertView;
    }

    private int getLastTime(CourseModel.Items listItem, int pos) {
        try {
            List<TvHistoryInfo> tvHistoryInfos = DataSource.getDataSourse().findAllTvHistory();
            if (tvHistoryInfos != null) {
                for (TvHistoryInfo info : tvHistoryInfos) {
                    if (info.getCourseId() == _courseCardItem.getId() && listItem.getId() == info.getVideoId()) {
                        info.setIndex(pos + 1);
                        DataSource.getDataSourse().updateTvHistory(info);
                        return info.getLastTime();
                    }
                }
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<CourseModel.Items> getAllItemData() {
        return _videoListData;
    }
}
