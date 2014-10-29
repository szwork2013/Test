package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.AnnouncementReply;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

import java.lang.reflect.Type;

public class AnnceReplyAPI extends API {

    /**
     * 获取课程全部通告
     *
     * @param courseId
     * @return
     */
    public static AnnouncementReply getAllAnnceReply(String courseId, String topicId) {
        // TODO Auto-generated method stub
        String url = buildAnnceReplyURL(courseId, topicId);
        String json;
        try {
            json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return null;
        }
        Type type = new TypeToken<AnnouncementReply>() {
        }.getType();
        AnnouncementReply announcement = (AnnouncementReply) JsonEngine.parseJson(json, type);
        return announcement;
    }


    //=======================↓↓ build URL ↓↓=======================

    private static String buildAnnceReplyURL(String courseId, String topicId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(DISCUSSION_TOPICS).append(SLASH).append(topicId).append(SLASH_VIEW);
        return url.toString();
    }
}
