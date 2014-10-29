package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;

public class Assignment implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -8613776200268430521L;
    private String assignment_group_id;
    private boolean automatic_peer_reviews;
    private Date due_at;
    private boolean grade_group_students_individually;
    private String grading_standard_id;
    private String grading_type;
    private String group_category_id;
    private String id;
    private Date lock_at;
    private boolean peer_reviews;
    private String points_possible;
    private String position;
    private Date unlock_at;
    private LockInfo lock_info;
    private String course_id;
    private String name;
    private ArrayList<String> submission_types;
    private String description;
    private boolean muted;
    private String html_url;
    private String lock_explanation;
    private Discussion discussion_topic;

    public String getAssignment_group_id() {
        return assignment_group_id;
    }

    public boolean isAutomatic_peer_reviews() {
        return automatic_peer_reviews;
    }

    public Date getDue_at() {
        return due_at;
    }

    public boolean isGrade_group_students_individually() {
        return grade_group_students_individually;
    }

    public String getGrading_standard_id() {
        return grading_standard_id;
    }

    public String getGrading_type() {
        return grading_type;
    }

    public String getGroup_category_id() {
        return group_category_id;
    }

    public String getId() {
        return id;
    }

    public Date getLock_at() {
        return lock_at;
    }

    public boolean isPeer_reviews() {
        return peer_reviews;
    }

    public String getPoints_possible() {
        return points_possible;
    }

    public String getPosition() {
        return position;
    }

    public Date getUnlock_at() {
        return unlock_at;
    }

    public LockInfo getLock_info() {
        return lock_info;
    }

    public String getCourse_id() {
        return course_id;
    }

    public String getName() {
        return name;
    }

    public ArrayList<String> getSubmission_types() {
        return submission_types;
    }

    public String getDescription() {
        return description;
    }

    public boolean isMuted() {
        return muted;
    }

    public String getHtml_url() {
        return html_url;
    }

    public String getLock_explanation() {
        return lock_explanation;
    }

    public Discussion getDiscussion_topic() {
        return discussion_topic;
    }

    public class LockInfo implements Serializable {
        /**
         *
         */
        private static final long serialVersionUID = 1017634121222732519L;
        private String asset_string;
        private Date lock_at;

        public String getAsset_string() {
            return asset_string;
        }

        public Date getLock_at() {
            return lock_at;
        }

    }
}
