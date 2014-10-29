package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-8-11.
 */
public class MicroInfo implements Serializable {
    private int id;
    private int microId;
    private boolean isJoin;
    private String userId;

    public MicroInfo() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMicroId() {
        return microId;
    }

    public void setMicroId(int microId) {
        this.microId = microId;
    }

    public boolean isJoin() {
        return isJoin;
    }

    public void setJoin(boolean isJoin) {
        this.isJoin = isJoin;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
