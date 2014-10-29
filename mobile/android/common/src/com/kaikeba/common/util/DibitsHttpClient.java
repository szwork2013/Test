package com.kaikeba.common.util;

import com.kaikeba.ContextUtil;
import com.kaikeba.common.HttpCallBack.HttpUtilInterface;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.lidroid.xutils.HttpUtils;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.auth.BasicScheme;
import org.apache.commons.httpclient.methods.*;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import java.io.*;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.*;


public class DibitsHttpClient {

    public static final String NOT_MODIFY = "NOT_MODIFY";
    public static String TAG = "HTTPCLIENT";

    public static String doGet(String url) throws DibitsExceptionC {
        return doGet(url, null, null, null, false, null, false);
    }

    public static String doGet4Token(String url, String token) throws DibitsExceptionC {
        return doGet(url, token, null, null, false, null, false);
    }

    public static String doGet(String url, Long update) throws DibitsExceptionC {
        return doGet(url, null, null, null, false, update, update != null);
    }

    public static String doGet(String url, String email, String password)
            throws DibitsExceptionC {
        return doGet(url, null, email, password, true, null, false);
    }

    public static String doGet(String url, String email, String password,
                               Long update) throws DibitsExceptionC {
        return doGet(url, null, email, password, true, update, true);
    }

    private static String doGet(String url, String useToken, String email, String password,
                                boolean isBasic, Long update, boolean isCon)
            throws DibitsExceptionC {
        String result = null;
        // 构造HttpClient的实例
        HttpClient httpClient = new HttpClient();
        // 创建GET方法的实例
        GetMethod getMethod = new GetMethod(url);
        // 使用系统提供的默认的恢复策略
        getMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("referer", "www.kaikeba.com"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
        if (useToken != null) {
            token = useToken;
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        if (isCon) {
            SimpleDateFormat sdf = new SimpleDateFormat(
                    "EE, dd MMM yyyy HH:mm:ss z", Locale.US);
            sdf.setTimeZone(new SimpleTimeZone(0, "Out Timezone"));
            getMethod.setRequestHeader(new Header("if-unmodified-since", sdf
                    .format(new Date(update))));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);
//        httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(10000);//10 second
        try {
            // 执行getMethod
            int statusCode = httpClient.executeMethod(getMethod);
            // 读取内容
            result = getMethodResponseText(getMethod);

            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_NOT_MODIFIED:
                        return NOT_MODIFY;
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            // 发生致命的异常，可能是协议不对或者返回的内容有问题
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            // 发生网络异常
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            // 释放连接
            getMethod.releaseConnection();
        }
        if (result != null) {
            result.trim();
        }
        return result;
    }


    public static String doPost4Token(String url, Part[] parts, String token)
            throws DibitsExceptionC {
        return doPost(url, token, null, null, parts, false);
    }

    public static String doPost(String url, Part[] parts)
            throws DibitsExceptionC {
        return doPost(url, null, null, null, parts, false);
    }

    public static String doPost(String url, String email, String password,
                                Part[] parts) throws DibitsExceptionC {
        return doPost(url, null, email, password, parts, true);
    }

    private static String doPost(String url, String useToken, String email, String password,
                                 Part[] parts, boolean isBasic) throws DibitsExceptionC {
        String result = null;
        HttpClient httpClient = new HttpClient();
        PostMethod postMethod = new PostMethod(url);
        postMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        if (parts != null) {
            postMethod.setRequestEntity(new MultipartRequestEntity(parts,
                    postMethod.getParams()));
        }

        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("Request", "multipart/form-data"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
        if (useToken != null) {
            token = useToken;
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);

        try {
            int statusCode = httpClient.executeMethod(postMethod);
            result = getMethodResponseText(postMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            postMethod.releaseConnection();
        }

        return result;
    }

    public static String doPost4Token(String url, String json, String token)
            throws DibitsExceptionC {
        return doPost(url, token, null, null, json, false);
    }

    public static String doPost(String url, String json)
            throws DibitsExceptionC {
        return doPost(url, null, null, null, json, false);
    }

    public static String doPost(String url, String email, String password,
                                String json) throws DibitsExceptionC {
        return doPost(url, null, email, password, json, true);
    }


    private static String doPost(String url, String useToken, String email, String password,
                                 String json, boolean isBasic) throws DibitsExceptionC {
        String result = null;
        HttpClient httpClient = new HttpClient();
        PostMethod postMethod = new PostMethod(url);
        postMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        if (json != null) {
            try {
                postMethod.setRequestEntity(new StringRequestEntity(json, "application/json", "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                throw new DibitsExceptionC(
                        DEC.Commons.CLIENT_REQUEST_ERROR, "json UnsupportedEncodingException");
            }
        }

        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("Request", "application/json"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
//        String token = API.getAPI().getUserObject().getAccessToken();
        if (useToken != null) {
            token = useToken;
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);

        try {
            int statusCode = httpClient.executeMethod(postMethod);
            result = getMethodResponseText(postMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            postMethod.releaseConnection();
        }
        return result;
    }

    public static String doDelete(String url) throws DibitsExceptionC {
        return doDelete(url, null, null, false);
    }

    public static String doDelete(String url, String email, String password)
            throws DibitsExceptionC {
        return doDelete(url, email, password, true);
    }

    private static String doDelete(String url, String email, String password,
                                   boolean isBasic) throws DibitsExceptionC {
        String result = null;
        // 构造HttpClient的实例
        HttpClient httpClient = new HttpClient();
        // 创建GET方法的实例
        DeleteMethod deleteMethod = new DeleteMethod(url);
        // 使用系统提供的默认的恢复策略
        deleteMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);
        try {
            // 执行getMethod
            int statusCode = httpClient.executeMethod(deleteMethod);
            // 读取内容
            result = getMethodResponseText(deleteMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            // 发生致命的异常，可能是协议不对或者返回的内容有问题
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            // 发生网络异常
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            // 释放连接
            deleteMethod.releaseConnection();
        }
        return result;

    }

    public static String doPut4Token(String url, Part[] parts, String token)
            throws DibitsExceptionC {
        return doPut(url, token, null, null, parts, false);
    }

    public static String doPut(String url, Part[] parts)
            throws DibitsExceptionC {
        return doPut(url, null, null, null, parts, false);
    }

    public static String doPut(String url, String email, String password,
                               Part[] parts) throws DibitsExceptionC {
        return doPut(url, null, email, password, parts, true);
    }

    private static String doPut(String url, String useToken, String email, String password,
                                Part[] parts, boolean isBasic) throws DibitsExceptionC {
        String result = null;
        HttpClient httpClient = new HttpClient();
        PutMethod postMethod = new PutMethod(url);
        postMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        if (parts != null) {
            postMethod.setRequestEntity(new MultipartRequestEntity(parts,
                    postMethod.getParams()));
        }

        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("Request", "multipart/form-data"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
        if (useToken != null) {
            token = useToken;
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);

        try {
            int statusCode = httpClient.executeMethod(postMethod);
            result = getMethodResponseText(postMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            postMethod.releaseConnection();
        }
        return result;
    }

    public static String doPut4Token(String url, String json, String token)
            throws DibitsExceptionC {
        return doPut(url, token, null, null, json, false);
    }

    public static String doPut(String url, String json)
            throws DibitsExceptionC {
        return doPut(url, null, null, null, json, false);
    }

    public static String doPut(String url, String email, String password,
                               String json) throws DibitsExceptionC {
        return doPut(url, null, email, password, json, true);
    }

    public static String doPut(String url, String useToken, String email,
                               String password, String json, boolean isBasic) throws DibitsExceptionC {
        String result = null;
        HttpClient httpClient = new HttpClient();
        PutMethod putMethod = new PutMethod(url);
        putMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        if (json != null) {
            try {
                putMethod.setRequestEntity(new StringRequestEntity(json, "application/json", "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                throw new DibitsExceptionC(
                        DEC.Commons.CLIENT_REQUEST_ERROR, "json UnsupportedEncodingException");
            }
        }

        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("Request", "application/json"));
        String token = null;
        if (API.getAPI().getUserObject() != null &&
                API.getAPI().getUserObject().getAccessToken() != null) {
            token = API.getAPI().getUserObject().getAccessToken();
        }
        if (useToken != null) {
            token = useToken;
        }
        if (token != null) {
            headers.add(new Header("Authorization", "Bearer " + token));
        } else if (isBasic) {
            String basicAuth = BasicScheme.authenticate(
                    new UsernamePasswordCredentials(email, password),
                    "UTF-8");
            headers.add(new Header("Authorization", basicAuth));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);

        try {
            int statusCode = httpClient.executeMethod(putMethod);
            result = getMethodResponseText(putMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            putMethod.releaseConnection();
        }

        return result;

    }


    /**
     * 获取方法返回的文本
     *
     * @param method
     * @return
     * @throws java.io.IOException
     */
    public static String getMethodResponseText(HttpMethodBase method)
            throws IOException {
        StringBuffer resBuffer = new StringBuffer();

        InputStream resStream = method.getResponseBodyAsStream();
        if (resStream != null) {
            BufferedReader br = new BufferedReader(new InputStreamReader(resStream, "UTF-8"));

            String resTemp = "";
            while ((resTemp = br.readLine()) != null) {
                resBuffer.append(resTemp);
            }
        }

        return resBuffer.toString();
    }

    public static byte[] doGetImage(String url) throws DibitsExceptionC {
        byte[] result = null;
        // 构造HttpClient的实例
        HttpClient httpClient = new HttpClient();
        // 创建GET方法的实例
        GetMethod getMethod = new GetMethod(url);
        // 使用系统提供的默认的恢复策略
        getMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        try {
            // 执行getMethod
            int statusCode = httpClient.executeMethod(getMethod);
            // 读取内容
            if (statusCode == 200) {
                result = getMethod.getResponseBody();
                ;
            }
               /* if (statusCode != HttpStatus.SC_OK
	                    && statusCode != HttpStatus.SC_CREATED
	                    && statusCode != HttpStatus.SC_ACCEPTED
	                    && statusCode != HttpStatus.SC_NO_CONTENT) {
	                switch (statusCode) {
	                    default:
	                        throw new DibitsExceptionC(DEC.Commons.);
	                }
	            }*/
        } catch (HttpException e) {
            // 发生致命的异常，可能是协议不对或者返回的内容有问题
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            // 发生网络异常
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            // 释放连接
            getMethod.releaseConnection();
        }

        return result;
    }

    public static String doNewPost(String url, String json) throws DibitsExceptionC {
        String result = null;
        HttpClient httpClient = new HttpClient();
        PostMethod postMethod = new PostMethod(url);
        postMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
        if (json != null) {
            try {
                postMethod.setRequestEntity(new StringRequestEntity(json, "application/json", "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                throw new DibitsExceptionC(
                        DEC.Commons.CLIENT_REQUEST_ERROR, "json UnsupportedEncodingException");
            }
        }

        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Content-Type", "application/json"));
        headers.add(new Header("kkb-token", "5191880744949296554"));
        headers.add(new Header("kkb-platform", logininfo.getPlatform()));
        headers.add(new Header("kkb-model", logininfo.getModel()));
        if (API.getAPI().getUserObject() != null && API.getAPI().getUserObject().getId() != null) {
            long user_id = API.getAPI().getUserObject().getId();
            String password = API.getAPI().getUserObject().getPassword();
            headers.add(new Header("kkb-user", user_id + ":" + password));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);
        try {
            int statusCode = httpClient.executeMethod(postMethod);
            result = getMethodResponseText(postMethod);
            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        API.getAPI().cleanUserInfo();
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            postMethod.releaseConnection();
        }
        return result;
    }

    public static String doNewGet(String url) throws DibitsExceptionC {
        String result = null;
        // 构造HttpClient的实例
        HttpClient httpClient = new HttpClient();
        // 创建GET方法的实例
        GetMethod getMethod = new GetMethod(url);
        // 使用系统提供的默认的恢复策略
        getMethod.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler());
        UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
        List<Header> headers = new ArrayList<Header>();
        headers.add(new Header("Accept", "application/json"));
        headers.add(new Header("kkb-token", "5191880744949296554"));
        headers.add(new Header("kkb-platform", logininfo.getPlatform()));
        headers.add(new Header("kkb-model", logininfo.getModel()));
        if (API.getAPI().getUserObject() != null && API.getAPI().getUserObject().getId() != null) {
            long user_id = API.getAPI().getUserObject().getId();
            String password = API.getAPI().getUserObject().getPassword();
            headers.add(new Header("kkb-user", user_id + ":" + password));
        }
        httpClient.getHostConfiguration().getParams()
                .setParameter("http.default-headers", headers);
        try {
            // 执行getMethod
            int statusCode = httpClient.executeMethod(getMethod);
            // 读取内容
            result = getMethodResponseText(getMethod);

            if (statusCode != HttpStatus.SC_OK
                    && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_NOT_MODIFIED:
                        return NOT_MODIFY;
                    case HttpStatus.SC_UNAUTHORIZED:
                        API.getAPI().cleanUserInfo();
                        throw new DibitsExceptionC(DEC.Commons.CLIENT_AUTH_FAILED,
                                result);
                    case HttpStatus.SC_NOT_FOUND:
                        throw new DibitsExceptionC(
                                DEC.Commons.CLIENT_URI_NOT_FOUND, result);
                    default:
                        throw new DibitsExceptionC(result);
                }
            }
        } catch (HttpException e) {
            // 发生致命的异常，可能是协议不对或者返回的内容有问题
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } catch (IOException e) {
            // 发生网络异常
            e.printStackTrace();
            throw new DibitsExceptionC(DEC.Commons.SERVER_ERROR, e.getMessage());
        } finally {
            // 释放连接
            getMethod.releaseConnection();
        }
        if (result != null) {
            result.trim();
        }
        return result;
    }

    public static String doPostDiscussionReply(String url) {
        HttpPost httpPost = new HttpPost(url);

//		httpPost.setHeader("User-Agent","SOHUWapRebot");
        httpPost.setHeader("Accept-Language", "zh-cn,zh;q=0.5");
        httpPost.setHeader("Accept-Charset", "GBK,utf-8;q=0.7,*;q=0.7");
        httpPost.setHeader("Connection", "keep-alive");

        MultipartEntity mutiEntity = new MultipartEntity();

        org.apache.http.client.HttpClient httpClient = new DefaultHttpClient();

        try {
            mutiEntity.addPart("desc", new StringBody("美丽的西双版纳", Charset.forName("utf-8")));
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        httpPost.setEntity(mutiEntity);

        HttpResponse httpResponse = null;
        try {
            httpResponse = httpClient.execute(httpPost);
        } catch (ClientProtocolException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        HttpEntity httpEntity = httpResponse.getEntity();

        try {
            String content = EntityUtils.toString(httpEntity);
            return content;
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public static void sendData(RequestParams params, String url, final HttpUtilInterface callback) {
        HttpUtils http = new HttpUtils();
        http.send(HttpRequest.HttpMethod.POST,
                url,
                params,
                new RequestCallBack<String>() {

                    @Override
                    public void onStart() {
                        callback.onStart();
                    }

                    @Override
                    public void onLoading(long total, long current, boolean isUploading) {
                        callback.onLoading(total, current, isUploading);
                    }

                    @Override
                    public void onSuccess(ResponseInfo<String> responseInfo) {
                        callback.onSuccess(responseInfo);
                    }

                    @Override
                    public void onFailure(com.lidroid.xutils.exception.HttpException e, String s) {
                        callback.onFailure(e, s);
                    }
                });
    }
}