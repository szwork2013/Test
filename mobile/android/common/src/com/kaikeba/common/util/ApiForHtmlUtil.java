package com.kaikeba.common.util;

import org.apache.http.util.ByteArrayBuffer;
import org.apache.http.util.EncodingUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ApiForHtmlUtil {


    /**
     * 获取数据
     *
     * @param url
     */
    public static List<Map<String, String>> load(String url) {
        Document doc = null;
        try {
            doc = Jsoup.parse(new URL(url), 50000);
        } catch (MalformedURLException e1) {
            e1.printStackTrace();
        } catch (IOException e1) {
            e1.printStackTrace();
        }

        List<Map<String, String>> list = new ArrayList<Map<String, String>>();
        Elements es = doc.getElementsByClass("");
        for (Element e : es) {
            Map<String, String> map = new HashMap<String, String>();
            map.put("title", e.getElementsByTag("a").text());
            list.add(map);
        }
        return list;
    }

    /**
     * @param urlString
     * @return
     */
    public static String getHtmlString(String urlString) {
        try {
            URL url = null;
            url = new URL(urlString);

            URLConnection ucon = null;
            ucon = url.openConnection();

            InputStream instr = null;
            instr = ucon.getInputStream();

            BufferedInputStream bis = new BufferedInputStream(instr);

            ByteArrayBuffer baf = new ByteArrayBuffer(500);
            int current = 0;
            while ((current = bis.read()) != -1) {
                baf.append((byte) current);
            }
            return EncodingUtils.getString(baf.toByteArray(), "utf-8");
        } catch (Exception e) {
            return "";
        }
    }
}
