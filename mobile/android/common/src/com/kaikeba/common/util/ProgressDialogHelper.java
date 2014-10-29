package com.kaikeba.common.util;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.os.Handler;
import com.lidroid.xutils.util.LogUtils;

public class ProgressDialogHelper {
    //
    private Activity mContext;
    // 等带对话框的标题
    private String mTitle;
    // 等待内容
    private String mMessage;

    private Handler handler;
    // 进度对话框
    private ProgressDialog progressDialog = null;

    public ProgressDialogHelper(Activity mContext, Handler handler) {
        this.mContext = mContext;
        this.handler = handler;
    }

    /**
     * 启用进度对话框
     *
     * @param title    进度框的标题
     * @param message  进度框显示的内容
     * @param callBack 回调的执行方法
     */
    public void showProgressDialog(String message,
                                   final ProgressCallBack callBack) {

        this.mMessage = message;
        progressDialog = new ProgressDialog(mContext);

        //设置ProgressDialog 标题
        progressDialog.setTitle(mTitle);
        //设置ProgressDialog 提示信息
        progressDialog.setMessage(mMessage);
        progressDialog.setIndeterminate(true);
        progressDialog.show();
        ImgLoaderUtil.threadPool.submit(new Runnable() {
            public void run() {
                try {
                    callBack.action();// 执行操作
                } catch (Exception e) {
                    LogUtils.e(e.getMessage(), e);
//                    handler.post(new Runnable(){
//                        public void run() {
//                            mContext.finish();
//                        };
//                    });
                } finally {
                    progressDialog.dismiss();
                    handler.post(new Runnable() {
                        public void run() {
                            mContext.finish();
                            ActivityManager activityMgr = (ActivityManager) mContext.getSystemService(Activity.ACTIVITY_SERVICE);
                            activityMgr.killBackgroundProcesses(mContext.getPackageName());
                            System.exit(0);
                        }

                        ;
                    });
                }
            }
        });
    }

    // 要在进度对话框显示时执行的操作
    public interface ProgressCallBack {
        public void action();
    }

}

