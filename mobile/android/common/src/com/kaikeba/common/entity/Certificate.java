package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by sjyin on 14-10-21.
 */
public class Certificate implements Serializable{
    private int id;
    private int course_id;
    private String name;
    private String intro;
    private int position;
    private String status;
    private long created_at;
    private long updated_at;
    private long awarded_at;
    private String image_url;
    private float score;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCourse_id() {
        return course_id;
    }

    public void setCourse_id(int course_id) {
        this.course_id = course_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getAwarded_at() {
        return awarded_at;
    }


    public void setAwarded_at(long awarded_at) {
        this.awarded_at = awarded_at;
    }

    public void setCreated_at(long created_at) {
        this.created_at = created_at;
    }

    public long getCreated_at() {
        return created_at;
    }

    public long getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(long updated_at) {
        this.updated_at = updated_at;
    }

    public String getStatus() {
        return status;
    }

    public String getImage_url() {
        return image_url;
    }

    public void setImage_url(String image_url) {
        this.image_url = image_url;
    }

    public float getScore() {
        return score;
    }

    public void setScore(float score) {
        this.score = score;
    }
}
