package com.kaikeba.common.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.ExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnGroupClickListener;

public class XDListView extends ExpandableListView implements OnScrollListener, OnGroupClickListener {
    private static final String TAG = "XDListView";
    private static final int MAX_ALPHA = 255;
    private XDHeaderAdapter mAdapter;
    private View mHeaderView;
    private boolean mHeaderViewVisible;
    private int mHeaderViewWidth;
    private int mHeaderViewHeight;
    private float mDownX;
    private float mDownY;
    private int mOldState = -1;
    public static final int GROUP_EXPAND_STATUS = 1;
    public static final int GROUP_COLLAPSE_STATUS = 0;

    public XDListView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        registerListener();
    }

    public XDListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        registerListener();
    }

    public XDListView(Context context) {
        super(context);
        registerListener();
    }

    public void setHeaderView(View view) {
        mHeaderView = view;
        LayoutParams lp = new LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        view.setLayoutParams(lp);

        if (mHeaderView != null) {
            setFadingEdgeLength(0);
        }

        requestLayout();
    }

    private void registerListener() {
        setOnScrollListener(this);
        setOnGroupClickListener(this);
    }

    private void headerViewClick() {
        long packedPosition = getExpandableListPosition(this.getFirstVisiblePosition());

        int groupPosition = ExpandableListView.getPackedPositionGroup(packedPosition);

        if (mAdapter.getGroupClickStatus(groupPosition) == GROUP_COLLAPSE_STATUS) {
            this.expandGroup(groupPosition);
            mAdapter.setGroupClickStatus(groupPosition, GROUP_EXPAND_STATUS);
        } else {
            this.collapseGroup(groupPosition);
            mAdapter.setGroupClickStatus(groupPosition, GROUP_COLLAPSE_STATUS);
        }

        this.setSelectedGroup(groupPosition);
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (mHeaderViewVisible) {
            switch (ev.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    mDownX = ev.getX();
                    mDownY = ev.getY();
                    if (mDownX <= mHeaderViewWidth && mDownY <= mHeaderViewHeight) {
                        return true;
                    }
                    break;
                case MotionEvent.ACTION_UP:
                    float x = ev.getX();
                    float y = ev.getY();
                    float offsetX = Math.abs(x - mDownX);
                    float offsetY = Math.abs(y - mDownY);
                    if (x <= mHeaderViewWidth && y <= mHeaderViewHeight
                            && offsetX <= mHeaderViewWidth && offsetY <= mHeaderViewHeight) {
                        if (mHeaderView != null) {
                            headerViewClick();
                        }

                        return true;
                    }
                    break;
                default:
                    break;
            }
        }

        return super.onTouchEvent(ev);

    }

    @Override
    public void setAdapter(ExpandableListAdapter adapter) {
        super.setAdapter(adapter);
        mAdapter = (XDHeaderAdapter) adapter;
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        Log.i(TAG, "group was clicked and mAdapter.getGroupClickStatus(groupPosition) = " + mAdapter.getGroupClickStatus(groupPosition));
        if (mAdapter.getGroupClickStatus(groupPosition) == GROUP_EXPAND_STATUS) {
            mAdapter.setGroupClickStatus(groupPosition, GROUP_COLLAPSE_STATUS);
            parent.collapseGroup(groupPosition);
//			parent.setSelectedGroup(groupPosition);

        } else if (mAdapter.getGroupClickStatus(groupPosition) == GROUP_COLLAPSE_STATUS) {
            mAdapter.setGroupClickStatus(groupPosition, GROUP_EXPAND_STATUS);
            collapseAllGroup();
            parent.expandGroup(groupPosition);
        }

        return true;

    }

    private void collapseAllGroup() {
        int groupCount = getCount();
        for (int i = 0; i < groupCount; i++) {
            if (isGroupExpanded(i)) {
                collapseGroup(i);
            }
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (mHeaderView != null) {
            measureChild(mHeaderView, widthMeasureSpec, heightMeasureSpec);
            mHeaderViewWidth = mHeaderView.getMeasuredWidth();
            mHeaderViewHeight = mHeaderView.getMeasuredHeight();
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        final long flatPostion = getExpandableListPosition(getFirstVisiblePosition());
        final int groupPos = ExpandableListView.getPackedPositionGroup(flatPostion);
        final int childPos = ExpandableListView.getPackedPositionChild(flatPostion);
        int state = mAdapter.getXDHeaderState(groupPos, childPos);
        if (mHeaderView != null && mAdapter != null && state != mOldState) {
            mOldState = state;
            mHeaderView.layout(0, 0, mHeaderViewWidth, mHeaderViewHeight);
        }

        configureHeaderView(groupPos, childPos);
    }

    public void configureHeaderView(int groupPosition, int childPosition) {
        if (mHeaderView == null || mAdapter == null
                || ((ExpandableListAdapter) mAdapter).getGroupCount() == 0) {
            return;
        }

        int state = mAdapter.getXDHeaderState(groupPosition, childPosition);

        switch (state) {
            case XDHeaderAdapter.PINNED_HEADER_GONE: {
                mHeaderViewVisible = false;
                break;
            }

            case XDHeaderAdapter.PINNED_HEADER_VISIBLE: {
                mAdapter.configureXDHeader(mHeaderView, groupPosition, childPosition, MAX_ALPHA);

                if (mHeaderView.getTop() != 0) {
                    mHeaderView.layout(0, 0, mHeaderViewWidth, mHeaderViewHeight);
                }

                mHeaderViewVisible = true;

                break;
            }

            case XDHeaderAdapter.PINNED_HEADER_PUSHED_UP: {
                View firstView = getChildAt(0);
                int bottom = 0;
                if (firstView != null) {
                    bottom = firstView.getBottom();
                }


                // intitemHeight = firstView.getHeight();
                int headerHeight = mHeaderView.getHeight();

                int y;

                int alpha;

                if (bottom < headerHeight && headerHeight != 0) {
                    y = (bottom - headerHeight);
                    alpha = MAX_ALPHA * (headerHeight + y) / headerHeight;
                } else {
                    y = 0;
                    alpha = MAX_ALPHA;
                }

                mAdapter.configureXDHeader(mHeaderView, groupPosition, childPosition, alpha);

                if (mHeaderView.getTop() != y) {
                    mHeaderView.layout(0, y, mHeaderViewWidth, mHeaderViewHeight + y);
                }

                mHeaderViewVisible = true;
                break;
            }
        }
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        if (mHeaderViewVisible) {
            drawChild(canvas, mHeaderView, getDrawingTime());
        }
    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
        final long flatPos = getExpandableListPosition(firstVisibleItem);
        int groupPosition = ExpandableListView.getPackedPositionGroup(flatPos);
        int childPosition = ExpandableListView.getPackedPositionChild(flatPos);

        configureHeaderView(groupPosition, childPosition);
    }

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {
    }

    public interface XDHeaderAdapter {
        public static final int PINNED_HEADER_GONE = 0;
        public static final int PINNED_HEADER_VISIBLE = 1;
        public static final int PINNED_HEADER_PUSHED_UP = 2;

        int getXDHeaderState(int groupPosition, int childPosition);

        void configureXDHeader(View header, int groupPosition, int childPosition, int alpha);

        void setGroupClickStatus(int groupPosition, int status);

        int getGroupClickStatus(int groupPosition);

    }
}
