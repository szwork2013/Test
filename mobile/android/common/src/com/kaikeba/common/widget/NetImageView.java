package com.kaikeba.common.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;
import com.kaikeba.ContextUtil;

/**
 * Created by baige on 14-8-24.
 */

public class NetImageView extends ImageView {

    private static final String tag = "NetImageView";

    public NetImageView(Context context) {
        super(context);

    }

    public NetImageView(Context context, AttributeSet attrs) {
        super(context, attrs);

    }

    public void setUrl(String url) {
        ContextUtil.imageLoader.displayImage(url, this, ContextUtil.options);
    }


}

