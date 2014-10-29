package com.kaikeba.common.entity;

/**
 * Created by baige on 14-8-12.
 */
public class CheckNameEmail4Repet {
    private String nickname;
    private String email;

    public CheckNameEmail4Repet() {
    }

    public CheckNameEmail4Repet(String nickname, String email) {
        this.nickname = nickname;
        this.email = email;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
