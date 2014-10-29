package com.kaikeba.common.entity;

import java.util.ArrayList;
import java.util.Date;

public class UserActivity {

    private Date created_at;
    private Date updated_at;
    private long id;
    private String title;
    private String message;
    /**
     * DiscussionTopic|Conversation|Message|Submission|Conference|Collaboration|...'
     */
    private String type;
    private boolean read_state;
    private String context_type;
    private long course_id;
    private String html_url;

    private long discussion_topic_id;
    private String total_root_discussion_entries;
    private boolean require_initial_post;
    private boolean user_has_posted;
    private ArrayList<root_discussion_entries> entries;
    private long announcement_id;
    private String url;
    private String notification_category;
    private long message_id;


    public String getMessage() {
        return message;
    }


    public Date getCreated_at() {
        return created_at;
    }


    public Date getUpdated_at() {
        return updated_at;
    }


    public long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getType() {
        return type;
    }

    public boolean isRead_state() {
        return read_state;
    }

    public String getContext_type() {
        return context_type;
    }

    public long getCourse_id() {
        return course_id;
    }

    public String getHtml_url() {
        return html_url;
    }

    public long getDiscussion_topic_id() {
        return discussion_topic_id;
    }

    public String getTotal_root_discussion_entries() {
        return total_root_discussion_entries;
    }

    public boolean isRequire_initial_post() {
        return require_initial_post;
    }

    public boolean isUser_has_posted() {
        return user_has_posted;
    }

    public ArrayList<root_discussion_entries> getEntries() {
        return entries;
    }

    public long getAnnouncement_id() {
        return announcement_id;
    }

    public String getUrl() {
        return url;
    }

    public String getNotification_category() {
        return notification_category;
    }

    public long getMessage_id() {
        return message_id;
    }

    class root_discussion_entries {
        private user user;
        private String message;

        public user getUser() {
            return user;
        }

        public String getMessage() {
            return message;
        }
    }

    class user {
        private long user_id;
        private String user_name;

        public long getUser_id() {
            return user_id;
        }

        public String getUser_name() {
            return user_name;
        }
    }
}

