package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

public class Discussion implements Serializable {
    /**
     *
     */
    private static final long serialVersionUID = -8154571834800148759L;

    private String assignment_id;

    private Date delayed_post_at;

    private Date last_reply_at;

    private boolean podcast_has_student_posts;

    private String root_topic_id;

    private String user_name;

    private String id;

    private Date posted_at;

    private String title;

    private String message;

    private String discussion_subentry_count;

    private author author;

    private permissions permissions;

    private String discussion_type;

    private String require_initial_post;

    private String podcast_url;

    private String read_state;

    private int unread_count;

    private ArrayList<Attachment> attachments;

    private boolean locked;

    private String html_url;

    private String url;

    public String getAssignment_id() {
        return assignment_id;
    }

    public Date getDelayed_post_at() {
        return delayed_post_at;
    }

    public Date getLast_reply_at() {
        return last_reply_at;
    }

    public boolean isPodcast_has_student_posts() {
        return podcast_has_student_posts;
    }

    public String getRoot_topic_id() {
        return root_topic_id;
    }

    public String getUser_name() {
        return user_name;
    }

    public String getId() {
        return id;
    }

    public Date getPosted_at() {
        return posted_at;
    }

    public String getTitle() {
        return title;
    }

    public String getMessage() {
        return message;
    }

    public String getDiscussion_subentry_count() {
        return discussion_subentry_count;
    }

    public author getAuthor() {
        return author;
    }

    public permissions getPermissions() {
        return permissions;
    }

    public String getDiscussion_type() {
        return discussion_type;
    }

    public String getRequire_initial_post() {
        return require_initial_post;
    }

    public String getPodcast_url() {
        return podcast_url;
    }

    public String getRead_state() {
        return read_state;
    }

    public int getUnread_count() {
        return unread_count;
    }

    public ArrayList<Attachment> getAttachments() {
        return attachments;
    }

    public boolean isLocked() {
        return locked;
    }

    public String getHtml_url() {
        return html_url;
    }

    public String getUrl() {
        return url;
    }

    public class author implements Serializable {
        /**
         *
         */
        private static final long serialVersionUID = 4366802180338505380L;
        private String display_name;
        private String avatar_image_url;

        public String getDisplay_name() {
            return display_name;
        }

        public String getAvatar_image_url() {
            return avatar_image_url;
        }
    }

    public class permissions implements Serializable {

        /**
         *
         */
        private static final long serialVersionUID = 3498168010377826076L;
        private boolean attach;
        private boolean update;
        private boolean delete;

        public boolean isAttach() {
            return attach;
        }

        public boolean isUpdate() {
            return update;
        }

        public boolean isDelete() {
            return delete;
        }
    }

    public class Attachment implements Serializable {
        /**
         *
         */
        private static final long serialVersionUID = 3930872088715237188L;

        private long id;

        private String content_type;

        private String display_name;

        private String filename;

        private String url;

        private String size;

        private Date created_at;
        private Date updated_at;
        private String unlock_at;
        private boolean locked;
        private boolean hidden;
        private String lock_at;
        private boolean locked_for_user;
        private boolean hidden_for_user;

        public long getId() {
            return id;
        }

        public String getContent_type() {
            return content_type;
        }

        public String getDisplay_name() {
            return display_name;
        }

        public String getFilename() {
            return filename;
        }

        public String getUrl() {
            return url;
        }

        public String getSize() {
            return size;
        }

        public Date getCreated_at() {
            return created_at;
        }

        public Date getUpdated_at() {
            return updated_at;
        }

        public String getUnlock_at() {
            return unlock_at;
        }

        public boolean isLocked() {
            return locked;
        }

        public boolean isHidden() {
            return hidden;
        }

        public String getLock_at() {
            return lock_at;
        }

        public boolean isLocked_for_user() {
            return locked_for_user;
        }

        public boolean isHidden_for_user() {
            return hidden_for_user;
        }
    }
}
