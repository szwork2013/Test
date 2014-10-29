package com.kaikeba.common.entity;

import java.io.Serializable;

public class Item implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = 8381910163895331300L;
    private Integer id;
    private Integer position;
    private String title;
    private Integer indent;
    private String type;
    private String html_url;
    private String url;
    private CompletionRequirement completion_requirement;

    private String videoUrl;
    private String downloadState;

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public String getDownloadState() {
        return downloadState;
    }

    public void setDownloadState(String downloadState) {
        this.downloadState = downloadState;
    }

    /**
     * @return the id
     */
    public Integer getId() {
        return id;
    }

    /**
     * @return the position
     */
    public Integer getPosition() {
        return position;
    }

    /**
     * @return the title
     */
    public String getTitle() {
        return title;
    }

    /**
     * @return the indent
     */
    public Integer getIndent() {
        return indent;
    }

    /**
     * @return the type
     */
    public String getType() {
        return type;
    }

    /**
     * @return the html_url
     */
    public String getHtmlUrl() {
        return html_url;
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @return the completion_requirement
     */
    public CompletionRequirement getCompletionRequirement() {
        return completion_requirement;
    }


    /**
     * Completion requirement for this module item
     *
     * @author ZhouKe
     */
    public class CompletionRequirement implements Serializable {
        /**
         *
         */
        private static final long serialVersionUID = -3361176678559832770L;
        private String type;
        private Integer min_score;
        private Boolean completed;

        /**
         * @return the type
         */
        public String getType() {
            return type;
        }

        /**
         * @return the min_score
         */
        public Integer getMinScore() {
            return min_score;
        }

        /**
         * @return the completed
         */
        public Boolean getCompleted() {
            return completed;
        }
    }
}
