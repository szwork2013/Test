package com.kaikeba.common.storage;

/**
 * Created by caojing on 14-2-21.
 */
public class UserInfo {
    private static UserInfo mInstance = null;

    public String username = "";
    public String password = "";

    protected UserInfo() {

    }

    public static UserInfo getInstance() {
        if (mInstance == null) {
            mInstance = new UserInfo();
        }
        return mInstance;
    }

}
