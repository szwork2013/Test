package com.kaikeba.loaddata;

import android.content.Context;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.activity.LoginActivity2;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.CollectInfo;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.MicroInfo;
import com.kaikeba.common.util.DataSource;
import com.lidroid.xutils.exception.DbException;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mjliu on 14-8-11.
 */
public class LoadMyData {
    private static LoadMyData instance;

    private LoadMyData() {

    }

    public static LoadMyData getInstance() {
        if (instance == null) {
            instance = new LoadMyData();
        }
        return instance;
    }

    /**
     * 预加载我的收藏
     */
    public static void loadCollect(final Context mContext) {
        PretreatDataCache.loadCollectFromChche(mContext, new LoadCallBack() {
            @Override
            public void loadFinished(Object allCourseData) {
                if (allCourseData != null) {
                    addCollectList(allCourseData);
                }
            }
        });
    }

    private static void addCollectList(Object allCourseData) {
        try {
            List<CollectInfo> oldList = DataSource.getDataSourse().findAllCollect();
            DataSource.getDataSourse().deleteCollectData(oldList);
            DataSource.getDataSourse().addCollectData(getCollectList((ArrayList<CourseModel>) allCourseData));
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private static List<CollectInfo> getCollectList(ArrayList<CourseModel> list) {
        List<CollectInfo> collectList = new ArrayList<CollectInfo>();
        for (int i = 0; i < list.size(); i++) {
            CollectInfo info = new CollectInfo();
            info.setConllect(true);
            info.setCourseId(list.get(i).getId());
            info.setUserId(API.getAPI().getUserObject().getId() + "");
            collectList.add(info);
        }
        return collectList;
    }

    /**
     * 预加载微专业
     */
    public static void loadMicroCourse(final Context mContext) {
        PretreatDataCache.loadMicroCourseFromChche(mContext, false, new LoadCallBack() {
            @Override
            public void loadFinished(Object allMicroData) {
                if (allMicroData != null) {
                    addMicroList(allMicroData);
                }
            }
        });
    }

    private static void addMicroList(Object allMicroData) {
        try {
            List<MicroInfo> oldList = DataSource.getDataSourse().findAllMicro();
            DataSource.getDataSourse().deleteMicroData(oldList);
            DataSource.getDataSourse().addMicroData(getMicroList((ArrayList<CourseInfo.MicroSpecialties>) allMicroData));
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private static List<MicroInfo> getMicroList(ArrayList<CourseInfo.MicroSpecialties> list) {
        List<MicroInfo> collectList = new ArrayList<MicroInfo>();
        for (int i = 0; i < list.size(); i++) {
            MicroInfo info = new MicroInfo();
            if (list.get(i).getJoin_status() == 1) {
                info.setJoin(true);
            } else {
                info.setJoin(false);
            }
            info.setUserId(API.getAPI().getUserObject().getId() + "");
            info.setMicroId(list.get(i).getId());
            collectList.add(info);
        }
        return collectList;
    }

    /**
     * 预加载我的导学课
     */
    public static void loadMyGuideCourse(final Context mContext) {
        PretreatDataCache.loadMyGuideCourse(mContext, new LoadCallBack() {
            @Override
            public void loadFinished(Object allGuideData) {

            }
        });
    }

    /**
     * 预加载我的公开课
     */
    public static void loadMyOpenCourse(final Context mContext) {
        PretreatDataCache.loadMyOpenCourse(mContext, new LoadCallBack() {
            @Override
            public void loadFinished(Object allGuideData) {

            }
        });
    }

    /**
     * 预加载我的证书
     * @param mContext
     */
    public static void loadMyCertificate(final Context mContext) {
        PretreatDataCache.loadMyCertificate(mContext, new LoadCallBack() {
            @Override
            public void loadFinished(Object myCertificate) {

            }
        });
    }
}
