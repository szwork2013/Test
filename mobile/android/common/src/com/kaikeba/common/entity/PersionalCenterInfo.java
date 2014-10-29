package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by chris on 14-7-22.
 */
public class PersionalCenterInfo implements Serializable {
    private String bg_url;
    private String user;
    private String user_url;
    private String location;
    private String lable;
    private ArrayList<Certificate> certificate_list;
    private ArrayList<GuideCourse> guide_list;
    private ArrayList<OpenCourse> open_list;

    public String getBgUrl() {
        return bg_url;
    }

    public void setBgUrl(String bg_url) {
        this.bg_url = bg_url;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getUserUrl() {
        return user_url;
    }

    public void setUserUrl(String user_url) {
        this.user_url = user_url;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getLable() {
        return lable;
    }

    public void setLable(String lable) {
        this.lable = lable;
    }

    public ArrayList<Certificate> getCertificateList() {
        return certificate_list;
    }

    public void setCertificateList(ArrayList<Certificate> certificate_list) {
        this.certificate_list = certificate_list;
    }

    public ArrayList<GuideCourse> getGuideList() {
        return guide_list;
    }

    public void setGuideList(ArrayList<GuideCourse> guide_list) {
        this.guide_list = guide_list;
    }

    public ArrayList<OpenCourse> getOpenList() {
        return open_list;
    }

    public void setOpenList(ArrayList<OpenCourse> open_list) {
        this.open_list = open_list;
    }

    public static class Certificate {
        private String url;
        private String name;
        private String type;
        private String time;

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }
    }

    public static class GuideCourse {
        private String url;
        private String name;
        private String type;
        private int weeks;
        private int hours;
        private int whichWeek;
        private int percent;

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getWeeks() {
            return weeks;
        }

        public void setWeeks(int weeks) {
            this.weeks = weeks;
        }

        public int getHours() {
            return hours;
        }

        public void setHours(int hours) {
            this.hours = hours;
        }

        public int getWhichWeek() {
            return whichWeek;
        }

        public void setWhichWeek(int whichWeek) {
            this.whichWeek = whichWeek;
        }

        public int getPercent() {
            return percent;
        }

        public void setPercent(int percent) {
            this.percent = percent;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }
    }

    public static class OpenCourse {
        private String url;
        private String name;
        private String type;
        private int witch;

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getWitch() {
            return witch;
        }

        public void setWitch(int witch) {
            this.witch = witch;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }
    }
}
