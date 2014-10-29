package com.kaikeba.common.entity;

/**
 * 获取最新版本<br/>
 * http://{HOST}/dummy-api/latest-version.json
 *
 * @author ZhouKe
 */
public class LatestVersion {

    private String androidLatestVersion;
    private String androidDownload;

    /*
 {
  "iOSLatestVersion": "1.0.0",
  "iOSDownload": "http://www.baidu.com",
  "androidLatestVersion": "1.0.0",
  "androidDownload": "http://www.kaikeba.com"
 }
     */
    public LatestVersion(String latestVersion, String downloadURL) {
        this.androidLatestVersion = latestVersion;
        this.androidDownload = downloadURL;
    }

    /**
     * @return the latestVersion
     */
    public String getLatestVersion() {
        return androidLatestVersion;
    }

    /**
     * @return the downloadURL
     */
    public String getDownloadURL() {
        return androidDownload;
    }
}
