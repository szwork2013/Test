package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.entity.Discussion;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class DiscusstionAPI extends API {

    /**
     * 获取全部讨论
     *
     * @param courseId
     * @return
     */
    public static ArrayList<Announcement> getAllDiscussion(String courseId) {
        // TODO Auto-generated method stub
        String url = buildDiscussionURL(courseId);
        String json;
        try {
            json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return null;
        }
        Type type = new TypeToken<ArrayList<Discussion>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Announcement> announcementsArray = (ArrayList<Announcement>) JsonEngine.parseJson(json, type);
        return announcementsArray;
    }

    public static String replyDiscussion(String courseId, String topicId, long entryId, String msg, String flag) {
        String url = null;
        if (flag.equals("entry")) {
            url = buildEntryURL(courseId, topicId);
        } else {
            url = buildReplyURL(courseId, topicId, entryId);
        }
        User user = API.getAPI().getUserObject();
        JSONObject obj = new JSONObject();
        try {
            obj.put("message", msg);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        try {
            String responseJson = DibitsHttpClient.doPost4Token(url, obj.toString(), user.getAccessToken());
            return responseJson;
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    //=======================↓↓ build URL ↓↓=======================


    private static String buildDiscussionURL(String courseId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(DISCUSSION_TOPICS);
        return url.toString();
    }

    private static String buildReplyURL(String courseId, String topicId, long entryId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(DISCUSSION_TOPICS).append(SLASH).append(topicId).append(SLASH_ENTRIES)
                .append(SLASH).append(entryId)
                .append(SLASH_REPLIES);
        return url.toString();
    }

    private static String buildEntryURL(String courseId, String topicId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(DISCUSSION_TOPICS).append(SLASH).append(topicId).append(SLASH_ENTRIES);
        return url.toString();
    }

}
