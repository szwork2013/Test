package com.kaikeba.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by sjyin on 14-8-13.
 */
public class UserCenterAdapter extends BaseAdapter {

    private Context mContext;
    private List<Map<String, Object>> list;

    public UserCenterAdapter(Context context) {
        this.mContext = context;

        list = new ArrayList<Map<String, Object>>();

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("tv", "我的微专业");
        map.put("iv", R.drawable.icon_micro);
        list.add(map);

        map = new HashMap<String, Object>();
        map.put("tv", "我的公开课");
        map.put("iv", R.drawable.icon_open);
        list.add(map);

        map = new HashMap<String, Object>();
        map.put("tv", "我的导学课");
        map.put("iv", R.drawable.icon_instructor);
        list.add(map);

        map = new HashMap<String, Object>();
        map.put("tv", "收藏的课程");
        map.put("iv", R.drawable.icon_collection);
        list.add(map);
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder viewHolder;
        if (convertView == null) {
            convertView = View.inflate(mContext, R.layout.user_center_item, null);
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
        viewHolder.mImg.setImageResource((Integer) list.get(position).get("iv"));
        viewHolder.mTxt.setText((String) list.get(position).get("tv"));
        if (position == list.size() - 1) {
            viewHolder.divider.setVisibility(View.GONE);
        }
        if (position == 0) {
            viewHolder.divider.setVisibility(View.VISIBLE);
        }

        return convertView;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
    }

    class ViewHolder {

        private ImageView mImg;
        private TextView mTxt;
        private LinearLayout divider;

        public ViewHolder(View v) {
            mImg = (ImageView) v.findViewById(R.id.iv_user_right);
            mTxt = (TextView) v.findViewById(R.id.tv_user_right);
            divider = (LinearLayout) v.findViewById(R.id.divider);
        }
    }
}

