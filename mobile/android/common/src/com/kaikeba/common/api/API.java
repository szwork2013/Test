package com.kaikeba.common.api;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.download.AvailableSpace;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.upyun.UpYun;
import com.kaikeba.common.util.ConfigLoader;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Field;

public class API {

    public final static String HOST = ConfigLoader.getLoader().getCanvas().getApiHost();
    public final static String DUMMY_HOST = ConfigLoader.getLoader().getCanvas().getDummyApiHost();
    public final static String V4Host = ConfigLoader.getLoader().getCanvas().getApiV4Host();
    public final static String SLASH = "/";
    public final static String EXT_JSON = ".json";
    public final static String TOKEN = "accessToken";
    public final static String TIME_ZONE = "Beijing";
    public final static String LOCALE = "zh";
    public final static Integer SEND_CONFIR = 1;

    public static final String SLASH_LOGIN_OAUTH = "/login/oauth2/token";
    public static final String SLASH_USERS = "/users";
    public static final String SLASH_SIGN_UP = "/sign_up";
    public static final String SLASH_PROFILE = "/profile";
    public static final String SLASH_MODULES = "/modules";
    public static final String SLASH_ITEMS = "/items";
    public static final String SLASH_PAGES = "/pages";
    public static final String SLASH_ACCOUNTS = "/accounts";

    public static final String SLASH_REGIST = "/users";
    public static final String SLASH_LOGINS = "/logins";
    public static final String SLASH_COURSES = "/courses";
    public static final String SLASH_COURSE = "/course";
    public static final String SLASH_META = "/meta";
    public static final String SLASH_INTRODUCTION = "/course-introduction-4tablet";
    public static final String SLASH_INSTRUCTOR = "/course-instructor-4tablet";
    public static final String SLASH_ENTRIES = "/entries";
    public static final String SLASH_REPLIES = "/replies";
    public static final String PAGINATION = "?per_page=" + ConfigLoader.getLoader().getCanvas().getPerPage();

    public static final String JS_TOKEN = "access_token";
    public static final String JS_USER = "user";
    public static final String JS_USER_ID = "id";
    public static final String JS_USER_NAME = "name";

    public static final String DISCUSSION_TOPICS = "/discussion_topics";
    public static final String ONLY_ANNOUNCEMENTS = "only_announcements";
    public static final String USERS = "/users";
    public static final String ENROLLMENT_TYPE = "enrollment_type";
    public static final String INCLUDE_ARRAY = "include";
    public static final String EQUALS = "=";
    public static final String SLASH_VIEW = "/view";
    public static final String SLASH_QUIZS = "/quizzes";
    public static final String SLASH_ASSIGNMENT = "/assignments";
    public static final String SELF = "/self";
    public static final String ACTIVITY_STREAM = "/activity_stream";
    /**
     * Parse HTML
     */
    public static final String COOKIE = "cookie";
    public static final String SUMMARY_QUIZ = "summary_quiz";
    public static final String UNDER_LINE = "_";
    public static final String MESSAGE_TITLE = "titile";
    public static final String HTML_TAG_A = "a";
    public static final String HTML_TAG_SPAN = "span";
    public static final String QUIZ_ID = "quiz_id";
    public static final String QUIZ_TIME_AM = "AM";
    public static final String QUIZ_TIME_PM = "PM";
    public static final String HTML_CLASS_USER_CONTENT = "div.description.user_content";
    public static final String QUIZ_CHINESE_SURPLUS = "剩余";
    public static final String QUIZ_CHINESE_ALLOW = "允许";
    public static final String TIME_SLICE = ":";
    public static final String SURPLUS_TIME_DEFAULT = "无信息";
    public static final String SUBMIT_TIME_DEFAULT = "暂无";
    public static final String TOTAL_POINT_DEFAULT = "暂无";
    public static final String QUESTION_HOLDER = "question_holder";
    public static final String QUESTION_DIV_HEADER = "div.header";

    public static final String DIV_DISPLAY_QUESTION_POINT = "div.display_question.question.";
    public static final String QUESTION_TYPE_MULTIPLE_CHOICE_QUESTION = "multiple_choice_question";
    public static final String QUESTION_TYPE_TRUE_FALSE_QUESTION = "true_false_question";
    public static final String QUESTION_TYPE_SHORT_ANSWER_QUESTION = "short_answer_question";
    public static final String QUESTION_TYPE_FILL_IN_BLANKS_QUESTION = "fill_in_multiple_blanks_question";
    public static final String QUESTION_TYPE_MULTIPLE_ANSWER_QUESTION = "multiple_answers_question";
    public static final String QUESTION_TYPE_MULTIPLE_DROPDOWNS_QUESTION = "multiple_dropdowns_question";
    public static final String QUESTION_TYPE_MATCH_QUESTION = "matching_question";
    public static final String QUESTION_TYPE_NUMERICAL_QUESTION = "numerical_question";
    public static final String QUESTION_TYPE_ESSAY_QUESTION = "essay_question";
    public static final String QUESTION_TYPE_TEXT_ONLY_QUESTION = "text_only_question";
    public static final String HTML_CLASS_ANSWER = "answer";
    public static final String HTML_CLASS_ANSWERS = "answers";
    public static final String HTML_CLASS_TEXT = "text";
    public static final String QUESTION_TEXT_USER_CONTENT = "question_text.user_content";
    public static final String DIV_QUESTION_TEXT_USER_CONTENT = "div.question_text.user_content";
    public static final String SPILIT_TEXT = "#EditText#";

    public final static long firstTime = 1000l * 60 * 60 * 24 * 365 * 100;
    //    private final static Timestamp      START_TIME_DEFAUTL = new Timestamp(firstTime);
    public final static Integer START_INDEX_DEFAUTL = 1;
    public final static Integer COUNT_DEFAULT = 20;
    public final static Integer COUNT_MIN = 1;
    public final static Integer COUNT_MAX = 100;


    public final static String USER_ID = "userID";
    public final static String USER_TOKEN = "userToken";
    public final static String USER_NAME = "userName";
    public final static String USER_NICKNAME = "userNickName";
    public final static String USER_EMAIL = "userEmail";
    public final static String USER_AVT_URL = "userAvatarURL";
    public final static String USER_PASSWORD = "userPassWord";

    public final static String GUIDE_COURSE_ID = "guide_course_id";
    public final static String LMS_COURSE_ID = "lms_course_id";
    public final static String ENROLL_AT = "enroll_at";

    public final static String CLIENTID = "clientid";
    public final static String PUSHSTATE = "pushstate";
    public static int which = 0;
    public static int VIEW_INTO = 0;
    //第一次进入应用调用事件判断
    public static int COUNT = 0;
    private static AvailableSpace space = null;
    private static volatile API api = null;
    private User userObject = null;
    private int guideCourseId;

    public static API getAPI() {
        if (api == null) {
            synchronized (ConfigLoader.class) {
                if (api == null) {
                    api = new API();
                }
            }
        }
        return api;
    }

    public static void adaptPhotoURL(Object o) {
        try {
            Class<? extends Object> c = o.getClass();
            Field[] fields = c.getDeclaredFields();
            for (int i = 0; i < fields.length; i++) {
                Field field = fields[i];
                field.setAccessible(true);
                if (field.get(o) instanceof String) {
                    String str = (String) fields[i].get(o);
                    if (str.startsWith(ConfigLoader.getLoader().getUpyun().getUrl())) {
                        if (str.endsWith("/cover.png")) {
                            field.set(o, str + "!cc.android.phone");
                        } else if (str.endsWith("/instructor-avatar.png")) {
                            field.set(o, str + "!ia.android");
                        } else if (str.contains("/home-slider/") && !str.endsWith("!hs.android.phone")) {
//                            field.set(o, str + "!hs.android.phone");
                            field.set(o, str.substring(0, str.length() - 3) + "tablet.png");
                            System.out.println("tablet lun bo tu url :" + str.substring(0, str.length() - 1) + "tablet.png");
                        } else if (str.contains("/user-avatar/") && !str.endsWith("!sa.ipad.2")) {
                            field.set(o, str + "!sa.ipad.2");
                        }
                    }
                }
            }
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

    }

    /**
     * 涓婁紶鍒癠pyun
     *
     * @param filePath
     * @param file
     * @return
     * @throws java.io.IOException
     */
    public final static String up2Upyun(String filePath, File file) throws IOException {
        UpYun upyun = new UpYun(ConfigLoader.getLoader().getUpyun().getBucketName(),
                ConfigLoader.getLoader().getUpyun().getUserName(),
                ConfigLoader.getLoader().getUpyun().getUserPassword());

        upyun.setContentMD5(UpYun.md5(file));

        boolean result = upyun.writeFile(filePath, file, true);

        System.out.println(filePath + " 涓婁紶" + (result ? " 鎴愬姛" : " 澶辫触"));

        // 鑾峰彇涓婁紶鏂囦欢鍚庣殑淇℃伅锛堜粎鍥剧墖绌洪棿鏈夎繑鍥炴暟鎹級
        System.out.println("\r\n****** " + file.getName() + " 鐨勫浘鐗囦俊鎭?*******");
        // 鍥剧墖瀹藉害
        System.out.println("鍥剧墖瀹藉害:" + upyun.getPicWidth());
        // 鍥剧墖楂樺害
        System.out.println("鍥剧墖楂樺害:" + upyun.getPicHeight());
        // 鍥剧墖甯ф暟
        System.out.println("鍥剧墖甯ф暟:" + upyun.getPicFrames());
        // 鍥剧墖绫诲瀷
        System.out.println("鍥剧墖绫诲瀷:" + upyun.getPicType());
        System.out.println("****************************************\r\n");
        // TODO 瑕佹敼缂╃暐鐗堟湰鍚庣紑
        String upURL = ConfigLoader.getLoader().getUpyun().getUrl() + filePath;
        System.out.println("鑻ヨ缃繃璁块棶瀵嗛挜(bac)锛屼笖缂╃暐鍥鹃棿闅旀爣蹇楃涓?!'锛屽垯鍙互閫氳繃浠ヤ笅璺緞鏉ヨ闂浘鐗囷細");
        System.out.println(upURL);
        System.out.println();

        return upURL;
    }

    public synchronized AvailableSpace getSpace() {
        if (space == null) {
            space = new AvailableSpace();
        }
        return space;
    }

    public User getUserObject() {
        return readUserInfo4SP2Object();
    }

    public void setUserObject(User userObject) {
        this.userObject = userObject;
    }

    public User readUserInfo4SP2Object() {
        SharedPreferences appPrefs = ContextUtil.getContext().getSharedPreferences("com.kaikeba.preferences", Context.MODE_PRIVATE);
        Long userID = appPrefs.getLong(API.USER_ID, 0l);
        String userAccessToken = appPrefs.getString(API.USER_TOKEN, null);
        String userName = appPrefs.getString(API.USER_NAME, null);
        String userEmail = appPrefs.getString(API.USER_EMAIL, null);
        String userAvatarURL = appPrefs.getString(API.USER_AVT_URL, null);
        String userPassWord = appPrefs.getString(API.USER_PASSWORD, null);
        if (userID != null &&
                userName != null &&
                userEmail != null &&
                userPassWord != null) {
            if (userObject == null) {
                userObject = new User();
            }
            userObject.setId(userID);
            userObject.setUserName(userName);
            userObject.setEmail(userEmail);
            userObject.setAvatarURL(userAvatarURL);
            userObject.setToken(userAccessToken);
            userObject.setPassword(userPassWord);
        } else {
            userObject = null;
        }
        return userObject;
    }


    public void writeUserInfo2SP(User user, String password) {
        userObject = user;

        SharedPreferences appPrefs = ContextUtil.getContext().getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = appPrefs.edit();
        prefsEditor.putLong(API.USER_ID, userObject.getId());
        prefsEditor.putString(API.USER_TOKEN, userObject.getToken());
        prefsEditor.putString(API.USER_NAME, userObject.getUserName());
        if (userObject.getAvatarUrl() != null) {
            prefsEditor.putString(API.USER_AVT_URL, userObject.getAvatarUrl());

        }
        prefsEditor.putString(API.USER_EMAIL, userObject.getEmail());
        if (password != null && !password.equals("")) {
            userObject.setPassword(password);
            prefsEditor.putString(API.USER_PASSWORD, password);
        }
        prefsEditor.commit();
    }

    /**
     * 判断是否已登录
     *
     * @return
     */
    public boolean alreadySignin() {
        if (getUserObject() != null) {
            return true;
        }
        return false;
    }

    /**
     * 清除用户信息
     */
    public void cleanUserInfo() {
        userObject = null;
        SharedPreferences appPrefs = ContextUtil.getContext().getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = appPrefs.edit();
        prefsEditor.remove(API.USER_ID);
        prefsEditor.remove(API.USER_TOKEN);
        prefsEditor.remove(API.USER_NAME);
        prefsEditor.remove(API.USER_EMAIL);
        prefsEditor.remove(API.USER_AVT_URL);
        prefsEditor.remove(API.USER_PASSWORD);
        prefsEditor.commit();
    }

}
