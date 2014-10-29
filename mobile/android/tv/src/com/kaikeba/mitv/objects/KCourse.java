package com.kaikeba.mitv.objects;

/**
 * Created by kkb on 8/5/14.
 */
public class KCourse {
    private int courseId;
    private String courseTitle;

    public KCourse(int courseId, String courseTitle) {
        this.courseId = courseId;
        this.courseTitle = courseTitle;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getCourseTitle() {
        return courseTitle;
    }

    public void setCourseTitle(String courseTitle) {
        this.courseTitle = courseTitle;
    }
}
