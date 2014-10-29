package com.kaikeba.common.api;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.R;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.*;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.common.util.ImgLoaderUtil;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;


public class UsersAPI extends API {
    /**
     * 创建用户，检查用户名或者密码是否重复
     *
     * @param nickname
     * @param
     * @param email
     * @return
     * @throws DibitsExceptionC
     */
    public final static CheckNameEmail4Repet check4Repet(String nickname, String email) throws DibitsExceptionC {
        String url = HttpUrlUtil.CHECK; //"https://api.kaikeba.com/v1/user/register/check";
        System.out.println("POST: " + url);
        CheckNameEmail4Repet user = new CheckNameEmail4Repet(nickname, email);
        String json = JsonEngine.generateJson(user);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = DibitsHttpClient.doNewPost(url, json);
        System.out.println("response body: ");
        System.out.println(responseJson);
        CheckNameEmail4Repet response = (CheckNameEmail4Repet) JsonEngine.parseJson(responseJson, CheckNameEmail4Repet.class);
        if (response.getEmail().equals("1")) {
            throw new DibitsExceptionC("Email error");
        }
        if (response.getNickname().equals("1")) {
            throw new DibitsExceptionC("UserName error");
        }
        return response;
    }

    /**
     * 注册用户，封装好的API，连同头像一起上传了
     *
     * @param username
     * @param email
     * @param password
     * @param avatarFile
     * @return
     * @throws DibitsExceptionC
     * @throws java.io.IOException
     */
    public final static User signupUser(String username, String email, String password, String confirmed_at, String from, File avatarFile) throws DibitsExceptionC, IOException {
        User user = createUser(username, email, password, confirmed_at, from);
        user.setUserName(username);
        user.setEmail(email);
        user.setPassword(password);
        User avatarUser = null;
        if (user.getId() != null) {
            avatarUser = editUser(user.getId().toString(), null, avatarFile);
        }
        user.setAvatarURL(avatarUser.getAvatarUrl());
        API.getAPI().writeUserInfo2SP(user, user.getPassword());
        return user;
    }

    /**
     * 创建用户，但没有头像，需要调用{@link #editUser}。建议直接使用{@link #signupUser}！
     *
     * @param username
     * @param confirmed_at
     * @param email
     * @param password
     * @return
     * @throws DibitsExceptionC
     */
    public final static User createUser(String username, String email, String password, String confirmed_at, String from) throws DibitsExceptionC {
        String url = HttpUrlUtil.REGISTER;//"https://api.kaikeba.com/v1/user/register";
        System.out.println("POST: " + url);
        User4Request.User user = new User4Request.User(username, email, password, confirmed_at, from);
        String json = JsonEngine.generateJson(user);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = DibitsHttpClient.doNewPost(url, json);
        System.out.println("response body: ");
        System.out.println(responseJson);
        ErrorInfo error = (ErrorInfo) JsonEngine.parseJson(responseJson, ErrorInfo.class);
        if (error != null && error.getError() != null) {
            if (error.getError().getEmail() != null) {
                throw new DibitsExceptionC("Email error");
            }
            if (error.getError().getUsername() != null) {
                throw new DibitsExceptionC("UserName error");
            }
        }
        RegisterResponse response = (RegisterResponse) JsonEngine.parseJson(responseJson, RegisterResponse.class);
        User responseUser = new User();
        if (response != null) {
            responseUser.setId(response.getId());
        }
        return responseUser;
    }

    /**
     * 修改用户信息，暂时只能修改用户名、昵称、头像
     *
     * @param userID
     * @param nickName
     * @param avatarFile
     * @return
     * @throws DibitsExceptionC
     * @throws java.io.IOException
     */
    public final static User editUser(String userID, String nickName, File avatarFile) throws DibitsExceptionC, IOException {
        String url = buildUserURL(userID);
        System.out.println("PUT: " + url);

        //设置服务器上保存文件的目录和文件名，如果服务器上同目录下已经有同名文件会被自动覆盖的。
        String filePath = "/user-avatar/" + userID + "-" + System.currentTimeMillis();
        String upURL;
        if (avatarFile == null) {
//            throw new DibitsExceptionC(DEC.Syntax.USER_EMAIL, "必须提供用户头像，请检查用户头像");
            BitmapDrawable bd = (BitmapDrawable) ContextUtil.getContext().getResources().getDrawable(R.drawable.avatar);
            Bitmap bm = bd.getBitmap();

            try {
                avatarFile = ImgLoaderUtil.writePic2SDCard(bm, "/userTempAvatar.png");
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        try {
            upURL = up2Upyun(filePath, avatarFile);
        } catch (Exception e) {
            throw new DibitsExceptionC(DEC.Syntax.USER_AVATAR, "头像上传失败，请重试");
        }
        // TODO 使用封装好的处理器
        User4Request user4Request = new User4Request(nickName, upURL);
        String json = JsonEngine.generateJson(user4Request);
        System.out.println("request body: ");
        System.out.println(json);
        String responseJson = DibitsHttpClient.doPut4Token(url, json,
                ConfigLoader.getLoader().getCanvas().getAccessToken());
        System.out.println("response body: ");
        System.out.println(responseJson);
        User responseUser = (User) JsonEngine.parseJson(responseJson, User.class);

        adaptPhotoURL(responseUser);
        return responseUser;
    }

    /**
     * OAuth登录时用来将code兑换成accessToken
     *
     * @param code
     * @return
     * @throws DibitsExceptionC
     * @throws org.json.JSONException
     */
    public final static HashMap<String, String> exchangeToken(String code) throws DibitsExceptionC, JSONException {
        HashMap<String, String> map = new HashMap<String, String>();
        String url = buildExchangeTokenURL(code);
        System.out.println("POST: " + url);
        String json = DibitsHttpClient.doPost(url, (String) null);
        JSONObject jsonObject = new JSONObject(json);
        map.put(JS_TOKEN, jsonObject.getString(JS_TOKEN));
        jsonObject = jsonObject.getJSONObject(JS_USER);
        map.put(JS_USER_ID, jsonObject.getString(JS_USER_ID));
        map.put(JS_USER_NAME, jsonObject.getString(JS_USER_NAME));

        return map;
    }

    /**
     * 获取用户profile，提供用户的accessToken能获取更多信息
     *
     * @param userID
     * @return
     * @throws DibitsExceptionC
     */
    public final static User getUserProfile(String userID) throws DibitsExceptionC {
        String url = buildUserProfileURL(userID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet(url);
        User user = (User) JsonEngine.parseJson(json, User.class);

        adaptPhotoURL(user);
        return user;
    }

    /**
     * 获取用户信息，提供用户的accessToken能获取更多信息
     *
     * @param userID
     * @return
     * @throws DibitsExceptionC
     */
    public final static User getUserInfo(String userID) throws DibitsExceptionC {
        String url = buildUserProfileURL(userID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet(url);
        User user = (User) JsonEngine.parseJson(json, User.class);

        adaptPhotoURL(user);
        return user;
    }

    //=======================↓↓ build URL ↓↓=======================

    private final static String buildUser4AccountURL(String accountID) {
        StringBuilder url = new StringBuilder();
        url.append(V4Host).append(SLASH_REGIST);//.append(SLASH_SIGN_UP)
        return url.toString();
    }

    private final static String buildUserURL(String userID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_USERS).append(SLASH).append(userID);
        return url.toString();
    }

    private final static String buildExchangeTokenURL(String code) {
        StringBuilder url = new StringBuilder();
        url.append(ConfigLoader.getLoader().getCanvas().getExchangeURL())
                .append(code);
        return url.toString();
    }

    private final static String buildUserProfileURL(String userID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_USERS).append(SLASH).append(userID).append(SLASH_PROFILE);
        return url.toString();
    }


}
