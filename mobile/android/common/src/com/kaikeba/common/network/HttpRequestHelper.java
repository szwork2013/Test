package com.kaikeba.common.network;

import android.util.Log;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.util.RecordUserLoginTool;
import com.umeng.analytics.MobclickAgent;
import org.apache.http.*;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class HttpRequestHelper {

    public static final String BAD_AUTH_ERROR_STR = "Received authentication challenge is null";

    private static HttpClient initClient() {
        HttpParams httpParameters = new BasicHttpParams();
        // Set the timeout in milliseconds until a connection is established.
        // The default value is zero, that means the timeout is not used.
        int timeoutConnection = 30000;//4000;
        HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);
        // Set the default socket timeout (SO_TIMEOUT)
        // in milliseconds which is the timeout for waiting for data.
        int timeoutSocket = 30000;//7500;
        HttpConnectionParams.setSoTimeout(httpParameters, timeoutSocket);
        //Init http client
        HttpClient httpclient = new DefaultHttpClient(httpParameters);
        return httpclient;
    }


    public static String get(String url, String email, String password) throws HttpException {
        HttpUriRequest request = new HttpGet(url);
        return requestHelper(email, password, request);
    }

    public static String post(String url, String email, String password) throws HttpException {
        HttpUriRequest request = new HttpPost(url);
        return requestHelper(email, password, request);
    }

    public static String get(String url, String email, String password, Map<String, String> params) throws HttpException {
        url = addParamsToUrl(url, params);
        HttpUriRequest request = new HttpGet(url);
        return requestHelper(email, password, request);
    }

    public static String get(String url, Map<String, String> params) throws HttpException {
        // url = addParamsToUrl(url, params);
        HttpUriRequest request = new HttpGet(url);
        if (params != null && params.get("Authorization") != null) {
            request.addHeader("Authorization", params.get("Authorization"));
        }
        return requestHelper(request);
    }

    public static String post(String url, String email, String password, Map<String, String> params) throws HttpException {
        HttpPost request = new HttpPost(url);
        List<NameValuePair> list = new ArrayList<NameValuePair>();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            list.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
        }
        try {
            request.setEntity(new UrlEncodedFormEntity(list, "UTF-8"));
        } catch (UnsupportedEncodingException e) {
            // for now we assume UTF-8 encoding is always supported
        }
        return requestHelper(email, password, request);
    }

    private static String addParamsToUrl(String url, Map<String, String> params) {
        if (params == null) {
            return url;
        }

        List<NameValuePair> paramsList = new LinkedList<NameValuePair>();
        for (String key : params.keySet()) {
            paramsList.add(new BasicNameValuePair(key, params.get(key)));
        }
        String paramString = URLEncodedUtils.format(paramsList, "utf-8");
        if (null != params && params.size() > 0) {
            url += "?" + paramString;
        }
        return url;
    }


    private static String requestHelper(HttpUriRequest request) throws HttpException {
        return requestHelper(null, null, request);
    }

    private static String requestHelper(String email, String password, HttpUriRequest request) throws HttpException {
        try {
//            if (email != null && password != null) {
//			    setBasicAuthHeader(email, password, request);
//            }
//            if (request.getURI().toString().indexOf("courses") ==32) {
//                setUserTokenHeader(request);
//            } else if (request.getURI().toString().indexOf("&courseid")==53) {
//                setUserTokenHeader(request);
//            }else if(request.getURI().toString().indexOf("open_courses")==30){
//                setUserHeader(request);
//            }else if(request.getURI().toString().indexOf("instructive_courses")==30){
//                setUserHeader(request);
//            } else if(request.getURI().toString().indexOf("dynamic") == 40){
//                setDynamicTokenHeader(request);
//            }else {
            setHeader(request);
//            }
            MobclickAgent.onEventBegin(ContextUtil.getContext(), "api_response", request.getURI().toURL().toString());
            HttpResponse response = initClient().execute(request);
            StatusLine statusLine = response.getStatusLine();

            Log.v("kkb", "performance " + System.currentTimeMillis() / 1000 + " requestHelper " + request.getURI());
            if (statusLine.getStatusCode() == HttpStatus.SC_OK) {
                MobclickAgent.onEventEnd(ContextUtil.getContext(), "api_response", request.getURI().toURL().toString());
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                response.getEntity().writeTo(out);
                out.close();
                return out.toString();
            } else {
                //Closes the connection.
                if (response != null) {
                    response.getEntity().getContent().close();
                }
                if (statusLine.getStatusCode() == HttpStatus.SC_UNAUTHORIZED) {
                    API.getAPI().cleanUserInfo();
                    throw new HttpException(BAD_AUTH_ERROR_STR, new Throwable(BAD_AUTH_ERROR_STR));
                } else {
                    throw new HttpException(statusLine.getReasonPhrase(), new Throwable(statusLine.getReasonPhrase()));
                }
            }
        } catch (IOException e) {
            String message = "";
            Throwable cause = null;
            if (e != null && e.getCause() != null) {
                message = e.getCause().getMessage();
                cause = e.getCause();
            } else {
                message = "Timeout";
                cause = new Throwable(message);
            }
            throw new HttpException(message, cause);
        }
    }

    //    private static void setUserHeader(HttpUriRequest request){
//        Log.i("HttpRequestHelper",API.getAPI().getUserObject().getId()+"");
//        request.addHeader("kkb-user",API.getAPI().getUserObject().getId()+"");
//        request.addHeader("kkb-token","5191880744949296554");
//    }
//
//    private static void setUserTokenHeader(HttpUriRequest response) {
//        response.addHeader("referer", "www.kaikeba.com");
//        response.addHeader("Accept", "application/json");
//        if(API.getAPI().getUserObject()!=null && API.getAPI().getUserObject().getAccessToken()!=null){
//            response.addHeader("Authorization", "Bearer " + API.getAPI().getUserObject().getAccessToken());
//        }
//    }
    private static void setHeader(HttpUriRequest response) {
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
        response.addHeader("referer", "www.kaikeba.com");
        response.addHeader("Content-Type", "application/json");
        response.addHeader("kkb-token", "5191880744949296554");
        response.addHeader("kkb-platform", logininfo.getPlatform());
        response.addHeader("kkb-model", logininfo.getModel());
        if (API.getAPI().alreadySignin()) {
            response.addHeader("kkb-user", API.getAPI().getUserObject().getId() + ":" + API.getAPI().getUserObject().getPassword());
        }
    }

//    private static void setDynamicTokenHeader(HttpUriRequest response){
//        response.addHeader("kkb-token","5191880744949296554");
//        response.addHeader("platform","aaa");
//        response.addHeader("kkb-model","bbb");
//    }
//
//	private static void setBasicAuthHeader(String email, String password, HttpUriRequest response){
//		String credentials = email + ":" + password;
//		String base64EncodedCredentials = Base64.encodeToString(credentials.getBytes(), Base64.NO_WRAP);
//		response.addHeader("Authorization", "Basic " + base64EncodedCredentials);
//        response.addHeader("User-Agent", "AAppC34JTB1NDTWD:4.2");
//	}

}
