package com.kaikeba.common.util;

import android.content.Context;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.bitmap.BitmapDisplayConfig;

/**
 * Author: wyouflf
 * Date: 13-11-12
 * Time: 上午10:24
 */
public class BitmapHelp {
    private final static String PATH = "mnt/sdcard/imageCache/";
    private static BitmapUtils bitmapUtils;

    private BitmapHelp() {
    }

    /**
     * BitmapUtils不是单例的 根据需要重载多个获取实例的方法
     *
     * @param appContext application context
     * @return
     */
    public static BitmapUtils getBitmapUtils(Context appContext) {
        if (bitmapUtils == null) {
            bitmapUtils = new BitmapUtils(appContext, PATH);
        }
        return bitmapUtils;
    }

    public static BitmapDisplayConfig getBitMapConfig(Context context,int res){
        BitmapDisplayConfig config = new BitmapDisplayConfig();
        config.setLoadFailedDrawable(context.getResources().getDrawable(res));
        return config;
    }
}
