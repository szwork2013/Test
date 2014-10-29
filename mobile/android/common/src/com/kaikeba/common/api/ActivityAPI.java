package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.UserActivity;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class ActivityAPI extends API {

    /**
     * 获取全部活动
     *
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<UserActivity> getAllActivity() throws DibitsExceptionC {
        String url = buildAllActivityURL();
        String json = DibitsHttpClient.doGet4Token(url, API.getAPI().getUserObject().getAccessToken());
        Type type = new TypeToken<ArrayList<UserActivity>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<UserActivity> allActivity = (ArrayList<UserActivity>) JsonEngine.parseJson(json, type);
        return allActivity;
    }

    private static String buildAllActivityURL() {
        return HOST + USERS + SELF + ACTIVITY_STREAM + PAGINATION;
    }
}
