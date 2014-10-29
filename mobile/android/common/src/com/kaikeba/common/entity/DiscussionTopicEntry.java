package com.kaikeba.common.entity;

import java.util.Date;
import java.util.List;

public class DiscussionTopicEntry {

    private Date created_at;
    private String id;
    private String parent_id;
    private Date updated_at;
    private String user_id;
    private String user_name;
    private String message;
    private String read_state;
    private List<RecentReply> recent_replies;
    private boolean has_more_replies;

    public Date getCreated_at() {
        return created_at;
    }

    public String getId() {
        return id;
    }

    public String getParent_id() {
        return parent_id;
    }

    public Date getUpdated_at() {
        return updated_at;
    }

    public String getUser_id() {
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

    public List<RecentReply> getRecent_replies() {
        return recent_replies;
    }

    public boolean isHas_more_replies() {
        return has_more_replies;
    }

    class RecentReply {
        private Date created_at;
        private String id;
        private String parent_id;
        private Date updated_at;
        private String user_id;
        private String user_name;
        private String message;
        private String read_state;

        public Date getCreated_at() {
            return created_at;
        }

        public String getId() {
            return id;
        }

        public String getParent_id() {
            return parent_id;
        }

        public Date getUpdated_at() {
            return updated_at;
        }

        public String getUser_id() {
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
