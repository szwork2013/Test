package com.kaikeba.mitv.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.entity.TvViewPagerInfo;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.widget.NetImageView;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.fragment.FragmentHelper;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.lidroid.xutils.BitmapUtils;

import java.util.List;

public class MainGalleryAdapter extends BaseAdapter {
    public static BitmapUtils bitmapUtils;
    NetImageView[] imageViews;
    List<CourseCardItem> courses;
    List<TvViewPagerInfo> viewPageinfos;
    private Context mContext;

    public MainGalleryAdapter(Context context, List<CourseCardItem> courseList, List<TvViewPagerInfo> viewPageinfos) {
        bitmapUtils = BitmapHelp.getBitmapUtils(context.getApplicationContext());
        this.mContext = context;
        imageViews = new NetImageView[courseList.size()];
        courses = courseList;
        this.viewPageinfos = viewPageinfos;
    }

    public List<CourseCardItem> getCourse() {
        return courses;
    }

    @Override
    public int getCount() {
        return courses.size();
    }

    @Override
    public Object getItem(int position) {
        return position;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        NetImageView imageView = imageViews[position];
        if (convertView != null) {
            imageView = (NetImageView) convertView;
        } else {
            imageView = new NetImageView(parent.getContext());
        }

        imageView.setScaleType(ImageView.ScaleType.FIT_XY);
        if (courses.get(position % courses.size()).getCover_image() != null) {
            ContextUtil.imageLoader.displayImage(viewPageinfos.get(position % courses.size()).getViwepager_img(), imageView, ContextUtil.options);
        } else {
            imageView.setImageResource(R.drawable.def_512x288);
        }

        imageView.setPadding(FragmentHelper.getGalleryImagePadding(MainActivity.getMainActivity()),
                FragmentHelper.getGalleryImagePadding(MainActivity.getMainActivity()),
                FragmentHelper.getGalleryImagePadding(MainActivity.getMainActivity()),
                FragmentHelper.getGalleryImagePadding(MainActivity.getMainActivity()));

        return imageView;
    }
}
