package com.kaikeba.common.download;

import java.util.ArrayList;
import java.util.List;

/**
 * 下载信息（根据课程分类）
 *
 * @author Super Man
 */
public class DownloadInfo4Course {

    private long id;

    private String courseId;

    private String courseName;

    private List<DownloadInfo> downloadInfoList;
    private boolean is_seleced = false;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public boolean getIs_seleced() {
        return is_seleced;
    }

    public void setIs_seleced(boolean is_seleced) {
        this.is_seleced = is_seleced;
    }

    public List<DownloadInfo> getDownloadInfoList() {
        if (downloadInfoList == null) {
            downloadInfoList = new ArrayList<DownloadInfo>();
        }
        return downloadInfoList;
    }

    public void setDownloadInfoList(
            List<DownloadInfo> downloadInfoList) {
        this.downloadInfoList = downloadInfoList;
    }
}
