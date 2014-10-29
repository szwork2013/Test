package com.kaikeba.mitv.utils;

/**
 * Created by mjliu on 14-8-14.
 */
public class UrlManager {

    private static UrlManager instance;
    private final String COURSES_URL = "https://api.kaikeba.com/v1/courses/basic";     //全部课程
    private final String COMPILE_RECOMMEND = "https://api.kaikeba.com/v1/tv/compile_recommend";//相关推荐
    private final String HOT_RECOMMEND = "https://api.kaikeba.com/v1/tv/hot_recommend"; //热门推荐
    private final String VIWEPAGER = "https://api.kaikeba.com/v1/tv/viwepager";//轮播图
    private final String CATEGORYURL = "https://api.kaikeba.com/v1/category";
    private String COURSES_INFO = "https://api.kaikeba.com/v1/courses/";
    private String GUESS_LIKE = "https://api.kaikeba.com/v1/tv/guess_like/";//猜你喜欢

    private UrlManager() {

    }

    public static UrlManager getInstance() {
        if (instance == null) {
            instance = new UrlManager();
        }
        return instance;
    }

    public String getCOURSES_URL() {
        return COURSES_URL;
    }

    public String getCOMPILE_RECOMMEND() {
        return COMPILE_RECOMMEND;
    }

    public String getGUESS_LIKE() {
        return GUESS_LIKE;
    }

    public String getHOT_RECOMMEND() {
        return HOT_RECOMMEND;
    }

    public String getVIWEPAGER() {
        return VIWEPAGER;
    }

    public String getCATEGORYURL() {
        return CATEGORYURL;
    }

    public String getCOURSES_INFO() {
        return COURSES_INFO;
    }
}
