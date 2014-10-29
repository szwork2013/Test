package com.kaikeba.common.api;

import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.conversion.JsonParser;
import com.kaikeba.common.entity.LatestVersion;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

public class OtherAPI extends API {


    /**
     * 获取最新版本信息
     *
     * @return
     * @throws DibitsExceptionC
     */
    public static LatestVersion getLatestVersion() throws DibitsExceptionC {
        String url = buildLatestVersionURL();

        String json = DibitsHttpClient.doGet(url);
        System.out.println(json);
        LatestVersion latestVersion = (LatestVersion)
                JsonEngine.parseJson(json, LatestVersion.class);

        return latestVersion;
    }

    /**
     * 获取关于页面URL
     *
     * @return
     * @throws DibitsExceptionC
     */
    public static String getAboutPageURL() throws DibitsExceptionC {
        String url = buildAboutURL();
        String json = DibitsHttpClient.doGet(url);
        return (String) JsonParser.parseOneObject(json, "androidAboutPageURL");
    }

    /**
     * 获取评分URL
     *
     * @return
     * @throws DibitsExceptionC
     */
    public static String getStarMeURL() throws DibitsExceptionC {
        String url = buildStarMeURL();
        String json = DibitsHttpClient.doGet(url);
        return (String) JsonParser.parseOneObject(json, "androidStarMe");
    }


    //=======================↓↓ build URL ↓↓=======================

    private final static String buildLatestVersionURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/latest-version.json");
        return url.toString();
    }

    private final static String buildAboutURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/about.json");
        return url.toString();
    }

    private final static String buildStarMeURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/star-me.json");
        return url.toString();
    }

    /**
     * @param args
     * @throws DibitsExceptionC
     */
    public static void main(String[] args) throws DibitsExceptionC {
//        LatestVersion latestVersion = OtherAPI.getLatestVersion();
//        System.out.println(latestVersion.getLatestVersion());
//        System.out.println(latestVersion.getDownloadURL());

//        String aboutPageURL = OtherAPI.getAboutPageURL();
//        System.out.println(aboutPageURL);

        String starMe = OtherAPI.getStarMeURL();
        System.out.println(starMe);
    }

}
