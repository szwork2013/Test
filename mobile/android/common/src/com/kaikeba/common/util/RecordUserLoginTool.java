package com.kaikeba.common.util;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import com.kaikeba.common.entity.UserLoginInfo;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by chris on 14-7-18.
 */
public class RecordUserLoginTool {

    private static RecordUserLoginTool instance = new RecordUserLoginTool();

    private RecordUserLoginTool() {

    }

    public static RecordUserLoginTool getRecordUserLoginTool() {
        return instance;
    }

    public UserLoginInfo getUserLoginInfo(Context mContext, String userId) {
        UserLoginInfo info = new UserLoginInfo();
        UserInfo phoneInfo = getPhoneInfo(mContext);
        info.setUser_id(userId);
        info.setPackage_name("com.kaikeba.phone");
        info.setPlatform("android");
        info.setOs_version(android.os.Build.VERSION.RELEASE);
        info.setModel(android.os.Build.MODEL);
        if (phoneInfo != null) {
            info.setImei(phoneInfo.imei);
            info.setMac(phoneInfo.mac);
            info.setChannel(phoneInfo.channel);
        }
        try {
            PackageManager manager = mContext.getPackageManager();
            PackageInfo package_info = manager.getPackageInfo(mContext.getPackageName(), 0);
            String version = package_info.versionName;
            info.setClient_version(version);
        } catch (PackageManager.NameNotFoundException exception) {
            exception.printStackTrace();
        }

        info.setIfa("");
        info.setIfv("");
        info.setTime_action(System.currentTimeMillis() / 1000);
        if (userId.equals("")) {
            info.setAction("firstOpen");
        } else {
            info.setAction("register");
        }
        return info;
    }

    public UserLoginInfo getUserLoginInfo(Context mContext) {
        UserLoginInfo info = new UserLoginInfo();
        UserInfo phoneInfo = getPhoneInfo(mContext);
        info.setUser_id("");
        info.setPackage_name("com.kaikeba.phone");
        info.setPlatform("android");
        info.setOs_version(android.os.Build.VERSION.RELEASE);
        if (phoneInfo != null) {
            info.setImei(phoneInfo.imei);
            info.setMac(phoneInfo.mac);
            info.setChannel(phoneInfo.channel);
        }
        try {
            PackageManager manager = mContext.getPackageManager();
            PackageInfo package_info = manager.getPackageInfo(mContext.getPackageName(), 0);
            String version = package_info.versionName;
            info.setClient_version(version);
        } catch (PackageManager.NameNotFoundException exception) {
            exception.printStackTrace();
        }
        info.setIfa("");
        info.setIfv("");
//        info.setTimeAction(getTime());
//        info.setTimeReceive("");
        return info;
    }

    public UserInfo getPhoneInfo(Context mContext) {
        TelephonyManager tm = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
        tm.getDeviceId();
        UserInfo info = new UserInfo();
        info.imei = tm.getDeviceId();

        WifiManager wifi = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifi.getConnectionInfo();

        info.mac = wifiInfo.getMacAddress();

        ApplicationInfo appInfo = null;
        try {
            appInfo = mContext.getPackageManager().getApplicationInfo(mContext.getPackageName(), PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        info.channel = appInfo.metaData.getString("UMENG_CHANNEL");
        return info;
    }

    private String getTime() {
        Date date = new Date();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return formatter.format(date);
    }

    static class UserInfo {
        public String imei;
        public String mac;
        public String channel;
    }


//    RequestParams params = new RequestParams();
//
//    params.addHeader("Content-Type", "application/json");
//    params.addQueryStringParameter("kkb-token", "5191880744949296554");

// 只包含字符串参数时默认使用BodyParamsEntity，
// 类似于UrlEncodedFormEntity（"application/x-www-form-urlencoded"）。

//        params.addBodyParameter("name", "value");

// 加入文件参数后默认使用MultipartEntity（"multipart/form-data"），
// 如需"multipart/related"，xUtils中提供的MultipartEntity支持设置subType为"related"。
// 使用params.setBodyEntity(httpEntity)可设置更多类型的HttpEntity（如：
// MultipartEntity,BodyParamsEntity,FileUploadEntity,InputStreamUploadEntity,StringEntity）。
// 例如发送json参数：params.setBodyEntity(new StringEntity(jsonStr,charset));

//        params.addBodyParameter("file", new File("path"));
}
