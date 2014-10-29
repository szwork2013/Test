package com.kaikeba.adapter;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.RelativeLayout;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.fragment.AllCoursesFragment.PagerListener;
import com.kaikeba.common.util.BitmapHelp;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

public class PageAdapter extends PagerAdapter {

    public BitmapUtils bitmapUtils;
    private List<ImageView> imageViews; // 滑动的图片集合
    private List<String> urls;
    private PagerListener listener;

    public PageAdapter(RelativeLayout rl_layout, View v, List<String> urls, Context c, PagerListener listener) {
        this.listener = listener;
        this.urls = urls;
//		LayoutParams params = rl_layout.getLayoutParams();
//		params.height = (int) (v.getWidth()/3);
//		rl_layout.setLayoutParams(params);
        imageViews = new ArrayList<ImageView>();
        bitmapUtils = BitmapHelp.getBitmapUtils(c.getApplicationContext());
//        bitmapUtils.configDefaultLoadingImage(R.drawable.scollerimg_default2);
//        bitmapUtils.configDefaultBitmapConfig(Bitmap.Config.RGB_565);
        // 初始化图片资源
        for (int i = 0; i < urls.size(); i++) {
            final ImageView view = new ImageView(MainActivity.getMainActivity());
            view.setScaleType(ScaleType.CENTER_CROP);
            bitmapUtils.display(view, urls.get(i));
            System.out.println(urls.get(i));
            imageViews.add(view);
        }
    }

    @Override
    public int getCount() {
        return urls.size();
    }

    @Override
    public Object instantiateItem(final ViewGroup arg0, int arg1) {
        View view = imageViews.get(arg1);
        view.setOnClickListener(listener);
        arg0.addView(view);
        return view;
    }

    @Override
    public void destroyItem(View arg0, int arg1, Object arg2) {
        ((ViewPager) arg0).removeView((View) arg2);
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0 == arg1;
    }
}
