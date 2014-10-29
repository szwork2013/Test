package com.kaikeba.common.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Created by caojing on 14-5-10.
 */
public class NetworkUtil {

    public static boolean isNetworkAvailable(Context context) {
        // 获得网络连接服务
        ConnectivityManager connManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo.State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
                .getState(); // 获取网络连接状态

        NetworkInfo.State mobileState = NetworkInfo.State.UNKNOWN;
        NetworkInfo mobileNetworkInfo = connManager
                .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        if (mobileNetworkInfo != null) {
            mobileState = mobileNetworkInfo.getState();
        }

        NetworkInfo.State ethernetState = NetworkInfo.State.DISCONNECTED;
        NetworkInfo ethernetInfo = connManager
                .getNetworkInfo(ConnectivityManager.TYPE_ETHERNET);
        if (ethernetInfo != null) {
            ethernetState = ethernetInfo.getState();
        }
        // 判断是否正在使用ETH, WIFI或3G网络
        if (NetworkInfo.State.CONNECTED == state
                || NetworkInfo.State.CONNECTED == mobileState
                || NetworkInfo.State.CONNECTED == ethernetState) {
            return true;
        } else {
            return false;
        }
    }
}
