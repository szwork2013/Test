package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.KeyWord;
import com.kaikeba.common.entity.SearchCourseItem;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.HttpUrlUtil;

import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * Created by sjyin on 14-9-18.
 */
public class SearchAPI {

    public static ArrayList<SearchCourseItem> getSearchCourse(KeyWord keyWord) throws DibitsExceptionC {
        String url = HttpUrlUtil.SEARCH_URL;
        String json = JsonEngine.generateJson(keyWord);
        String responseJson = DibitsHttpClient.doNewPost(url, json);
        Type type = new TypeToken<ArrayList<SearchCourseItem>>() {
        }.getType();
        ArrayList<SearchCourseItem> searchCourses = (ArrayList<SearchCourseItem>) JsonEngine.parseJson(responseJson, type);
        return searchCourses;
    }
}
