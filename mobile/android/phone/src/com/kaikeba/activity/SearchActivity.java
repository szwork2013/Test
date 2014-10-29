package com.kaikeba.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.*;
import com.iflyek.util.JsonParser;
import com.iflytek.cloud.*;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;
import com.kaikeba.ContextUtil;
import com.kaikeba.PretreatDataCache;
import com.kaikeba.adapter.CategoryCourseAdapter;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.common.api.SearchAPI;
import com.kaikeba.common.entity.*;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.*;
import com.kaikeba.phone.R;
import com.lidroid.xutils.DbUtils;
import com.lidroid.xutils.db.sqlite.Selector;
import com.lidroid.xutils.db.sqlite.WhereBuilder;
import com.lidroid.xutils.exception.DbException;

import java.util.*;

/**
 * Created by chris on 14-8-1.
 */
public class SearchActivity extends Activity implements View.OnClickListener {

    private static final int VOICE_ICON = 1;
    private static final int BACK_ICON = 2;
    private static final String TAG = "SearchActivity";
    /**
     * **************讯飞语音************************
     */
    private SpeechRecognizer mIat;
    private RecognizerDialog iatDialog;
    private ImageView voice_mic;
    private EditText tv_search;
    private TextView voice_cancle;
    private ImageView iv_clear;
    private RelativeLayout rl_container;
    private LinearLayout ll_no_courses;
    private TextView tv_no_course;

    private List<CourseModel> courses = new ArrayList<CourseModel>();
    private List<CourseModel> showCourses = new ArrayList<CourseModel>();

    private Toast mToast;

    /**
     * ***************获取所有课程*******************
     */
    private ListView lv_course;
    private ListView lv_history;
    private ListView lv_course_names;
    private List<String> hisList = new ArrayList<String>();
    private List<String> showHistory = new ArrayList<String>();
    private List<String> tempShowHistory = new ArrayList<String>();
    private DbUtils db;
    private HistoryAdapter hisAdapter;
    private NamesAdapter namesAdapter;
    private CategoryCourseAdapter ccAdapter;
    private TextView lv_course_header;
    private LinearLayout history_footer;
    private LinearLayout history_header;
    private String key = "";
    private String tempKey = "";

    private KeyWord keyWord = new KeyWord();

    private boolean flag = true;
    private int micro_flag = VOICE_ICON;
    private LinearLayout progressBar;

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            Log.i(TAG,"msg what = " + msg.what);
            goneProgressBar();
            switch (msg.what) {
                case 1:// 返回网络数据不为空
                    fillShowCourses();
                    break;
                case 0://联网错误
                case 2://返回网络数据为空
                case 3://返回码不为成功
                    getShowCoursesFromNative(key);
                    break;
                default:
                    break;
            }
        }
    };
    /*
     * 初始化监听器。
     */
    private InitListener mInitListener = new InitListener() {

        @Override
        public void onInit(int code) {
            if (code == ErrorCode.SUCCESS) {
                findViewById(R.id.voice_mic).setEnabled(true);
            }
        }
    };
    /*
     * 听写UI监听器
     */
    private RecognizerDialogListener recognizerDialogListener = new RecognizerDialogListener() {
        public void onResult(RecognizerResult results, boolean isLast) {
            String text = JsonParser.parseIatResult(results.getResultString());
            text = text.replace("。", "").replace("，", "").replace("？", "").replace("！", "");
            tv_search.append(text);
            tv_search.setSelection(tv_search.length());
        }

        /*
         * 识别回调错误.
         */
        public void onError(SpeechError error) {
            showTip(error.getPlainDescription(true));
        }

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_search);
        initData();
        initView();
    }

    private void initData() {
        // 初始化识别对象
        mIat = SpeechRecognizer.createRecognizer(this, mInitListener);
        // 初始化听写Dialog
        iatDialog = new RecognizerDialog(this, mInitListener);

        db = DbUtils.create(SearchActivity.this);
        db.configAllowTransaction(true);
        db.configDebug(true);
        loadAllCourseData();
    }

    protected void loadAllCourseData() {
        PretreatDataCache.loadCoursesFromCache(new LoadCallBack() {
            @Override
            public void loadFinished(Object data) {
                if (data != null) {
                    courses = (List<CourseModel>) data;
                }
            }
        });
    }

    private void getDbHistory() {
        try {
            List<History> hiss = db.findAll(History.class);
            if (hiss != null && hiss.size() > 0) {
                hisList.clear();
                showHistory.clear();
                for (History history : hiss) {
                    hisList.add(history.getName());
                }
                Collections.reverse(hisList);
                if (hisList.size() > 10) {
                    showHistory.addAll(hisList.subList(0, 10));
                } else {
                    showHistory.addAll(hisList);
                }
                showHistory();
                hisAdapter.notifyDataSetChanged();
            } else {
                showNoHistory();
            }
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private void showNoHistory() {
        rl_container.setVisibility(View.GONE);
    }

    private void initView() {
        mToast = Toast.makeText(this, "", Toast.LENGTH_SHORT);
        voice_mic = (ImageView) findViewById(R.id.voice_mic);
        voice_cancle = (TextView) findViewById(R.id.voice_cancle);
        iv_clear = (ImageView) findViewById(R.id.iv_clear);
        rl_container = (RelativeLayout) findViewById(R.id.rl_container);
        ll_no_courses = (LinearLayout) findViewById(R.id.ll_no_courses);
        tv_no_course = (TextView) findViewById(R.id.tv_no_course);
        tv_no_course.setText("未搜索到相关课程");
        progressBar = (LinearLayout) findViewById(R.id.load_progress_bar_layout);

        voice_cancle.setOnClickListener(this);
        voice_mic.setOnClickListener(this);
        iv_clear.setOnClickListener(this);

        tv_search = (EditText) findViewById(R.id.et_search);

        tv_search.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Log.e(TAG,"CharSequence="+s.toString() +" start = " + start +"  before =" +before +"  count="+count);
                String inPutTxt = s.toString();
                key = inPutTxt;
                voice_mic.setImageResource(R.drawable.micro_phone);
                micro_flag = VOICE_ICON;
                if (TextUtils.isEmpty(inPutTxt)) {
                    voice_cancle.setText("取消");
                    iv_clear.setVisibility(View.INVISIBLE);
                    flag = true;
                    goneProgressBar();
                    getDbHistory();
                } else {
                    voice_cancle.setText("搜索");
                    voice_cancle.setVisibility(View.VISIBLE);
                    iv_clear.setVisibility(View.VISIBLE);
                    if(!tempKey.equals(key)){
                        filterCourse(key);
                        tempKey = "";
                    }
                    tv_search.setSelection(key.length());
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ccAdapter = new CategoryCourseAdapter(this, showCourses, handler);
        lv_course = (ListView) findViewById(R.id.lv_course);
        lv_course_header = (TextView) (View.inflate(this, R.layout.filter_course_header, null).findViewById(R.id.course_header));
        lv_course.addHeaderView(lv_course_header, null, false);
        lv_course.setAdapter(ccAdapter);
        lv_course.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //跳转到单品页上
                Intent it = new Intent();
                Bundle b = new Bundle();
                b.putSerializable(ContextUtil.CATEGORY_COURSE, showCourses.get(position - 1));
                if (showCourses.get(position - 1).getType().equals("OpenCourse")) {
                    it.setClass(SearchActivity.this, OpenCourseActivity.class);
                } else {
                    it.setClass(SearchActivity.this, GuideCourseAcitvity.class);
                }
                it.putExtras(b);
                startActivity(it);
            }
        });

        history_footer = (LinearLayout) (View.inflate(this, R.layout.history_footer, null).findViewById(R.id.history_footer));
        history_header = (LinearLayout) (View.inflate(this, R.layout.history_header, null).findViewById(R.id.history_footer));
        TextView tv_history_footer = (TextView) history_footer.findViewById(R.id.tv_history_footer);
        tv_history_footer.setOnClickListener(this);
        hisAdapter = new HistoryAdapter();
        lv_history = (ListView) findViewById(R.id.lv_history);
        lv_history.addHeaderView(history_header);
        lv_history.addFooterView(history_footer, null, false);
        lv_history.setOnItemClickListener( new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if(position == 0)
                    return;
                if(showHistory != null){
                    String hisTxt = showHistory.get(position -1);
                    tempKey = hisTxt;
                    tv_search.setText(hisTxt);
                    filterCourse(hisTxt);
                }
            }
        });
        lv_history.setAdapter(hisAdapter);

        lv_course_names = (ListView) findViewById(R.id.lv_course_names);
        namesAdapter = new NamesAdapter();
        lv_course_names.setAdapter(namesAdapter);
        lv_course_names.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //显示搜索的课程
                CourseModel courseModel = showCourses.get(position);
                String hisTxt = courseModel.getName();
                tempKey = hisTxt;
                tv_search.setText(hisTxt);
                micro_flag = BACK_ICON;
                showCourses.clear();
                showCourses.add(courseModel);
                voice_mic.setImageResource(R.drawable.search_back);
                fillShowCoursesHeader();
            }
        });

        getDbHistory();

    }

    private void showTip(final String str) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mToast.setText(str);
                mToast.show();
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.iv_clear:
                tv_search.setText("");// 清空显示内容
                getDbHistory();
                break;

            case R.id.voice_cancle:
                Log.i(TAG,"搜索被点击");
                if ("取消".equals(voice_cancle.getText().toString().trim())) {
                    appointSkip();
                } else {
                    if (!TextUtils.isEmpty(key)) {
                        addHisList(key);
                    }
                    voice_mic.setImageResource(R.drawable.search_back);
                    micro_flag = BACK_ICON;
                    fillShowCoursesHeader();
                }
                break;

            case R.id.voice_mic:
                if (micro_flag == VOICE_ICON) {
                    voiceInput();
                } else {
                    appointSkip();
                }

                break;

            case R.id.tv_history_footer:
                //清空 showHistory 中的数据 和 数据库中的数据
                try {
                    db.deleteAll(History.class);
                    showHistory.clear();
                    hisList.clear();
                    lv_history.setVisibility(View.GONE);
                } catch (DbException e) {
                    e.printStackTrace();
                }

                break;

            default:
                break;
        }

    }

    private void voiceInput() {
        tv_search.setText("");// 清空显示内容
        setParam();
        // 显示听写对话框
        iatDialog.setListener(recognizerDialogListener);
        iatDialog.show();
    }

    private void showHistory() {
        rl_container.setVisibility(View.VISIBLE);
        rl_container.setBackgroundColor(Color.WHITE);
        lv_course.setVisibility(View.GONE);
        lv_history.setVisibility(View.VISIBLE);
        ll_no_courses.setVisibility(View.GONE);
        lv_course_names.setVisibility(View.GONE);

        voice_cancle.setVisibility(View.VISIBLE);
    }

    private void showCourseNames(){
        rl_container.setVisibility(View.VISIBLE);
        Log.i(TAG,"lv_course_names is visibilty false");
        rl_container.setBackgroundColor(Color.WHITE);
        lv_course_names.setVisibility(View.VISIBLE);
        lv_course.setVisibility(View.GONE);
        lv_history.setVisibility(View.GONE);
        ll_no_courses.setVisibility(View.GONE);
        voice_cancle.setVisibility(View.VISIBLE);
    }

    private void showCourse() {
        rl_container.setVisibility(View.VISIBLE);
        rl_container.setBackgroundColor(getResources().getColor(R.color.course_bg_color));
        lv_course.setVisibility(View.VISIBLE);
        lv_course_names.setVisibility(View.GONE);
        lv_history.setVisibility(View.GONE);
        ll_no_courses.setVisibility(View.GONE);
        hideSoftInput();
        iv_clear.setVisibility(View.INVISIBLE);
        voice_cancle.setVisibility(View.GONE);
    }

    private void hideSoftInput() {
        InputMethodControl.hideInputMethod(SearchActivity.this);
    }

    private void showNothing() {
        rl_container.setVisibility(View.VISIBLE);
        rl_container.setBackgroundColor(Color.WHITE);
        lv_course.setVisibility(View.GONE);
//        lv_history.setVisibility(View.GONE);
        lv_course_names.setVisibility(View.GONE);
        ll_no_courses.setVisibility(View.VISIBLE);
//        hideSoftInput();
    }

    private void addHisList(String newHis) {
        try {
            WhereBuilder builder = WhereBuilder.b("name", "=", newHis);
            List<History> hisName = db.findAll(Selector.from(History.class).where(builder));
            if(hisName != null && hisName.size() > 0){
                return;
            }
            db.save(new History(newHis));
        } catch (DbException e) {
            e.printStackTrace();
        }
    }

    private void filterCourse(String newHis) {
        showCourses.clear();
        //网络搜索 本地搜索
        if (NetworkUtil.isNetworkAvailable(this)) {
            if(flag == true ){
                flag = false;
                showProgressBar();
            }
            getShowCourseFromNet(newHis);
        } else {
            getShowCoursesFromNative(newHis);
        }
    }

    private void getShowCoursesFromNative(String newHis) {
        showCourses.clear();
        for (CourseModel course : courses) {
            if (course.getName().toLowerCase().contains(newHis.toLowerCase())) {
                showCourses.add(course);
            }
        }
        fillShowCourses();
    }

    private Thread thread;

    private void getShowCourseFromNet(final String newHis) {
        if(thread != null && thread.getState() != Thread.State.TERMINATED){
            Log.i(TAG,"thread state = " + thread.getState());
            thread.interrupt();
            thread = null;
            System.gc();
        }
        thread = new Thread( new Runnable() {//开启线程

            public void run() {
                Log.i(TAG, Thread.currentThread().getName() + " start");
                try {
                    keyWord.setKeyword(newHis);
                    ArrayList<SearchCourseItem> courseInfos = SearchAPI.getSearchCourse(keyWord);
                    Log.i(TAG,"courseInfos size = " + courseInfos.size());
                    if (courseInfos != null && courseInfos.size() > 0) {
                        Log.i(TAG,"courseInfos.get(0) id =" + courseInfos.get(0).getId());
                        Log.i(TAG,"courses size =" + courses.size());
                        for (SearchCourseItem courseItem : courseInfos) {
                            String courseItemId = courseItem.getId();
                            for (CourseModel courseModel : courses) {
                                if (courseModel.getId() == Integer.parseInt(courseItemId)) {
                                    showCourses.add(courseModel);
                                    break;
                                }
                            }
                        }
                        handler.sendEmptyMessage(1);
                    } else if (courseInfos != null) {
                        handler.sendEmptyMessage(2);
                    } else {
                        Log.i(TAG, "courseInfos == null");
                    }
                } catch (DibitsExceptionC e) {
                    e.printStackTrace();
                    handler.sendEmptyMessage(0);
                    return;
                }
            }
        });
        thread.start();

    }

    private void fillShowCourses() {
        if (showCourses.size() <= 0) {
            showNothing();
        } else {
            showCourseNames();
            namesAdapter.notifyDataSetChanged();
        }
    }

    private void fillShowCoursesHeader(){
        if (showCourses.size() <= 0) {
            showNothing();
            return;
        }
        showCourse();
        lv_course_header.setText("找到" + showCourses.size() + "个相关课程：");
        ccAdapter.notifyDataSetChanged();
    }

    /*
     * 参数设置
     *
     * @return
     */
    @SuppressLint("SdCardPath")
    public void setParam() {
        // 设置语言
        mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
        // 设置语言区域
        mIat.setParameter(SpeechConstant.ACCENT, "mandarin");
        // 设置语音前端点
        mIat.setParameter(SpeechConstant.VAD_BOS, "4000");
        // 设置语音后端点
        mIat.setParameter(SpeechConstant.VAD_EOS, "1000");
        // 设置标点符号
        mIat.setParameter(SpeechConstant.ASR_PTT, "1");
        // 设置音频保存路径
        mIat.setParameter(SpeechConstant.ASR_AUDIO_PATH, "/sdcard/iflytek/wavaudio.pcm");
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (SpeechUtility.getUtility() != null)
            SpeechUtility.getUtility().checkServiceInstalled();
    }

    @Override
    protected void onPause() {
        super.onPause();
        Constants.search_is_click = false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // 退出时释放连接
        mIat.cancel();
        mIat.destroy();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }
    public void appointSkip() {
            Intent intent = new Intent(SearchActivity.this, TabCourseActivity.class);
            intent.putExtra("TabTag", "Category");
            intent.putExtra("TabNum", 1);
            startActivity(intent);
            finish();
    }
    private class HistoryAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            if (showHistory != null) {
                return showHistory.size();
            }
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder viewHolder = null;
            if (convertView == null) {
                viewHolder = new ViewHolder();
                convertView = View.inflate(SearchActivity.this, R.layout.history_item, null);
                viewHolder.tv_his = (TextView) convertView.findViewById(R.id.history_item);
                convertView.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) convertView.getTag();
            }
            viewHolder.tv_his.setText(showHistory.get(position));

            return convertView;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public Object getItem(int position) {
            if (showHistory != null) {
                return showHistory.get(position);
            }
            return null;
        }

    }

    private class NamesAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            if (showCourses!= null) {
                return showCourses.size();
            }
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder viewHolder = null;
            if (convertView == null) {
                viewHolder = new ViewHolder();
                convertView = View.inflate(SearchActivity.this, R.layout.history_item, null);
                viewHolder.tv_his = (TextView) convertView.findViewById(R.id.history_item);
                convertView.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) convertView.getTag();
            }
            viewHolder.tv_his.setText(showCourses.get(position).getName());

            return convertView;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public Object getItem(int position) {
            if (showCourses != null) {
                return showCourses.get(position);
            }
            return null;
        }

    }

    class ViewHolder {
        TextView tv_his;
    }

    private void showProgressBar(){
        progressBar.setVisibility(View.VISIBLE);
    }

    private void goneProgressBar(){
        progressBar.setVisibility(View.GONE);
    }
}

