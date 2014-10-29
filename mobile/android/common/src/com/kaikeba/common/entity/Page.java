package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.Date;


public class Page implements Serializable {

    private String url;
    private String title;
    private Date created_at;
    private Date updated_at;
    private Boolean hide_from_students;
    private String body;

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @return the title
     */
    public String getTitle() {
        return title;
    }

    /**
     * @return the created_at
     */
    public Date getCreatedAt() {
        return created_at;
    }

    /**
     * @return the updated_at
     */
    public Date getUpdatedAt() {
        return updated_at;
    }

    /**
     * @return the hide_from_students
     */
    public Boolean getHideFromStudents() {
        return hide_from_students;
    }

    /**
     * @return the body
     */
    public String getBody() {
        return body;
    }

    /**
     * @param body
     * @return
     */
    public String setBody(String body) {
        this.body = body;
        return body;
    }

}
