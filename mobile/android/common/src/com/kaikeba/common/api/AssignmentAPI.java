package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Assignment;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class AssignmentAPI extends API {

    /**
     * 获取课程全部作业
     *
     * @param courseId
     * @return
     */
    public static ArrayList<Assignment> getAllAssignment(String courseId) {
        // TODO Auto-generated method stub
        String url = buildAssignmentURL(courseId);
        String json;
        try {
            json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
        } catch (DibitsExceptionC e) {
            e.printStackTrace();
            return null;
        }
        Type type = new TypeToken<ArrayList<Assignment>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Assignment> assignmentList = (ArrayList<Assignment>) JsonEngine.parseJson(json, type);
        return assignmentList;
    }

    //=======================↓↓ build URL ↓↓=======================


    //http://learn.kaikeba.com/api/v1/courses/49/assignments

    private static String buildAssignmentURL(String courseId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(SLASH_ASSIGNMENT);
        return url.toString();
    }
}
