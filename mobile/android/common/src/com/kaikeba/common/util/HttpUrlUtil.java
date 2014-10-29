package com.kaikeba.common.util;

import android.content.pm.PackageManager;
import com.kaikeba.ContextUtil;

/**
 * Created by mjliu on 14-9-17.
 */
public class HttpUrlUtil {
    private static final String DEVELOPMENT_HTTP_HEAD = "https://api";
    private static String HTTP_HEAD = DEVELOPMENT_HTTP_HEAD;
    private static final String TEST_HTTP_HEAD = "http://api-stg";
    private static final String VERSION = "v1";
    //    public static final String SEARCH_URL = getHttpHeader() + ".kaikeba.com/" + VERSION + "/courses/search";
    public static final String SEARCH_URL = "https://api.kaikeba.com/v1/courses/search";
    public static String COLLECTIONS = getHttpHeader() + ".kaikeba.com/" + VERSION + "/collections/";
    public static String COLLECTION_DELETE = getHttpHeader() + ".kaikeba.com/" + VERSION + "/collections/delete";
    public static String ENROLL_COURSES = getHttpHeader() + ".kaikeba.com/" + VERSION + "/userapply/register/course/";
    public static String LOGIN = getHttpHeader() + ".kaikeba.com/" + VERSION + "/user/login";
    public static String CHECK = getHttpHeader() + ".kaikeba.com/" + VERSION + "/user/register/check";
    public static String REGISTER = getHttpHeader() + ".kaikeba.com/" + VERSION + "/user/register";
    public static String PLAY_RECORDS = getHttpHeader() + ".kaikeba.com/" + VERSION + "/play_records";
    public static String CPA = getHttpHeader() + ".kaikeba.com/" + VERSION + "/cpa";
    public static String PUSH = getHttpHeader() + ".kaikeba.com/" + VERSION + "/push";
    public static String ALL_COLLECTIONS = getHttpHeader() + ".kaikeba.com/" + VERSION + "/collections/user";
    public static String COURSE_BASIC = getHttpHeader() + ".kaikeba.com/" + VERSION + "/courses/basic";
    public static String INSTRUCTIVE_COURSES = getHttpHeader() + ".kaikeba.com/" + VERSION + "/instructive_courses";
    public static String MY_MICRO_SPECIALTIES = getHttpHeader() + ".kaikeba.com/" + VERSION + "/micro_specialties/user";
    public static String OPEN_COURSES = getHttpHeader() + ".kaikeba.com/" + VERSION + "/open_courses";
//    public static String MY_CERTIFICATE = getHttpHeader() + ".kaikeba.com/" + VERSION + "/certificate";
    public static String MY_CERTIFICATE = "http://api-stg.kaikeba.com/v1/certificate";
    public static String CATEGORY = getHttpHeader() + ".kaikeba.com/" + VERSION + "/category";
    public static String SPECIALTY = getHttpHeader() + ".kaikeba.com/" + VERSION + "/specialty";
    public static String DYNAMIC = getHttpHeader() + ".kaikeba.com/" + VERSION + "/userapply/dynamic";
    public static String COURSES = getHttpHeader() + ".kaikeba.com/" + VERSION + "/courses/";
    public static String EVALUATION = getHttpHeader() + ".kaikeba.com/" + VERSION + "/evaluation/courseid/";
    public static String MICRO_JOIN = getHttpHeader() + ".kaikeba.com/" + VERSION + "/micro_specialties/join";
    public static String MODIFY = getHttpHeader() + ".kaikeba.com/" + VERSION + "/user/modify";

    private static String getHttpHeader() {
        /*try {
            if (PackageSignManager.isReleaseSign(ContextUtil.getContext())) {
                HTTP_HEAD = TEST_HTTP_HEAD;
            } else {
                HTTP_HEAD = DEVELOPMENT_HTTP_HEAD;
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }*/
        return HTTP_HEAD;
    }
}
