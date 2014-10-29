package com.kaikeba.common.entity;

import java.util.Date;

public class Quiz {

    private Long id;

    private String title;

    private String html_url;

    private String mobile_url;

    private String description;

    //"practice_quiz", "assignment", "graded_survey", "survey"
    private String quiz_type;

    private String assignment_group_id;

    private String time_limit;

    private String shuffle_answers;

    private String hide_results;

    private String show_correct_answers;

    private String scoring_policy;

    private String allowed_attempts;

    private String one_question_at_a_time;

    private String question_count;

    private String points_possible;

    private String cant_go_back;

    private String access_code;

    private String ip_filter;

    private Date due_at;

    private String lock_at;

    private Date unlock_at;

    private String published;

    private String locked_for_user;

    private LockInfo lock_info;

    private String lock_explanation;

    /**
     * 与API无关的属性
     */
    private String score;

    private String surplusTime;

    private String submitTime;

    private String totalPoint;

    private String point;

    public String getTotalPoint() {
        return totalPoint;
    }

    public void setTotalPoint(String totalPoint) {
        this.totalPoint = totalPoint;
    }

    public String getPoint() {
        return point;
    }

    public void setPoint(String point) {
        this.point = point;
    }

    public String getSubmitTime() {
        return submitTime;
    }

    public void setSubmitTime(String submitTime) {
        this.submitTime = submitTime;
    }

    public String getSurplusTime() {
        return surplusTime;
    }

    public void setSurplusTime(String surplusTime) {
        this.surplusTime = surplusTime;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getHtml_url() {
        return html_url;
    }

    public void setHtml_url(String html_url) {
        this.html_url = html_url;
    }

    public String getMobile_url() {
        return mobile_url;
    }

    public void setMobile_url(String mobile_url) {
        this.mobile_url = mobile_url;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getQuiz_type() {
        return quiz_type;
    }

    public void setQuiz_type(String quiz_type) {
        this.quiz_type = quiz_type;
    }

    public String getAssignment_group_id() {
        return assignment_group_id;
    }

    public void setAssignment_group_id(String assignment_group_id) {
        this.assignment_group_id = assignment_group_id;
    }

    public String getTime_limit() {
        return time_limit;
    }

    public void setTime_limit(String time_limit) {
        this.time_limit = time_limit;
    }

    public String getShuffle_answers() {
        return shuffle_answers;
    }

    public void setShuffle_answers(String shuffle_answers) {
        this.shuffle_answers = shuffle_answers;
    }

    public String getHide_results() {
        return hide_results;
    }

    public void setHide_results(String hide_results) {
        this.hide_results = hide_results;
    }

    public String getShow_correct_answers() {
        return show_correct_answers;
    }

    public void setShow_correct_answers(String show_correct_answers) {
        this.show_correct_answers = show_correct_answers;
    }

    public String getScoring_policy() {
        return scoring_policy;
    }

    public void setScoring_policy(String scoring_policy) {
        this.scoring_policy = scoring_policy;
    }

    public String getAllowed_attempts() {
        return allowed_attempts;
    }

    public void setAllowed_attempts(String allowed_attempts) {
        this.allowed_attempts = allowed_attempts;
    }

    public String getOne_question_at_a_time() {
        return one_question_at_a_time;
    }

    public void setOne_question_at_a_time(String one_question_at_a_time) {
        this.one_question_at_a_time = one_question_at_a_time;
    }

    public String getPoints_possible() {
        return points_possible;
    }

    public String getQuestion_count() {
        return question_count;
    }

    public String getCant_go_back() {
        return cant_go_back;
    }

    public void setCant_go_back(String cant_go_back) {
        this.cant_go_back = cant_go_back;
    }

    public String getAccess_code() {
        return access_code;
    }

    public void setAccess_code(String access_code) {
        this.access_code = access_code;
    }

    public String getIp_filter() {
        return ip_filter;
    }

    public void setIp_filter(String ip_filter) {
        this.ip_filter = ip_filter;
    }

    public Date getDue_at() {
        return due_at;
    }

    public void setDue_at(Date due_at) {
        this.due_at = due_at;
    }

    public String getLock_at() {
        return lock_at;
    }

    public void setLock_at(String lock_at) {
        this.lock_at = lock_at;
    }

    public Date getUnlock_at() {
        return unlock_at;
    }

    public void setUnlock_at(Date unlock_at) {
        this.unlock_at = unlock_at;
    }

    public String getPublished() {
        return published;
    }

    public void setPublished(String published) {
        this.published = published;
    }

    public String getLocked_for_user() {
        return locked_for_user;
    }

    public void setLocked_for_user(String locked_for_user) {
        this.locked_for_user = locked_for_user;
    }

    public LockInfo getLock_info() {
        return lock_info;
    }

    public void setLock_info(LockInfo lock_info) {
        this.lock_info = lock_info;
    }

    public String getLock_explanation() {
        return lock_explanation;
    }

    public void setLock_explanation(String lock_explanation) {
        this.lock_explanation = lock_explanation;
    }

    public class LockInfo {
        private String asset_string;

        // (Optional) Time at which this was/will be unlocked.
        private String unlock_at;

        // (Optional) Time at which this was/will be locked.
        private String lock_at;

        public String getAsset_string() {
            return asset_string;
        }

        public String getUnlock_at() {
            return unlock_at;
        }

        public String getLock_at() {
            return lock_at;
        }
    }
}
