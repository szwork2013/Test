package com.kaikeba.common.util;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import com.umeng.socialize.bean.RequestType;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.controller.UMServiceFactory;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.media.QQShareContent;
import com.umeng.socialize.media.QZoneShareContent;
import com.umeng.socialize.media.SinaShareContent;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.sso.*;
import com.umeng.socialize.weixin.controller.UMWXHandler;
import com.umeng.socialize.weixin.media.CircleShareContent;
import com.umeng.socialize.weixin.media.WeiXinShareContent;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Field;

/**
 * Created by baige on 14-7-17.
 */
public class CommonUtils {
    /**
     * 友盟分享设置
     */
    public static UMSocialService mController = UMServiceFactory.getUMSocialService("com.umeng.share",
            RequestType.SOCIAL);
    private static UMQQSsoHandler qqSsoHandler;
    private static QZoneSsoHandler qZoneSsoHandler;

    /**
     * 获取通知栏的高度
     *
     * @param context
     * @return
     */
    public static int getStatusBarHeight(Context context) {
        Class<?> c = null;
        Object obj = null;
        Field field = null;
        int x = 0, statusBarHeight = 0;
        try {
            c = Class.forName("com.android.internal.R$dimen");
            obj = c.newInstance();
            field = c.getField("status_bar_height");
            x = Integer.parseInt(field.get(obj).toString());
            statusBarHeight = context.getResources().getDimensionPixelSize(x);
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        return statusBarHeight;
    }

    // 获取屏幕的宽度
    public static int getScreenWidth(Context context) {
        int width = 0;
        Display disp = ((Activity) context).getWindowManager().getDefaultDisplay();
        width = disp.getWidth();
        return width;
    }

    // 获取屏幕的高度
    public static int getScreenHeight(Context context) {
        int height = 0;
        Display disp = ((Activity) context).getWindowManager().getDefaultDisplay();
        height = disp.getHeight();
        return height;
    }

    // 获取控件的高度
    public static int getViewHeight(View view) {
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        view.measure(w, h);
        int height = view.getMeasuredHeight();
        return height;
    }

    // 获取控件的高度
    public static int getViewWidth(View view) {
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        view.measure(w, h);
        int width = view.getMeasuredWidth();
        return width;
    }

    /**
     * 测量视图的大小
     *
     * @param child
     */
    public static void measureView(View child) {
        ViewGroup.LayoutParams p = child.getLayoutParams();
        if (p == null) {
            p = new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT);
        }

        int childWidthSpec = ViewGroup.getChildMeasureSpec(0,
                0 + 0, p.width);
        int lpHeight = p.height;
        int childHeightSpec;
        if (lpHeight > 0) {
            childHeightSpec = View.MeasureSpec.makeMeasureSpec(lpHeight, View.MeasureSpec.EXACTLY);
        } else {
            childHeightSpec = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        }
        child.measure(childWidthSpec, childHeightSpec);
    }

    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public static String formatLongToTimeStr(int l) {
        int hour = 0;
        int minute = 0;
        int second = 0;

        second = l / 1000;

        if (second >= 60) {
            minute = second / 60;
            second = second % 60;
        }
        if (minute >= 60) {
            hour = minute / 60;
            minute = minute % 60;
        }
        return (getTwoLength(hour) + ":" + getTwoLength(minute) + ":" + getTwoLength(second));
    }

    //TODO
    private static String getTwoLength(final int data) {
        if (data < 10) {
            return "0" + data;
        } else {
            return "" + data;
        }
    }
    // 获得可用的内存
    public static long getmem_UNUSED(Context mContext) {
        long MEM_UNUSED;
        // 得到ActivityManager
        ActivityManager am = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
        // 创建ActivityManager.MemoryInfo对象

        ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
        am.getMemoryInfo(mi);

        // 取得剩余的内存空间

        MEM_UNUSED = mi.availMem / 1024;
        return MEM_UNUSED;
    }

    // 获得总内存
    public static long getmem_TOLAL() {
        long mTotal;
        // /proc/meminfo读出的内核信息进行解释
        String path = "/proc/meminfo";
        String content = null;
        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(path), 8);
            String line;
            if ((line = br.readLine()) != null) {
                content = line;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        // beginIndex
        int begin = content.indexOf(':');
        // endIndex
        int end = content.indexOf('k');
        // 截取字符串信息

        content = content.substring(begin + 1, end).trim();
        mTotal = Integer.parseInt(content);
        return mTotal;
    }
    
    // 友盟分享设置
    private static void shareSetting(Context context) {
        // 首先在您的Activity中添加如下成员变量
        mController.getConfig().removePlatform(SHARE_MEDIA.EMAIL, SHARE_MEDIA.SMS);
        // 首先在您的Activity中添加如下成员变量
        mController = UMServiceFactory.getUMSocialService("com.umeng.share",
                RequestType.SOCIAL);
        mController.getConfig().removePlatform(SHARE_MEDIA.EMAIL, SHARE_MEDIA.SMS);

        String QQappID = "1101226009";
        String QQappKey = "AlzkSHyxiIxitwGq";

        //分享到  QQ
        qqSsoHandler = new UMQQSsoHandler((Activity) context, QQappID,
                QQappKey);
        qqSsoHandler.addToSocialSDK();

        //分享到  QQ空间
        qZoneSsoHandler = new QZoneSsoHandler((Activity) context, QQappID,
                QQappKey);
        qZoneSsoHandler.addToSocialSDK();

        String WeiXinappID = "wxef4c838d5f6cb77f";
        // 添加微信平台
        UMWXHandler wxHandler = new UMWXHandler(context, WeiXinappID);
        wxHandler.addToSocialSDK();
        // 支持微信朋友圈
        UMWXHandler wxCircleHandler = new UMWXHandler(context, WeiXinappID);
        wxCircleHandler.setToCircle(true);
        wxCircleHandler.addToSocialSDK();
        // 设置新浪SSO handler
        mController.getConfig().setSsoHandler(new SinaSsoHandler());
        // 设置腾讯微博SSO handler
        mController.getConfig().setSsoHandler(new TencentWBSsoHandler());
        //添加人人网SSO授权功能
        String RRappId = "270160";
        String RRAPI_KEY = "0d60afd0779b4126af1ff2b71e18ce6c";
        String RRSecret_Key = "908619d4f50147138e67f87a7ad888b3";
        RenrenSsoHandler renrenSsoHandler = new RenrenSsoHandler(context,
                RRappId, RRAPI_KEY,
                RRSecret_Key);
        mController.getConfig().setSsoHandler(renrenSsoHandler);
    }


    /**
     * 友盟分享设置
     *
     * @param context
     * @param share_url    分享的链接
     * @param share_title  分享的title
     * @param share_body   分享的内容
     * @param share_imgUrl 分享的图片链接
     *                     //     * @param share_videoUrl 分享的视频链接
     *                     //     * @param share_videoImgUrl 分享的视频图片URL
     *                     //     * @param share_videoTitle  分享的视频title
     *                     //当视频链接不为空的时候分享视频
     */
    public static void shareSettingContent(Context context, String share_url, String share_title,
                                           String share_body, String share_imgUrl, String sinaContent) {
        //  分享带视频的参数
        // ,String share_videoUrl,String share_videoImgUrl,String share_videoTitle
        shareSetting(context);
        String from = " ?social_share=";
        mController.setAppWebSite(SHARE_MEDIA.RENREN, share_url + from + "renren");
        mController.setAppWebSite(SHARE_MEDIA.SINA, share_url + from + "weibo");
        mController.setAppWebSite(SHARE_MEDIA.TENCENT, share_url + from + "t_weibo");
        mController.setAppWebSite(SHARE_MEDIA.DOUBAN, share_url + from + "douban");
//        mController.setAppWebSite(SHARE_MEDIA.QQ, share_url+from+"qq");


        SinaSsoHandler sinaSsoHandler = new SinaSsoHandler();
        sinaSsoHandler.addToSocialSDK();
        SinaShareContent sinaShareContent = new SinaShareContent();
        sinaShareContent.setShareContent(sinaContent);
        sinaShareContent.setTargetUrl(share_url + from + "weibo");
        sinaShareContent.setTitle(share_title);
        sinaShareContent.setShareImage(new UMImage(context,
                share_imgUrl));
        mController.setShareMedia(sinaShareContent);

        // 设置分享到微信的内容, 图片类型
        UMImage mUMImgBitmap = new UMImage(context,
                share_imgUrl);
        WeiXinShareContent weixinContent = new WeiXinShareContent(mUMImgBitmap);
        weixinContent.setTitle(share_title);
        weixinContent.setShareContent(share_body);
        weixinContent.setTargetUrl(share_url + from + "wechat");
        mController.setShareMedia(weixinContent);

        // 设置朋友圈分享的内容
        CircleShareContent circleMedia = new CircleShareContent(new UMImage(context,
                share_imgUrl));
        circleMedia.setShareContent(share_body);
        circleMedia.setTitle(share_title);
        circleMedia.setTargetUrl(share_url + from + "wechat_quan");
        mController.setShareMedia(circleMedia);
//        // 设置qq分享的内容
        QQShareContent qqShareContent = new QQShareContent();
        qqShareContent.setShareContent(share_body);
        qqShareContent.setTitle(share_title);
        qqShareContent.setShareImage(new UMImage(context,
                share_imgUrl));
        qqShareContent.setTargetUrl(share_url + from + "qq");
        mController.setShareMedia(qqShareContent);

        // 设置qq空间分享的内容
        QZoneShareContent qZoneShareContent = new QZoneShareContent();
        qZoneShareContent.setShareContent(sinaContent);
        qZoneShareContent.setTargetUrl(share_url + from + "qzone");
        qZoneShareContent.setTitle(share_title);
        qZoneShareContent.setShareImage(new UMImage(context,
                share_imgUrl));
        mController.setShareMedia(qZoneShareContent);

//        if(share_videoUrl!=null){
//            //设置分享视频
//            UMVideo umVideo = new UMVideo(share_videoUrl);
//            //设置视频缩略图
//            umVideo.setThumb(share_videoImgUrl);
//            umVideo.setTitle(share_videoTitle);
//            mController.setShareMedia(umVideo);
//        }
//        if(share_videoUrl!=null){
//            //// 视频分享，并且设置了腾讯微博平台的文字内容
//            UMVideo umVideo = new UMVideo(
//                    share_videoUrl);
//            umVideo.setThumb(share_videoImgUrl);
//            umVideo.setTitle(share_videoTitle);
//            TencentWbShareContent tencentContent = new TencentWbShareContent(share_body);
//             // 设置分享到腾讯微博的文字内容
//            tencentContent.setShareContent(share_body);
//             // 设置分享到腾讯微博的多媒体内容
//            mController.setShareMedia(tencentContent);
//        }


        // ** 其他平台的分享内容.除了上文中已单独设置了分享内容的微信、朋友圈、腾讯微博平台，
        // 剩下的其他平台的分享内容都为如下文字和UMImage  **
        mController.setShareContent(share_body);
        // 设置分享图片，参数2为图片的url.
        mController.setShareMedia(new UMImage(context,
                share_imgUrl));
        // 是否只有已登录用户才能打开分享选择页
        mController.openShare((Activity) context, false);


    }
}
