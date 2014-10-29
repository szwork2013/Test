package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * Created by mjliu on 14-8-1.
 */
public class DynamicFirstPageInfo implements Serializable {
    private String date;
    private int course_id;
    private String type;
    private int lms_course_id;
    private String name;
    private String create_at;
    private String update_at;
    private String supper_class_id;
    private String supper_class_name;
    private String cover_image;
    private String cardtype;
    private Map<String, List<Map<String, String>>> info;
    private int week;

    public Map<String, List<Map<String, String>>> getInfo() {
        return info;
    }

    public void setInfo(Map<String, List<Map<String, String>>> info) {
        this.info = info;
    }

    public int getWeek() {
        return week;
    }

    public void setWeek(int week) {
        this.week = week;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public int getCourse_id() {
        return course_id;
    }

    public void setCourse_id(int course_id) {
        this.course_id = course_id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getLms_course_id() {
        return lms_course_id;
    }

    public void setLms_course_id(int lms_course_id) {
        this.lms_course_id = lms_course_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCreate_at() {
        return create_at;
    }

    public void setCreate_at(String create_at) {
        this.create_at = create_at;
    }

    public String getUpdate_at() {
        return update_at;
    }

    public void setUpdate_at(String update_at) {
        this.update_at = update_at;
    }

    public String getSupper_class_id() {
        return supper_class_id;
    }

    public void setSupper_class_id(String supper_class_id) {
        this.supper_class_id = supper_class_id;
    }

    public String getSupper_class_name() {
        return supper_class_name;
    }

    public void setSupper_class_name(String supper_class_name) {
        this.supper_class_name = supper_class_name;
    }

    public String getCover_image() {
        return cover_image;
    }

    public void setCover_image(String cover_image) {
        this.cover_image = cover_image;
    }

    public String getCardtype() {
        return cardtype;
    }

    public void setCardtype(String cardtype) {
        this.cardtype = cardtype;
    }

}
