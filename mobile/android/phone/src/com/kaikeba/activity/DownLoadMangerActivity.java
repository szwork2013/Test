package com.kaikeba.activity;

import android.app.AlertDialog;
import android.content.*;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.kaikeba.common.BaseClass.BaseActivity;
import com.kaikeba.common.download.DownloadInfo;
import com.kaikeba.common.download.DownloadInfo4Course;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.download.DownloadService;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.phone.R;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by user on 14-7-23.
 */
public class DownLoadMangerActivity extends BaseActivity implements View.OnClickListener {

    private final static String tag = "DownLoadMangerActivity";
    public TextView load_edit;
    private ExpandableListView exList;
    private DownLoadAdapter adapter;
    private LayoutInflater inflater;
    private DownloadManager downloadManager;
    private TextView start_all_load;
    private TextView stop_all_load;
    private LinearLayout ll_load_all_operation;
    private LinearLayout ll_load_edit_state;
    private TextView rel_load_check_all;
    private ImageView load_check_all;
    private TextView delete_already_check;
    private Button find_more_course;
    private int already_num;
    private Context mContext;
    private View.OnClickListener onClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            int id = view.getId();
            switch (id) {
                case R.id.start_all_load:
                    if (NetUtil.getNetType(mContext) != Constants.NO_NET) {
                        if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(DownLoadMangerActivity.this)) {
                            KKDialog.getInstance().showNoWifi2Doload(DownLoadMangerActivity.this,
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            Constants.nowifi_doload = false;
                                            allStart();
                                            refreshAllstartAllstopColor();
                                        }
                                    },
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                        }
                                    });
                        } else {
                            allStart();
                            refreshAllstartAllstopColor();
                        }
                    } else {
                        KKDialog.getInstance().showNoNetToast(DownLoadMangerActivity.this);
                    }
                    break;
                case R.id.stop_all_load:
                    if (NetUtil.getNetType(mContext) != Constants.NO_NET) {

                        allPause();
                        refreshAllstartAllstopColor();
                    } else {
                        KKDialog.getInstance().showNoNetToast(DownLoadMangerActivity.this);
                    }
                    break;
                case R.id.rel_load_check_all:
                    adapter.check_all_group();
                    adapter.check_all_child();
                    if (Constants.IS_ALL_CHECK) {
                        Constants.IS_ALL_CHECK = false;
                        rel_load_check_all.setText("全选");
//                        load_check_all.setImageResource(R.drawable.download_circle);
                    } else {
                        Constants.IS_ALL_CHECK = true;
                        rel_load_check_all.setText("取消全选");
//                        load_check_all.setImageResource(R.drawable.download_selected);
                    }
                    break;
                case R.id.delete_already_check:
                    if (already_num != 0) {
                        ConfirmExit();
                    }
                    break;
                case R.id.iv_back:
                    appointSkip();
                    break;
                case R.id.find_more_course:
                    Intent intent = new Intent(DownLoadMangerActivity.this, TabCourseActivity.class);
                    intent.putExtra("TabTag", "Category");
                    intent.putExtra("TabNum", 1);
                    startActivity(intent);
                    finish();
                    break;
            }
        }
    };
    private LinearLayout ll_load_no_empty;
    private RelativeLayout load_empty;
    private BroadcastReceiver netChangeRecevier;
    private int From_where;
    private TextView load_title;
    private ImageView iv_back;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.load_manager);
        mContext = this;
        inflater = LayoutInflater.from(mContext);
        Constants.IS_EDIT = false;
        initView();
        initData();
        initAdapter();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (netChangeRecevier != null) {
            unregisterReceiver(netChangeRecevier);
            netChangeRecevier = null;
        }
    }

    private void initView() {
        exList = (ExpandableListView) findViewById(R.id.expandableLoadmanager);
        iv_back = (ImageView) findViewById(R.id.iv_back);
        start_all_load = (TextView) findViewById(R.id.start_all_load);
        stop_all_load = (TextView) findViewById(R.id.stop_all_load);
        ll_load_all_operation = (LinearLayout) findViewById(R.id.ll_load_all_operation);
        ll_load_edit_state = (LinearLayout) findViewById(R.id.ll_load_edit_state);
        rel_load_check_all = (TextView) findViewById(R.id.rel_load_check_all);
        load_check_all = (ImageView) findViewById(R.id.load_check_all);
        delete_already_check = (TextView) findViewById(R.id.delete_already_check);
        load_empty = (RelativeLayout) findViewById(R.id.download_empty);
        ll_load_no_empty = (LinearLayout) findViewById(R.id.ll_download_no_empty);
        find_more_course = (Button) findViewById(R.id.find_more_course);
        load_edit = (TextView) findViewById(R.id.download_edit);
        load_edit.setOnClickListener(this);
        load_title = (TextView) findViewById(R.id.load_logo_loadmanager);
    }

    @Override
    public void onClick(View view) {
        if (!Constants.IS_EDIT) {
            Constants.IS_EDIT = true;
            load_edit.setText(getResources().getString(R.string.load_finish));
            edit_State();
        } else {
            Constants.IS_EDIT = false;
            load_edit.setText(getResources().getString(R.string.load_edit));
            edit_State();
        }
    }

    private void initData() {
        downloadManager = DownloadService.getDownloadManager(DownLoadMangerActivity.this);
    }

    private void initAdapter() {
        start_all_load.setOnClickListener(onClickListener);
        stop_all_load.setOnClickListener(onClickListener);
        rel_load_check_all.setOnClickListener(onClickListener);
        delete_already_check.setOnClickListener(onClickListener);
        iv_back.setOnClickListener(onClickListener);
        find_more_course.setOnClickListener(onClickListener);
        if (null == adapter) {
            adapter = new DownLoadAdapter();
        }
        exList.setAdapter(adapter);
        downloadInfoIsEmpty();

        netChangeRecevier = new NetChangeReceiver();
        //注册一个广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(Constants.NOTICE_NET_3G);
        this.registerReceiver(netChangeRecevier, filter);
    }

    public void goneEditButton() {
        load_edit.setVisibility(View.GONE);
    }

    public void downloadInfoIsEmpty() {
        if (downloadManager == null) {
            load_empty.setVisibility(View.VISIBLE);
            ll_load_no_empty.setVisibility(View.GONE);
            goneEditButton();
            edit_State();
        } else {
            if (downloadManager.getDownloadInfoList() != null) {
                if (downloadManager.getDownloadInfoList().size() == 0) {
                    load_empty.setVisibility(View.VISIBLE);
                    ll_load_no_empty.setVisibility(View.GONE);
                    goneEditButton();
                    edit_State();
                    Constants.IS_EDIT = false;
                    load_edit.setText(getResources().getString(R.string.load_edit));
                } else {
                    load_empty.setVisibility(View.GONE);
                    ll_load_no_empty.setVisibility(View.VISIBLE);
                    refreshAllstartAllstopColor();
                    edit_State();
                }
            } else {
                load_empty.setVisibility(View.VISIBLE);
                ll_load_no_empty.setVisibility(View.GONE);
                goneEditButton();
                edit_State();
            }

        }
    }

    public void edit_State() {
        if (Constants.IS_EDIT) {
            rel_load_check_all.setText("全选");
//            load_check_all.setImageResource(R.drawable.download_circle);
            Constants.IS_ALL_CHECK = false;
            ll_load_all_operation.setVisibility(View.GONE);
            ll_load_edit_state.setVisibility(View.VISIBLE);
            already_num = 0;
            setDeleteNum(0);
            try {
                downloadManager.clearCheckState();
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            adapter.clearGroupCheckState();
        } else {
            Constants.IS_ALL_CHECK = false;
            rel_load_check_all.setText("全选");
//            load_check_all.setImageResource(R.drawable.download_circle);
            ll_load_all_operation.setVisibility(View.VISIBLE);
            ll_load_edit_state.setVisibility(View.GONE);
            already_num = 0;
            setDeleteNum(0);
            try {
                downloadManager.clearCheckState();
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            adapter.clearGroupCheckState();

        }
        if (adapter != null) {
            adapter.notifyDataSetInvalidated();
        }
    }

    /**
     * 设置已选删除数量
     */
    public void setDeleteNum(int num) {
        if (num == 0) {
            delete_already_check.setText("删除");
            delete_already_check.setTextColor(getResources().getColor(R.color.text_download_normal));
        } else {
            delete_already_check.setText("删除(已选" + num + "个）");
            delete_already_check.setTextColor(getResources().getColor(R.color.text_color_delete));
        }
    }

    public void refreshAllstartAllstopColor() {
        if (NetUtil.getNetType(mContext) == Constants.NO_NET) {
            stop_all_load.setTextColor(getResources().getColor(R.color.text_download_normal));
            start_all_load.setTextColor(getResources().getColor(R.color.text_download_normal));
        } else {
            if (downloadManager.getDownloadIngCount() > 0) {
                stop_all_load.setTextColor(getResources().getColor(R.color.standard_blue));
            } else {
                stop_all_load.setTextColor(getResources().getColor(R.color.text_download_normal));
            }
            if (downloadManager.getDownloadPauseCount() > 0) {
                start_all_load.setTextColor(getResources().getColor(R.color.standard_blue));
            } else {
                start_all_load.setTextColor(getResources().getColor(R.color.text_download_normal));
            }
        }

    }

    /**
     * 全部暂停
     */
    public void allPause() {
        try {
            if (adapter != null && downloadManager != null) {
                downloadManager.stopAllDownload();
                adapter.notifyDataSetChanged();
                Constants.IS_ALL_DOWNLOAD = false;
            }
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    /**
     * 全部开始
     */
    public void allStart() {
        try {
            downloadManager.resumeDownloadAll(new DownloadManagerRequestCallBack());
//            }
            adapter.notifyDataSetChanged();
            Constants.IS_ALL_DOWNLOAD = true;
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    /**
     * 确认删除
     */
    public void ConfirmExit() {
        AlertDialog.Builder ad = new AlertDialog.Builder(DownLoadMangerActivity.this);
        ad.setTitle("删除视频");
        ad.setMessage("您确认删除已选视频么?");
        ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {

            }
        });
        ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
            @Override
            public void onClick(DialogInterface dialog, int i) {
                adapter.delete_already_check();
                downloadInfoIsEmpty();
            }
        });
        ad.show();
    }

    /**
     * 确认删除单个视频
     */
    public void ConfirmDeleteSingle(final DownloadInfo downloadInfo) {
        AlertDialog.Builder ad = new AlertDialog.Builder(DownLoadMangerActivity.this);
        ad.setTitle("删除视频");
        ad.setMessage("您确认删除已选视频么?");
        ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {

            }
        });
        ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
            @Override
            public void onClick(DialogInterface dialog, int i) {
                adapter.delete_one(downloadInfo);
                downloadInfoIsEmpty();
            }
        });
        ad.show();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        appointSkip();
    }

    public void appointSkip() {
        if (Constants.FROM_WHERE == Constants.FROM_USER_CENTET) {
            Constants.FROM_WHERE = 0;
            Intent intent = new Intent(DownLoadMangerActivity.this, TabCourseActivity.class);
            intent.putExtra("TabTag", "UserCenter");
            intent.putExtra("TabNum", 3);
            startActivity(intent);
            finish();
        } else {
            finish();
        }
    }

    private class NetChangeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Constants.NOTICE_NET_3G) && Constants.NET_IS_CHANGED) {
                allPause();
                refreshAllstartAllstopColor();
                KKDialog.getInstance().showNoWifi2Doload(DownLoadMangerActivity.this,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                allStart();
                                refreshAllstartAllstopColor();
                                KKDialog.getInstance().dismiss();
                                Constants.NET_IS_CHANGED = false;
                            }
                        },
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                KKDialog.getInstance().dismiss();
                                Constants.NET_IS_CHANGED = false;
                            }
                        });
            }
        }
    }

    private class DownloadManagerRequestCallBack extends RequestCallBack<File> {

        @SuppressWarnings("unchecked")
        private void refreshListItem() {
            if (userTag == null) return;
            try {
                WeakReference<ChildViewHolder> tag = (WeakReference<ChildViewHolder>) userTag;
                ChildViewHolder holder = tag.get();
                if (holder != null) {
                    holder.refresh();
                }
            } catch (ClassCastException e) {
                try {
                    WeakReference<GuideCourseLearnActivity.ChildViewHolder> tag = (WeakReference<GuideCourseLearnActivity.ChildViewHolder>) userTag;
                    GuideCourseLearnActivity.ChildViewHolder holder = tag.get();
                    if (holder != null) {
                        holder.refresh();
                    }
                } catch (ClassCastException e1) {
                    WeakReference<OpenCourseActivity.ChildViewHolder> tag = (WeakReference<OpenCourseActivity.ChildViewHolder>) userTag;
                    OpenCourseActivity.ChildViewHolder holder = tag.get();
                    if (holder != null) {
                        holder.refresh();
                    }
                }
            }

        }

        @Override
        public void onStart() {
            refreshListItem();
            refreshAllstartAllstopColor();
        }

        @Override
        public void onLoading(long total, long current, boolean isUploading) {
            refreshListItem();
            refreshAllstartAllstopColor();
            Constants.NET_IS_CHANGED = true;
        }

        @Override
        public void onSuccess(ResponseInfo<File> responseInfo) {
            refreshListItem();
            refreshAllstartAllstopColor();
            Constants.NET_IS_CHANGED = false;
        }

        @Override
        public void onFailure(HttpException error, String msg) {
            refreshListItem();
            refreshAllstartAllstopColor();
        }

        @Override
        public void onCancelled() {

            refreshListItem();
            refreshAllstartAllstopColor();
            Constants.NET_IS_CHANGED = false;
        }
    }

    public class ChildViewHolder {
        ImageView load_check_child;
        TextView load_video_name;
        ProgressBar load_video_progress;
        TextView load_video_size;
        ImageView load_video;
        View load_check_child_gone;
        DownloadInfo downloadInfo;
        DownLoadAdapter adapter;

        public ChildViewHolder(View v, DownloadInfo downloadInfo, DownLoadAdapter adapter) {
            load_check_child = (ImageView) v.findViewById(R.id.load_check_child);
            load_video_name = (TextView) v.findViewById(R.id.load_video_name);
            load_video_progress = (ProgressBar) v.findViewById(R.id.load_video_progress);
            load_video_size = (TextView) v.findViewById(R.id.load_video_size);
            load_video = (ImageView) v.findViewById(R.id.load_video);
            load_check_child_gone = v.findViewById(R.id.load_check_child_gone);
            this.downloadInfo = downloadInfo;
            this.adapter = adapter;
        }

        public void update(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
            refresh();
        }

        public void refresh() {
            //TODO
            adapter.notifyDataSetChanged();
        }
    }

    private class GroupViewHolder {
        ImageView load_check_group;
        TextView load_group_name;
        LinearLayout rel_download_group;
        ImageView download_down_up;

        public GroupViewHolder(View v) {
            load_check_group = (ImageView) v.findViewById(R.id.load_check_group);
            load_group_name = (TextView) v.findViewById(R.id.load_group_name);
            rel_download_group = (LinearLayout) v.findViewById(R.id.rel_download_group);
            download_down_up = (ImageView) v.findViewById(R.id.download_down_up);
        }
    }

    class childLoadClickListener implements View.OnClickListener {
        private DownloadInfo downloadInfo;

        public childLoadClickListener(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
        }

        @Override
        public void onClick(View v) {
            if (NetUtil.getNetType(mContext) != Constants.NO_NET) {
                if (downloadInfo != null) {
                    HttpHandler.State state = downloadInfo.getState();
                    switch (state) {
                        case STARTED:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case WAITING:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case LOADING:
                            try {
                                downloadManager.stopDownload(downloadInfo);
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;
                        case CANCELLED:
                            /*try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadManagerRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;*/
                        case FAILURE:
                            /*try {
                                downloadManager.resumeDownload(downloadInfo, new DownloadManagerRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            break;*/
                        default:
                            if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(DownLoadMangerActivity.this)) {
                                KKDialog.getInstance().showNoWifi2Doload(DownLoadMangerActivity.this,
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                                Constants.nowifi_doload = false;
                                                try {
                                                    downloadManager.resumeDownload(downloadInfo, new DownloadManagerRequestCallBack());
                                                } catch (DbException e) {
                                                    LogUtils.e(e.getMessage(), e);
                                                }
                                            }
                                        },
                                        new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                KKDialog.getInstance().dismiss();
                                            }
                                        });
                            } else {
                                try {
                                    downloadManager.resumeDownload(downloadInfo, new DownloadManagerRequestCallBack());
                                } catch (DbException e) {
                                    LogUtils.e(e.getMessage(), e);
                                }
                            }

                            break;
                    }
                }
                adapter.notifyDataSetChanged();
                refreshAllstartAllstopColor();
            } else {
                KKDialog.getInstance().showNoNetToast(DownLoadMangerActivity.this);
            }
        }
    }

    private class DownLoadAdapter extends BaseExpandableListAdapter {

        public void check_all_group() {
            if (Constants.IS_ALL_CHECK) {
                if (downloadManager != null) {
                    for (DownloadInfo4Course info4Course : downloadManager.getDownloadInfo4CourseList()) {
                        info4Course.setIs_seleced(false);
                    }
                    notifyDataSetChanged();
                }
            } else {
                if (downloadManager != null) {
                    for (DownloadInfo4Course info4Course : downloadManager.getDownloadInfo4CourseList()) {
                        info4Course.setIs_seleced(true);
                    }
                    notifyDataSetChanged();
                }
            }
        }

        public void clearGroupCheckState() {
            if (downloadManager != null) {
                for (DownloadInfo4Course info4Course : downloadManager.getDownloadInfo4CourseList()) {
                    info4Course.setIs_seleced(false);
                }
            }
        }

        public void check_all_child() {
            if (Constants.IS_ALL_CHECK) {
                if (downloadManager.getDownloadInfoList() != null) {
                    for (DownloadInfo downloadInfo : downloadManager.getDownloadInfoList()) {
                        already_num = 0;
                        setDeleteNum(already_num);
                        downloadInfo.setIs_child_selected(false);
                    }
                    notifyDataSetChanged();
                }
            } else {
                if (downloadManager.getDownloadInfoList() != null) {
                    for (DownloadInfo downloadInfo : downloadManager.getDownloadInfoList()) {
                        if (!downloadInfo.getIs_child_selected()) {
                            already_num++;
                            setDeleteNum(already_num);
                            downloadInfo.setIs_child_selected(true);
                        }
                    }
                    notifyDataSetChanged();
                }
            }

        }

        public void delete_already_check() {
//            Iterator<DownloadInfo> i = downloadManager.getDownloadInfoList().iterator();
//            while (i.hasNext()) {
//                DownloadInfo di = i.next();
//                if (di.getIs_child_selected()) {
//                    i.remove();
//                }
//            }
            List<DownloadInfo> removeDownloadList = new ArrayList<DownloadInfo>();
            for (DownloadInfo downloadInfo : downloadManager.getDownloadInfoList()) {
                if (downloadInfo.getIs_child_selected()) {
                    removeDownloadList.add(downloadInfo);
                }
            }
            for (DownloadInfo downloadInfo : removeDownloadList) {
                try {
                    downloadManager.removeDownloadByCheck(downloadInfo, downloadInfo.getGroupIndex());
                    already_num--;
                    setDeleteNum(already_num);
                } catch (DbException e) {
                    LogUtils.e(e.getMessage(), e);
                }
            }
            downloadManager.refreshDownloadInfo();
            notifyDataSetChanged();
        }

        public void delete_one(DownloadInfo downloadInfo) {
            try {
                downloadManager.removeDownloadByCheck(downloadInfo, downloadInfo.getGroupIndex());
                already_num--;
                setDeleteNum(already_num);
            } catch (DbException e) {
                LogUtils.e(e.getMessage(), e);
            }
            downloadManager.refreshDownloadInfo();
            notifyDataSetChanged();
        }

        @Override
        public int getGroupCount() {
            if (downloadManager == null) return 0;
            return downloadManager.getDownloadInfoListCount();
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (downloadManager == null) return 0;
            if (downloadManager.getDownloadInfo(groupPosition) == null) {
                return 0;
            }
            return downloadManager.getDownloadInfo(groupPosition).getDownloadInfoList().size();
        }

        @Override
        public DownloadInfo4Course getGroup(int groupPosition) {
            return downloadManager.getDownloadInfo(groupPosition);
        }

        @Override
        public DownloadInfo getChild(int groupPosition, int childPosition) {
            return downloadManager.getDownloadInfo(groupPosition).getDownloadInfoList().get(childPosition);

        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return 0;
        }

        @Override
        public boolean hasStableIds() {
            return false;
        }

        @Override
        public View getGroupView(final int groupPosition, boolean isExpanded, View convertView, ViewGroup viewGroup) {
            GroupViewHolder groupViewHolder = null;
            final DownloadInfo4Course info4Course = downloadManager.getDownloadInfo(groupPosition);
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.download_list_group, null);
                groupViewHolder = new GroupViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GroupViewHolder) convertView.getTag();
            }
            groupViewHolder.load_group_name.setText(info4Course.getCourseName());
            if (Constants.IS_EDIT) {
                groupViewHolder.load_check_group.setVisibility(View.VISIBLE);
            } else {
                groupViewHolder.load_check_group.setVisibility(View.GONE);
            }
            if (info4Course.getIs_seleced()) {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_select);
            } else {
                groupViewHolder.load_check_group.setImageResource(R.drawable.download_circle);
            }
            final GroupViewHolder finalGroupViewHolder = groupViewHolder;
            groupViewHolder.load_check_group.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (!info4Course.getIs_seleced()) {
                        finalGroupViewHolder.load_check_group.setImageResource(R.drawable.download_select);
                        info4Course.setIs_seleced(true);
                        if (downloadManager != null) {
                            for (DownloadInfo downloadInfo : info4Course.getDownloadInfoList()) {
                                if (!downloadInfo.getIs_child_selected()) {
                                    already_num++;
                                    setDeleteNum(already_num);
                                    downloadInfo.setIs_child_selected(true);
                                    Log.i(tag, "downloadInfo.getIs_child_selected()0:" + downloadInfo.getIs_child_selected());
                                }
                            }
                            notifyDataSetChanged();
                        }
                    } else {
                        finalGroupViewHolder.load_check_group.setImageResource(R.drawable.download_circle);
                        info4Course.setIs_seleced(false);
                        if (downloadManager != null) {
                            for (DownloadInfo downloadInfo : info4Course.getDownloadInfoList()) {
                                if (downloadInfo.getIs_child_selected()) {
                                    already_num--;
                                    setDeleteNum(already_num);
                                    downloadInfo.setIs_child_selected(false);
                                }
                            }
                            notifyDataSetChanged();
                        }
                    }
                    if (downloadManager.getAllSelecedCount() == downloadManager.getAllDownloadInfoCount()) {
                        Constants.IS_ALL_CHECK = true;
                        rel_load_check_all.setText("取消全选");
//                        load_check_all.setImageResource(R.drawable.download_selected);
                    } else {
                        Constants.IS_ALL_CHECK = false;
                        rel_load_check_all.setText("全选");
//                        load_check_all.setImageResource(R.drawable.download_circle);
                    }
                }
            });
            if (isExpanded) {
                groupViewHolder.download_down_up.setImageResource(R.drawable.download_up);
            } else {
                groupViewHolder.download_down_up.setImageResource(R.drawable.download_down);
            }
            return convertView;
        }

        @Override
        public View getChildView(final int groupPosition, final int childPosition, boolean b, View convertView, final ViewGroup viewGroup) {
            ChildViewHolder childHolder = null;
            final DownloadInfo downloadInfo = getChild(groupPosition, childPosition);
            final DownloadInfo4Course info4Course = downloadManager.getDownloadInfo(groupPosition);
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.download_list_child, null);
                childHolder = new ChildViewHolder(convertView, downloadInfo, this);
                convertView.setTag(childHolder);
                childHolder.refresh();
            } else {
                childHolder = (ChildViewHolder) convertView.getTag();
                childHolder.update(downloadInfo);
            }
            childHolder.load_video_name.setText(downloadInfo.getFileName());
            childHolder.load_video_size.setText(downloadInfo.getProgress() / 1024 / 1024 + "M/" + downloadInfo.getFileLength() / 1024 / 1024 + "M");
//            long all_fileLength = downloadInfo.getFileLength();
//            long current_filelth=downloadInfo.getProgress();
//            if (all_fileLength != 0) {
//                long all_fileMbSize =  all_fileLength / 1024 / 1024;
//                long current_fileMbSize=current_filelth/1024/1024;
//                childHolder.load_video_size.setText(current_fileMbSize + "M/"+all_fileMbSize+"M");
//            }
            if (downloadInfo.getFileLength() > 0) {
                childHolder.load_video_progress.setProgress((int) (downloadInfo.getProgress() * 100 / downloadInfo.getFileLength()));
            } else {
                childHolder.load_video_progress.setProgress(0);
            }
            childHolder.load_video.setVisibility(View.VISIBLE);
            HttpHandler.State state = downloadInfo.getState();
            switch (state) {
                case WAITING:
                    childHolder.load_video.setImageResource(R.drawable.download_wait);
                    if (downloadInfo.getProgress() > 0 && downloadInfo.getProgress() == downloadInfo.getFileLength()) {
                        downloadInfo.setState(HttpHandler.State.SUCCESS);
                        childHolder.load_video.setImageResource(R.drawable.download_done);
                    }
                    break;
                case STARTED:
                    childHolder.load_video.setImageResource(R.drawable.download_stop);
                    break;
                case LOADING:
                    childHolder.load_video.setImageResource(R.drawable.download_stop);
                    break;
                case CANCELLED:
                    childHolder.load_video.setImageResource(R.drawable.download_start);
                    break;
                case SUCCESS:
                    childHolder.load_video.setImageResource(R.drawable.download_done);
                    if (downloadInfo.getProgress() != downloadInfo.getFileLength()) {
                        downloadInfo.setState(HttpHandler.State.FAILURE);
                        childHolder.load_video.setImageResource(R.drawable.download_error_item);
                    }
                    break;
                case FAILURE:
                    childHolder.load_video.setImageResource(R.drawable.download_error_item);
                    break;

            }
            if (Constants.IS_EDIT) {
                childHolder.load_check_child.setVisibility(View.VISIBLE);
                childHolder.load_video.setVisibility(View.GONE);
                childHolder.load_check_child_gone.setVisibility(View.VISIBLE);

            } else {
                childHolder.load_check_child.setVisibility(View.GONE);
                childHolder.load_video.setVisibility(View.VISIBLE);
                childHolder.load_check_child_gone.setVisibility(View.GONE);
            }
            if (downloadInfo.getIs_child_selected()) {
                childHolder.load_check_child.setImageResource(R.drawable.download_select_item);
                downloadInfo.setGroupIndex(groupPosition);
                downloadInfo.setChildIndex(childPosition);
            } else {
                childHolder.load_check_child.setImageResource(R.drawable.download_circle_item);
            }
            final ChildViewHolder finalChildHolder = childHolder;
            childHolder.load_check_child.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    download(downloadInfo, finalChildHolder, info4Course, groupPosition);
                }
            });
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                RequestCallBack callBack = handler.getRequestCallBack();
                if (callBack instanceof DownloadManager.ManagerCallBack) {
                    DownloadManager.ManagerCallBack managerCallBack = (DownloadManager.ManagerCallBack) callBack;
                    if (managerCallBack.getBaseCallBack() == null) {
                        managerCallBack.setBaseCallBack(new DownloadManagerRequestCallBack());
                    }
                }
                callBack.setUserTag(new WeakReference<ChildViewHolder>(childHolder));
            }
            childHolder.load_video.setOnClickListener(new childLoadClickListener(downloadInfo));
            convertView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (Constants.IS_EDIT) {
                        download(downloadInfo, finalChildHolder, info4Course, groupPosition);
                    } else {
                        if (downloadInfo != null) {
                            if (downloadInfo.getState().equals(HttpHandler.State.SUCCESS)) {
                                if (new File(downloadInfo.getLocalURL()).exists()) {
                                    Intent intent = new Intent();
                                    intent.putExtra("url", downloadInfo.getLocalURL());
                                    intent.putExtra("lms_courseId", Integer.parseInt(downloadInfo.getLms_course_id()));
                                    intent.putExtra("lastVideoId", Integer.parseInt(downloadInfo.getItemId()));
                                    intent.setClass(mContext, VideoPlayActivity.class);
                                    mContext.startActivity(intent);
                                }
                            }
                        }
                    }
                }
            });
            convertView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    ConfirmDeleteSingle(downloadInfo);
                    return false;
                }
            });
            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }


        private void download(DownloadInfo downloadInfo, ChildViewHolder finalChildHolder, DownloadInfo4Course info4Course, int groupPosition) {
            if (!downloadInfo.getIs_child_selected()) {
                finalChildHolder.load_check_child.setImageResource(R.drawable.download_select_item);
                downloadInfo.setIs_child_selected(true);
                already_num++;
                setDeleteNum(already_num);
            } else {
                finalChildHolder.load_check_child.setImageResource(R.drawable.download_circle_item);
                downloadInfo.setIs_child_selected(false);
                already_num--;
                setDeleteNum(already_num);
            }
            int num1 = info4Course.getDownloadInfoList().size();
            int num2 = downloadManager.getDowninfo4CourseByGroupSelecedCount(groupPosition);
            if (num1 == num2) {
                info4Course.setIs_seleced(true);
            } else {
                info4Course.setIs_seleced(false);
            }
            if (downloadManager.getAllSelecedCount() == downloadManager.getAllDownloadInfoCount()) {
                Constants.IS_ALL_CHECK = true;
                rel_load_check_all.setText("取消全选");
//                load_check_all.setImageResource(R.drawable.download_selected);
            } else {
                Constants.IS_ALL_CHECK = false;
                rel_load_check_all.setText("全选");
//                load_check_all.setImageResource(R.drawable.download_circle);
            }
            notifyDataSetChanged();
        }

    }
}
