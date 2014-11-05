package com.imooc.pull_refresh_listview;

import android.app.Activity;
import android.os.Bundle;
import android.widget.*;
import com.example.myapp.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by sjyin on 14-11-4.
 */
public class MainActivity extends Activity {

    private ListView lv;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_refresh);
        lv = (ListView) findViewById(R.id.lv);

        String[] strings = {"img", "title"};//Map的key集合数组
        int[] ids = {R.id.item_img, R.id.item_txt};//对应布局文件的id
        SimpleAdapter simpleAdapter = new SimpleAdapter(this,
                getData(), R.layout.item, strings, ids);
        lv.setAdapter(simpleAdapter);
    }

    // 初始化一个List
    private List<HashMap<String, Object>> getData() {
        // 新建一个集合类，用于存放多条数据
        ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
        HashMap<String, Object> map = null;
        for (int i = 1; i <= 40; i++) {
            map = new HashMap<String, Object>();
            map.put("title", "人物" + i);
            map.put("time", "9月20日");
            map.put("info", "我通过了你的好友验证请求，现在我们可以开始对话啦");
            map.put("img", R.drawable.img_2);
            list.add(map);
        }
        return list;
    }
}
