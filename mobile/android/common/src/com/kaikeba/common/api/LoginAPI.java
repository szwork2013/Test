package com.kaikeba.common.api;

import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.HttpUrlUtil;

/**
 * Created by baige on 14-7-24.
 */
public class LoginAPI extends API {
    /**
     * 登录
     *
     * @return
     * @throws com.kaikeba.common.exception.DibitsExceptionC
     */
    @Deprecated
    public final static User login(String email, String password) throws DibitsExceptionC {
        String url = HttpUrlUtil.LOGIN;//"https://api.kaikeba.com/v1/user/login";
        User post_user = new User(email, password);
        String json = JsonEngine.generateJson(post_user);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = DibitsHttpClient.doNewPost(url, json);
        System.out.println("response body: ");
        System.out.println(responseJson);

        User responseUser = (User) JsonEngine.parseJson(responseJson, User.class);
        API.getAPI().writeUserInfo2SP(responseUser, password);
        return responseUser;
    }

}
