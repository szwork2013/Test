package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.adapter.CategoryAdapter;
import com.kaikeba.common.entity.Category;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.HttpUrlUtil;
import com.kaikeba.common.widget.CGridView;
import com.kaikeba.phone.R;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;


public class CategoryActivity extends Activity implements OnClickListener {

    private CGridView gv;
    private RelativeLayout ll_search;
    private CategoryAdapter categoryAdapter;
    private List<Category> categories = new ArrayList<Category>();
    private RelativeLayout view_loading;
    private LinearLayout view_loading_fail;

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    };
    private long exitTime = 0;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_category);

        initView();
        initData(true);
        initData(false);
    }

    private void initData(final boolean fromCache) {
        if (fromCache) {
            showloading();
        }
        String categoryUrl = HttpUrlUtil.CATEGORY;//"https://api.kaikeba.com/v1/category";
        Type type = new TypeToken<ArrayList<Category>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(categoryUrl, null, fromCache, type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {

                if (data != null) {
                    categories.clear();
                    categories.addAll((java.util.Collection<? extends Category>) data);
                    categoryAdapter.notifyDataSetChanged();
                    showSuccessData();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void initView() {
        ll_search = (RelativeLayout) findViewById(R.id.ll_search);
        view_loading = (RelativeLayout) findViewById(R.id.view_loading);
        view_loading_fail = (LinearLayout) findViewById(R.id.view_loading_fail);
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        ll_search.measure(w, h);
        int height = ll_search.getMeasuredHeight();
        Log.i("CategoryActivity", "height == " + height);
        ll_search.setOnClickListener(this);
        categoryAdapter = new CategoryAdapter(this, categories, handler, height);
        gv = (CGridView) findViewById(R.id.gv_categories);
        gv.setAdapter(categoryAdapter);
        gv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(CategoryActivity.this, CategoryCourseActivity.class);
                intent.putExtra("category", categories.get(position));
                startActivity(intent);
            }
        });
        view_loading_fail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                initData(true);
            }
        });

    }

    private void showSuccessData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.VISIBLE);
    }

    private void showloading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading_fail.setVisibility(View.GONE);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ll_search:
                Constants.search_is_click = true;
                Intent searIn = new Intent(this, SearchActivity.class);
                startActivity(searIn);
                break;
            default:

                break;
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("FindCourse"); //统计页面
        MobclickAgent.onResume(this);          //统计时长
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("FindCourse");
        MobclickAgent.onPause(this);
    }

    @Override
    public void onBackPressed() {
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            finish();
        }
    }

}

