package com.kaikeba.common.download;

import com.lidroid.xutils.db.annotation.Transient;
import com.lidroid.xutils.http.HttpHandler;

import java.io.File;

/**
 * 单个下载信息
 *
 * @author Super Man
 */
public class DownloadInfo {

    private long id;
    private String userId;
    private String courseId;
    private String courseName;
    private String lms_course_id;
    private String itemId;
    /**
     * 下载信息 handler
     */
    @Transient
    private HttpHandler<File> handler;
    /**
     * 下载状态
     */
    private HttpHandler.State state;
    /**
     * 下载路径
     */
    private String downloadUrl;
    /**
     * 文件名
     */
    private String fileName;
    /**
     * 保存路径
     */
    private String fileSavePath;
    /**
     * 下载进度
     */
    private long progress;
    /**
     * 文件长度
     */
    private long fileLength;
    /**
     * 是否自动开始
     */
    private boolean autoResume;
    /**
     * 是否重命名
     */
    private boolean autoRename;
    /**
     * 下载唯一ID userId_courseId_moduleId_itemId
     */
    private String downloadOnlyId;
    /**
     * 下载卡片北京URL
     */
    private String bgUrl;
    /**
     * 存储的本地路径
     */
    private String localURL;
    private boolean is_child_selected = false;
    private int groupIndex;
    private int childIndex;

    public DownloadInfo() {
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getLocalURL() {
        return localURL;
    }

    public void setLocalURL(String localURL) {
        this.localURL = localURL;
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getLms_course_id() {
        return lms_course_id;
    }

    public void setLms_course_id(String lms_course_id) {
        this.lms_course_id = lms_course_id;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getBgUrl() {
        return bgUrl;
    }

    public void setBgUrl(String bgUrl) {
        this.bgUrl = bgUrl;
    }

    public String getDownloadOnlyId() {
        return downloadOnlyId;
    }

    public void setDownloadOnlyId(String downloadOnlyId) {
        this.downloadOnlyId = downloadOnlyId;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public HttpHandler<File> getHandler() {
        return handler;
    }

    public void setHandler(HttpHandler<File> handler) {
        this.handler = handler;
    }

    public HttpHandler.State getState() {
        return state;
    }

    public void setState(HttpHandler.State state) {
        this.state = state;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFileSavePath() {
        return fileSavePath;
    }

    public void setFileSavePath(String fileSavePath) {
        this.fileSavePath = fileSavePath;
    }

    public long getProgress() {
        return progress;
    }

    public void setProgress(long progress) {
        this.progress = progress;
    }

    public long getFileLength() {
        return fileLength;
    }

    public void setFileLength(long fileLength) {
        this.fileLength = fileLength;
    }

    public boolean isAutoResume() {
        return autoResume;
    }

    public void setAutoResume(boolean autoResume) {
        this.autoResume = autoResume;
    }

    public boolean isAutoRename() {
        return autoRename;
    }

    public void setAutoRename(boolean autoRename) {
        this.autoRename = autoRename;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DownloadInfo)) return false;

        DownloadInfo that = (DownloadInfo) o;

        if (id != that.id) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return (int) (id ^ (id >>> 32));
    }

    public boolean getIs_child_selected() {
        return is_child_selected;
    }

    public void setIs_child_selected(boolean is_child_selected) {
        this.is_child_selected = is_child_selected;
    }

    public int getChildIndex() {
        return childIndex;
    }

    public void setChildIndex(int childIndex) {
        this.childIndex = childIndex;
    }

    public int getGroupIndex() {
        return groupIndex;
    }

    public void setGroupIndex(int groupIndex) {
        this.groupIndex = groupIndex;
    }
}
