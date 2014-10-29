package com.kaikeba.common.entity;

import java.util.ArrayList;
import java.util.Date;

public class ReplyEntry {

    private Date created_at;
    private long id;
    private String parent_id;
    private Date updated_at;
    private long user_id;
    private String user_name;
    private String message;
    private String read_state;
    private boolean delete;
    private ArrayList<recent_replies> recent_replies;
    private boolean has_more_replies;

    public boolean isDelete() {
        return delete;
    }

    public Date getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Date created_at) {
        this.created_at = created_at;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getParent_id() {
        return parent_id;
    }

    public void setParent_id(String parent_id) {
        this.parent_id = parent_id;
    }

    public Date getUpdated_at() {
        return updated_at;
    }

    public void setUpdated_at(Date updated_at) {
        this.updated_at = updated_at;
    }

    public long getUser_id() {
        return user_id;
    }

    public void setUser_id(long user_id) {
        this.user_id = user_id;
    }

    public String getUser_name() {
        return user_name;
    }

    public void setUser_name(String user_name) {
        this.user_name = user_name;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getRead_state() {
        return read_state;
    }

    public void setRead_state(String read_state) {
        this.read_state = read_state;
    }

    public ArrayList<recent_replies> getRecent_replies() {
        return recent_replies;
    }

    public void setRecent_replies(ArrayList<recent_replies> recent_replies) {
        this.recent_replies = recent_replies;
    }

    public boolean isHas_more_replies() {
        return has_more_replies;
    }

    public void setHas_more_replies(boolean has_more_replies) {
        this.has_more_replies = has_more_replies;
    }

    class recent_replies {
        private Date created_at;
        private long id;
        private String parent_id;
        private Date updated_at;
        private long user_id;
        private String user_name;
        private String message;
        private String read_state;

        public Date getCreated_at() {
            return created_at;
        }

        public long getId() {
            return id;
        }

        public String getParent_id() {
            return parent_id;
        }

        public Date getUpdated_at() {
            return updated_at;
        }

        public long getUser_id() {
            return user_id;
        }

        public String getUser_name() {
            return user_name;
        }

        public String getMessage() {
            return message;
        }

        public String getRead_state() {
            return read_state;
        }

    }
}
