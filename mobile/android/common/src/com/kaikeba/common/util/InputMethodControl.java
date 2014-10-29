package com.kaikeba.common.util;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import com.kaikeba.ContextUtil;

/**
 * 软件盘控制器
 * Created by sjyin on 14-9-4.
 */
public class InputMethodControl {

    private static final String TAG = "InputMethodControl";
    private static Context context = ContextUtil.getContext();

    public static boolean isActive() {
        InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
        return imm.isActive();//isOpen若返回true，则表示输入法打开
    }

    public static void hideOrShowInputMethod() {
        InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
    }

    /**
     * @param targetView 软键盘所在的Activity
     */
    public static void hideInputMethod(Activity targetView) {
        Log.i(TAG, "current inputmethod is open == " + isActive());
        if (isActive()) {
            ((InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE)).
                    hideSoftInputFromWindow(targetView.getCurrentFocus().getWindowToken(),
                            InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }

    /**
     * @param targetView 触发软键盘的View
     */
    public static void showInputMethod(View targetView) {
        if (!isActive()) {
            InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.showSoftInput(targetView, InputMethodManager.SHOW_FORCED);
        }
    }
}
