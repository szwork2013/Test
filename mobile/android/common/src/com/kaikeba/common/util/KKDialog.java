package com.kaikeba.common.util;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.provider.Settings;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.kaikeba.common.R;

/**
 * Created by user on 14-7-7.
 */
public class KKDialog {

    public static boolean IS_LOADING = true;
    public static boolean LOADING_FAIL = false;

    private static KKDialog instance = null;
    private AlertDialog dialog = null;

    private KKDialog() {

    }

    public static KKDialog getInstance() {
        if (instance == null) {
            synchronized (KKDialog.class) {
                if (instance == null) {
                    instance = new KKDialog();
                }
            }
        }
        return instance;
    }

    public void showErollCourseDialog(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "请先注册此课程";
        String positiveTex = "确定";
        String negativeTex = "取消";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    public void showNoWifi2Play(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "您当前处于非wifi环境，播放视频可能产生额外的流量费用";
        String positiveTex = "继续播放";
        String negativeTex = "取消播放";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    public void showNoWifi2Doload(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "您当前处于非wifi环境，下载视频可能产生额外的流量费用";
        String positiveTex = "继续下载";
        String negativeTex = "取消下载";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    public void showNoNetPlayDialog(final Context context) {
        String content = "无网络连接，无法播放视频";
        String positiveTex = "连接网络";
        String negativeTex = "取消观看";
        showDialg(context, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(Settings.ACTION_SETTINGS);
                        context.startActivity(intent);
                        dismiss();
                    }
                },
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dismiss();
                    }
                }, content, positiveTex, negativeTex);
    }

    public void showNoNetToast(final Context context) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT);
        View contentView = View.inflate(context, R.layout.no_net_view, null);
        builder.setView(contentView);
        builder.setCancelable(false);
        final AlertDialog alertDialog = builder.create();
        alertDialog.setCanceledOnTouchOutside(true);
        alertDialog.show();
        TextView go_set = (TextView) contentView.findViewById(R.id.go_set);
        TextView go_cancle = (TextView) contentView.findViewById(R.id.go_cancle);
        go_set.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Intent intent = new Intent(Settings.ACTION_SETTINGS);
                context.startActivity(intent);
                alertDialog.dismiss();
            }
        });
        go_cancle.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });
    }

    public void showNoDataDialog(Context context, DialogInterface.OnClickListener positiveListener, DialogInterface.OnClickListener negativeListener) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_DARK);
        builder.setMessage("数据加载失败,是否重新加载!");
        builder.setPositiveButton("取消", positiveListener);
        builder.setNegativeButton("确定", negativeListener);
        dialog = builder.create();
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }

    public void showLoginDialog(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "您还没有登录账号，登录之后\n就可以开始学习啦！";
        String positiveTex = "去登录";
        String negativeTex = "再看看";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    public void showResetPsw(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "是否成功重置密码?";
        String positiveTex = "没有，重发邮件";
        String negativeTex = "是的，去登录";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    public void showConfirmMail(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener) {
        String content = "已发送至邮箱，请注意查阅";
        String positiveTex = "不，以后再去";
        String negativeTex = "去邮箱验证";
        showDialg(context, positiveListener, negativeListener, content, positiveTex, negativeTex);
    }

    private void showDialg(Context context, View.OnClickListener positiveListener, View.OnClickListener negativeListener, String content, String positiveTex, String negativeTex) {

        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT);
        View contentView = View.inflate(context, R.layout.no_net_view, null);
        TextView go_set = (TextView) contentView.findViewById(R.id.go_set);
        TextView go_cancle = (TextView) contentView.findViewById(R.id.go_cancle);
        TextView tv_dialog = (TextView) contentView.findViewById(R.id.tv_dialog);
        if (!TextUtils.isEmpty(content) && !TextUtils.isEmpty(positiveTex) && !TextUtils.isEmpty(negativeTex)) {
            tv_dialog.setText(content);
            go_set.setText(positiveTex);
            go_cancle.setText(negativeTex);
        }
        builder.setView(contentView);
        builder.setCancelable(false);
        dialog = builder.create();
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();
        go_set.setOnClickListener(positiveListener);
        go_cancle.setOnClickListener(negativeListener);
    }

    public void showLoadDataFailed(Context context) {
        show(context, R.layout.load_failed_view, "");
    }

    public void showLoadCourse(Context context, String loadingMsg) {
        show(context, R.layout.loading_view, loadingMsg);
    }

    public void showEnterCourse(Context context) {
        show(context, R.layout.enter_course_view, "");
    }

    private void show(Context context, int view_id, String loadingMsg) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT);
        View load_failed_view = View.inflate(context, view_id, null);
        TextView tv_msg = (TextView) load_failed_view.findViewById(R.id.tv_loading);
        if (!TextUtils.isEmpty(loadingMsg)) {
            tv_msg.setText(loadingMsg);
        }
        builder.setView(load_failed_view);
        dialog = builder.create();
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }


    public void showProgressBar(Context context, boolean loadFlag) {

        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT);
        View load_view = View.inflate(context, R.layout.progressdialog, null);
        TextView tv_msg = (TextView) load_view.findViewById(R.id.tv_loading);
        ProgressBar progressBar = (ProgressBar) load_view.findViewById(R.id.progressBar);
        ImageView loadFail = (ImageView) load_view.findViewById(R.id.load_fail);

//        builder.setView(load_view);
        dialog = builder.create();
        dialog.setView(load_view);

        if (loadFlag) {
            tv_msg.setText("加载中...");
            loadFail.setVisibility(View.GONE);
            progressBar.setVisibility(View.VISIBLE);
        } else {
            tv_msg.setText("加载失败，请稍后再试");
            loadFail.setVisibility(View.VISIBLE);
            progressBar.setVisibility(View.GONE);
        }
        dialog.setCanceledOnTouchOutside(false);
        dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface d) {
                dialog.dismiss();
            }
        });
        dialog.show();
        dialog.getWindow().setLayout(500, 500);
    }

    public void showGO3wDialg(Context context) {

        AlertDialog.Builder builder = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT);
        View contentView = View.inflate(context, R.layout.go_3w_view, null);
        TextView content_txt = (TextView) contentView.findViewById(R.id.content);
        //创建一个 SpannableString对象
//        SpannableString sp = new SpannableString("程序猿们正在完善,请先到开课吧网站查看");
//        sp.setSpan(new ForegroundColorSpan(context.getResources().getColor(R.color.txt_normal)), 0, 12,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
//        sp.setSpan(new ForegroundColorSpan(context.getResources().getColor(R.color.txt_blue)), 12, 14,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
//        sp.setSpan(new ForegroundColorSpan(context.getResources().getColor(R.color.txt_normal)), 14, 18,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

//        content_txt.setText(sp);
        builder.setView(contentView);
        builder.setCancelable(true);
        dialog = builder.create();
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();
    }

    public void dismiss() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }
}
