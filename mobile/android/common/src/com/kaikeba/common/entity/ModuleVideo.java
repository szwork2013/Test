package com.kaikeba.common.entity;

import java.io.Serializable;
import java.util.List;

public class ModuleVideo implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = 6580797692460218581L;

    private long moduleID;

    private List<ItemVideo> videoList;

    public long getModuleID() {
        return moduleID;
    }

    public void setModuleID(long moduleID) {
        this.moduleID = moduleID;
    }

    public List<ItemVideo> getVideoList() {
        return videoList;
    }

    public void setVideoList(List<ItemVideo> videoList) {
        this.videoList = videoList;
    }

    public class ItemVideo implements Serializable {

        /**
         *
         */
        private static final long serialVersionUID = 403241031729307957L;
        private long itemID;
        private String itemTitle;
        private String videoURL;

        public long getItemID() {
            return itemID;
        }

        public void setItemID(long itemID) {
            this.itemID = itemID;
        }

        public String getItemTitle() {
            return itemTitle;
        }

        public void setItemTitle(String itemTitle) {
            this.itemTitle = itemTitle;
        }

        public String getVideoURL() {
            return videoURL;
        }

        public void setVideoURL(String videoURL) {
            this.videoURL = videoURL;
        }
    }
}
