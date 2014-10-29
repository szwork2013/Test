package com.kaikeba.mitv.utils;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.entity.CollectInfo;
import com.kaikeba.common.entity.TvHistoryInfo;
import com.kaikeba.common.entity.TvViewPagerInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.DataSource;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.CourseListItem;
import com.lidroid.xutils.exception.DbException;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by baige on 14-8-6.
 */
public class PretreatDataCache {

    public static void loadCoursesFromCache(final LoadCallBack callBack) {
        Type courseType = new TypeToken<ArrayList<CourseCardItem>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(UrlManager.getInstance().getCOURSES_URL(), null, true, courseType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                callBack.loadFinished(data);
            }
        });
    }


    public static void loadAllData() {
        String allCourseUrl = UrlManager.getInstance().getCOURSES_URL();
        Type all_course_type = new TypeToken<ArrayList<CourseCardItem>>() {
        }.getType();

        ServerDataCache.getInstance().dataWithURL(allCourseUrl, null, false, all_course_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
            }
        });
    }


    public static String getCollectedID() {
        List<CollectInfo> list;
        String id = "";
        try {
            list = DataSource.getDataSourse().findAllTvCollect();
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    id += list.get(i).getCourseId() + "-";
                }
                return id;
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return 0 + "";
    }

    public static void loadCollectFromChche(final LoadCallBack callBack) throws DbException {
        Type courseType = new TypeToken<ArrayList<CourseCardItem>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(UrlManager.getInstance().getCOURSES_URL(), null, true, courseType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    ArrayList<CourseCardItem> lst = getCollectCourses((ArrayList<CourseCardItem>) data);
                    callBack.loadFinished(lst);
                }
            }
        });


    }

    private static ArrayList<CourseCardItem> getCollectCourses(ArrayList<CourseCardItem> list) {
        ArrayList<CourseCardItem> collectCoures = new ArrayList<CourseCardItem>();
        try {
            List<CollectInfo> collectList = DataSource.getDataSourse().findAllTvCollect();
            if (collectList != null) {
                for (int j = collectList.size() - 1; j >= 0; j--) {
                    for (int i = 0; i < list.size(); i++) {
                        if (list.get(i).getId() == collectList.get(j).getCourseId()) {
                            collectCoures.add(list.get(i));
                            break;
                        }
                    }
                }
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return collectCoures;
    }

    public static void loadHistoryFromChche(final LoadCallBack callBack) throws DbException {
        Type courseType = new TypeToken<ArrayList<CourseCardItem>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(UrlManager.getInstance().getCOURSES_URL(), null, true, courseType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    callBack.loadFinished(getHistoryCourses((ArrayList<CourseCardItem>) data));
                }
            }
        });


    }

    private static ArrayList<CourseCardItem> getHistoryCourses(ArrayList<CourseCardItem> list) {
        ArrayList<CourseCardItem> historyCourse = new ArrayList<CourseCardItem>();
        try {
            List<TvHistoryInfo> historyList = DataSource.getDataSourse().findAllTvHistory();
            if (historyList != null) {
                for (int j = historyList.size() - 1; j >= 0; j--) {
                    for (int i = 0; i < list.size(); i++) {
                        if (list.get(i).getId() == historyList.get(j).getCourseId()) {
                            historyCourse.add(list.get(i));
                            break;
                        }
                    }
                }
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
        return historyCourse;
    }

    public static void loadCategory() {
        Type categoryType = new TypeToken<ArrayList<CourseListItem>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(UrlManager.getInstance().getCATEGORYURL(), null, false, categoryType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {

            }
        });
    }

    public static void loadData() {
        Type compile_recommend_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String compile_recommend_url = UrlManager.getInstance().getCOMPILE_RECOMMEND();
        ServerDataCache.getInstance().dataWithURL(compile_recommend_url, null, false, compile_recommend_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {

            }
        });

        Type guess_like_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String guess_like_url = UrlManager.getInstance().getGUESS_LIKE();
        ServerDataCache.getInstance().dataWithURL(guess_like_url, null, false, guess_like_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
            }
        });

        Type hot_recommend_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String hot_recommend_url = UrlManager.getInstance().getHOT_RECOMMEND();
        ServerDataCache.getInstance().dataWithURL(hot_recommend_url, null, false, hot_recommend_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
            }
        });

        Type viwepager_type = new TypeToken<ArrayList<TvViewPagerInfo>>() {
        }.getType();
        String viwepager_url = UrlManager.getInstance().getVIWEPAGER();
        ServerDataCache.getInstance().dataWithURL(viwepager_url, null, false, viwepager_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
            }
        });
    }

}
