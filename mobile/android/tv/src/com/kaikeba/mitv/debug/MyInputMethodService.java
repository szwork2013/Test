package com.kaikeba.mitv.debug;

import android.inputmethodservice.InputMethodService;
import android.view.View;
import android.view.inputmethod.EditorInfo;

/**
 * Created by sjyin on 14-8-19.
 */
public class MyInputMethodService extends InputMethodService {
    public void onCreate() {
        super.onCreate();
        View decorView = getWindow().getWindow().getDecorView();
        String name = "MyInputMethodService";
        ViewServer.get(this).addWindow(decorView, name);
    }

    public void onDestroy() {
        super.onDestroy();
        View decorView = getWindow().getWindow().getDecorView();
        ViewServer.get(this).removeWindow(decorView);
    }

    public void onStartInput(EditorInfo attribute, boolean restarting) {
        super.onStartInput(attribute, restarting);
        View decorView = getWindow().getWindow().getDecorView();
        ViewServer.get(this).setFocusedWindow(decorView);
    }
}