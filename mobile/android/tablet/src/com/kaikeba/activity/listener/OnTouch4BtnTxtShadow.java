package com.kaikeba.activity.listener;

import android.content.Context;
import android.graphics.Color;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.phone.R;


public class OnTouch4BtnTxtShadow implements OnTouchListener {

    public static final byte LIGHT = 1;
    public static final byte DARK = 2;
    private Context context = ContextUtil.getContext();
    private TextView txt;
    private byte style;

    /**
     * 设置按钮上文字阴影的按压效果
     *
     * @param txt   文字TextView
     * @param style <br/>
     *              原本是亮色文字{@link OnTouch4BtnTxtShadow#LIGHT}<br/>
     *              原本是暗色文字{@link OnTouch4BtnTxtShadow#DARK}<br/>
     */
    public OnTouch4BtnTxtShadow(TextView txt, byte style) {
        this.txt = txt;
        this.style = style;
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        switch (style) {
            case LIGHT:
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    txt.setTextColor(context.getResources().getColor(R.color.txt_dlg_btn_gray));
                    txt.setShadowLayer(0.7f, 0.0f, 0.5f, Color.WHITE);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    txt.setTextColor(context.getResources().getColor(R.color.txt_dlg_btn_white));
                    txt.setShadowLayer(2.5f, 0.0f, 1.5f, R.color.shadow_black);
                }
                break;
            case DARK:
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    txt.setTextColor(context.getResources().getColor(R.color.txt_dlg_btn_white));
                    txt.setShadowLayer(2.5f, 0.0f, 1.5f, R.color.shadow_black);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    txt.setTextColor(context.getResources().getColor(R.color.txt_dlg_btn_gray));
                    txt.setShadowLayer(0.7f, 0.0f, 0.5f, Color.WHITE);
                }
            default:
                break;
        }

        return false;
    }

}
