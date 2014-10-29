package com.kaikeba.common.entity;

import java.io.Serializable;


public class PromoInfo implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -9158019408676683820L;
    private Long id;
    private String sliderImage;
    private String courseTitle;
    private String courseBrief;

    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @return the sliderImage
     */
    public String getSliderImage() {
        return sliderImage;
    }

    /**
     * @return the courseTitle
     */
    public String getCourseTitle() {
        return courseTitle;
    }

    /**
     * @return the courseBrief
     */
    public String getCourseBrief() {
        return courseBrief;
    }
}
