package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by chris on 14-7-16.
 */
public class CourseInfo implements Serializable {
    private int id;
    private int parent_id;
    private String name;
    private String intro;
    private int position;
    private int status;
    private String created_at;
    private String updated_at;
    private String img_url;
    private List<MicroSpecialties> micro_specialties;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getParent_id() {
        return parent_id;
    }

    public void setParent_id(int parent_id) {
        this.parent_id = parent_id;
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

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public String getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(String updated_at) {
        this.updated_at = updated_at;
    }

    public String getImg_url() {
        return img_url;
    }

    public void setImg_url(String img_url) {
        this.img_url = img_url;
    }

    public List<MicroSpecialties> getMicro_specialties() {
        return micro_specialties;
    }

    public void setMicro_specialties(List<MicroSpecialties> micro_specialties) {
        this.micro_specialties = micro_specialties;
    }

    public static class MicroSpecialties implements Serializable {
        private int id;
        private int specialty_id;
        private String name;
        private String intro;
        private int parent_id;
        private String color;
        private int status;
        private int position;
        private String created_at;
        private String updated_at;
        private String url_about_video;
        private String url_to_zhaozuor;
        private String image_url;
        private int join_status;
        private String certificate_url;
        private Map<String, Integer> learn_status;
        private String learn_progress;

        private ArrayList<Courses> courses;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public int getSpecialty_id() {
            return specialty_id;
        }

        public void setSpecialty_id(int specialty_id) {
            this.specialty_id = specialty_id;
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

        public int getParent_id() {
            return parent_id;
        }

        public void setParent_id(int parent_id) {
            this.parent_id = parent_id;
        }

        public String getColor() {
            return color;
        }

        public void setColor(String color) {
            this.color = color;
        }

        public int getStatus() {
            return status;
        }

        public void setStatus(int status) {
            this.status = status;
        }

        public int getPosition() {
            return position;
        }

        public void setPosition(int position) {
            this.position = position;
        }

        public String getCreated_at() {
            return created_at;
        }

        public void setCreated_at(String created_at) {
            this.created_at = created_at;
        }

        public String getUpdated_at() {
            return updated_at;
        }

        public void setUpdated_at(String updated_at) {
            this.updated_at = updated_at;
        }

        public String getUrl_about_video() {
            return url_about_video;
        }

        public void setUrl_about_video(String url_about_video) {
            this.url_about_video = url_about_video;
        }

        public String getUrl_to_zhaozuor() {
            return url_to_zhaozuor;
        }

        public void setUrl_to_zhaozuor(String url_to_zhaozuor) {
            this.url_to_zhaozuor = url_to_zhaozuor;
        }

        public String getImage_url() {
            return image_url;
        }

        public void setImage_url(String image_url) {
            this.image_url = image_url;
        }

        public int getJoin_status() {
            return join_status;
        }

        public void setJoin_status(int join_status) {
            this.join_status = join_status;
        }

        public ArrayList<Courses> getCourses() {
            return courses;
        }

        public void setCourses(ArrayList<Courses> courses) {
            this.courses = courses;
        }

        public String getCertificate_url() {
            return certificate_url;
        }

        public void setCertificate_url(String certificate_url) {
            this.certificate_url = certificate_url;
        }

        public Map<String, Integer> getLearn_status() {
            return learn_status;
        }

        public void setLearn_status(Map<String, Integer> learn_status) {
            this.learn_status = learn_status;
        }

        public String getLearn_progress() {
            return learn_progress;
        }

        public void setLearn_progress(String learn_progress) {
            this.learn_progress = learn_progress;
        }

        public static class Courses extends CourseModel implements Serializable {

        }
    }
}
