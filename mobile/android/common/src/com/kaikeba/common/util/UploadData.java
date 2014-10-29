package com.kaikeba.common.util;

import android.content.Context;
import android.content.SharedPreferences;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.HttpCallBack.HttpUtilInterface;
import com.kaikeba.common.api.API;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.DBUploadInfo;
import com.kaikeba.common.entity.ErrorInfo;
import com.kaikeba.common.entity.PushInfo;
import com.kaikeba.common.entity.UserLoginInfo;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.http.RequestParams;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Type;

/**
 * Created by chris on 14-7-21.
 */
public class UploadData {
    private static UploadData instance;
    private int flag = 0;

    private UploadData() {
    }

    public static UploadData getInstance() {
        synchronized (UploadData.class) {
            if (instance == null) {
                instance = new UploadData();
            }
        }
        return instance;
    }

    // 获取所有的网页信息以String 返回
    private static String getStringFromHttp(HttpEntity entity) {

        StringBuffer buffer = new StringBuffer();

        try {
            // 获取输入流
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    entity.getContent()));

            // 将返回的数据读到buffer中
            String temp = null;

            while ((temp = reader.readLine()) != null) {
                buffer.append(temp);
            }
        } catch (IllegalStateException e) {

            //e.printStackTrace();
        } catch (IOException e) {
            //e.printStackTrace();
        }
        return buffer.toString();
    }

    public synchronized void startUpload(Context context) throws DbException, InterruptedException {
        flag = 0;
        DBUploadInfo info = DataSource.getDataSourse().selectData();
        String url = null;
        String request = null;
        while (info != null) {
            String type = info.getCpa();
            if (type.equals("CPA")) {
                url = HttpUrlUtil.CPA;//"http://api-stg.kaikeba.com/v1/cpa";
                request = "post";
            } else if (type.equals("playRecord")) {
                url = HttpUrlUtil.PLAY_RECORDS; //"https://api.kaikeba.com/v1/play_records";
                request = "put";
            } else if (type.equals("push")) {
                url = HttpUrlUtil.PUSH;//"http://api-stg.kaikeba.com/v1/push";
                request = "post";
            } else {
                //
            }
            sendDataSync(info.getContent(), url, info, request);
//            Log.e("jack","info.getContent():"+info.getContent());
            info = DataSource.getDataSourse().selectData();
            if (flag >= 5) {
                break;
            }
        }
    }

    //同步请求
    public void sendDataSync(String dataString, String url, DBUploadInfo info, String requestType) throws DbException {
        HttpResponse response = null;
        DefaultHttpClient client = null;
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
        try {
            if (requestType.equals("post")) {
                HttpPost request = new HttpPost(url);
                request.addHeader("kkb-token", "5191880744949296554");
                request.addHeader("Content-Type", "application/json");
                request.addHeader("kkb-platform", logininfo.getPlatform());
                request.addHeader("kkb-model", logininfo.getModel());
                if (API.getAPI().alreadySignin()) {
                    request.addHeader("kkb-user", API.getAPI().getUserObject().getId() + ":" + API.getAPI().getUserObject().getPassword());
                }
                request.setEntity(new StringEntity(dataString, "utf-8"));
                HttpParams httpParams = new BasicHttpParams();
                HttpConnectionParams.setConnectionTimeout(httpParams, 180000);
                HttpConnectionParams.setSoTimeout(httpParams, 180000);
                client = new DefaultHttpClient(httpParams);
                response = client.execute(request);

            }
            if (requestType.equals("put")) {
                HttpPut request = new HttpPut(url);
                request.addHeader("kkb-token", "5191880744949296554");
                request.addHeader("Content-Type", "application/json");
                request.addHeader("kkb-platform", logininfo.getPlatform());
                request.addHeader("kkb-model", logininfo.getModel());
                if (API.getAPI().alreadySignin()) {
                    request.addHeader("kkb-user", API.getAPI().getUserObject().getId() + ":" + API.getAPI().getUserObject().getPassword());
                }
                request.setEntity(new StringEntity(dataString, "utf-8"));
                HttpParams httpParams = new BasicHttpParams();
                HttpConnectionParams.setConnectionTimeout(httpParams, 180000);
                HttpConnectionParams.setSoTimeout(httpParams, 180000);
                client = new DefaultHttpClient(httpParams);
                response = client.execute(request);
            }
        } catch (IOException e) {
            flag++;
            e.printStackTrace();
        }
        if (response != null) {
            String json = getStringFromHttp(response.getEntity());
            ErrorInfo errorInfo = (ErrorInfo) JsonEngine.parseJson(json, ErrorInfo.class);
            try {
                if (response.getStatusLine().getStatusCode() == 201 || response.getStatusLine().getStatusCode() == 200) {
                    DataSource.getDataSourse().deleteData(info);
                } else {
                    if (errorInfo != null && errorInfo.getMessage().equals("创建信息已存在")) {
                        DataSource.getDataSourse().deleteData(info);
                    } else {
                        flag++;
                    }
                }
            } finally {
                if (null != client) {
                    client.getConnectionManager().shutdown();
                }
            }
        }
    }

//    public void addDbData(Context context, String userId) throws DbException {   //id首次登陆“”；注册登陆id
//        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(context,userId);
//        Type type = new TypeToken<UserLoginInfo>() {
//        }.getType();
//        String jsonStr = JsonEngine.toJson(logininfo, type);
//        DBUploadInfo info = new DBUploadInfo();
//        info.setCpa("CPA");
//        info.setContent(jsonStr);
//        ContextUtil.dataSource.addData(info);
//    }

    public void addDbData(Context context, Object object, String typeName) throws DbException {
        Type type = new TypeToken<Object>() {
        }.getType();
        String jsonStr = JsonEngine.toJson(object, type);
        DBUploadInfo info = new DBUploadInfo();
        info.setCpa(typeName);
        info.setContent(jsonStr);
        DataSource.getDataSourse().addData(info);
    }

    public void upload(final Context context) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    DBUploadInfo uploadInfo = DataSource.getDataSourse().selectData();
                    if (uploadInfo != null) {
                        UploadData.getInstance().startUpload(context);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    //异步请求
    public void sendData(String jsonStr, String url, HttpUtilInterface callBack) throws InterruptedException {
        RequestParams params = new RequestParams();
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
        params.addHeader("kkb-token", "5191880744949296554");
        params.addHeader("Content-Type", "application/json");
        params.addHeader("kkb-platform", logininfo.getPlatform());
        params.addHeader("kkb-model", logininfo.getModel());
        if (API.getAPI().alreadySignin()) {
            params.addHeader("kkb-user", API.getAPI().getUserObject().getId() + ":" + API.getAPI().getUserObject().getPassword());
        }
        try {
            params.setBodyEntity(new StringEntity(jsonStr, "utf-8"));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        DibitsHttpClient.sendData(params, url, callBack);
    }

    public void uploadPushInfo(Context context) {
        try {
            RecordUserLoginTool.UserInfo info = RecordUserLoginTool.getRecordUserLoginTool().getPhoneInfo(context);
            SharedPreferences appPrefs = ContextUtil.getContext().getSharedPreferences("com.kaikeba.preferences", Context.MODE_PRIVATE);
            String clientId = appPrefs.getString(API.CLIENTID, null);
            String mac = "";
            String imei = "";
            if (info != null) {
                mac = info.mac;
                imei = info.imei;
            }
            PushInfo pushInfo;
            if (API.getAPI().alreadySignin()) {
                pushInfo = new PushInfo(clientId, API.getAPI().getUserObject().getId(), mac, imei, API.getAPI().getUserObject().getEmail());
            } else {
                pushInfo = new PushInfo(clientId, 0, mac, imei, "");
            }
            addDbData(context, pushInfo, "push");
        } catch (DbException e) {
            e.printStackTrace();
        }
        upload(context);
    }
}
