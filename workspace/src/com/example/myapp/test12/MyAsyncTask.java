package com.example.myapp.test12;

import android.os.AsyncTask;
import android.util.Log;

import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Created by sjyin on 14-10-23.
 */
public class MyAsyncTask {


    public static void main(String[] args){
        MyTask myTask = new MyTask();
        myTask.execute();
        myTask.executeOnExecutor(Executors.newFixedThreadPool(7));


        Executors.newSingleThreadExecutor();
        Executors.newCachedThreadPool();

    }

    // 需要先继承AsyncTask接口，第一个参数是执行路径，第二个是进度，第三个是返回值
    public static class MyTask extends AsyncTask<String, Integer, ArrayList<Map<String, Object>>> {

        // 可以在这里执行耗时操作
        protected ArrayList<Map<String, Object>> doInBackground(String... params) {
            ArrayList<Map<String, Object>> list1 = null;
            Log.i("sjyin","do in back ground run");
            return list1;

        }

        // 表示任务执行之前的操作
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected void onProgressUpdate(Integer... values) {
            super.onProgressUpdate(values);
        }

        // 在这个方法里进行更新UI操作
        protected void onPostExecute(ArrayList<Map<String, Object>> result) {
            super.onPostExecute(result);
        }

    }

}
