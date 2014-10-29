package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import com.kaikeba.phone.R;


public class PaymentFragment extends Fragment {

    private WebView payment_webview;
    private String url;
    private View v;
    private ProgressBar progressBar;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        v = inflater.inflate(R.layout.payment, container, false);
        payment_webview = (WebView) v.findViewById(R.id.payment_webview);
        payment_webview.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                super.onProgressChanged(view, newProgress);
                progressBar.setProgress(newProgress);
                if (newProgress == 100) {
                    progressBar.setVisibility(View.GONE);
                }
            }
        });
        progressBar = (ProgressBar) v.findViewById(R.id.progressBar);
        url = getArguments().getString("url");
        if (url == null) {
            return v;
        }
        WebSettings webSettings = payment_webview.getSettings();
        webSettings.setJavaScriptEnabled(true);

        payment_webview.loadUrl(url);

        payment_webview.setWebViewClient(new WebViewClient() {
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }
        });
        return v;
    }
}
