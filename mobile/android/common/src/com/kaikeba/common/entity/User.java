package com.kaikeba.common.entity;


import java.io.Serializable;

public class User implements Serializable {

    //    private Long    id;
    private String name;
    private String short_name;
    private String sortable_name;
    private String time_zone;
    private String login_id;
    private String locale;
    private String cookie;

    private String email;
    private String password;
    private String token;
    private Long id;
    private String username;
    private String avatar_url;
    private String accessToken;

    public User(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public User(String token, Long id, String username, String avatar_url) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.avatar_url = avatar_url;
    }


    public User() {
    }

    /**
     * @return the email
     */
    public String getEmail() {
        return email;
    }

    /**
     * @param email the email to set
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * @param avatarURL the avatar_url to set
     */
    public void setAvatarURL(String avatarURL) {
        this.avatar_url = avatarURL;
    }

    /**
     * @return the avatar_url
     */
    public String getAvatarUrl() {
        return avatar_url;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getUserName() {
        return username;
    }

    public void setUserName(String username) {
        this.username = username;
    }

    public String getCookie() {
        return cookie;
    }

    public void setCookie(String cookie) {
        this.cookie = cookie;
    }

    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the short_name
     */
    public String getShortName() {
        return short_name;
    }

    /**
     * @param shortName the short_name to set
     */
    public void setShortName(String shortName) {
        this.short_name = shortName;
    }

    /**
     * @return the sortable_name
     */
    public String getSortableName() {
        return sortable_name;
    }

    /**
     * @param sortableName the sortable_name to set
     */
    public void setSortableName(String sortableName) {
        this.sortable_name = sortableName;
    }

    /**
     * @return the time_zone
     */
    public String getTimeZone() {
        return time_zone;
    }

    /**
     * @param timeZone the time_zone to set
     */
    public void setTimeZone(String timeZone) {
        this.time_zone = timeZone;
    }

    /**
     * @return the login_id
     */
    public String getLoginId() {
        return login_id;
    }

    /**
     * @return the locale
     */
    public String getLocale() {
        return locale;
    }

    /**
     * @param locale the locale to set
     */
    public void setLocale(String locale) {
        this.locale = locale;
    }

    /**
     * @param loginID the login_id to set
     */
    public void setLoginID(String loginID) {
        this.login_id = loginID;
    }

    /**
     * @return the accessToken
     */
    public String getAccessToken() {
        return accessToken;
    }


    /**
     * @param accessToken the accessToken to set
     */
    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }


}
