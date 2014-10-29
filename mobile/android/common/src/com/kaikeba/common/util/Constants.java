package com.kaikeba.common.util;

public class Constants {

    public static final int NO_NET = 0;
    public static final int WIFI_STATE_CONNECTED = 1;
    public static final int MOBILE_STATE_CONNECTED = 2;
    public static final int COURSE_TIME_OUT = -1;
    public static final int THERE_IS_NONET = -2;
    public static final int COURSE_JOIN_SUCCESS = 0;
    public static final int LOGIN_TIME_OUT = 401;
    public static final int GET_DATA_SUCCESS = 555;
    public static final int COLLECT_EEROR = 300;
    public static final int COVER_WIDTH = 450;
    public static final int COVER_HEIGHT = 232;
    public static final String ACTIVITY_NAME_KEY = "activity_name";
    public static final int RESULT_CODE = 101;
    public static final int FROM_DANPINYE = 102;
    /**
     * 导学课TabHost中展现的Fragement标识
     */
    public static final int BASE_COURSE = 1;
    public static int current_position = BASE_COURSE;
    public static final int OUT_LINE_COURSE = 2;
    public static final int LOOK_REMARK = 3;
    public static final int RECOMMEND_COURSE = 4;
    public static boolean NET_IS_SUCCESS = false;
    public static boolean nowifi_doload = true;
    public static boolean nowifi_doplay = true;
    public static boolean NOWIFI_DOLOAD = false;
    public static int CURRENT_NET_STATE = 0;
    public static boolean NET_IS_CHANGED = false;
    public static int ACTIVITY_VIEW = 0;

    //	public static String ACTION_IS_THERE_NET= "com.kaikeba.isThereNet";
    public static boolean isFirst = false;
    public static int which = 0;
    public static int VIEW_INTO = 0;
    public static float window_width;
    public static int goWhich = 0;
    public static boolean IS_DISSCUSSTION = false;
    public static String PROMO_INFO = "PromoInfo";
    public static String ALL_COURSES = "AllCourses";
    public static String BADGE = "Badge";
    public static String CATEGORY = "Category";
    public static String MY_COURSE = "MyCourse";
    public static String MODULE = "Module";
    public static String MODULE_ITEM = "ModuleItme";
    public static String PAGE = "Page";
    public static String ACTION_IS_REFRESH = "com.kaikeba.isrefresh";
    public static String NOTICE_NET_3G = "com.kaikeba.netis3g";
    public static boolean IS_EDIT = false;
    public static boolean IS_ALL_DOWNLOAD;
    public static boolean IS_ALL_CHECK = false;
    public static String PATH = "mnt/sdcard/kaikeba/";
    public static boolean videoUrlIsNull = false;
    public static int INFO_TAB;
    public static int INFO_ONE = 0;
    public static int INFO_TWO = 1;
    public static int INFO_THREE = 2;
    public static String ModuleVideo = "ModuleVideo";
    public static int DOWNLOAD_VIEW = 0;
    public static int LOGIN_FROM = 0;
    public static int FROM_MAIN = 1;
    public static int FROM_PAY = 2;
    public static int FROM_SETTING = 3;
    public static int FROM_OPENCOURSE = 4;
    public static int FROM_ALLCOURSE = 5;
    public static int FROM_GUIDECOURSE = 6;
    public static int FROM_MYMICRO_COURSE = 7;
    public static int FROM_USER_CENTET = 8;
    public static int FROM_DYNAMIC = 9;
    public static boolean isFreshMyCourse = false;
        public static int SCREEN_WIDTH = 1080;
//
    public static int SCREEN_HEIGHT = 1776;
    public static float SCREEN_DENSITY = 3.0f;
    public static float SCALE_DENSITY = 3.0f;
    /**
     * 课程中ScrollView 是否滑动到最右边
     */
    public static boolean SCROLLRIGHT_IS_END = false;
    /**
     * 课程中ScrollView 是否滑动到最左边
     */
    public static boolean SCROLLLEFT_IS_END = false;
    public static boolean FULL_SCREEN_NO_CLICK = false;
    public static String HTTP_GET = "GET";
    public static String GRAPH_SIMPLE_USER_INFO = "get_simple_userinfo";
    public static int FROM_WHERE = 0;
    public static boolean search_is_click = false;

    //重力感应标识
    public static int GRIVITY_INTERACTION = 1;

    public static boolean isFromDynamicTop = false;

    public static boolean PLAY_VIDEO_FROM_LOCAL = false;
    public static boolean FULL_SCREEN_ONLY = false;
}
