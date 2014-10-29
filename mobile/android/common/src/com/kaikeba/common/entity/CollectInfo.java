package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-8-11.
 */
public class CollectInfo implements Serializable {

    private int id;
    private boolean isConllect;
    private int courseId;
    private String time;
    private String userId;

    public CollectInfo() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public boolean isConllect() {
        return isConllect;
    }

    public void setConllect(boolean isConllect) {
        this.isConllect = isConllect;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
