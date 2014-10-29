package com.kaikeba.common.api;

import android.content.Context;
import com.kaikeba.ContextUtil;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.BasicScheme;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Created by user on 14-6-26.
 */
public class KKBHttpClient {

    private static KKBHttpClient client = null;

    private KKBHttpClient() {

    }

    public static KKBHttpClient getInstance() {
        if (client == null) {
            synchronized (KKBHttpClient.class) {
                if (client == null) {
                    client = new KKBHttpClient();
                    client.enableHttpResponseCache(ContextUtil.getContext());
                }
            }
        }
        return client;
    }

    public String requestFromURL(String url, boolean fromCache, String token) {
        return requestFromURL(fromCache, url, token, null, null, false, null, false);
    }

    public String requestFromURL(String url, boolean fromCache) {
        return requestFromURL(fromCache, url, null, null, null, false, null, false);
    }


    private String requestFromURL(boolean fromCache, String url, String useToken, String email, String password, boolean isBasic, Long update, boolean isCon) {
        StringBuffer resBuffer = new StringBuffer();
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
            conn.setUseCaches(true);
            conn.setDoInput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setRequestMethod("GET");
            conn.setRequestProperty("charset", "UTF-8");
            conn.setRequestProperty("referer", "www.kaikeba.com");
            conn.setRequestProperty("Accept", "application/json");
            int maxStale = 60 * 60 * 24 * 28;// tolerate 4-weeks stale
            conn.addRequestProperty("Cache-Control", "max-stale=" + maxStale);

            String token = null;
            if (API.getAPI().getUserObject() != null &&
                    API.getAPI().getUserObject().getAccessToken() != null) {
                token = API.getAPI().getUserObject().getAccessToken();
            }
            if (useToken != null) {
                token = useToken;
            }
            if (!fromCache) {
                if (token != null) {
                    conn.setRequestProperty("Authorization", "Bearer " + token);
                } else if (isBasic) {
                    String basicAuth = BasicScheme.authenticate(
                            new UsernamePasswordCredentials(email, password),
                            "UTF-8");
                    conn.setRequestProperty("Authorization", basicAuth);
                }
            }
//            if (isCon) {
//                SimpleDateFormat sdf = new SimpleDateFormat(
//                        "EE, dd MMM yyyy HH:mm:ss z", Locale.US);
//                sdf.setTimeZone(new SimpleTimeZone(0, "Out Timezone"));
//                conn.setRequestProperty("if-unmodified-since", sdf.format(new Date(update)));
//            }
            int responseCode = -1;
            if (fromCache) {
                try {
                    conn.setRequestProperty("Cache-Control", "only-if-cached");
                    InputStream cached = conn.getInputStream();
                    responseCode = conn.getResponseCode();
                    System.out.println("url:" + url + " responsecode:" + responseCode + " 获取缓存数据");
                    return getResponseText(cached);
                } catch (IOException e) {
                    e.printStackTrace();

                    return requestFromURL(!fromCache, url, useToken, email, password, isBasic, update, isCon);
                }
            }

            // download from server
            conn.setRequestProperty("Cache-Control", "no-cache");
            InputStream serIs = conn.getInputStream();
            responseCode = conn.getResponseCode();
            System.out.println("url:" + url + " responsecode:" + responseCode + " 联网获取数据");
            return getResponseText(serIs);

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    //cache in local
    private void enableHttpResponseCache(Context context) {
        try {
            long httpCacheSize = 100 * 1024 * 1024; // 10 MiB
            File httpCacheDir = new File(context.getCacheDir(), "http");
            Class.forName("android.net.http.HttpResponseCache")
                    .getMethod("install", File.class, long.class)
                    .invoke(null, httpCacheDir, httpCacheSize);
        } catch (Exception httpResponseCacheNotAvailable) {
            httpResponseCacheNotAvailable.printStackTrace();
        }
    }

    private String getResponseText(InputStream in) {
        StringBuffer resBuffer = new StringBuffer();
        String result = "";
        try {
            if (in != null) {
                BufferedReader br = new BufferedReader(new InputStreamReader(in, "UTF-8"));

                String resTemp = "";
                while ((resTemp = br.readLine()) != null) {
                    resBuffer.append(resTemp);
                }
                result = resBuffer.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

}
