package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-8-5.
 */
public class DynamicTitleInfo implements Serializable {

    private String id;
    private int course_id;
    private String user_id;
    private int lms_course_id;
    private String progress;
    private int last_video_id;
    private String last_video_title;
    private int duration;
    private String status;
    private String created_at;
    private String updated_at;
    private String course_name;
    private String type;
    private String logtime;
    private String videolen;
    private String email;
    //    private ArrayList<HisViewPeriod> hisViewPeriod;
    private String viewPeriods;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getCourse_id() {
        return course_id;
    }

    public void setCourse_id(int course_id) {
        this.course_id = course_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public int getLms_course_id() {
        return lms_course_id;
    }

    public void setLms_course_id(int lms_course_id) {
        this.lms_course_id = lms_course_id;
    }

    public String getProgress() {
        return progress;
    }

    public void setProgress(String progress) {
        this.progress = progress;
    }

    public int getLast_video_id() {
        return last_video_id;
    }

    public void setLast_video_id(int last_video_id) {
        this.last_video_id = last_video_id;
    }

    public String getLast_video_title() {
        return last_video_title;
    }

    public void setLast_video_title(String last_video_title) {
        this.last_video_title = last_video_title;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(String updated_at) {
        this.updated_at = updated_at;
    }

    public String getCourse_name() {
        return course_name;
    }

    public void setCourse_name(String course_name) {
        this.course_name = course_name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getLogtime() {
        return logtime;
    }

    public void setLogtime(String logtime) {
        this.logtime = logtime;
    }

    public String getVideolen() {
        return videolen;
    }

    public void setVideolen(String videolen) {
        this.videolen = videolen;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getViewPeriods() {
        return viewPeriods;
    }

    public void setViewPeriods(String viewPeriods) {
        this.viewPeriods = viewPeriods;
    }

    //    public static class HisViewPeriod{
//        private int from;
//        private int view;
//
//    }
}
