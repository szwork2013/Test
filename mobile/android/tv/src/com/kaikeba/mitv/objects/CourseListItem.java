package com.kaikeba.mitv.objects;

import com.kaikeba.common.entity.Category;

/**
 * Created by kkb on 8/7/14.
 */
public class CourseListItem extends Category {
    private String courseDurationText;
    private String watchProgressText;
    private boolean isSelected;

    public CourseListItem(int courseId, String courseTitle, String courseDurationText, String watchProgressText) {
        this.id = courseId;
        this.name = courseTitle;
        this.courseDurationText = courseDurationText;
        this.watchProgressText = watchProgressText;
    }

    public String getCourseDurationText() {
        return courseDurationText;
    }

    public void setCourseDurationText(String courseDurationText) {
        this.courseDurationText = courseDurationText;
    }

    public String getWatchProgressText() {
        return watchProgressText;
    }

    public void setWatchProgressText(String watchProgressText) {
        this.watchProgressText = watchProgressText;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean isSelected) {
        this.isSelected = isSelected;
    }
}
