package com.kaikeba.common.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.R;

/**
 * Created by sjyin on 14-9-24.
 */
public class MyToast {

    private static Context context;
    private static MyToast instance;
    private MyToast(){
        super();
    }
    public static MyToast getInstance(){
        if(instance == null){
            instance = new MyToast();
            context = ContextUtil.getContext();
        }
        return instance;
    }

    public void okToast(String msg){
        Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        LayoutInflater inflate = (LayoutInflater)
                context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View v = inflate.inflate(R.layout.toast_activity, null);
        TextView tv = (TextView)v.findViewById(R.id.tv_toast);
        tv.setText(msg);
        toast.setView(v);
        toast.setDuration(Toast.LENGTH_SHORT);
        toast.show();
    }
}