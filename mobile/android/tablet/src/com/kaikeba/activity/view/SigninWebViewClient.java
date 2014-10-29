package com.kaikeba.activity.view;

import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;


public class SigninWebViewClient extends WebViewClient {

    private static final String LOGTAG = "OAuth";
    private Handler handler;
    private int step = 0;

    public SigninWebViewClient(Handler handler) {
        super();
        this.handler = handler;
    }

    /* (non-Javadoc)
     * @see android.webkit.WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView, java.lang.String)
     */
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        Log.d(LOGTAG, "shouldOverriderUrlLoading url = " + url);
        view.loadUrl(url);
        return false;
    }

    /* (non-Javadoc)
     * @see android.webkit.WebViewClient#onPageStarted(android.webkit.WebView, java.lang.String, android.graphics.Bitmap)
     */
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        // TODO Auto-generated method stub
        Log.d(LOGTAG, "onPageStarted url = " + url);

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
}
