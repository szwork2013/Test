package com.kaikeba.mitv.Listener;


import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import com.kaikeba.mitv.MainActivity;

public class MoreOnKeyListener implements OnKeyListener {

    ViewPager vp;
    int index;

    public MoreOnKeyListener(ViewPager vp, int index) {
        this.vp = vp;
        this.index = index;
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
            Log.i("test", "按钮被点击了" + v.getId());
            vp.setCurrentItem(index);
            MainActivity.getMainActivity().updateTabBackground();
        }
        return false;
    }

}
