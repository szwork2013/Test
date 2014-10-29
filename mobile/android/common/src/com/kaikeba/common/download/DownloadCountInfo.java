package com.kaikeba.common.download;

public class DownloadCountInfo {

    private int allVideoCount;

    private int loadedVideo;

    private int readyLoadVideo;

    public int getAllVideoCount() {
        return allVideoCount;
    }

    public void setAllVideoCount(int allVideoCount) {
        this.allVideoCount = allVideoCount;
    }

    public int getLoadedVideo() {
        return loadedVideo;
    }

    public void setLoadedVideo(int loadedVideo) {
        this.loadedVideo = loadedVideo;
    }

    public int getReadyLoadVideo() {
        return readyLoadVideo;
    }

    public void setReadyLoadVideo(int readyLoadVideo) {
        this.readyLoadVideo = readyLoadVideo;
    }
}
