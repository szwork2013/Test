package com.kaikeba.common.util;

import android.database.Cursor;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.*;
import com.lidroid.xutils.DbUtils;
import com.lidroid.xutils.db.sqlite.Selector;
import com.lidroid.xutils.db.sqlite.WhereBuilder;
import com.lidroid.xutils.db.table.TableUtils;
import com.lidroid.xutils.exception.DbException;

import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: test
 * Date: 7/24/13
 * Time: 4:43 PM
 * To change this template use File | Settings | File Templates.
 */
public class DataSource {

    private static DataSource dataSource;
    private DbUtils db;

    private DataSource() {
        db = DbUtils.create(ContextUtil.getContext());
        db.configAllowTransaction(true);
        db.configDebug(true);
    }

    public static DataSource getDataSourse() {
        if (dataSource == null) {
            dataSource = new DataSource();
        }
        return dataSource;
    }

    public boolean addData(DBUploadInfo info) throws DbException {
        return db.saveBindingId(info);
    }

    public DBUploadInfo selectData() throws DbException {
        DBUploadInfo info = db.findFirst(DBUploadInfo.class);
        return info;
    }

    public void deleteData(DBUploadInfo info) throws DbException {
        db.delete(info);
    }


    public void saveVideoPlayHistory(VideoPlayHistory videoPlayHistory) throws DbException {
        db.saveOrUpdate(videoPlayHistory);
    }

    public void updateVideoPlayHistory(VideoPlayHistory videoPlayHistory) throws DbException {
        db.update(videoPlayHistory);
    }

    public boolean IsExistAtVideoPlayHistory(VideoPlayHistory videoPlayHistory) throws DbException {
        boolean table_exist = db.tableIsExist(videoPlayHistory.getClass());
        if (table_exist) {
            Cursor c = db.execQuery("select * from " + TableUtils.getTableName(videoPlayHistory.getClass()) + " where lastVideoId=" + videoPlayHistory.getLastVideoId());
            if ((c != null) && (c.moveToFirst()) && (c.getCount() > 0)) {
                return true;
            }
        }
        return false;
    }

    public VideoPlayHistory selectVideoPlayHistory(int lastVideoId) throws DbException {
        VideoPlayHistory videoPlayHistory = db.findFirst(Selector.from(VideoPlayHistory.class).where("lastVideoId", "=", lastVideoId));
        return videoPlayHistory;
    }

    public void deleteVideoPlayHistory(VideoPlayHistory videoPlayHistory) throws DbException {
        db.delete(videoPlayHistory);
    }

    //    ------------------ 收藏信息
    public void addCollectData(List<CollectInfo> infoList) throws DbException {
        db.saveAll(infoList);
    }

    public void addCollectData(CollectInfo info) throws DbException {
        db.save(info);
    }

    public void deleteCollectData(CollectInfo info) throws DbException {
        db.delete(info);
    }

    public void deleteCollectData(List<CollectInfo> infoList) throws DbException {
        db.deleteAll(infoList);
    }

    public List<CollectInfo> findAllCollect() throws DbException {
        if (API.getAPI().alreadySignin()) {
            WhereBuilder builder = WhereBuilder.b("userId", "=", API.getAPI().getUserObject().getId());
            return db.findAll(Selector.from(CollectInfo.class).where(builder));
        }
        return null;
    }

    public List<CollectInfo> findAllTvCollect() throws DbException {
        return db.findAll(Selector.from(CollectInfo.class));
    }

    //    ------------------ 我的微专业信息
    public void addMicroData(List<MicroInfo> infoList) throws DbException {
        db.saveAll(infoList);
    }

    public void addMicroData(MicroInfo info) throws DbException {
        db.save(info);
    }

    public void deleteMicroData(List<MicroInfo> infoList) throws DbException {
        db.deleteAll(infoList);
    }

    public void deleteMicroData(MicroInfo info) throws DbException {
        db.delete(info);
    }

    public List<MicroInfo> findAllMicro() throws DbException {
        if (API.getAPI().alreadySignin()) {
            WhereBuilder builder = WhereBuilder.b("userId", "=", API.getAPI().getUserObject().getId());
            return db.findAll(Selector.from(MicroInfo.class).where(builder));
        }
        return null;
    }

    // --------------------tv 播放记录的信息
    public void addTvHistoryData(List<TvHistoryInfo> infoList) throws DbException {
        db.saveAll(infoList);
    }

    public void addTvHistoryData(TvHistoryInfo info) throws DbException {
        db.save(info);
    }

    public void deleteTvHistoryData(List<TvHistoryInfo> infoList) throws DbException {
        db.deleteAll(infoList);
    }

    public void deleteTvHistoryData(TvHistoryInfo info) throws DbException {
        db.delete(info);
    }

    public List<TvHistoryInfo> findAllTvHistory() throws DbException {
        return db.findAll(Selector.from(TvHistoryInfo.class));
    }

    public void updateTvHistory(TvHistoryInfo tvHistoryInfo) throws DbException {
        db.update(tvHistoryInfo);
    }
}
