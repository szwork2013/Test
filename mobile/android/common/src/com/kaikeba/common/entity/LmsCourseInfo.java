package com.kaikeba.common.entity;

import java.util.List;

/**
 * Created by baige on 14-8-11.
 */
public class LmsCourseInfo {
    private long id;
    private int number_of_enrolled_lms_course;
    private int position_of_nearest_enrolled;
    private List<Lms_Course_List> lms_course_list;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getNumber_of_enrolled_lms_course() {
        return number_of_enrolled_lms_course;
    }

    public void setNumber_of_enrolled_lms_course(int number_of_enrolled_lms_course) {
        this.number_of_enrolled_lms_course = number_of_enrolled_lms_course;
    }

    public int getPosition_of_nearest_enrolled() {
        return position_of_nearest_enrolled;
    }

    public void setPosition_of_nearest_enrolled(int position_of_nearest_enrolled) {
        this.position_of_nearest_enrolled = position_of_nearest_enrolled;
    }

    public List<Lms_Course_List> getLms_course_list() {
        return lms_course_list;
    }

    public void setLms_course_list(List<Lms_Course_List> lms_course_list) {
        this.lms_course_list = lms_course_list;
    }

    public static class Lms_Course_List {
        private int lms_course_id;
        private String name;
        private String start_at;
        private String conclude_at;
        private String status;
        private String opened_weeks;

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

        public String getStart_at() {
            return start_at;
        }

        public void setStart_at(String start_at) {
            this.start_at = start_at;
        }

        public String getConclude_at() {
            return conclude_at;
        }

        public void setConclude_at(String conclude_at) {
            this.conclude_at = conclude_at;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getOpened_weeks() {
            return opened_weeks;
        }

        public void setOpened_weeks(String opened_weeks) {
            this.opened_weeks = opened_weeks;
        }
    }
}
