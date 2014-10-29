package com.kaikeba.common.util;

import android.util.Log;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.UserLoginInfo;
import com.kaikeba.common.exception.DibitsExceptionC;
import org.apache.commons.httpclient.HttpStatus;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

//上传工具类 支持上传文件和参数
public class UploadFileUtil {
    public static final int UPLOAD_SUCCESS_CODE = 1; //上传成功
    //文件不存在
    public static final int UPLOAD_FILE_NOT_EXISTS_CODE = 2;
    //服务器出错
    public static final int UPLOAD_SERVER_ERROR_CODE = 3;
    protected static final int WHAT_TO_UPLOAD = 1;
    protected static final int WHAT_UPLOAD_DONE = 2;
    private static final String BOUNDARY = UUID.randomUUID().toString(); // 边界标识 随机生成
    private static final String PREFIX = "--";
    private static final String LINE_END = "\r\n";
    private static final String CONTENT_TYPE = "multipart/form-data"; // 内容类型
    private static final String TAG = "UploadUtil";
    private static final String CHARSET = "utf-8"; // 设置编码
    private static UploadFileUtil uploadUtil;
    private static int requestTime = 0;    //请求使用多长时间
    private int readTimeOut = 30 * 1000; // 读取超时
    private int connectTimeout = 30 * 1000; // 超时时间
    private OnUploadProcessListener onUploadProcessListener;
    private UploadFileUtil() {

    }

    /**
     * 单例模式获取上传工具类
     *
     * @return
     */
    public static UploadFileUtil getInstance() {
        if (null == uploadUtil) {
            uploadUtil = new UploadFileUtil();
        }
        return uploadUtil;
    }

    /**
     * 获取方法返回的文本
     *
     * @param conn
     * @return
     * @throws java.io.IOException
     */
    public static String getMethodResponseText(HttpURLConnection conn)
            throws IOException {
        String result = null;
        //从链接中获取一个输入流对象
        InputStream inStream = conn.getInputStream();
        //调用数据流处理方法
        byte[] data = StringUtils.readInputStream(inStream);
        String json = new String(data);
//        InputStream input = conn.getInputStream();
//                StringBuffer sb1 = new StringBuffer();
//                int ss;
//                while ((ss = input.read()) != -1) {
//                    sb1.append((char) ss);
//                }
//                result = sb1.toString();
//                Log.e(TAG, "result : " + result);

        return json.toString();
    }

    //获取上传使用的时间
    public static int getRequestTime() {
        return requestTime;
    }

    /**
     * android上传文件到服务器
     *
     * @param filePath   需要上传的文件的路径
     * @param fileKey    在网页上<input type=file name=xxx/> xxx就是这里的fileKey
     * @param RequestURL 请求的URL
     */
    public void uploadFile(String filePath, String fileKey, String RequestURL,
                           Map<String, String> param) {
        if (filePath == null) {
            sendMessage(UPLOAD_FILE_NOT_EXISTS_CODE, "文件不存在");
            return;
        }
        try {
            File file = new File(filePath);
            uploadFile(file, fileKey, RequestURL, param);
        } catch (Exception e) {
            sendMessage(UPLOAD_FILE_NOT_EXISTS_CODE, "文件不存在");
            e.printStackTrace();
            return;
        }
    }

    /**
     * android上传文件到服务器
     *
     * @param file       需要上传的文件
     * @param fileKey    在网页上<input type=file name=xxx/> xxx就是这里的fileKey
     * @param RequestURL 请求的URL
     */
    public void uploadFile(final File file, final String fileKey,
                           final String RequestURL, final Map<String, String> param) throws DibitsExceptionC {
        if (file == null || (!file.exists())) {
            sendMessage(UPLOAD_FILE_NOT_EXISTS_CODE, "文件不存在");
            return;
        }

        Log.i(TAG, "请求的URL=" + RequestURL);
        Log.i(TAG, "请求的fileName=" + file.getName());
        Log.i(TAG, "请求的fileKey=" + fileKey);

        toUploadFile(file, fileKey, RequestURL, param);

    }

    private void toUploadFile(File file, String fileKey, String RequestURL,
                              Map<String, String> param) throws DibitsExceptionC {
        String result = null;
        requestTime = 0;

        long requestTime = System.currentTimeMillis();
        long responseTime = 0;

        try {
            URL url = new URL(RequestURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
            conn.setReadTimeout(readTimeOut);
            conn.setConnectTimeout(connectTimeout);
            conn.setDoInput(true); // 允许输入流
            conn.setDoOutput(true); // 允许输出流
            conn.setUseCaches(false); // 不允许使用缓存
            conn.setRequestMethod("POST"); // 请求方式
            conn.setRequestProperty("Charset", CHARSET); // 设置编码
            conn.setRequestProperty("connection", "keep-alive");
            conn.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)");
            conn.setRequestProperty("Content-Type", CONTENT_TYPE + ";boundary=" + BOUNDARY);
            conn.setRequestProperty("kkb-token", "5191880744949296554");
            conn.setRequestProperty("kkb-platform", logininfo.getPlatform());
            conn.setRequestProperty("kkb-model", logininfo.getModel());
            if (API.getAPI().alreadySignin()) {
                long user_id = API.getAPI().getUserObject().getId();
                String password = API.getAPI().getUserObject().getPassword();
                conn.setRequestProperty("kkb-user", user_id + ":" + password);
            }
//			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            //当文件不为空，把文件包装并且上传
            DataOutputStream dos = new DataOutputStream(conn.getOutputStream());
            StringBuffer sb = null;
            String params = "";

            /***
             * 以下是用于上传参数
             */
            if (param != null && param.size() > 0) {
                Iterator<String> it = param.keySet().iterator();
                while (it.hasNext()) {
                    sb = null;
                    sb = new StringBuffer();
                    String key = it.next();
                    String value = param.get(key);
                    sb.append(PREFIX).append(BOUNDARY).append(LINE_END);
                    sb.append("Content-Disposition: form-data; name=\"").append(key).append("\"").append(LINE_END).append(LINE_END);
                    sb.append(value).append(LINE_END);
                    params = sb.toString();
                    Log.i(TAG, key + "=" + params + "##");
                    dos.write(params.getBytes());
//					dos.flush();
                }
            }

            sb = null;
            params = null;
            sb = new StringBuffer();
            /**
             * 这里重点注意： name里面的值为服务器端需要key 只有这个key 才可以得到对应的文件
             * filename是文件的名字，包含后缀名的 比如:abc.png
             */
            sb.append(PREFIX).append(BOUNDARY).append(LINE_END);
            sb.append("Content-Disposition:form-data; name=\"" + fileKey
                    + "\"; filename=\"" + file.getName() + "\"" + LINE_END);
            sb.append("Content-Type:image/pjpeg" + LINE_END); // 这里配置的Content-type很重要的 ，用于服务器端辨别文件的类型的
            sb.append(LINE_END);
            params = sb.toString();
            sb = null;

            Log.i(TAG, file.getName() + "=" + params + "##");
            dos.write(params.getBytes());
            /**上传文件*/
            InputStream is = new FileInputStream(file);
            onUploadProcessListener.initUpload((int) file.length());
            byte[] bytes = new byte[1024];
            int len = 0;
            int curLen = 0;
            while ((len = is.read(bytes)) != -1) {
                curLen += len;
                dos.write(bytes, 0, len);
                onUploadProcessListener.onUploadProcess(curLen);
            }
            is.close();

            dos.write(LINE_END.getBytes());
            byte[] end_data = (PREFIX + BOUNDARY + PREFIX + LINE_END).getBytes();
            dos.write(end_data);
            dos.flush();
            //获取响应码 200=成功 当响应成功，获取响应的流
            responseTime = System.currentTimeMillis();
            this.requestTime = (int) ((responseTime - requestTime) / 1000);
            int statusCode = conn.getResponseCode();
            if (statusCode != HttpStatus.SC_OK && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                    case HttpStatus.SC_NOT_FOUND:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                    default:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                }
            } else {
                result = getMethodResponseText(conn);
                sendMessage(UPLOAD_SUCCESS_CODE, ""
                        + result);
                return;
            }
        } catch (MalformedURLException e) {
            sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error=" + e.getMessage());
            e.printStackTrace();
            return;
        } catch (IOException e) {
            sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error=" + e.getMessage());
            e.printStackTrace();
            return;
        }
    }

    public void signupUser(final String RequestURL, final Map<String, String> param) throws DibitsExceptionC {
        doPost(RequestURL, param);
    }

    public void doSearch(final String RequestURL, final Map<String, String> param) throws DibitsExceptionC {
        doPost(RequestURL, param);
    }

    private void doPost(String RequestURL,
                        Map<String, String> param) throws DibitsExceptionC {
        String result = null;
        requestTime = 0;

        long requestTime = System.currentTimeMillis();
        long responseTime = 0;

        try {
            URL url = new URL(RequestURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            UserLoginInfo logininfo = RecordUserLoginTool.getRecordUserLoginTool().getUserLoginInfo(ContextUtil.getContext(), "");
            conn.setReadTimeout(readTimeOut);
            conn.setConnectTimeout(connectTimeout);
            conn.setDoInput(true); // 允许输入流
            conn.setDoOutput(true); // 允许输出流
            conn.setUseCaches(false); // 不允许使用缓存
            conn.setRequestMethod("POST"); // 请求方式
            conn.setRequestProperty("Charset", CHARSET); // 设置编码
            conn.setRequestProperty("connection", "keep-alive");
            conn.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)");
            conn.setRequestProperty("Content-Type", CONTENT_TYPE + ";boundary=" + BOUNDARY);
            conn.setRequestProperty("kkb-token", "5191880744949296554");
            conn.setRequestProperty("kkb-platform", logininfo.getPlatform());
            conn.setRequestProperty("kkb-model", logininfo.getModel());
            if (API.getAPI().alreadySignin()) {
                long user_id = API.getAPI().getUserObject().getId();
                String password = API.getAPI().getUserObject().getPassword();
                conn.setRequestProperty("kkb-user", user_id + ":" + password);
            }
//			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            //当文件不为空，把文件包装并且上传
            DataOutputStream dos = new DataOutputStream(conn.getOutputStream());
            StringBuffer sb = null;
            String params = "";

            /***
             * 以下是用于上传参数
             */
            if (param != null && param.size() > 0) {
                Iterator<String> it = param.keySet().iterator();
                while (it.hasNext()) {
                    sb = null;
                    sb = new StringBuffer();
                    String key = it.next();
                    String value = param.get(key);
                    sb.append(PREFIX).append(BOUNDARY).append(LINE_END);
                    sb.append("Content-Disposition: form-data; name=\"").append(key).append("\"").append(LINE_END).append(LINE_END);
                    sb.append(value).append(LINE_END);
                    params = sb.toString();
                    Log.i(TAG, key + "=" + params + "##");
                    dos.write(params.getBytes());
                }
            }
//          dos.write(LINE_END.getBytes());
            byte[] end_data = (PREFIX + BOUNDARY + PREFIX + LINE_END).getBytes();
            dos.write(end_data);
            dos.flush();
            //获取响应码 200=成功 当响应成功，获取响应的流
            int statusCode = conn.getResponseCode();
            if (statusCode != HttpStatus.SC_OK && statusCode != HttpStatus.SC_CREATED
                    && statusCode != HttpStatus.SC_ACCEPTED
                    && statusCode != HttpStatus.SC_NO_CONTENT) {
                switch (statusCode) {
                    case HttpStatus.SC_UNAUTHORIZED:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                    case HttpStatus.SC_NOT_FOUND:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                    default:
                        sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error");
                        return;
                }
            } else {
                result = getMethodResponseText(conn);
                sendMessage(UPLOAD_SUCCESS_CODE, ""
                        + result);
                return;
            }
        } catch (MalformedURLException e) {
            sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error=" + e.getMessage());
            e.printStackTrace();
            return;
        } catch (IOException e) {
            sendMessage(UPLOAD_SERVER_ERROR_CODE, "上传失败：error=" + e.getMessage());
            e.printStackTrace();
            return;
        }
    }

    //发送上传结果
    private void sendMessage(int responseCode, String responseMessage) {
        onUploadProcessListener.onUploadDone(responseCode, responseMessage);
    }

    public void setOnUploadProcessListener(
            OnUploadProcessListener onUploadProcessListener) {
        this.onUploadProcessListener = onUploadProcessListener;
    }

    public int getReadTimeOut() {
        return readTimeOut;
    }

    public void setReadTimeOut(int readTimeOut) {
        this.readTimeOut = readTimeOut;
    }

    public int getConnectTimeout() {
        return connectTimeout;
    }

    public void setConnectTimeout(int connectTimeout) {
        this.connectTimeout = connectTimeout;
    }

    //自定义的回调函数，用到回调上传文件是否完成1
    public static interface OnUploadProcessListener {
        /**
         * 上传响应
         *
         * @param responseCode
         * @param message
         */
        void onUploadDone(int responseCode, String message);

        /**
         * 上传中
         *
         * @param uploadSize
         */
        void onUploadProcess(int uploadSize);

        /**
         * 准备上传
         *
         * @param fileSize
         */
        void initUpload(int fileSize);
    }

    public static interface uploadProcessListener {

    }


}
