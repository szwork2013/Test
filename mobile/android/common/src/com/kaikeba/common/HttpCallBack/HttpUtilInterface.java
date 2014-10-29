package com.kaikeba.common.HttpCallBack;

import com.lidroid.xutils.http.ResponseInfo;

/**
 * Created by chris on 14-7-18.
 */
public interface HttpUtilInterface {
    void onStart();

    void onLoading(long total, long current, boolean isUploading);

    void onSuccess(ResponseInfo<String> responseInfo);

    void onFailure(com.lidroid.xutils.exception.HttpException e, String s);
}
