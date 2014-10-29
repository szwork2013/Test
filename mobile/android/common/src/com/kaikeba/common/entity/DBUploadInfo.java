package com.kaikeba.common.entity;

/**
 * Created by chris on 14-7-21.
 */
public class DBUploadInfo {
    private long id;
    private String cpa = "CPA";
    private String content;

    public String getCpa() {
        return cpa;
    }

    public void setCpa(String cpa) {
        this.cpa = cpa;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }
}
