package com.kaikeba.common.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class NetUtil {

    public static boolean isNetType(Context context) {
        if (context == null) {
            return false;
        }
        ConnectivityManager connectivityManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo mobNetInfo = connectivityManager.getActiveNetworkInfo();
        if (mobNetInfo != null && mobNetInfo.isConnected() && mobNetInfo.isAvailable()) {
            return true;
        }
        return false;
    }

    public static int getNetType(Context context) {
        // 获得网络连接服务
        ConnectivityManager connManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo.State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
                .getState(); // 获取网络连接状态
        if (NetworkInfo.State.CONNECTED == state) {
            Constants.NET_IS_SUCCESS = true;
            return Constants.WIFI_STATE_CONNECTED;
        }

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
            Constants.NET_IS_SUCCESS = true;
            return Constants.MOBILE_STATE_CONNECTED;
        }
        Constants.NET_IS_SUCCESS = false;
        return Constants.NO_NET;
    }
}
