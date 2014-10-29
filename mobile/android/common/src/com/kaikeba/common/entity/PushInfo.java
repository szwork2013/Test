package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-9-10.
 */
public class PushInfo implements Serializable {
    private String cid;
    private long uid;
    private String mac;
    private String imei;
    private String email;

    public PushInfo(String cid, long uid, String mac, String imei, String email) {
        this.cid = cid;
        this.uid = uid;
        this.mac = mac;
        this.imei = imei;
        this.email = email;
    }

    public String getCid() {
        return cid;
    }

    public void setCid(String cid) {
        this.cid = cid;
    }

    public long getUid() {
        return uid;
    }

    public void setUid(long uid) {
        this.uid = uid;
    }

    public String getMac() {
        return mac;
    }

    public void setMac(String mac) {
        this.mac = mac;
    }

    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
