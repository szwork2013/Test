package com.kaikeba.adapter;

import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import com.kaikeba.activity.CourseSquareActivity;
import com.kaikeba.activity.CourseSquareActivity.PagerListener;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.BitmapManager;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 填充ViewPager页面的适配器
 *
 * @author Administrator
 */
public class PageAdapter extends PagerAdapter {

    //	ViewPager viewPager;
    public BitmapUtils bitmapUtils;
    CourseSquareActivity a;
    private List<ImageView> imageViews; // 滑动的图片集合
    private List<String> urls;
    private PagerListener listener;

    public PageAdapter(List<String> urls, CourseSquareActivity a, BitmapManager bmpManager, PagerListener listener) {
        this.urls = urls;
//		this.viewPager = viewPager;
        this.a = a;
        this.listener = listener;
        imageViews = new ArrayList<ImageView>();
        bitmapUtils = BitmapHelp.getBitmapUtils(a.getApplicationContext());
        // 初始化图片资源
        for (int i = 0; i < urls.size(); i++) {
            final ImageView view = new ImageView(a);
            view.setScaleType(ScaleType.CENTER_CROP);
//			BitmapDrawable bd = (BitmapDrawable) a.getResources().getDrawable(R.drawable.allcourse_cover_default);
//			Bitmap bm = bd.getBitmap();
//			bmpManager.loadBitmap(urls.get(i), view, bm);

            bitmapUtils.display(view, urls.get(i));
//			view.setOnClickListener(listener);
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
//		view.setOnTouchListener(new OnTouchListener() {
//			
//			@Override
//			public boolean onTouch(View v, MotionEvent event) {
//				// TODO Auto-generated method stub
//				arg0.requestDisallowInterceptTouchEvent(true);
//				return true;
//			}
//		});
//		view.setFocusableInTouchMode(false);
//		arg0.setFocusableInTouchMode(true);
//		arg0.requestFocus(ViewGroup.FOCUS_RIGHT);
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
