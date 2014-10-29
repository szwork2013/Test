package com.kaikeba.common.entity;

import java.util.ArrayList;
import java.util.List;


public class StaticDate {

    public static List<CourseModel> openCourseList = new ArrayList<CourseModel>();

    public static List<CourseModel> guideCourseList = new ArrayList<CourseModel>();

    public static void setGuideCourseList(List<CourseModel> mGuideCourseList) {
        if (mGuideCourseList == null) {
            guideCourseList = new ArrayList<CourseModel>();
        }
        StaticDate.guideCourseList = mGuideCourseList;
    }

    public static void setOpenCourseList(List<CourseModel> mOpenCourseList) {
        if (mOpenCourseList == null) {
            openCourseList = new ArrayList<CourseModel>();
        }
        StaticDate.openCourseList = mOpenCourseList;
    }

}
