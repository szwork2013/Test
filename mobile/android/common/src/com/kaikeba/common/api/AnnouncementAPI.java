package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class AnnouncementAPI extends API {

    /**
     * 获取课程全部通告
     *
     * @param courseId
     * @return
     */
    public static ArrayList<Announcement> getAllAnnouncement(String courseId) {
        // TODO Auto-generated method stub
        String url = buildAnnouncementURL(courseId);
        String json;
        try {
            json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
        } catch (DibitsExceptionC e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return null;
        }
        Type type = new TypeToken<ArrayList<Announcement>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Announcement> announcementsArray = (ArrayList<Announcement>) JsonEngine.parseJson(json, type);
        return announcementsArray;
    }


    //=======================↓↓ build URL ↓↓=======================

    private static String buildAnnouncementURL(String courseId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(DISCUSSION_TOPICS).append("?").append(ONLY_ANNOUNCEMENTS).append(EQUALS).append("true");
        return url.toString();
    }


    /**
     * @param args
     */
    public static void main(String[] args) {
        // TODO Auto-generated method stub
//		ArrayList<Announcement> list = getAllAnnouncement(44);
//		System.out.println("");
    }

}
