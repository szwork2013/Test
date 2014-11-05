package com.imooc.pull_refresh_listview.widget;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AnimationUtils;
import android.widget.AbsListView;
import android.widget.ListView;
import com.example.myapp.R;

/**
 * Created by sjyin on 14-11-4.
 */
public class RefreshListView extends ListView implements AbsListView.OnScrollListener {

    private View footer;
    private String tag = "sjyin";

    public RefreshListView(Context context) {
        super(context);
        init();
    }

    public RefreshListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public RefreshListView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        footer = LayoutInflater.from(getContext()).inflate(R.layout.layout_footer, null);
        addFooterView(footer);
        setOnScrollListener(this);
    }

    private int lastVisibleItem;
    private int mTotalItemCount;

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {
        Log.i(tag,"scroll state :" + scrollState);
        if( lastVisibleItem == mTotalItemCount && scrollState == OnScrollListener.SCROLL_STATE_IDLE){
            Log.i(tag,"hide loading ");
            ObjectAnimator animator = ObjectAnimator.ofFloat(this,"y", TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,70,getResources().getDisplayMetrics()));
            animator.setDuration(3000).start();
        }
    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
        Log.i(tag,"firstVisibleItem : " +firstVisibleItem +" visibleItemCount: " + visibleItemCount
        +"totalItemCount : " + totalItemCount);

        lastVisibleItem = firstVisibleItem + visibleItemCount;
        mTotalItemCount = totalItemCount;
        Log.i(tag,"lastVisibleItem:" + lastVisibleItem + " total item count :" + totalItemCount);
    }
}
