package com.kaikeba.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.common.entity.Appraisement;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.widget.MyRatingBar;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.Date;
import java.util.List;

/**
 * Created by chris on 14-7-15.
 */
public class AppraiseListAdapter extends BaseAdapter {

    private List<Appraisement> appraisementList;

    private Context mContext;
    private LayoutInflater inflate;
    private BitmapUtils bitmapUtils;

    public AppraiseListAdapter(Context context, List<Appraisement> appraisementList) {
        this.mContext = context;
        this.appraisementList = appraisementList;
        inflate = LayoutInflater.from(mContext);
        bitmapUtils = BitmapHelp.getBitmapUtils(mContext);
    }

    @Override
    public int getCount() {
        return appraisementList == null ? 0 : appraisementList.size();

    }

    @Override
    public Object getItem(int position) {
        return appraisementList == null ? null : appraisementList.get(position);

    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        Appraisement item = appraisementList.get(position);
        if (convertView == null) {
            convertView = inflate.inflate(R.layout.appraise_list_item, null);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.rating_bar.setRating(item.getRating() * 1.0f / 2);
        holder.rating_level.setText("(" + item.getRating() + "分)");
        if (item.getUpdated_at() != null)
            holder.appraise_time.setText(DateUtils.getCourseStartTime(new Date(Long.parseLong(item.getUpdated_at()))));
        if (item.getUser_image_url() != null) {
//            bitmapUtils.display(holder.appraise_img, item.getUser_image_url());
            bitmapUtils.display(holder.appraise_img, item.getUser_image_url(),BitmapHelp.getBitMapConfig(mContext,R.drawable.assess_user));
        } else {
            holder.appraise_img.setImageResource(R.drawable.assess_user);
        }
        holder.user_nick.setText(item.getUser_name());
        holder.appraise_content.setText(item.getContent());
        holder.usefulTv.setText("有用(" + item.getUseful() + ")");
        holder.unusefulTv.setText("没用(" + item.getUseless() + ")");
        holder.useful.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        holder.unuseful.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        holder.feedBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        return convertView;
    }


    class ViewHolder {
        ImageView appraise_img;
        TextView user_nick;
        MyRatingBar rating_bar;
        TextView rating_level;
        TextView appraise_content;
        TextView appraise_time;
        ImageView useful;
        ImageView unuseful;
        TextView unusefulTv;
        TextView usefulTv;
        TextView feedBack;

        public ViewHolder(View v) {
            appraise_img = (ImageView) v.findViewById(R.id.appraise_icon);
            user_nick = (TextView) v.findViewById(R.id.user_name);
            rating_bar = (MyRatingBar) v.findViewById(R.id.appraise_rating);
            rating_level = (TextView) v.findViewById(R.id.rating_level);
            appraise_time = (TextView) v.findViewById(R.id.appraise_time);
            appraise_content = (TextView) v.findViewById(R.id.appraise_content);
            useful = (ImageView) v.findViewById(R.id.iv_discuss_useful);
            unuseful = (ImageView) v.findViewById(R.id.iv_discuss_unuseful);
            unusefulTv = (TextView) v.findViewById(R.id.tv_discuss_unuseful);
            usefulTv = (TextView) v.findViewById(R.id.tv_discuss_useful);
            feedBack = (TextView) v.findViewById(R.id.tv_feedback);
        }
    }
}
