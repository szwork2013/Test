package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.CoursesUser;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Type;
import java.net.URLEncoder;
import java.util.ArrayList;

public class CourseUsersAPI extends API {

    public static String tempToken = "sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I";

    /**
     * 获取课程全部人员
     *
     * @param courseId
     * @return
     */
    public static ArrayList<CoursesUser> getAllCourseUsers(String courseId) {
        // TODO Auto-generated method stub
        String url = buildAllUsersURL(courseId);
        String json;
        try {
//			json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
            json = DibitsHttpClient.doGet4Token(url, tempToken);
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return new ArrayList<CoursesUser>();
        }
        Type type = new TypeToken<ArrayList<CoursesUser>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<CoursesUser> usersArray = (ArrayList<CoursesUser>) JsonEngine.parseJson(json, type);
        return usersArray;
    }

    /**
     * 获取课程讲师
     *
     * @param courseId
     * @return
     */
    public static ArrayList<CoursesUser> getCourseStructors(String courseId) {
        // TODO Auto-generated method stub
        String url = buildCourseStructorURL(courseId);
        String json;
        try {
//			json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
            json = DibitsHttpClient.doGet4Token(url, tempToken);
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return new ArrayList<CoursesUser>();
        }
        Type type = new TypeToken<ArrayList<CoursesUser>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<CoursesUser> usersArray = (ArrayList<CoursesUser>) JsonEngine.parseJson(json, type);
        return usersArray;
    }

    /**
     * 获取课程学生
     *
     * @param courseId
     * @return
     */
    public static ArrayList<CoursesUser> getCourseStudents(String courseId) {
        // TODO Auto-generated method stub
        String url = buildCourseStudentURL(courseId);
        String json;
        try {
//			json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
            json = DibitsHttpClient.doGet4Token(url, tempToken);
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return new ArrayList<CoursesUser>();
        }
        Type type = new TypeToken<ArrayList<CoursesUser>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<CoursesUser> usersArray = (ArrayList<CoursesUser>) JsonEngine.parseJson(json, type);
        return usersArray;
    }

    /**
     * 获取课程助教
     *
     * @param courseId
     * @return
     */
    public static ArrayList<CoursesUser> getCourseTa(String courseId) {
        // TODO Auto-generated method stub
        String url = buildCourseTaURL(courseId);
        String json;
        try {
//			json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
            json = DibitsHttpClient.doGet4Token(url, tempToken);
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return new ArrayList<CoursesUser>();
        }
        Type type = new TypeToken<ArrayList<CoursesUser>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<CoursesUser> usersArray = (ArrayList<CoursesUser>) JsonEngine.parseJson(json, type);
        return usersArray;
    }

    //=======================↓↓ build URL ↓↓=======================

    //http://learn.kaikeba.com/api/v1/courses/44/users?enrollment_type=teacher&include[]=email&include[]=avatar_url&access_token=sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I
    private static String buildAllUsersURL(String courseId) {
        StringBuilder url = new StringBuilder();
        try {
            url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                    .append(USERS).append("?").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("email&").append(INCLUDE_ARRAY).append(EQUALS).append("avatar_url");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return url.toString();
    }

    private static String buildCourseStructorURL(String courseId) {
        StringBuilder url = new StringBuilder();
        try {
            url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                    .append(USERS).append("?").append(ENROLLMENT_TYPE).append(EQUALS).append("teacher")
                    .append("&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("email&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("avatar_url");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return url.toString();
    }

    private static String buildCourseTaURL(String courseId) {
        StringBuilder url = new StringBuilder();
        try {
            url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                    .append(USERS).append("?").append(ENROLLMENT_TYPE).append(EQUALS).append("ta")
                    .append("&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("email&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("avatar_url");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return url.toString();
    }

    private static String buildCourseStudentURL(String courseId) {
        StringBuilder url = new StringBuilder();
        try {
            url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                    .append(USERS).append("?").append(ENROLLMENT_TYPE).append(EQUALS).append("student")
                    .append("&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("email&").append(INCLUDE_ARRAY).append(URLEncoder.encode("[]", "utf-8")).append(EQUALS).append("avatar_url");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return url.toString();
    }
}
