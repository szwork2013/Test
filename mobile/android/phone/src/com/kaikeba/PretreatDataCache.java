package com.kaikeba;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.activity.AllCourseActivity;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.API;
import com.kaikeba.common.entity.Certificate;
import com.kaikeba.common.entity.CourseInfo;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.PersionalCenterInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.HttpUrlUtil;

import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * Created by baige on 14-8-6.
 */
public class PretreatDataCache {
    public static void loadCourses(final Context mContext) {
        String allCourseUrl = HttpUrlUtil.COURSE_BASIC; //"https://api.kaikeba.com/v1/courses/basic";
        Type courseType = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(allCourseUrl, null, false, courseType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {

            }
        });
    }

    public static void loadMyGuideCourse(final Context mContext, final LoadCallBack callBack) {
        if (API.getAPI().alreadySignin()) {
            String guideCourseUrl = HttpUrlUtil.INSTRUCTIVE_COURSES;//"https://api.kaikeba.com/v1/instructive_courses";
            Type guideCourseType = new TypeToken<ArrayList<CourseModel>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(guideCourseUrl, null, false, guideCourseType, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    callBack.loadFinished(data);
                }
            });
            ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
                @Override
                public void onAuthenticationFail() {
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                }
            });
        }
    }

    public static void loadCoursesFromCache(final LoadCallBack callBack) {
        String allCourseUrl = HttpUrlUtil.COURSE_BASIC;//"https://api.kaikeba.com/v1/courses/basic";
        Type courseType = new TypeToken<ArrayList<CourseModel>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(allCourseUrl, null, true, courseType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                callBack.loadFinished(data);
            }
        });
    }

    public static void loadCollectFromChche(final Context mContext, final LoadCallBack callBack) {
        if (API.getAPI().alreadySignin()) {
            String allCollectUrl = HttpUrlUtil.ALL_COLLECTIONS;//"https://api.kaikeba.com/v1/collections/user";
            Type collectType = new TypeToken<ArrayList<CourseModel>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(allCollectUrl, null, false, collectType, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    callBack.loadFinished(data);
                }
            });
            ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
                @Override
                public void onAuthenticationFail() {
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                }
            });
        }
    }

    public static void loadMicroCourseFromChche(final Context mContext, boolean fromCache, final LoadCallBack callBack) {
        if (API.getAPI().alreadySignin()) {
            String allMicroCourseUrl = HttpUrlUtil.MY_MICRO_SPECIALTIES;//"https://api.kaikeba.com/v1/micro_specialties/user";
            Type type = new TypeToken<ArrayList<CourseInfo.MicroSpecialties>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(allMicroCourseUrl, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    callBack.loadFinished(data);
                }
            });
            ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
                @Override
                public void onAuthenticationFail() {
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                }
            });
        }
    }

    public static void loadMyOpenCourse(final Context mContext, final LoadCallBack callBack) {
        if (API.getAPI().alreadySignin()) {
            String openCourseUrl = HttpUrlUtil.OPEN_COURSES;//"https://api.kaikeba.com/v1/open_courses";
            Type openCourseType = new TypeToken<ArrayList<CourseModel>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(openCourseUrl, null, false, openCourseType, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    callBack.loadFinished(data);
                }
            });
            ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
                @Override
                public void onAuthenticationFail() {
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                }
            });
        }
    }

    public static void loadMyCertificate(final Context mContext,final LoadCallBack callBack) {
        if (API.getAPI().alreadySignin()) {
            String myCertificateUrl = HttpUrlUtil.MY_CERTIFICATE;//"https://api.kaikeba.com/v1/open_courses";
            Type certificateType = new TypeToken<ArrayList<Certificate>>() {
            }.getType();
            ServerDataCache.getInstance().dataWithURL(myCertificateUrl, null, false, certificateType, new ServerDataCache.LoadDataCallbacks() {
                @Override
                public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                    callBack.loadFinished(data);
                }
            });
            ServerDataCache.getInstance().loginOut401(new ServerDataCache.AuthenticationFailCallback() {
                @Override
                public void onAuthenticationFail() {
                    Intent i = new Intent(mContext, AllCourseActivity.class);
                    mContext.startActivity(i);
                    ((Activity) mContext).finish();
                }
            });
        }
    }
}
