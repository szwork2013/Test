package com.kaikeba.common.entity;

/**
 * Created by baige on 14-7-29.
 */
public class VideoPlayHistory {
    private long id;
    private long userId;
    private int courseId;
    private int lastVideoId;
    private int duration;

    public VideoPlayHistory() {
    }

    public VideoPlayHistory(long userId, int courseId, int lastVideoId, int duration) {
        this.userId = userId;
        this.courseId = courseId;
        this.lastVideoId = lastVideoId;
        this.duration = duration;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public int getLastVideoId() {
        return lastVideoId;
    }

    public void setLastVideoId(int lastVideoId) {
        this.lastVideoId = lastVideoId;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }
}
