package com.kaikeba.common.entity;

import java.io.Serializable;

/**
 * Created by user on 14-7-21.
 */
public class Category implements Serializable {
    protected int id;
    protected int parent_id;
    protected String name;
    protected String short_name;
    protected String link;
    protected String permalink;
    protected String lft;
    protected String rgt;
    protected String depth;
    protected String desc;
    protected String position;
    protected String status;
    protected String created_at;
    protected String updated_at;
    protected String image_url;

    public int getId() {
        return id;
    }

    public int getParentId() {
        return parent_id;
    }

    public String getName() {
        return name;
    }

    public String getShortName() {
        return short_name;
    }

    public String getLink() {
        return link;
    }

    public String getPermalink() {
        return permalink;
    }

    public String getLft() {
        return lft;
    }

    public String getRgt() {
        return rgt;
    }

    public String getDepth() {
        return depth;
    }

    public String getDesc() {
        return desc;
    }

    public String getPosition() {
        return position;
    }

    public String getStatus() {
        return status;
    }

    public String getCreatedAt() {
        return created_at;
    }

    public String getUpdatedAt() {
        return updated_at;
    }

    public String getImageUrl() {
        return image_url;
    }
}
