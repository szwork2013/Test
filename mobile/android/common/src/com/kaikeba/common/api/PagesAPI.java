package com.kaikeba.common.api;


import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Page;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.DibitsHttpClient;

public class PagesAPI extends API {

    /**
     * 获取课程简介Page，用在首页课程简介浮层中的课程简介introduction
     *
     * @param courseID
     * @return
     * @throws DibitsExceptionC
     */
    public final static Page getIntroduction(String courseID) throws DibitsExceptionC {
        String url = buildIntroductionURL(courseID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, ConfigLoader.getLoader().getCanvas().getPublicToken());
        Page page = (Page) JsonEngine.parseJson(json, Page.class);

        return page;
    }

    /**
     * 获取讲师简介Page，用在首页课程简介浮层中的讲师简介
     *
     * @param courseID
     * @return
     * @throws DibitsExceptionC
     */
    public final static Page getInstructor(String courseID) throws DibitsExceptionC {
        String url = buildInstructorURL(courseID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, ConfigLoader.getLoader().getCanvas().getPublicToken());
        Page page = (Page) JsonEngine.parseJson(json, Page.class);

        return page;
    }

    /**
     * 获取指定的Page，用在课程框架、课程单元点击某些页面时
     *
     * @param courseID
     * @param pageURL
     * @return
     * @throws DibitsExceptionC
     */
    public final static Page getPage(String courseID, String pageURL) throws DibitsExceptionC {
        String url = buildPageURL(courseID, pageURL);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, ConfigLoader.getLoader().getCanvas().getPublicToken());
        Page page = (Page) JsonEngine.parseJson(json, Page.class);

        String html = page.getBody();
        if (html.contains("<div id=\"embed_media")) {
            html = ConfigLoader.getLoader().getCanvas().getPageHtmlHead() +
                    page.getBody() +
                    ConfigLoader.getLoader().getCanvas().getPageHtmlTail();
            page.setBody(html);
        }

        System.out.println(page.getBody());

        return page;
    }


    //=======================↓↓ build URL ↓↓=======================

    private final static String buildIntroductionURL(String courseID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseID)
                .append(SLASH_PAGES).append(SLASH_INTRODUCTION);
        return url.toString();
    }

    private final static String buildInstructorURL(String courseID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseID)
                .append(SLASH_PAGES).append(SLASH_INSTRUCTOR);
        return url.toString();
    }

    private final static String buildPageURL(String courseID, String pageURL) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseID)
                .append(SLASH_PAGES).append(SLASH).append(pageURL);
        return url.toString();
    }


    public static void main(String[] args) throws DibitsExceptionC {

//        Page intruction = PagesAPI.getIntruction(String.valueOf(8));
//        System.out.println(intruction.getUrl());
//        System.out.println(intruction.getTitle());
//        System.out.println(intruction.getCreatedAt());
//        System.out.println(intruction.getUpdatedAt());
//        System.out.println(intruction.getHideFromStudents());
//        System.out.println(intruction.getBody());
//        System.out.println("=====================================");
//        System.out.println();
//        
//        Page instructor = PagesAPI.getInstructor(String.valueOf(8));
//        System.out.println(instructor.getUrl());
//        System.out.println(instructor.getTitle());
//        System.out.println(instructor.getCreatedAt());
//        System.out.println(instructor.getUpdatedAt());
//        System.out.println(instructor.getHideFromStudents());
//        System.out.println(instructor.getBody());
//        System.out.println("=====================================");
//        System.out.println();
//        
//        Page test01 = PagesAPI.getPage(String.valueOf(8), "test01");
//        System.out.println(test01.getUrl());
//        System.out.println(test01.getTitle());
//        System.out.println(test01.getCreatedAt());
//        System.out.println(test01.getUpdatedAt());
//        System.out.println(test01.getHideFromStudents());
//        System.out.println(test01.getBody());
//        System.out.println("=====================================");
//        System.out.println();


//        //androidying-yong-cheng-xu-mu-lu-jie-gou
//        Page test02 = PagesAPI.getPage(String.valueOf(8), "androidying-yong-cheng-xu-mu-lu-jie-gou");
//        System.out.println(test02.getUrl());
//        System.out.println(test02.getTitle());
//        System.out.println(test02.getCreatedAt());
//        System.out.println(test02.getUpdatedAt());
//        System.out.println(test02.getHideFromStudents());
//        System.out.println(test02.getBody());
//        System.out.println("=====================================");
//        System.out.println();

        //androidying-yong-cheng-xu-mu-lu-jie-gou
//        API.getAPI().getUserObject().setAccessToken(ConfigLoader.getLoader().getCanvas().getAccessToken());
        Page test02 = PagesAPI.getPage(String.valueOf(2), "qqq");
        System.out.println(test02.getUrl());
        System.out.println(test02.getTitle());
        System.out.println(test02.getCreatedAt());
        System.out.println(test02.getUpdatedAt());
        System.out.println(test02.getHideFromStudents());
        System.out.println(test02.getBody());
        System.out.println("=====================================");
        System.out.println();

    }

}
