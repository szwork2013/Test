package com.kaikeba.common.util;

import android.content.Context;
import android.content.SharedPreferences;
import com.kaikeba.ContextUtil;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class RedirectTools {

    public static String getQuizId(String strUrl) {

        SharedPreferences appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences",
                        Context.MODE_PRIVATE);
        String cookie = appPrefs.getString("cookie", "OAuth");

        try {
            URL url = new URL(strUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(5 * 5000);
            conn.setDoInput(true);
            conn.setDoOutput(true);
            conn.setUseCaches(false);
//			conn.setRequestProperty("Connection", "keep-alive");
//			conn.setRequestProperty("Charset", "UTF-8");
//			conn.setRequestProperty("Host", "learn.kaikeba.com");
//			conn.setRequestProperty("Origin", "http://learn.kaikeba.com");
//			conn.setRequestProperty("Referer", strUrl);
            conn.setInstanceFollowRedirects(false);
            conn.setRequestProperty("Cookie", cookie);
//			conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36");
            int responseCode = conn.getResponseCode();
            System.out.println("msg:" + conn.getResponseMessage());
            StringBuilder result = new StringBuilder();

            if (responseCode == 302) {
                BufferedReader bufferedReader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream()));
                String readLine = "";
                while ((readLine = bufferedReader.readLine()) != null) {
                    result.append(readLine);
                }
                bufferedReader.close();
            }
            conn.disconnect();

            String[] array = result.toString().split("quizzes/");

            return array[1].split("\"")[0];
        } catch (Exception e) {
            return null;
        }
//		URL url = new URL(strUrl);
//		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
//		conn.setReadTimeout(5 * 5000);
//		conn.setDoInput(true);
//		conn.setDoOutput(true);
//		conn.setUseCaches(false);
//		conn.setRequestProperty("Cookie", API.getAPI().getUserObject().getCookie());
//		int responseCode = conn.getResponseCode();
//		System.out.println("msg:" + conn.getResponseMessage());
//		StringBuilder result = new StringBuilder();
//
//		if (responseCode == 302) {
//			BufferedReader bufferedReader = new BufferedReader(
//					new InputStreamReader(conn.getInputStream()));
//			String readLine = "";
//			while ((readLine = bufferedReader.readLine()) != null) {
//				result.append(readLine);
//			}
//			bufferedReader.close();
//		}
//		conn.disconnect();
//		
//		String[] array = result.toString().split("quizzes/");
//		
//		return array[1].split("\"")[0];
    }

}
