package com.kaikeba.common.entity;

import java.util.ArrayList;

/**
 * Created by baige on 14-7-29.
 */
public class PostVideoPlayHistory {
    private int id;
    private String email;
    private int course_id;
    private int last_video_id;
    private int videolen;
    private ArrayList<ViewPeriod> viewperiods;

    public PostVideoPlayHistory() {
    }

    public PostVideoPlayHistory(String email, int course_id, int last_video_id, int videolen, ArrayList<ViewPeriod> viewPeriods) {
        this.email = email;
        this.course_id = course_id;
        this.last_video_id = last_video_id;
        this.videolen = videolen;
        this.viewperiods = viewPeriods;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getCourseid() {
        return course_id;
    }

    public void setCourseid(int course_id) {
        this.course_id = course_id;
    }

    public int getItemid() {
        return last_video_id;
    }

    public void setItemid(int last_video_id) {
        this.last_video_id = last_video_id;
    }

    public int getVideolen() {
        return videolen;
    }

    public void setVideolen(int videolen) {
        this.videolen = videolen;
    }

    public ArrayList<ViewPeriod> getViewPeriods() {
        return viewperiods;
    }

    public void setViewPeriods(ArrayList<ViewPeriod> viewPeriods) {
        this.viewperiods = viewPeriods;
    }

    public static class ViewPeriod {
        private int vtime;
        private String action;

        public ViewPeriod() {
        }

        public int getVtime() {
            return vtime;
        }

        public void setVtime(int vtime) {
            this.vtime = vtime;
        }

        public String getAction() {
            return action;
        }

        public void setAction(String action) {
            this.action = action;
        }
    }
}
