package com.example.myapp.test4;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import com.example.myapp.R;
import com.example.myapp.test4.adapter.ShareAdapter;
import com.example.myapp.test4.entity.ShareModel;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by sjyin on 14-9-28.
 */
public class GridViewTest extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main3);
        GridView gv_share = (GridView)findViewById(R.id.gv_share);
        final List<ShareModel> res = new ArrayList<ShareModel>();
        res.add(new ShareModel(R.drawable.wechat_default,"微信"));
        res.add(new ShareModel(R.drawable.wechat_default,"朋友圈"));
        res.add(new ShareModel(R.drawable.wechat_default,"QQ空间"));
        res.add(new ShareModel(R.drawable.wechat_default,"QQ"));
        res.add(new ShareModel(R.drawable.wechat_default,"微博"));
        res.add(new ShareModel(R.drawable.wechat_default,"腾讯微博"));
        res.add(new ShareModel(R.drawable.wechat_default,"人人网"));
        res.add(new ShareModel(R.drawable.wechat_default,"豆瓣网"));
        gv_share.setAdapter(new ShareAdapter(this,res));
        gv_share.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            }
        });
    }
}
