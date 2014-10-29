package com.kaikeba.common.util;

import android.util.Log;

/**
 * Created by caojing on 14-5-27.
 */
public class MemoryUtil {

    public static boolean isLowMemory() {
        Log.v("Kaikeba", "maxMemory=" + (Runtime.getRuntime().maxMemory() / 1000000) +
                "M; \ttotalMemory=" + (Runtime.getRuntime().totalMemory() / 1000000) +
                "M; \tfreeMemory=" + (Runtime.getRuntime().freeMemory() / 1000000) + "M");
        if (Runtime.getRuntime().totalMemory() * 1.0 / Runtime.getRuntime().maxMemory() > 0.6) {
            return true;
        } else {
            return false;
        }
    }
}
