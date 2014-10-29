package com.kaikeba.activity.view;

import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;


public class SigninWebViewClient extends WebViewClient {

    private Handler handler;
    private int step = 0;
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;

    public SigninWebViewClient(Handler handler, RelativeLayout view_loading, LinearLayout view_loading_fail) {
        super();
        this.handler = handler;
        this.view_loading = view_loading;
        this.view_loading_fail = view_loading_fail;
    }

    /* (non-Javadoc)
     * @see android.webkit.WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView, java.lang.String)
     */
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        view.loadUrl(url);
        return false;
    }

    /* (non-Javadoc)
     * @see android.webkit.WebViewClient#onPageStarted(android.webkit.WebView, java.lang.String, android.graphics.Bitmap)
     */
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        // TODO Auto-generated method stub
//        load_progressBar.setVisibility(View.GONE);
        view_loading.setVisibility(View.GONE);
        if (url.contains("auth?code") && step == 0) {
            step++;
            Uri uri = Uri.parse(url);
            String code = uri.getQueryParameter("code");

            Bundle bundle = new Bundle();
            bundle.putString("code", code);
            Message message = new Message();
            message.setData(bundle);
            handler.sendMessage(message);
//            new ExchangeTokenThread(url, view.getContext()).run();
        }
        super.onPageStarted(view, url, favicon);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        // TODO Auto-generated method stub
        super.onPageFinished(view, url);
    }

    public void onReceivedError(WebView view, int errorCode,
                                String description, String failingUrl) {
        view_loading_fail.setVisibility(View.VISIBLE);
        super.onReceivedError(view, errorCode, description, failingUrl);
    }
}
