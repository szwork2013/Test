package com.kaikeba.common.entity;

/**
 * Created by baige on 14-7-24.
 */
public class Collect4Request {
    private String user_id;
    private String course_id;

    public Collect4Request(String user_id, String course_id) {
        this.user_id = user_id;
        this.course_id = course_id;
    }

    public String getUserId() {
        return user_id;
    }

    public void setUserId(String userId) {
        this.user_id = user_id;
    }

    public String getCourseId() {
        return course_id;
    }

    public void setCourseId(String courseId) {
        this.course_id = course_id;
    }
}
