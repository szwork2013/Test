package com.kaikeba.activity.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.adapter.AppraiseListAdapter;
import com.kaikeba.common.entity.Appraisement;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.phone.R;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by mjliu on 14-7-30.
 */
public class LookRemarkFragment extends Fragment implements View.OnClickListener {
    private final static String tag = "CourseArrangeFragment";
    private LayoutInflater inflater;
    private ArrayList<Appraisement> appraisementList;
    private ListView appraise_list;
    private AppraiseListAdapter appraiseListAdapter;
    private ImageView appraise_loading_fail;
    private RelativeLayout appraise_view_loading;
    private LinearLayout view_loading_fail;
    private CourseModel c;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.appraise_list_guide, container, false);
        c = (CourseModel) getArguments().getSerializable(ContextUtil.CATEGORY_COURSE);
        appraise_list = (ListView) v.findViewById(R.id.appraise_list);
        appraise_view_loading = (RelativeLayout) v.findViewById(R.id.view_loading);
        appraise_loading_fail = (ImageView) v.findViewById(R.id.loading_fail);
        view_loading_fail = (LinearLayout) v.findViewById(R.id.view_loading_fail);
        appraise_loading_fail.setOnClickListener(this);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        setData();
        loadAppraiseData(true);
    }

    private void setData() {
        appraisementList = new ArrayList<Appraisement>();
        appraiseListAdapter = new AppraiseListAdapter(getActivity(), appraisementList);
        appraise_list.setAdapter(appraiseListAdapter);
    }

    private void loadAppraiseData(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        Type type = new TypeToken<ArrayList<Appraisement>>() {
        }.getType();
        String url = HttpUrlUtil.EVALUATION + c.getId();
        ServerDataCache.getInstance().dataWithURL(url, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    if (appraisementList != null) {
                        appraisementList.clear();
                    }
                    appraisementList.addAll((List<Appraisement>) data);
                    showDataSuccess();
                } else if (appraisementList != null) {
                    showDataSuccess();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void showLoading() {
        appraise_view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        appraise_view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showDataSuccess() {
        appraiseListAdapter.notifyDataSetChanged();
        appraise_view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    public void onResume() {
        super.onResume();
    }

    @Override
    public void onClick(View v) {
        if (v.equals(appraise_loading_fail)) {
            if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                KKDialog.getInstance().showNoNetToast(getActivity());
            } else {
                showLoading();
                loadAppraiseData(true);
            }
        }
    }
}