package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-8-15.
 */
public class TvHistoryInfo implements Serializable {
    private int id;
    private int courseId;
    private String time;
    private int videoId;
    private int lastTime;
    private int duationTime;
    private String type;
    private int idx;

    public TvHistoryInfo(int courseId, String time, int videoId, int lastTime, String type, int idx) {
        this.time = time;
        this.courseId = courseId;
        this.videoId = videoId;
        this.lastTime = lastTime;
        this.idx = idx;
        this.type = type;
    }

    public TvHistoryInfo() {

    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public int getVideoId() {
        return videoId;
    }

    public void setVideoId(int videoId) {
        this.videoId = videoId;
    }

    public int getLastTime() {
        return lastTime;
    }

    public void setLastTime(int lastTime) {
        this.lastTime = lastTime;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getIndex() {
        return idx;
    }

    public void setIndex(int index) {
        this.idx = index;
    }

    public int getDuationTime() {
        return duationTime;
    }

    public void setDuationTime(int duationTime) {
        this.duationTime = duationTime;
    }
}
