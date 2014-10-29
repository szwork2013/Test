package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.List;

/**
 * Created by baige on 14-8-7.
 */
public class CourseArrange implements Serializable {
    private long id;
    private long course_id;
    private String name;
    private String position;
    private String unlock_at;
    private String workflow_state;
    private String require_sequential_progress;
    private List<Long> prerequisite_module_ids;
    private List<Items> items;


    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getCourse_id() {
        return course_id;
    }

    public void setCourse_id(long course_id) {
        this.course_id = course_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public String getUnlock_at() {
        return unlock_at;
    }

    public void setUnlock_at(String unlock_at) {
        this.unlock_at = unlock_at;
    }

    public String getWorkflow_state() {
        return workflow_state;
    }

    public void setWorkflow_state(String workflow_state) {
        this.workflow_state = workflow_state;
    }

    public String getRequire_sequential_progress() {
        return require_sequential_progress;
    }

    public void setRequire_sequential_progress(String require_sequential_progress) {
        this.require_sequential_progress = require_sequential_progress;
    }

    public List<Long> getPrerequisite_module_ids() {
        return prerequisite_module_ids;
    }

    public void setPrerequisite_module_ids(List<Long> prerequisite_module_ids) {
        this.prerequisite_module_ids = prerequisite_module_ids;
    }

    public List<Items> getItems() {
        return items;
    }

    public void setItems(List<Items> items) {
        this.items = items;
    }

    public static class Items implements Serializable {
        private long id;
        private long indent;
        private long position;
        private String title;      //    ": "第01周-导学",
        private String type;       // ": "Page",
        private String html_url;   //   ": "http://learn-test.kaikeba.com/courses/735/modules/items/23900",
        private String url;        //   "http://learn-test.kaikeba.com/api/v1/courses/735/pages/di-02zhou-dao-xue"
        private String downloadState;

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
        }

        public long getIndent() {
            return indent;
        }

        public void setIndent(long indent) {
            this.indent = indent;
        }

        public long getPosition() {
            return position;
        }

        public void setPosition(long position) {
            this.position = position;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getHtml_url() {
            return html_url;
        }

        public void setHtml_url(String html_url) {
            this.html_url = html_url;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getDownloadState() {
            return downloadState;
        }

        public void setDownloadState(String downloadState) {
            this.downloadState = downloadState;
        }
    }
}
