package com.kaikeba.common.api;


import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Badge;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.Course4My;
import com.kaikeba.common.entity.PromoInfo;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.ObjectSerializableUtil;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CoursesAPI extends API {


    private static List<Course> courseArray;
    private static List<Course> currentAllcourse;
    private static int categoryNum;

    /**
     * 获取全部课程数据
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static List<Course> getAllCourses(boolean fromCache) throws DibitsExceptionC {
        List<Course> courseArray = new ArrayList<Course>();
        String url = buildAllCoursesURL();
        System.out.println("GET: " + url);
        String json = KKBHttpClient.getInstance().requestFromURL(url, fromCache);
        Type type = new TypeToken<List<Course>>() {
        }.getType();
        courseArray = (List<Course>) JsonEngine.parseJson(json, type);
        if (courseArray != null) {
            for (Course c : courseArray) {
                adaptPhotoURL(c);
            }
        } else {
            return null;
        }
        return courseArray;
    }

    /**
     * 获取全部课程页面（首页）的轮播图数据
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<PromoInfo> getPromoInfo(boolean fromCache) throws DibitsExceptionC {
        ArrayList<PromoInfo> promoInfos = new ArrayList<PromoInfo>();
        String url = buildPromoInfoURL();
        System.out.println("GET: " + url);
        String json = KKBHttpClient.getInstance().requestFromURL(url, fromCache);
        Type type = new TypeToken<ArrayList<PromoInfo>>() {
        }.getType();
        try {
            promoInfos = (ArrayList<PromoInfo>) JsonEngine.parseJson(json, type);
            if (promoInfos != null)
                for (PromoInfo promoInfo : promoInfos) {
                    adaptPhotoURL(promoInfo);
                }
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
        return promoInfos;
    }

    /**
     * 获取我的全部课程，必须登录（拥有用户自己的accessToken），否则有异常
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Long> getMyCoursesId(boolean fromCache) throws DibitsExceptionC {
        if (API.getAPI().getUserObject().getAccessToken() == null) {
            throw new DibitsExceptionC(DEC.Business.COURSE_ID, "token is null!");
        }
        ArrayList<Long> pList = null;
        if (!Constants.NET_IS_SUCCESS) {
            try {
                pList = (ArrayList<Long>) ObjectSerializableUtil.readObject(Constants.MY_COURSE + API.getAPI().getUserObject().getId());
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        if (pList != null) {
            return pList;
        }
        String url = buildMyCoursesURL();
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet(url);
        Type type = new TypeToken<ArrayList<Course4My>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Course4My> myCourses = (ArrayList<Course4My>) JsonEngine.parseJson(json, type);
        ArrayList<Long> ids = new ArrayList<Long>();
        for (Course4My c : myCourses) {
            ids.add(c.getId());
        }
        try {
            ObjectSerializableUtil.writeObject(ids, Constants.MY_COURSE + API.getAPI().getUserObject().getId());
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return ids;
    }

    /**
     * 获取Badge
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Badge> getBadge(boolean fromCache) throws DibitsExceptionC {
        ArrayList<Badge> badges = new ArrayList<Badge>();
        String url = buildBadgeURL();
        String json = KKBHttpClient.getInstance().requestFromURL(url, fromCache);
        Type type = new TypeToken<ArrayList<Badge>>() {
        }.getType();
        try {
            badges = (ArrayList<Badge>) JsonEngine.parseJson(json, type);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
        return badges;
    }

    public final static ArrayList<String> getCourseCategory() throws DibitsExceptionC {
        ArrayList<String> pList = null;
        if (!Constants.NET_IS_SUCCESS) {
            try {
                pList = (ArrayList<String>) ObjectSerializableUtil.readObject(Constants.CATEGORY);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        if (pList != null) {
            return pList;
        }
        String url = buildCategoryURL();
        String json = DibitsHttpClient.doGet(url);
        Type type = new TypeToken<ArrayList<String>>() {
        }.getType();
        ArrayList<String> badges = (ArrayList<String>) JsonEngine.parseJson(json, type);
        try {
            ObjectSerializableUtil.writeObject(badges, Constants.CATEGORY);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return badges;
    }

    public static Map<String, List<Course>> getAllCourseWithOpenOrGuide(List<Course> allcourse) {
        Map<String, List<Course>> map = new HashMap<String, List<Course>>();
        for (Course course : allcourse) {
            if ("open".equals(course.getCourseType())) {
                if (map.get("open") != null) {
                    map.get("open").add(course);
                } else {
                    ArrayList<Course> courses = new ArrayList<Course>();
                    courses.add(course);
                    map.put("open", courses);
                }
            } else {
                if (map.get("guide") != null) {
                    map.get("guide").add(course);
                } else {
                    ArrayList<Course> courses = new ArrayList<Course>();
                    courses.add(course);
                    map.put("guide", courses);
                }
            }
        }
        return map;
    }

    public static Map<String, List<Course>> getOpenAllCourse(List<Course> allCourse,
                                                             ArrayList<String> categories) {
        Map<String, List<Course>> map = new HashMap<String, List<Course>>();
        for (String category : categories) {
            for (Course course : allCourse) {
                if (course.getCourseType().equals("open") && category.equals(course.getCourseCategory())) {
                    if (map.get(category) != null) {
                        map.get(category).add(course);
                    } else {
                        ArrayList<Course> courses = new ArrayList<Course>();
                        courses.add(course);
                        map.put(category, courses);
                    }
                }
            }
        }
        return map;
    }

    /**
     * 获取全部课程数据
     *
     * @return
     * @throws DibitsExceptionC
     */
    @SuppressWarnings("unchecked")
    public final static List<Course> getAllCourses(String json) {
        if (courseArray == null) {
            Type type = new TypeToken<List<Course>>() {
            }.getType();
            courseArray = (List<Course>) JsonEngine.parseJson(json, type);
            for (Course c : courseArray) {
                adaptPhotoURL(c);
            }
            currentAllcourse = new ArrayList<Course>();
            for (Course course : courseArray) {
                if (course.isVisible()) currentAllcourse.add(course);
            }
        }
        return currentAllcourse;
    }

    //=======================↓↓ build URL ↓↓=======================

    @SuppressWarnings("unchecked")
    public final static ArrayList<String> getCourseCategory(String json) {
        Type type = new TypeToken<ArrayList<String>>() {
        }.getType();
        ArrayList<String> badges = (ArrayList<String>) JsonEngine.parseJson(json, type);
        if (badges == null) {
            badges = new ArrayList<String>();
        }
        return badges;
    }

    public final static String buildPromoInfoURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/home-slider.json");
        return url.toString();
    }

    public final static String buildMyCoursesURL() {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES)
                .append(PAGINATION);
        return url.toString();
    }

    public final static String buildAllCoursesURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/all-courses-meta.json");
        return url.toString();
    }

    public final static String buildBadgeURL() {
        StringBuilder url = new StringBuilder();
        url.append(DUMMY_HOST).append("/badges-info.json");
        return url.toString();
    }

    public final static String buildCategoryURL() {
        return "http://www.kaikeba.com/api/v2/categories.json";
    }

    public static int getCategoryNum() {
        return categoryNum;
    }

    public static Map<String, List<Course>> getGudieAllCourse(List<Course> allCourse,
                                                              ArrayList<String> categories) {
        Map<String, List<Course>> map = new HashMap<String, List<Course>>();
        categoryNum = categories.size();
        for (String category : categories) {
            for (Course course : allCourse) {
                if (course.getCourseType().equals("guide") && category.equals(course.getCourseCategory())) {
                    if (map.get(category) != null) {
                        map.get(category).add(course);
                    } else {
                        ArrayList<Course> courses = new ArrayList<Course>();
                        courses.add(course);
                        map.put(category, courses);
                    }
                }
            }
        }
        return map;
    }

}
