package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

public class AnnouncementReply implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -3949328930611638313L;
    //	private ArrayList<ReplyEntry> unread_entries;
    private ArrayList<Participant> participants;
    //	private ArrayList<ReplyEntry> new_entries;
    private ArrayList<ReplyView> view;

    //	public ArrayList<ReplyEntry> getUnread_entries() {
//		return unread_entries;
//	}
    public ArrayList<Participant> getParticipants() {
        return participants;
    }

    public void setParticipants(ArrayList<Participant> participants) {
        this.participants = participants;
    }

    //	public ArrayList<ReplyEntry> getNew_entries() {
//		return new_entries;
//	}
    public ArrayList<ReplyView> getView() {
        return view;
    }

    public void setView(ArrayList<ReplyView> view) {
        this.view = view;
    }

    public class Participant implements Serializable {

        /**
         *
         */
        private static final long serialVersionUID = 1405730839911400998L;
        private String id;
        private String display_name;
        private String avatar_image_url;
        private String html_url;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getDisplay_name() {
            return display_name;
        }

        public void setDisplay_name(String display_name) {
            this.display_name = display_name;
        }

        public String getAvatar_image_url() {
            return avatar_image_url;
        }

        public void setAvatar_image_url(String avatar_image_url) {
            this.avatar_image_url = avatar_image_url;
        }

        public String getHtml_url() {
            return html_url;
        }

        public void setHtml_url(String html_url) {
            this.html_url = html_url;
        }

    }

    public class ReplyView implements Serializable {

        /**
         *
         */
        private static final long serialVersionUID = -547113926893301039L;
        private Date created_at;
        private String id;
        private String parent_id;
        private Date updated_at;
        private String user_id;
        private String message;
        private ArrayList<Reply> replies;
        private boolean deleted;

        private boolean isExpand = false;

        public boolean isExpand() {
            return isExpand;
        }

        public void setExpand(boolean expand) {
            isExpand = expand;
        }

        public boolean isDeleted() {
            return deleted;
        }

        public Date getCreated_at() {
            return created_at;
        }

        public void setCreated_at(Date created_at) {
            this.created_at = created_at;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
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

        public String getUser_id() {
            return user_id;
        }

        public void setUser_id(String user_id) {
            this.user_id = user_id;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public ArrayList<Reply> getReplies() {
            return replies;
        }

        public void setReplies(ArrayList<Reply> replies) {
            this.replies = replies;
        }

        public class Reply implements Serializable {
            /**
             *
             */
            private static final long serialVersionUID = 2453567875025205883L;
            private Date created_at;
            private String id;
            private String parent_id;
            private Date updated_at;
            private long user_id;
            private String message;
            private boolean deleted = false;

            public boolean isDeleted() {
                return deleted;
            }

            public Date getCreated_at() {
                return created_at;
            }

            public void setCreated_at(Date created_at) {
                this.created_at = created_at;
            }

            public String getId() {
                return id;
            }

            public void setId(String id) {
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

            public String getMessage() {
                return message;
            }

            public void setMessage(String message) {
                this.message = message;
            }
        }
    }
}
