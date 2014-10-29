package com.kaikeba;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.view.View;
import com.iflytek.cloud.SpeechUtility;
import com.kaikeba.common.R;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.download.DownloadService;
import com.kaikeba.common.network.CreateDbHelper;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.memory.impl.WeakMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;

import java.io.File;
import java.util.LinkedList;
import java.util.List;


public class ContextUtil extends Application {

    public static final String isFirstLead = "isfirstlead";
    public static final String isFirstOpened = "ISUSEROPENED";
    public static final String CATEGORY_COURSE = "categorycourse";
    public static DownloadManager downloadManager;
    public static ImageLoader imageLoader = ImageLoader.getInstance();
    public static DisplayImageOptions options = new DisplayImageOptions.Builder()
            .showImageOnLoading(R.drawable.def_512x288) // 设置图片下载期间显示的图片
            .showImageForEmptyUri(R.drawable.def_512x288) // 设置图片Uri为空或是错误的时候显示的图片
            .showImageOnFail(R.drawable.def_512x288) // 设置图片加载或解码过程中发生错误显示的图片
            .cacheInMemory(false) // 设置下载的图片是否缓存在内存中
            .cacheOnDisc(true) // 设置下载的图片是否缓存在SD卡中
            .bitmapConfig(Bitmap.Config.RGB_565) // 设置图片的解码类型
//          .displayer(new RoundedBitmapDisplayer(20))//是否设置为圆角，弧度为多少
            .build();
    private static ContextUtil instance;
    private List<Activity> activityList = new LinkedList<Activity>();

    public static ContextUtil getContext() {
        return instance;
    }

    public static void initImageLoader(Context context) {
        File cacheDir = getContext().getCacheDir();
        long memorySize = Runtime.getRuntime().maxMemory() / 8;
        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(
                context).threadPoolSize(1)
                .threadPriority(Thread.NORM_PRIORITY - 2)
                .denyCacheImageMultipleSizesInMemory()
                .memoryCache(new WeakMemoryCache())
                .memoryCacheSize((int) memorySize)
                .diskCacheSize(100 * 1024 * 1024) // 50 Mb //缓存到文件的最大数据
                .discCacheFileCount(1000)              //文件数量
                .discCache(new UnlimitedDiscCache(cacheDir))
//                .writeDebugLogs()
//                .defaultDisplayImageOptions(options)
                .tasksProcessingOrder(QueueProcessingType.FIFO).build();
        ImageLoader.getInstance().init(config);
    }

    public static DownloadManager getDownloadManager() {
        return downloadManager;
    }

    public void setDownloadManager(DownloadManager downloadManager) {
        this.downloadManager = downloadManager;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        CreateDbHelper.setContext(this);
        CreateDbHelper.getInstance();
        SpeechUtility.createUtility(this, "appid=" + getString(R.string.app_id));

        downloadManager = DownloadService.getDownloadManager(this);
        if (NetUtil.getNetType(this) != Constants.NO_NET) {
            //全部开始下载
            try {
                downloadManager.resumeDownloadAll(new DownloadRequestCallBack());
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
        }
        initImageLoader(getApplicationContext());
    }

    public void addActivity(Activity activity) {
        activityList.add(activity);
    }

    public void exit() {
        for (Activity a : activityList) {
            a.finish();
        }
        System.exit(0);
    }

    public List<Activity> getActivityList() {
        return activityList;
    }

    public void removeActivity(Activity activity) {
        activityList.remove(activity);
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {
        @Override
        public void onStart() {
        }


        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            Constants.NET_IS_CHANGED = true;
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            Constants.NET_IS_CHANGED = false;
        }

        @Override
        public void onFailure(HttpException error, String msg) {
        }

        @Override
        public void onCancelled() {
            Constants.NET_IS_CHANGED = false;
        }
    }

}
