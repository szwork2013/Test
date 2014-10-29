package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Collect4Request;
import com.kaikeba.common.entity.Collection;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.HttpUrlUtil;

import java.lang.reflect.Type;

/**
 * Created by baige on 14-7-24.
 */
public class CollectionAPI extends API {
    /**
     * 添加收藏
     *
     * @return
     * @throws com.kaikeba.common.exception.DibitsExceptionC
     */
    public final static Collection addCollection(String user_id, String course_id) throws DibitsExceptionC {
        String url = HttpUrlUtil.COLLECTIONS;//"https://api.kaikeba.com/v1/collections/";
        Collect4Request collect4Request = new Collect4Request(user_id, course_id);
        String json = JsonEngine.generateJson(collect4Request);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = doPost4CollectInfo(url, json);
        System.out.println("response body: ");
        System.out.println(responseJson);

        Type courseType = new TypeToken<Collection>() {
        }.getType();
        Collection responseUser = (Collection) JsonEngine.parseJson(responseJson, courseType);

        return responseUser;
    }

    /**
     * 取消收藏
     *
     * @return
     * @throws com.kaikeba.common.exception.DibitsExceptionC
     */
    @Deprecated
    public final static Collection deleteCollection(String userId, String courseId) throws DibitsExceptionC {
        String url = HttpUrlUtil.COLLECTION_DELETE;//"https://api.kaikeba.com/v1/collections/delete";
        Collect4Request collect4Request = new Collect4Request(userId, courseId);
        String json = JsonEngine.generateJson(collect4Request);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = doPost4CollectInfo(url, json);
        System.out.println("response body: ");
        System.out.println(responseJson);

        Collection responseUser = (Collection) JsonEngine.parseJson(responseJson, Collection.class);

        return responseUser;
    }

    public static String doPost4CollectInfo(String url, String json)
            throws DibitsExceptionC {
        return DibitsHttpClient.doNewPost(url, json);
    }

}
