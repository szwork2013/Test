package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by mjliu on 14-8-19.
 */
public class TvViewPagerInfo implements Serializable {

    private int id;
    private String inner_name;
    private String category;
    private String title;
    private String subtitle;
    private String url;
    private String button_text;
    private int position;
    private String created_at;
    private String updated_at;
    private String viwepager_img;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getInner_name() {
        return inner_name;
    }

    public void setInner_name(String inner_name) {
        this.inner_name = inner_name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getButton_text() {
        return button_text;
    }

    public void setButton_text(String button_text) {
        this.button_text = button_text;
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

    public String getViwepager_img() {
        return viwepager_img;
    }

    public void setViwepager_img(String viwepager_img) {
        this.viwepager_img = viwepager_img;
    }
}
