package com.kaikeba.common.download;

import android.content.Context;
import android.database.Cursor;
import android.util.Log;
import com.kaikeba.common.api.API;
import com.kaikeba.common.util.Constants;
import com.lidroid.xutils.DbUtils;
import com.lidroid.xutils.HttpUtils;
import com.lidroid.xutils.db.converter.ColumnConverter;
import com.lidroid.xutils.db.converter.ColumnConverterFactory;
import com.lidroid.xutils.db.sqlite.ColumnDbType;
import com.lidroid.xutils.db.sqlite.Selector;
import com.lidroid.xutils.db.sqlite.WhereBuilder;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


public class DownloadManager2 {
    private final static String tag = "DownloadManager";

    private List<DownloadInfo4Course> downloadInfo4CourseList = new ArrayList<DownloadInfo4Course>();

    private List<DownloadInfo> infoList;

    /**
     * 最多线程数
     */
    private int maxDownloadThread = 3;

    private Context mContext;

    private DbUtils db;

    public DownloadManager2(Context appContext) {
        ColumnConverterFactory.registerColumnConverter(HttpHandler.State.class, new HttpHandlerStateConverter());
        mContext = appContext;
        db = DbUtils.create(mContext);
        if (API.getAPI().getUserObject() != null) {
            setDate();
        }
    }

    /**
     * 初始化数据
     */
    private void setDate() {
        if (infoList == null) {
            infoList = new ArrayList<DownloadInfo>();
        }
        try {
            WhereBuilder builder = WhereBuilder.b("userId", "=", API.getAPI().getUserObject().getId());
//        	infoList = db.findAll(DownloadInfo.class);
            infoList = db.findAll(Selector.from(DownloadInfo.class));
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
        if (infoList != null) {
            for (DownloadInfo info : infoList) {
                boolean isExist = false;
                for (DownloadInfo4Course info4Course : downloadInfo4CourseList) {
                    if (info4Course.getCourseId().equals(info.getCourseId())) {
                        info4Course.getDownloadInfoList().add(info);
                        isExist = true;
                        Log.i(tag, "setDate  1");
                        break;
                    }
                }
                if (!isExist) {
                    DownloadInfo4Course dCourseInfo = new DownloadInfo4Course();
                    dCourseInfo.setCourseId(info.getCourseId());
                    dCourseInfo.setCourseName(info.getCourseName());
                    dCourseInfo.getDownloadInfoList().add(info);
                    downloadInfo4CourseList.add(dCourseInfo);
                    Log.i(tag, "setDate  2");
                }
            }
        }
    }

    /**
     * 刷新数据
     */
    public void refreshDownloadInfo() {
        if (infoList != null) {
            infoList.clear();
        }
        downloadInfo4CourseList.clear();
        setDate();
    }

    public void clearCheckState() throws DbException {
        if (infoList != null) {
            for (DownloadInfo downloadInfo : infoList) {
                if (downloadInfo.getIs_child_selected()) {
                    downloadInfo.setIs_child_selected(false);
                    db.update(downloadInfo);
                }
            }
        }
    }

    public List<DownloadInfo> getDownloadInfoList() {
        return infoList;
    }

    public int getDownloadInfoListCount() {
        return downloadInfo4CourseList.size();
    }

    public DownloadInfo4Course getDownloadInfo(int index) {
        if (downloadInfo4CourseList.isEmpty()) {
            return null;
        }
        return downloadInfo4CourseList.get(index);
    }

    public int getDowninfo4CourseByGroupSelecedCount(int index) {
        int num = 0;
        for (DownloadInfo downloadInfo : downloadInfo4CourseList.get(index).getDownloadInfoList()) {
            if (downloadInfo.getIs_child_selected()) {
                num++;
            }
        }
        return num;
    }

    public int getAllSelecedCount() {
        int num = 0;
        for (DownloadInfo downloadInfo : infoList) {
            if (downloadInfo.getIs_child_selected()) {
                num++;
            }
        }
        return num;
    }

    public int getAllDownloadInfoCount() {
        return infoList.size();
    }

    public DownloadInfo getDownloadInfoByCourseId(String courseId, int itemId) {
        if (downloadInfo4CourseList.isEmpty()) {
            return null;
        }
        for (DownloadInfo4Course info4Course : downloadInfo4CourseList) {
            if (info4Course.getCourseId().equals(courseId)) {
                for (DownloadInfo info : info4Course.getDownloadInfoList()) {
                    if (info.getItemId().equals(String.valueOf(itemId))) {
                        return info;
                    }
                }
            }
        }
        return null;
    }

    public List<DownloadInfo4Course> getDownloadInfo4CourseList() {
        return downloadInfo4CourseList;
    }

    public void addCourseId(List<String> courseIds, String courseId) {
        if (!courseIds.contains(courseId)) {
            courseIds.add(courseId);
        }
    }

    public int getDownloadIngCount() {
        int num = 0;
        if (infoList != null) {
            for (DownloadInfo downloadInfo : infoList) {
                HttpHandler.State state = downloadInfo.getState();
                if (state.equals(HttpHandler.State.LOADING) || state.equals(HttpHandler.State.WAITING) || state.equals(HttpHandler.State.FAILURE)) {
                    num++;
                }
            }
        }
        return num;
    }

    public int getDownloadPauseCount() {
        int num = 0;
        if (infoList != null) {
            for (DownloadInfo downloadInfo : infoList) {
                HttpHandler.State state = downloadInfo.getState();
                if (state.equals(HttpHandler.State.CANCELLED)) {
                    num++;
                }
            }
        }
        return num;
    }

    /**
     * 创建新的下载信息
     *
     * @param onlyId
     * @param courseName
     * @param url
     * @param bgUrl
     * @param videoName
     * @param target
     * @param autoResume
     * @param autoRename
     * @param callback
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void addNewDownload(String onlyId, String courseName, String url, String bgUrl, String videoName, String target,
                               boolean autoResume, boolean autoRename,
                               final RequestCallBack<File> callback) throws DbException {
        if (infoList == null) {
            infoList = new ArrayList<DownloadInfo>();
        }
        DownloadInfo loadInfo = getNewDownloadInfo(onlyId, courseName, url, bgUrl, videoName, target, autoResume, autoRename, callback);
        for (DownloadInfo4Course info4Course : downloadInfo4CourseList) {
            for (DownloadInfo downloadInfo : info4Course.getDownloadInfoList()) {
                if (onlyId.equals(downloadInfo.getDownloadOnlyId())) {
                    return;
                }
            }
        }
        Log.i(tag, "addNewDownload");
        boolean isExist = false;
        for (DownloadInfo4Course info4Course : downloadInfo4CourseList) {
            if (onlyId.split("_")[1].equals(info4Course.getCourseId())) {
                isExist = true;
                info4Course.getDownloadInfoList().add(loadInfo);
                infoList.add(loadInfo);
                Log.i(tag, "db.save  1");
                db.saveBindingId(loadInfo);
                break;
            }
        }
        if (!isExist) {
            String courseId = onlyId.split("_")[1];
            DownloadInfo4Course dCourseInfo = new DownloadInfo4Course();
            dCourseInfo.setCourseId(courseId);
            dCourseInfo.setCourseName(courseName);
            dCourseInfo.getDownloadInfoList().add(loadInfo);
            downloadInfo4CourseList.add(dCourseInfo);
            infoList.add(loadInfo);
            Log.i(tag, "db.save  2");
            db.saveBindingId(loadInfo);
        }

    }

    private DownloadInfo getNewDownloadInfo(String onlyId, String courseName, String url, String bgUrl, String fileName, String target,
                                            boolean autoResume, boolean autoRename,
                                            final RequestCallBack<File> callback) {
        final DownloadInfo downloadInfo = new DownloadInfo();
        downloadInfo.setDownloadUrl(url);
        String userId = onlyId.split("_")[0];
        String courseId = onlyId.split("_")[1];
        String lms_course_id = onlyId.split("_")[2];
        String itemId = onlyId.split("_")[3];
        downloadInfo.setCourseId(courseId);
        downloadInfo.setLms_course_id(lms_course_id);
        downloadInfo.setItemId(itemId);
        downloadInfo.setLocalURL(Constants.PATH + userId + "/" + courseId + "/" + lms_course_id + "/" + itemId + "/" + fileName + ".mp4");
        downloadInfo.setUserId(userId);
        downloadInfo.setCourseName(courseName);
        downloadInfo.setAutoRename(autoRename);
        downloadInfo.setAutoResume(autoResume);
        downloadInfo.setFileName(fileName);
        downloadInfo.setBgUrl(bgUrl);
        downloadInfo.setFileSavePath(target);
        downloadInfo.setDownloadOnlyId(onlyId);
        HttpUtils http = new HttpUtils();
        http.configRequestThreadPoolSize(maxDownloadThread);
        HttpHandler<File> handler = http.download(url, target, autoResume, autoRename, new ManagerCallBack(downloadInfo, callback));
        downloadInfo.setHandler(handler);
        downloadInfo.setState(handler.getState());
        return downloadInfo;
    }

    /**
     * 继续下载全部
     *
     * @param callback
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void resumeDownloadAll(final RequestCallBack<File> callback) throws DbException {
        List<DownloadInfo> downloadInfos = getDownloadInfoList();
        if (downloadInfos != null) {
            for (DownloadInfo downloadInfo : downloadInfos) {
                HttpHandler.State state = downloadInfo.getState();
                if (state.equals(HttpHandler.State.LOADING)) continue;
                if (state.equals(HttpHandler.State.SUCCESS)) continue;
                if (state.equals(HttpHandler.State.FAILURE)) {
                    if (new File(downloadInfo.getFileSavePath()).exists()) {
                        new File(downloadInfo.getFileSavePath()).delete();
                    }
                    downloadInfo.setProgress(0);
                }
                HttpUtils http = new HttpUtils();
                http.configRequestThreadPoolSize(maxDownloadThread);
                HttpHandler<File> handler = http.download(
                        downloadInfo.getDownloadUrl(),
                        downloadInfo.getFileSavePath(),
                        downloadInfo.isAutoResume(),
                        downloadInfo.isAutoRename(),
                        new ManagerCallBack(downloadInfo, callback));
                downloadInfo.setHandler(handler);
                downloadInfo.setState(handler.getState());
                Log.i(tag, "db.saveOrUpdate  9");
                db.update(downloadInfo);
            }
        }
    }

    /**
     * 继续下载单个
     *
     * @param downloadInfo
     * @param callback
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void resumeDownload(DownloadInfo downloadInfo, final RequestCallBack<File> callback) throws DbException {
        HttpHandler.State state = downloadInfo.getState();
        if (state.equals(HttpHandler.State.LOADING)) return;
        if (state.equals(HttpHandler.State.SUCCESS)) return;
        if (state.equals(HttpHandler.State.FAILURE)) {
            if (new File(downloadInfo.getFileSavePath()).exists()) {
                new File(downloadInfo.getFileSavePath()).delete();
            }
            downloadInfo.setProgress(0);
        }
        HttpUtils http = new HttpUtils();
        http.configRequestThreadPoolSize(maxDownloadThread);
        HttpHandler<File> handler = http.download(
                downloadInfo.getDownloadUrl(),
                downloadInfo.getFileSavePath(),
                downloadInfo.isAutoResume(),
                downloadInfo.isAutoRename(),
                new ManagerCallBack(downloadInfo, callback));
        downloadInfo.setHandler(handler);
        downloadInfo.setState(handler.getState());
        Log.i(tag, "db.saveOrUpdate  8");
        db.update(downloadInfo);
    }

    /**
     * 删除已选中的下载项
     *
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void removeDownloadByCheck(DownloadInfo downloadInfo, int groupIndex) throws DbException {
        if (new File(downloadInfo.getFileSavePath()).exists()) {
            new File(downloadInfo.getFileSavePath()).delete();
        }
        HttpHandler<File> handler = downloadInfo.getHandler();
        if (handler != null && !handler.isCancelled()) {
            handler.cancel();
        }
        if (downloadInfo4CourseList.get(groupIndex).getDownloadInfoList().isEmpty()) {
            downloadInfo4CourseList.remove(groupIndex);
        }
        db.delete(downloadInfo);
        infoList.remove(downloadInfo);
    }

    /**
     * 删除下载项
     *
     * @param groupIndex
     * @param childIndex
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void removeDownload(int groupIndex, int childIndex) throws DbException {
        try {
            DownloadInfo downloadInfo = downloadInfo4CourseList.get(groupIndex).getDownloadInfoList().get(childIndex);
            removeDownload(downloadInfo, groupIndex);
        } catch (IndexOutOfBoundsException e) {
            e.printStackTrace();
        }
    }

    public void removeDownload(DownloadInfo downloadInfo, int groupIndex) throws DbException {
        if (new File(downloadInfo.getFileSavePath()).exists()) {
            new File(downloadInfo.getFileSavePath()).delete();
        }
        HttpHandler<File> handler = downloadInfo.getHandler();
        if (handler != null && !handler.isCancelled()) {
            handler.cancel();
        }
        downloadInfo4CourseList.get(groupIndex).getDownloadInfoList().remove(downloadInfo);
        if (downloadInfo4CourseList.get(groupIndex).getDownloadInfoList().isEmpty()) {
            downloadInfo4CourseList.remove(groupIndex);
        }
        infoList.remove(downloadInfo);
        db.delete(downloadInfo);
    }

    public void removeOneCourseDownload(int groupIndex) throws DbException {
        List<DownloadInfo> downloadInfoList = downloadInfo4CourseList.get(groupIndex).getDownloadInfoList();
        for (int i = 0; i < downloadInfoList.size(); i++) {
            removeDownload(downloadInfoList.get(i), groupIndex);
            i--;
        }
//        downloadInfo4CourseList.remove(groupIndex);
    }

    /**
     * 暂停下载任务
     *
     * @param groupIndex
     * @param childIndex
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void stopDownload(int groupIndex, int childIndex) throws DbException {
        DownloadInfo downloadInfo = downloadInfo4CourseList.get(groupIndex).getDownloadInfoList().get(childIndex);
        stopDownload(downloadInfo);
    }

    public void stopDownload(DownloadInfo downloadInfo) throws DbException {
        HttpHandler<File> handler = downloadInfo.getHandler();
        if (handler != null && !handler.isCancelled()) {
            if (downloadInfo.getState().equals(HttpHandler.State.SUCCESS)) {
                return;
            }
            if (downloadInfo.getState().equals(HttpHandler.State.FAILURE)) {
                if (new File(downloadInfo.getFileSavePath()).exists()) {
                    new File(downloadInfo.getFileSavePath()).delete();
                }
                downloadInfo.setProgress(0);
            }
            downloadInfo.setState(HttpHandler.State.CANCELLED);
            handler.cancel();
        } else {
            downloadInfo.setState(HttpHandler.State.CANCELLED);
        }
        Log.i(tag, "db.saveOrUpdate  2");
        db.update(downloadInfo);
    }

    /**
     * 暂停所有下载任务
     *
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void stopAllDownload() throws DbException {
        List<DownloadInfo> downloadInfos = getDownloadInfoList();
        if (downloadInfos != null) {
            for (DownloadInfo downloadInfo : downloadInfos) {
                HttpHandler<File> handler = downloadInfo.getHandler();
                if (downloadInfo.getState().equals(HttpHandler.State.SUCCESS)) {
                    continue;
                }
                if (downloadInfo.getState().equals(HttpHandler.State.FAILURE)) {
                    if (new File(downloadInfo.getFileSavePath()).exists()) {
                        new File(downloadInfo.getFileSavePath()).delete();
                    }
                    downloadInfo.setProgress(0);
                }
                if (handler != null && !handler.isCancelled()) {
                    handler.cancel();
                    downloadInfo.setState(HttpHandler.State.CANCELLED);
                } else {
                    downloadInfo.setState(HttpHandler.State.CANCELLED);
                }
            }
            Log.i(tag, "db.saveOrUpdateAll  1");
            db.updateAll(infoList);
        }
    }

    /**
     * 备份数据
     *
     * @throws com.lidroid.xutils.exception.DbException
     */
    public void backupDownloadInfoList() throws DbException {
        for (DownloadInfo4Course info4Course : downloadInfo4CourseList) {
            for (DownloadInfo downloadInfo : info4Course.getDownloadInfoList()) {
                HttpHandler<File> handler = downloadInfo.getHandler();
                if (handler != null) {
                    downloadInfo.setState(handler.getState());
                }
            }
        }
        Log.i(tag, "db.saveOrUpdateAll  2");
        db.updateAll(infoList);
    }

    public int getMaxDownloadThread() {
        return maxDownloadThread;
    }

    public void setMaxDownloadThread(int maxDownloadThread) {
        this.maxDownloadThread = maxDownloadThread;
    }

    /**
     * 下载管理状态回调类
     *
     * @author Super Man
     */
    public class ManagerCallBack extends RequestCallBack<File> {
        private DownloadInfo downloadInfo;
        private RequestCallBack<File> baseCallBack;

        private ManagerCallBack(DownloadInfo downloadInfo, RequestCallBack<File> baseCallBack) {
            this.baseCallBack = baseCallBack;
            this.downloadInfo = downloadInfo;
        }

        public RequestCallBack<File> getBaseCallBack() {
            return baseCallBack;
        }

        public void setBaseCallBack(RequestCallBack<File> baseCallBack) {
            this.baseCallBack = baseCallBack;
        }

        @Override
        public Object getUserTag() {
            if (baseCallBack == null) return null;
            return baseCallBack.getUserTag();
        }

        @Override
        public void setUserTag(Object userTag) {
            if (baseCallBack == null) return;
            baseCallBack.setUserTag(userTag);
        }

        @Override
        public void onStart() {
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                downloadInfo.setState(handler.getState());
            }
            try {
                Log.i(tag, "db.saveOrUpdate  3");
                db.update(downloadInfo);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            if (baseCallBack != null) {
                baseCallBack.onStart();
            }
        }

        @Override
        public void onCancelled() {
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                downloadInfo.setState(handler.getState());
            }
            try {
                Log.i(tag, "db.saveOrUpdate  4");
                db.update(downloadInfo);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            if (baseCallBack != null) {
                baseCallBack.onCancelled();
            }
        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                downloadInfo.setState(handler.getState());
            }
            downloadInfo.setFileLength(total);
            downloadInfo.setProgress(current);
            try {
                Log.i(tag, "db.saveOrUpdate  5");
                db.update(downloadInfo);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            if (baseCallBack != null) {
                baseCallBack.onLoading(total, current, isUploading);
            }
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                downloadInfo.setState(handler.getState());
            }
            try {
                Log.i(tag, "db.saveOrUpdate  6");
                db.update(downloadInfo);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            if (baseCallBack != null) {
                baseCallBack.onSuccess(responseInfo);
            }
        }

        @Override
        public void onFailure(HttpException error, String msg) {
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                downloadInfo.setState(handler.getState());
            }
            try {
                Log.i(tag, "db.saveOrUpdate  7");
                db.update(downloadInfo);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            if (baseCallBack != null) {
                baseCallBack.onFailure(error, msg);
            }
        }
    }


    private class HttpHandlerStateConverter implements ColumnConverter<HttpHandler.State> {

        @Override
        public HttpHandler.State getFieldValue(Cursor cursor, int index) {
            return HttpHandler.State.valueOf(cursor.getInt(index));
        }

        @Override
        public HttpHandler.State getFieldValue(String fieldStringValue) {
            if (fieldStringValue == null) return null;
            return HttpHandler.State.valueOf(fieldStringValue);
        }

        @Override
        public Object fieldValue2ColumnValue(HttpHandler.State fieldValue) {
            return fieldValue.value();
        }

        @Override
        public ColumnDbType getColumnDbType() {
            return ColumnDbType.INTEGER;
        }
    }
}
