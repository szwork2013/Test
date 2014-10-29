package com.kaikeba.common.listeners;

/**
 * Created by mjliu on 14-9-23.
 */

/**
 *
 * 滚动的回调接口
 *
 * @author xiaanming
 *
 */
public interface OnScrollListener{
    /**
     * 回调方法， 返回MyScrollView滑动的Y方向距离
     * @param scrollY
     *              、
     */
    public void onScroll(int scrollY);
}