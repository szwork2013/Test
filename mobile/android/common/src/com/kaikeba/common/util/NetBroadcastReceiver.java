package com.kaikeba.common.util;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.NetworkInfo.State;
import android.util.Log;
import android.widget.Toast;

public class NetBroadcastReceiver extends BroadcastReceiver {
    private static NetBroadcastReceiver instance;

    private NetBroadcastReceiver() {

    }

    public static NetBroadcastReceiver getInstance() {
        if (instance == null) {
            instance = new NetBroadcastReceiver();
        }
        return instance;
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        Log.e("NetBroadcastReceiver", "网络状态改变");

        // 获得网络连接服务
        ConnectivityManager connManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState(); // 获取网络连接状态
        if (State.CONNECTED == state) { // 判断是否正在使用WIFI网络
            Constants.NET_IS_SUCCESS = true;
            Constants.CURRENT_NET_STATE = Constants.WIFI_STATE_CONNECTED;
            Toast.makeText(context, "当前使用wifi网络", Toast.LENGTH_LONG).show();
        } else {
            Constants.NET_IS_SUCCESS = false;
        }
        NetworkInfo info = connManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        if (info != null) {
            state = info.getState(); // 获取网络连接状态
            if (State.CONNECTED == state) { // 判断是否正在使用GPRS网络
                Constants.NET_IS_SUCCESS = true;
                Constants.CURRENT_NET_STATE = Constants.MOBILE_STATE_CONNECTED;
                Toast.makeText(context, "当前使用2G/3G网络", Toast.LENGTH_LONG).show();

                //发送当前正在使用2G/3G网络的广播
                Intent netIntent = new Intent(Constants.NOTICE_NET_3G);
                context.sendBroadcast(netIntent);
            }

        }

        if (!Constants.NET_IS_SUCCESS) {
            Constants.CURRENT_NET_STATE = Constants.NO_NET;
            Toast.makeText(context, "网络未连接", Toast.LENGTH_LONG).show();
        }
        Intent mIntent = new Intent(Constants.ACTION_IS_REFRESH);
        mIntent.putExtra("isRefresh", Constants.NET_IS_SUCCESS);

        //发送广播 
        context.sendBroadcast(mIntent);
    }
}