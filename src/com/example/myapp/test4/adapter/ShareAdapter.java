package com.example.myapp.test4.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.example.myapp.R;
import com.example.myapp.test4.entity.ShareModel;

import java.util.List;

/**
 * Created by sjyin on 14-9-26.
 */
public class ShareAdapter extends BaseAdapter {
    private List<ShareModel> res;
    private Context context;

    public ShareAdapter(Context context, List<ShareModel> res) {
        this.context = context;
        this.res = res;
    }

    @Override
    public int getCount() {
        return res != null ? res.size():0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = View.inflate(context, R.layout.activity_share_item, null);
        ImageView iv_share = (ImageView) view.findViewById(R.id.iv_share);
        TextView tv_share = (TextView) view.findViewById(R.id.tv_share);
        iv_share.setImageResource(res.get(position).getRes());
        tv_share.setText(res.get(position).getName());
        return view;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public Object getItem(int position) {
        return res != null ? res.get(position):null;
    }

}
