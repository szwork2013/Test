package com.kaikeba.common.util;

import android.app.Activity;
import com.umeng.socialize.controller.UMServiceFactory;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.sso.QZoneSsoHandler;
import com.umeng.socialize.sso.RenrenSsoHandler;
import com.umeng.socialize.sso.SinaSsoHandler;
import com.umeng.socialize.sso.UMQQSsoHandler;

/**
 * Created by chris on 14-7-29.
 */
public class UMLoginController {

    public static UMLoginController controller;
    public String REDIRECT_URL = "http://sns.whalecloud.com/sina2/callback";
    private String QQappID = "1101226009";
    private String QQappKey = "AlzkSHyxiIxitwGq";
    private String RENREN_API_KEY = "0d60afd0779b4126af1ff2b71e18ce6c";
    private String RENREN_SECRET_KEY = "908619d4f50147138e67f87a7ad888b3";
    private String RENREN_APP_ID = "270160";
    private String SINA_APP_KEY = "108795687";
    private String SINA_APP_SECRET = "602ea1a182cf078e5a7d2b1c9829ba3d";

    private UMLoginController() {

    }

    public static UMLoginController getController() {
        if (controller == null) {
            synchronized (UMLoginController.class) {
                if (controller == null) {
                    controller = new UMLoginController();
                }
            }
        }
        return controller;
    }

    public UMSocialService getUMSocialService(Activity context) {
        //QQ
//        mTencent = Tencent.createInstance("100424468", context);
//        qqListener = new MIUiListener();
        //授权新浪、QQ、人人 SSO 登陆
        UMSocialService mloginController = UMServiceFactory.getUMSocialService("com.umeng.login");
        mloginController.getConfig().setSsoHandler(new SinaSsoHandler());
        mloginController.getConfig().setSsoHandler(new UMQQSsoHandler(context, QQappID, QQappKey));
        mloginController.getConfig().setSsoHandler(new RenrenSsoHandler(context, RENREN_APP_ID, RENREN_API_KEY, RENREN_SECRET_KEY));
        /*UMQQSsoHandler qqSsoHandler = new UMQQSsoHandler(context,QQappID,QQappKey);
        qqSsoHandler.addToSocialSDK();*/
        return mloginController;
    }
}
