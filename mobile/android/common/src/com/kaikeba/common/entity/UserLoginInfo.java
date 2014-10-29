package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by chris on 14-7-18.
 */
public class UserLoginInfo implements Serializable {
    private String user_id;
    private String package_name;
    private String os_version;
    private String channel;
    private String platform;
    private String ifv;
    private String ifa;
    private String mac;
    private String imei;
    private long time_action;
    private String action = "firstOpen";
    private String client_version;
    private String model;

    @Override
    public String toString() {
        return "print info ---" + " user_id:" + user_id + " package_name:" + package_name
                + " os_version:" + os_version + " channel:" + channel + " platform:" + platform + " ifv" + ifv
                + " ifa" + ifa + " mac" + mac + " imei:" + imei + " timeAction:" + " :timeReceive";
    }

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public String getPackage_name() {
        return package_name;
    }

    public void setPackage_name(String package_name) {
        this.package_name = package_name;
    }

    public String getOs_version() {
        return os_version;
    }

    public void setOs_version(String os_version) {
        this.os_version = os_version;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public String getIfv() {
        return ifv;
    }

    public void setIfv(String ifv) {
        this.ifv = ifv;
    }

    public String getIfa() {
        return ifa;
    }

    public void setIfa(String ifa) {
        this.ifa = ifa;
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

    public long getTime_action() {
        return time_action;
    }

    public void setTime_action(long time_action) {
        this.time_action = time_action;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getClient_version() {
        return client_version;
    }

    public void setClient_version(String client_version) {
        this.client_version = client_version;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }
}
