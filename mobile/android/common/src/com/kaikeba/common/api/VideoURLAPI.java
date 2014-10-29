package com.kaikeba.common.api;

import com.kaikeba.ContextUtil;
import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;

public class VideoURLAPI extends API {

    public static HashMap<String, String> videoMap;

    public static String getFromAssets(String fileName) {
        try {
            String res = "";
            try {
                InputStream in = ContextUtil.getContext().getResources()
                        .getAssets().open(fileName);
                // \Test\assets\yan.txt这里有这样的文件存在
                int length = in.available();
                byte[] buffer = new byte[length];
                in.read(buffer);
                res = EncodingUtils.getString(buffer, "UTF-8");
            } catch (Exception e) {
                e.printStackTrace();
            }
            return res;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getVideoURL(String urlKey) {
        String json = null;
        if (videoMap == null) {
            json = getFromAssets("obsoletecode");
            videoMap = getMap(json);
        }
        return videoMap.get(urlKey);
    }


    public static HashMap<String, String> getMap(String jsonString) {
        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(jsonString);
            @SuppressWarnings("unchecked")
            Iterator<String> keyIter = jsonObject.keys();

            String key;

            String value;

            HashMap<String, String> valueMap = new HashMap<String, String>();

            while (keyIter.hasNext()) {
                key = (String) keyIter.next();
                value = (String) jsonObject.get(key);
                valueMap.put(key, value + ".mp4");
            }
            return valueMap;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;

    }

}
