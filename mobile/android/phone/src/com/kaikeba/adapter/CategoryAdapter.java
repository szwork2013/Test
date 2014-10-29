package com.kaikeba.adapter;

import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.kaikeba.activity.TabCourseActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.Category;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.CommonUtils;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

/**
 * Created by user on 14-7-21.
 */
public class CategoryAdapter extends BaseAdapter {


    public BitmapUtils bitmapUtils;
    Context context;
    int height;
    private LayoutInflater inflater;
    private List<Category> categoryList;
    private Handler handler;

    public CategoryAdapter(Context context, List<Category> categoryCourses, Handler handler, int height) {

        super();
        this.context = context;
        this.categoryList = categoryCourses;
        this.handler = handler;
        this.height = height;
        if (context == null) {
            return;
        }
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
//        bitmapUtils.configDefaultLoadingImage(R.drawable.find_courses_default);
//        bitmapUtils.configDefaultLoadFailedImage(R.drawable.find_courses_default);
        inflater = LayoutInflater.from(context);
    }

    public void addCategory(List<Category> courses) {
        this.categoryList.addAll(courses);
        handler.sendEmptyMessage(1);
    }

    @Override
    public int getCount() {
        if (categoryList != null) {
            return categoryList.size();
        }
        return 0;
    }

    @Override
    public Object getItem(int position) {
        if (categoryList != null) {
            return categoryList.get(position);
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
        int item_height = 0;
        if (API.getAPI().alreadySignin()) {
            item_height = getGridHeight() / 3 - 3 * CommonUtils.getScreenHeight(context) / 1920;
        } else {
            item_height = -1;
        }
        AbsListView.LayoutParams params = new AbsListView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, item_height);
        Category category = categoryList.get(position);
        if (convertView == null) {
            viewHolder = new ViewHolder();
            convertView = inflater.inflate(R.layout.category_item, parent, false);
            viewHolder.categoryImg = (ImageView) convertView.findViewById(R.id.iv_category_img);
            viewHolder.categoryName = (TextView) convertView.findViewById(R.id.tv_category_name);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
        if (!TextUtils.isEmpty(category.getImageUrl())) {
            bitmapUtils.display(viewHolder.categoryImg, category.getImageUrl(),BitmapHelp.getBitMapConfig(context,R.drawable.find_courses_default));
        }
        viewHolder.categoryName.setText(category.getName());
        convertView.setLayoutParams(params);
        int padding_top_height = 72 * CommonUtils.getScreenHeight(context) / 1920;
        int padding_bottom_height = 48* CommonUtils.getScreenHeight(context) / 1920;
        if(!API.getAPI().alreadySignin()){
            convertView.setPadding(0,padding_top_height,0,padding_bottom_height    );
        }
        return convertView;
    }

    public int getGridHeight() {
        return CommonUtils.getScreenHeight(context) - CommonUtils.getStatusBarHeight(context) - TabCourseActivity.getTabHeight4Find() - height;
    }

    public int getNimingHeight() {
        return CommonUtils.getScreenHeight(context) - CommonUtils.getStatusBarHeight(context) - height;
    }

    static class ViewHolder {
        ImageView categoryImg;
        TextView categoryName;
    }
}
