package com.kaikeba.common.BaseClass;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.view.View;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;

import java.io.File;

/**
 * Created by cwang on 14-7-30.
 */


public class BaseActivityImpl {
    private BroadcastReceiver netChangeRecevier;
    private Context mContext;

    public BaseActivityImpl(Context mContext) {
        this.mContext = mContext;
        netChangeRecevier = new NetChangeReceiver();
        //注册一个广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(Constants.NOTICE_NET_3G);
        mContext.registerReceiver(netChangeRecevier, filter);
    }

    public void onDestroy(Context mcontext) {
        if (netChangeRecevier != null) {
            mcontext.unregisterReceiver(netChangeRecevier);
            netChangeRecevier = null;
        }
    }

    /**
     * 全部暂停
     */
    public void allPause() {
        try {
            if (ContextUtil.getDownloadManager() != null) {
                ContextUtil.getDownloadManager().stopAllDownload();
                Constants.IS_ALL_DOWNLOAD = false;
            }
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    /**
     * 全部开始
     */
    public void allStart() {
        try {
            ContextUtil.getDownloadManager().resumeDownloadAll(new DownloadRequestCallBack());
            Constants.IS_ALL_DOWNLOAD = true;
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    private class NetChangeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Constants.NOTICE_NET_3G) && Constants.NET_IS_CHANGED) {
                allPause();
                KKDialog.getInstance().showNoWifi2Doload(mContext,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                allStart();
                                KKDialog.getInstance().dismiss();
                                Constants.NET_IS_CHANGED = false;
                            }
                        },
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                                Constants.NET_IS_CHANGED = false;
                            }
                        });
            }
        }
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {
        @Override
        public void onStart() {
        }


        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            Constants.NET_IS_CHANGED = true;
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            Constants.NET_IS_CHANGED = false;
        }

        @Override
        public void onFailure(HttpException error, String msg) {
        }

        @Override
        public void onCancelled() {
            Constants.NET_IS_CHANGED = false;
        }
    }
}
