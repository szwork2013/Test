package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.DibitsHttpClient;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;


public class AccountsAPI extends API {


    /**
     * 获取全部课程
     *
     * @return
     * @throws DibitsExceptionC
     */
    @Deprecated
    public final static ArrayList<Course> getAllCourses(String accountID) throws DibitsExceptionC {
        String url = buildAllCoursesURL(accountID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, ConfigLoader.getLoader().getCanvas().getPublicToken());
        Type type = new TypeToken<ArrayList<Course>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Course> allCourses = (ArrayList<Course>) JsonEngine.parseJson(json, type);
        return allCourses;
    }

    /**
     * 获取全部课程（返回HashMap，不需要accountID）
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static HashMap<Long, Course> getAllCourses() throws DibitsExceptionC {
        HashMap<Long, Course> allCourses = new HashMap<Long, Course>();
        String url = buildAllCoursesURL(ConfigLoader.getLoader().getCanvas().getOpenAccountID());
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, ConfigLoader.getLoader().getCanvas().getPublicToken());
        Type type = new TypeToken<ArrayList<Course>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Course> allCoursesArray = (ArrayList<Course>) JsonEngine.parseJson(json, type);
        for (Course course : allCoursesArray) {
            allCourses.put(course.getId(), course);
        }
        return allCourses;
    }


//    /**
//     * 获取全部课程 并填充额外元数据
//     * @param accountID
//     * @return
//     * @throws DibitsExceptionC
//     */
//    @Deprecated
//    public final static ArrayList<Course> getAllCoursesWithMeta(String accountID) throws DibitsExceptionC {
//        ArrayList<Course> allCourses = getAllCourses(accountID);
//        ArrayList<Course.Meta> allMeta = CoursesAPI.getAllCoursesMeta();
//        for (Course course : allCourses) {
//            for (Course.Meta meta : allMeta) {
//                if (meta.getId().equals(course.getId())) {
//                    course.setMeta(meta);
//                }
//            }
//        }
//        return allCourses;
//    }

//    /**
//     * 获取获取全部课程 并填充额外元数据(返回HashMap，不需要accountID)
//     * @return
//     * @throws DibitsExceptionC
//     */
//    public final static HashMap<Long, Course> getAllCoursesWithMeta() throws DibitsExceptionC {
//        HashMap<Long, Course> allCourses = getAllCourses();
//        System.out.println(allCourses.size());
//        HashMap<Long, Course.Meta> allMeta = CoursesAPI.getAllCoursesMetaMap();
//        Long courseID;
//        ArrayList<Long> shouldDeltet = new ArrayList<Long>();
//        for (Course course : allCourses.values()) {
//            courseID = course.getId();
//            Course.Meta meta = allMeta.get(courseID);
//            if (meta != null) {
//                adaptPhotoURL(meta);
//                course.setMeta(meta);
//            } else {
//                shouldDeltet.add(courseID);
//            }
//        }
//        for (Long id : shouldDeltet) {
//            allCourses.remove(id);
//        }
//        
//        return allCourses;
//    }

//    /**
//     * 获取用户ID，必须在用户登录后才能调用（必须有用户的accessToken）
//     * @return
//     * @throws DibitsExceptionC
//     * @throws JSONException
//     */
//    public final static String getUserID() throws DibitsExceptionC, JSONException {
//        String url = buildloginsURL(ConfigLoader.getLoader().getCanvas().getRootAccountID());
//        String json = DibitsHttpClient.doGet(url);
//        JSONArray jsonArray = new JSONArray(json);
//        JSONObject object = (JSONObject) jsonArray.get(0);
//        Integer userID = (Integer) object.get("user_id");
//        
//        return userID.toString();
//    }

    //=======================↓↓ build URL ↓↓=======================

    private final static String buildAllCoursesURL(String accountID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_ACCOUNTS)
                .append(SLASH).append(accountID).append(SLASH_COURSES)
                .append(PAGINATION);
//            .append("?access_token=ZsKbfSzm9dtNKi6B0zUkv7JignvsJCGyTNssszMUUZcOAPbvA9r82BwwO4WY3jjz");
        return url.toString();
    }

//    private final static String buildloginsURL(String accountID) {
//        StringBuilder url = new StringBuilder();
//        url.append(HOST).append(SLASH_ACCOUNTS)
//            .append(SLASH).append(accountID).append(SLASH_LOGINS);
////            .append("?access_token=ZsKbfSzm9dtNKi6B0zUkv7JignvsJCGyTNssszMUUZcOAPbvA9r82BwwO4WY3jjz");
//        return url.toString();
//    }


    public static void main(String[] args) throws DibitsExceptionC {

//        ArrayList<Course> allCourses = AccountsAPI.getAllCoursesWithMeta(ConfigLoader.getLoader().getCanvas().getOpenAccountID());
//        for (Course course : allCourses) {
//            System.out.println("---------------------------");
//            System.out.println(course.getAccoundId());
//            System.out.println(course.getId());
//            System.out.println(course.getSisCourseId());
//            System.out.println(course.getCourseCode());
//            System.out.println(course.getName());
//            System.out.println(course.getStartAt());
//            System.out.println(course.getEndAt());
//            System.out.println("Meta:");
//            System.out.println("\t" + course.getMeta().getCoverImage());
//            System.out.println("\t" + course.getMeta().getPrice());
//            System.out.println("\t" + course.getMeta().getSchoolName());
//            System.out.println("\t" + course.getMeta().getInstructorName());
//            System.out.println("\t" + course.getMeta().getInstructorTitle());
//            System.out.println("\t" + course.getMeta().getInstructorAvatar());
//        }

//        int count = 0;
//        HashMap<Long, Course> allCourses2 = getAllCoursesWithMeta();
//        for (Course course : allCourses2.values()) {
//            count++;
//            System.out.println(count + ": ---------------------------");
////            System.out.println(course.getAccoundId());
//            System.out.println(course.getId());
////            System.out.println(course.getSisCourseId());
////            System.out.println(course.getCourseCode());
////            System.out.println(course.getName());
////            System.out.println(course.getStartAt());
////            System.out.println(course.getEndAt());
////            System.out.println("Meta:");
////            System.out.println("\t" + course.getMeta().getCoverImage());
////            System.out.println("\t" + course.getMeta().getPrice());
////            System.out.println("\t" + course.getMeta().getSchoolName());
////            System.out.println("\t" + course.getMeta().getInstructorName());
////            System.out.println("\t" + course.getMeta().getInstructorTitle());
////            System.out.println("\t" + course.getMeta().getInstructorAvatar());
//        }
//        
//        System.out.println("Total: " + count);
    }

}
