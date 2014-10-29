package com.kaikeba.activity.fragment;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import com.kaikeba.ContextUtil;
import com.kaikeba.activity.AllCourseActivity;
import com.kaikeba.phone.R;

public class Lead4Fragment extends Fragment {
    private ImageView go_go;
    private SharedPreferences appPrefs;
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            int id = v.getId();
            switch (id) {
                case R.id.go_go:
                    Intent intent = new Intent(getActivity(), AllCourseActivity.class);
                    startActivity(intent);
                    SharedPreferences.Editor editor = appPrefs.edit();
                    editor.putBoolean(ContextUtil.isFirstLead, false);
                    editor.commit();
                    break;
                default:
                    break;
            }
        }
    };

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.unit_right_nav, container, false);
        initView(v);
        setListener();
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
    }

    public void onResume() {
        super.onResume();
    }

    public void onPause() {
        super.onPause();
    }

    private void initView(View v) {
        appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences", Activity.MODE_PRIVATE);
        go_go = (ImageView) v.findViewById(R.id.go_go);
    }

    private void setListener() {
        go_go.setOnClickListener(listener);
    }


}
