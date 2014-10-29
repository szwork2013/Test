package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.List;

public class Course implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = 3286865375150398750L;
    private Long id;
    private String courseType;
    private String courseName;
    private String courseNum;
    private String courseBrief;
    private String courseIntro;
    private String courseKeywords;
    private String coverImage;
    private String promoVideo;
    private String price;
    private String price4Phone;
    private String startDate;
    private String estimate;
    private String schoolName;
    private String payURL;
    private String instructorAvatar;
    private String instructorName;
    private String instructorTitle;
    private List<Long> courseBadges;
    private boolean visible;
    private String courseCategory;

    public static long getSerialversionuid() {
        return serialVersionUID;
    }

    public boolean isVisible() {
        return visible;
    }

    public Long getId() {
        return id;
    }

    public String getCourseType() {
        return courseType;
    }

    public String getCourseName() {
        return courseName;
    }

    public String getCourseNum() {
        return courseNum;
    }

    public String getCourseBrief() {
        return courseBrief;
    }

    public String getCourseIntro() {
        return courseIntro;
    }

    public String getCourseKeywords() {
        return courseKeywords;
    }

    public String getCoverImage() {
        return coverImage;
    }

    public String getPromoVideo() {
        return promoVideo;
    }

    public String getPrice() {
        return price;
    }

    public String getStartDate() {
        return startDate;
    }

    public String getEstimate() {
        return estimate;
    }

    public String getSchoolName() {
        return schoolName;
    }

    public String getPayURL() {
        return payURL;
    }

    public String getInstructorAvatar() {
        return instructorAvatar;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public List<Long> getCourseBadges() {
        return courseBadges;
    }

    public String getPrice4Phone() {
        return price4Phone;
    }

    public String getInstructorTitle() {
        return instructorTitle;
    }

    public String getCourseCategory() {
        return courseCategory;
    }
}
