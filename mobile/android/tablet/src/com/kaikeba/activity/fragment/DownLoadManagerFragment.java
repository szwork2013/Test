package com.kaikeba.activity.fragment;

import android.app.AlertDialog;
import android.app.Fragment;
import android.content.*;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.kaikeba.activity.MainActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.api.API;
import com.kaikeba.common.download.DownloadInfo;
import com.kaikeba.common.download.DownloadInfo4Course;
import com.kaikeba.common.download.DownloadManager;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.util.NetUtil;
import com.kaikeba.common.widget.AllCoursesGridView;
import com.kaikeba.phone.R;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.DbException;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.lidroid.xutils.view.annotation.event.OnClick;

import java.io.File;
import java.lang.ref.WeakReference;

/**
 * 下载Fragment
 *
 * @author Super Man
 */
public class DownLoadManagerFragment extends Fragment {
    private final static String tag = "DownLoadManagerFragment";
    public BitmapUtils bitmapUtils;
    private DownloadManager downloadManager;
    private Context mAppContext;
    private DownloadListAdapter downloadListAdapter;
    @ViewInject(R.id.course_download_list)
    private ListView downloadList;

    @ViewInject(R.id.tv_unused_space)
    private TextView tv_unused_space;

    @ViewInject(R.id.text_unused_space)
    private TextView text_unused_space;

    @ViewInject(R.id.text_used_space)
    private TextView text_used_space;

    @ViewInject(R.id.tv_used_space)
    private TextView tv_used_space;

    @ViewInject(R.id.tv_manage)
    private TextView tv_manage;

    @ViewInject(R.id.tv_all_start)
    private TextView tv_all_start;

    @ViewInject(R.id.tv_all_pause)
    private TextView tv_all_pause;

    @ViewInject(R.id.rv)
    private RelativeLayout rv;

    private ImageButton btn_togo;
    private NetChangeReceiver netChangeReceiver;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.download_manager, container, false);
        ViewUtils.inject(this, view);
        bitmapUtils = BitmapHelp.getBitmapUtils(getActivity().getApplicationContext());
        mAppContext = getActivity().getApplicationContext();
        downloadManager = MainActivity.getMainActivity().getDownloadManager();
        setSpaceSize();
        downloadListAdapter = new DownloadListAdapter(mAppContext);
        downloadList.setAdapter(downloadListAdapter);
        btn_togo = (ImageButton) view.findViewById(R.id.btn_togo);
        btn_togo.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                MainActivity.getMainActivity().getMslidingMenu().showMenu();
            }
        });
        if (downloadManager.getDownloadInfoList() != null) {
            refreshAllstartAllstopColor();
        } else {
            tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
            tv_all_start.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
        }

        return view;
    }

    /**
     * 剩余空间大小
     */
    public void setSpaceSize() {
        tv_unused_space.setText(API.getAPI().getSpace().getUnUusedSpace_gb());
        tv_used_space.setText(API.getAPI().getSpace().getUsedSpace_gb());
    }

    /**
     * 管理按钮
     *
     * @param view
     */
    @OnClick(R.id.tv_manage)
    public void manager(View view) {
        if (Constants.IS_EDIT) {
            Constants.IS_EDIT = false;
            rv.setBackground(getResources().getDrawable(R.drawable.bg_nav_unit));
            tv_unused_space.setTextColor(getResources().getColor(R.color.download_space));
            text_unused_space.setTextColor(getResources().getColor(R.color.txt_setting));
            text_used_space.setTextColor(getResources().getColor(R.color.txt_setting));
            tv_used_space.setTextColor(getResources().getColor(R.color.download_space));
            tv_manage.setTextColor(getResources().getColor(R.color.txt_setting));
            tv_manage.setText("管理");
            tv_all_start.setVisibility(View.VISIBLE);
            tv_all_pause.setVisibility(View.VISIBLE);
        } else {
            setTextColor(getResources().getColor(R.color.download_title), getResources().getColor(R.color.white));
            Constants.IS_EDIT = true;
        }
        downloadListAdapter.notifyDataSetInvalidated();
    }

    public void refreshView() {
        downloadListAdapter.notifyDataSetChanged();
        setSpaceSize();
    }

    public void refreshAllstartAllstopColor() {
        if (downloadManager.getDownloadInfoList() == null) {
            tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
            tv_all_start.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
        } else {
            if (NetUtil.getNetType(MainActivity.getMainActivity()) == Constants.NO_NET) {
                tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
                tv_all_start.setTextColor(getResources().getColor(R.color.txt_setting));
            } else {
                if (downloadManager.getDownloadIngCount() > 0) {
                    tv_all_pause.setTextColor(getResources().getColor(R.color.txt_setting));
                } else {
                    tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
                }
                if (downloadManager.getDownloadPauseCount() > 0) {
                    tv_all_start.setTextColor(getResources().getColor(R.color.txt_setting));
                } else {
                    tv_all_start.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
                }
            }
        }
    }

    private void setTextColor(int rvColor, int textColor) {
        rv.setBackgroundColor(rvColor);
        tv_unused_space.setTextColor(textColor);
        text_unused_space.setTextColor(textColor);
        text_used_space.setTextColor(textColor);
        tv_used_space.setTextColor(textColor);
        tv_manage.setTextColor(textColor);
        tv_manage.setText("完成");
        tv_all_start.setVisibility(View.INVISIBLE);
        tv_all_pause.setVisibility(View.INVISIBLE);
    }

    /**
     * 全部开始
     *
     * @param view
     */
    @OnClick(R.id.tv_all_start)
    public void allStart(View view) {
        if (NetUtil.getNetType(MainActivity.getMainActivity()) != Constants.NO_NET) {
            if (downloadManager.getDownloadInfoList() != null) {
                if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                    KKDialog.getInstance().showNoWifi2Doload(getActivity(),
                            new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    KKDialog.getInstance().dismiss();
                                    Constants.nowifi_doload = false;
                                    resumeDownload();
                                }
                            },
                            new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    KKDialog.getInstance().dismiss();
                                }
                            });
                } else {
                    resumeDownload();
                }
            }
        } else {
//            Toast.makeText(mAppContext,"网络已断开,请检查网络",Toast.LENGTH_SHORT).show();
            KKDialog.getInstance().showNoNetToast(getActivity());
        }
    }

    private void resumeDownload() {
        if (downloadManager.getDownloadIngCount() > 0) {
            tv_all_pause.setTextColor(getResources().getColor(R.color.txt_setting));
        } else {
            tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
        }
        if (downloadManager.getDownloadPauseCount() > 0) {
            tv_all_start.setTextColor(getResources().getColor(R.color.txt_setting));
        } else {
            tv_all_start.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
        }
        try {
            downloadManager.resumeDownloadAll(new DownloadRequestCallBack());
            downloadListAdapter.notifyDataSetChanged();
        } catch (DbException e) {
            LogUtils.e(e.getMessage(), e);
        }
    }

    /**
     * 全部暂停
     *
     * @param view
     */
    @OnClick(R.id.tv_all_pause)
    public void allPause(View view) {
        if (NetUtil.getNetType(MainActivity.getMainActivity()) != Constants.NO_NET) {
            if (downloadManager.getDownloadInfoList() != null) {
                if (downloadManager.getDownloadIngCount() > 0) {
                    tv_all_pause.setTextColor(getResources().getColor(R.color.txt_setting));
                } else {
                    tv_all_pause.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
                }
                if (downloadManager.getDownloadPauseCount() > 0) {
                    tv_all_start.setTextColor(getResources().getColor(R.color.txt_setting));
                } else {
                    tv_all_start.setTextColor(getResources().getColor(R.color.activity_top_text_normal));
                }
                try {
                    if (downloadListAdapter != null && downloadManager != null) {
                        downloadManager.stopAllDownload();
                    }
                    downloadListAdapter.notifyDataSetChanged();
                } catch (DbException e) {
                    LogUtils.e(e.getMessage(), e);
                }
            }
        } else {
//            Toast.makeText(mAppContext,"网络已断开,请检查网络",Toast.LENGTH_SHORT).show();
            KKDialog.getInstance().showNoNetToast(getActivity());
        }

    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        downloadListAdapter.notifyDataSetChanged();
        //注册一个广播

        IntentFilter filter = new IntentFilter();
        filter.addAction(Constants.NOTICE_NET_3G);
        getActivity().registerReceiver(netChangeReceiver, filter);
    }

    @Override
    public void onDestroyView() {
        // TODO Auto-generated method stub
        super.onDestroyView();

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (netChangeReceiver != null) {
            getActivity().unregisterReceiver(netChangeReceiver);
            netChangeReceiver = null;
        }
    }

    private class NetChangeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Constants.NOTICE_NET_3G) && Constants.NET_IS_CHANGED) {
                allPause(null);
                KKDialog.getInstance().showNoWifi2Doload(getActivity(),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                allStart(null);
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

    /**
     * 下载适配器
     *
     * @author Super Man
     */
    private class DownloadListAdapter extends BaseAdapter {

        private final Context mContext;
        private final LayoutInflater mInflater;

        private DownloadListAdapter(Context context) {
            mContext = context;
            mInflater = LayoutInflater.from(mContext);
        }

        @Override
        public int getCount() {
            if (downloadManager == null) return 0;
            return downloadManager.getDownloadInfoListCount();
        }

        @Override
        public DownloadInfo4Course getItem(int arg0) {
            return downloadManager.getDownloadInfo(arg0);
        }

        @Override
        public long getItemId(int arg0) {
            return arg0;
        }

        @Override
        public View getView(final int arg0, View view, ViewGroup arg2) {
            GroupViewHolder holder;
            final DownloadInfo4Course info4Course = getItem(arg0);
            if (view == null) {
                view = mInflater.inflate(R.layout.course_download_item, null);
                holder = new GroupViewHolder(arg0);
                ViewUtils.inject(holder, view);
                view.setTag(holder);
            } else {
                holder = (GroupViewHolder) view.getTag();
            }
            holder.tv_download_coursename.setText(info4Course.getCourseName());
            holder.course_download_gridview.setAdapter(new DownloadGridAdapter(mContext, arg0));
            holder.course_download_gridview.setOnItemClickListener(new OnItemClickListener() {

                @Override
                public void onItemClick(AdapterView<?> adapterView, View arg1,
                                        final int arg2, long arg3) {
                    // TODO Auto-generated method stub
                    if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoNetToast(getActivity());
                    } else {
                        if (Constants.nowifi_doplay && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                            KKDialog.getInstance().showNoWifi2Play(getActivity(),
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            Constants.nowifi_doplay = false;
                                            toPlay(info4Course, arg2);
                                        }
                                    },
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                        }
                                    });
                        } else {
                            toPlay(info4Course, arg2);
                        }
                    }
                }
            });
            holder.tv_all_delete.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {

                    AlertDialog.Builder ad = new AlertDialog.Builder(getActivity());
                    ad.setTitle("删除视频");
                    ad.setMessage("您确认删除该课程的全部视频么?");
                    ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int i) {

                        }
                    });
                    ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
                        @Override
                        public void onClick(DialogInterface dialog, int i) {
                            try {
                                Log.d(tag, "groupIndex:" + arg0);
                                downloadManager.removeOneCourseDownload(arg0);
                                downloadListAdapter.notifyDataSetChanged();
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            refreshAllstartAllstopColor();
                        }
                    });
                    ad.show();
                }
            });
            if (Constants.IS_EDIT) {
                holder.tv_all_delete.setVisibility(View.VISIBLE);
            } else {
                holder.tv_all_delete.setVisibility(View.INVISIBLE);
            }
            notifyDataSetChanged();
            return view;
        }

        void toPlay(DownloadInfo4Course info4Course, int arg2) {
            Constants.DOWNLOAD_VIEW = 2;
            String courseID = info4Course.getCourseId();
            Course course = MainActivity.getMainActivity().getCourse(Long.parseLong(courseID));
            Intent mIntent = new Intent();
            mIntent.putExtra("course", course);
//					if (!new File(info4Course.getDownloadInfoList().get(arg2).getLocalURL()).exists()||!new File(info4Course.getDownloadInfoList().get(arg2).getFileSavePath()).exists()) {
//						Toast.makeText(mAppContext, "视频已删除请重新下载！", Toast.LENGTH_SHORT).show();
//						try {
//							downloadManager.removeDownload(info4Course.getDownloadInfoList().get(arg2), arg0);
//						} catch (DbException e) {
//							// TODO Auto-generated catch block
//							e.printStackTrace();
//							return;
//						}
//						notifyDataSetChanged();
//						return;
//					}
            mIntent.putExtra("url", info4Course.getDownloadInfoList().get(arg2).getLocalURL());
            mIntent.setClass(getActivity(), ModuleActivity.class);
            startActivity(mIntent);
        }

        class GroupViewHolder {

            @ViewInject(R.id.tv_download_coursename)
            TextView tv_download_coursename;

            @ViewInject(R.id.tv_all_delete)
            Button tv_all_delete;

            @ViewInject(R.id.course_download_gridview)
            AllCoursesGridView course_download_gridview;

            private int groupIndex;

            public GroupViewHolder(int groupIndex) {
                this.groupIndex = groupIndex;
            }

//			@OnClick(R.id.tv_all_delete)
//	        public void remove(View view) {
//	        	ConfirmExit();
//	        }

            /**
             * 确认删除
             */
//	    	public void ConfirmExit() {
//	    		AlertDialog.Builder ad = new AlertDialog.Builder(getActivity());
//	    		ad.setTitle("删除视频");
//	    		ad.setMessage("您确认删除该课程的全部视频么?");
//	    		ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
//	    			@Override
//	    			public void onClick(DialogInterface dialog, int i) {
//
//	    			}
//	    		});
//	    		ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
//	    					@Override
//	    					public void onClick(DialogInterface dialog, int i) {
//	    						try {
//                                    Log.d(tag,"groupIndex:"+groupIndex);
//	    			                downloadManager.removeOneCourseDownload(groupIndex);
//	    			                downloadListAdapter.notifyDataSetChanged();
//	    			            } catch (DbException e) {
//	    			                LogUtils.e(e.getMessage(), e);
//	    			            }
//	    					}
//	    				});
//	    		ad.show();
//	    	}
        }
    }

    private class DownloadGridAdapter extends BaseAdapter {

        private final Context mContext;
        private final LayoutInflater mInflater;
        private int groupIndex;

        private DownloadGridAdapter(Context context, int groupIndex) {
            mContext = context;
            this.groupIndex = groupIndex;
            mInflater = LayoutInflater.from(mContext);
        }

        @Override
        public int getCount() {
            if (downloadManager == null) return 0;
            if (downloadManager.getDownloadInfo(groupIndex) == null) {
                return 0;
            }
            return downloadManager.getDownloadInfo(groupIndex).getDownloadInfoList().size();
        }

        @Override
        public Object getItem(int i) {
            return downloadManager.getDownloadInfo(groupIndex).getDownloadInfoList().get(i);
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @SuppressWarnings("rawtypes")
        @Override
        public View getView(int i, View view, ViewGroup viewGroup) {
            DownloadItemViewHolder holder = null;
            DownloadInfo downloadInfo = downloadManager.getDownloadInfo(groupIndex).getDownloadInfoList().get(i);
            if (view == null) {
                view = mInflater.inflate(R.layout.course_download_gridview_item, null);
                holder = new DownloadItemViewHolder(downloadInfo, this, groupIndex);
                ViewUtils.inject(holder, view);
                view.setTag(holder);
                holder.refresh();
            } else {
                holder = (DownloadItemViewHolder) view.getTag();

            }
            holder.update(downloadInfo);
            bitmapUtils.display(holder.gridCourseBg, downloadInfo.getBgUrl());
            HttpHandler<File> handler = downloadInfo.getHandler();
            if (handler != null) {
                RequestCallBack callBack = handler.getRequestCallBack();
                if (callBack instanceof DownloadManager.ManagerCallBack) {
                    DownloadManager.ManagerCallBack managerCallBack = (DownloadManager.ManagerCallBack) callBack;
                    if (managerCallBack.getBaseCallBack() == null) {
                        managerCallBack.setBaseCallBack(new DownloadRequestCallBack());
                    }
                }
                callBack.setUserTag(new WeakReference<DownloadItemViewHolder>(holder));
                notifyDataSetChanged();
            }
            return view;
        }
    }

    public class DownloadItemViewHolder {

        @ViewInject(R.id.tv_video_large)
        TextView tvFileLength;

        @ViewInject(R.id.tv_video_name)
        TextView label;

        @ViewInject(R.id.tv_loadstate)
        TextView loadState;

        @ViewInject(R.id.download_pb)
        ProgressBar progressBar;

        @ViewInject(R.id.iv_startOrPause)
        ImageView stopBtn;

        @ViewInject(R.id.iv_delete)
        ImageView removeBtn;

        @ViewInject(R.id.gridCourseBg)
        ImageView gridCourseBg;

        private DownloadInfo downloadInfo;
        private DownloadGridAdapter adapter;
        private int groupIndex;

        public DownloadItemViewHolder(DownloadInfo downloadInfo, DownloadGridAdapter adapter, int groupIndex) {
            this.downloadInfo = downloadInfo;
            this.adapter = adapter;
            this.groupIndex = groupIndex;
        }

        @OnClick(R.id.iv_startOrPause)
        public void stop(View view) {
            refreshAllstartAllstopColor();
            HttpHandler.State state = downloadInfo.getState();
            switch (state) {
                case WAITING:
                    try {
                        downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                    } catch (DbException e) {
                        LogUtils.e(e.getMessage(), e);
                    }
                    adapter.notifyDataSetChanged();
                    break;
                case STARTED:
                    try {
                        downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                    } catch (DbException e) {
                        LogUtils.e(e.getMessage(), e);
                    }
                    adapter.notifyDataSetChanged();
                    break;
                case LOADING:
                    try {
                        downloadManager.stopDownload(downloadInfo);
                    } catch (DbException e) {
                        LogUtils.e(e.getMessage(), e);
                    }
                    break;
                case CANCELLED:
                case FAILURE:
                    if (Constants.NO_NET == NetUtil.getNetType(getActivity())) {
                        KKDialog.getInstance().showNoNetToast(getActivity());
                    } else {
                        if (Constants.nowifi_doload && Constants.MOBILE_STATE_CONNECTED == NetUtil.getNetType(getActivity())) {
                            KKDialog.getInstance().showNoWifi2Doload(getActivity(),
                                    new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            KKDialog.getInstance().dismiss();
                                            Constants.nowifi_doload = false;
                                            try {
                                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                                            } catch (DbException e) {
                                                LogUtils.e(e.getMessage(), e);
                                            }
                                            adapter.notifyDataSetChanged();
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
                                downloadManager.resumeDownload(downloadInfo, new DownloadRequestCallBack());
                            } catch (DbException e) {
                                LogUtils.e(e.getMessage(), e);
                            }
                            adapter.notifyDataSetChanged();
                        }
                    }

                    break;
                default:
                    break;
            }
        }

        @OnClick(R.id.iv_delete)
        public void remove(View view) {
            ConfirmExit();
        }

        /**
         * 确认删除
         */
        public void ConfirmExit() {
            AlertDialog.Builder ad = new AlertDialog.Builder(getActivity());
            ad.setTitle("删除视频");
            ad.setMessage("您确认删除该视频么?");
            ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int i) {

                }
            });
            ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
                @Override
                public void onClick(DialogInterface dialog, int i) {
                    try {
                        if (new File(downloadInfo.getFileSavePath()).exists()) {
                            new File(downloadInfo.getFileSavePath()).delete();
                        }
                        if (new File(downloadInfo.getLocalURL()).exists()) {
                            new File(downloadInfo.getLocalURL()).delete();
                        }
                        downloadManager.removeDownload(downloadInfo, groupIndex);
                        adapter.notifyDataSetChanged();
                    } catch (DbException e) {
                        LogUtils.e(e.getMessage(), e);
                    }
                    refreshAllstartAllstopColor();
                }
            });
            ad.show();
        }

        public void update(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
            refresh();
        }

        @SuppressWarnings("deprecation")
        public void refresh() {
            long fileLength = downloadInfo.getFileLength();
            if (fileLength != 0) {
                double fileMbSize = fileLength / 1024 / 1024;
                tvFileLength.setText(fileMbSize + "M");
            }

            label.setText(downloadInfo.getFileName());

            if (Constants.IS_EDIT) {
                removeBtn.setVisibility(View.VISIBLE);
            } else {
                removeBtn.setVisibility(View.INVISIBLE);
            }
            loadState.setText(downloadInfo.getState().toString());
            if (fileLength > 0) {
                progressBar.setProgress((int) (downloadInfo.getProgress() * 100 / fileLength));
            } else {
                progressBar.setProgress(0);
            }

            stopBtn.setVisibility(View.VISIBLE);
            //TODO
            HttpHandler.State state = downloadInfo.getState();
            switch (state) {
                case WAITING:
                    HttpHandler<File> handler = downloadInfo.getHandler();
                    Log.e(tag, "state=:" + state + " handler.getState()= " + handler.getState());
                    if (handler.getState() == HttpHandler.State.LOADING) {
                        loadState.setText("下载中");
                    } else {
                        loadState.setText("等待");
                    }
                    break;
                case STARTED:
                    loadState.setText("就绪");
                    break;
                case LOADING:
                    loadState.setText("下载中");
                    stopBtn.setImageResource(R.drawable.button_pause_normal);
                    break;
                case CANCELLED:
                    loadState.setText("已暂停");
                    stopBtn.setImageResource(R.drawable.button_download_normal_module);
                    break;
                case SUCCESS:
                    downloadInfo.setState(HttpHandler.State.SUCCESS);
                    stopBtn.setVisibility(View.INVISIBLE);
                    loadState.setVisibility(View.INVISIBLE);
                    gridCourseBg.setAlpha(255);
                    label.setTextColor(getResources().getColor(R.color.download_complete));
                    tvFileLength.setTextColor(getResources().getColor(R.color.download_complete));
                    break;
                case FAILURE:
                    loadState.setText("FAILURE");
                    break;
                default:
                    break;
            }
            adapter.notifyDataSetChanged();
        }
    }

    private class DownloadRequestCallBack extends RequestCallBack<File> {

        @SuppressWarnings("unchecked")
        private void refreshListItem() {
            if (userTag == null) return;
            WeakReference<DownloadItemViewHolder> tag = (WeakReference<DownloadItemViewHolder>) userTag;
            DownloadItemViewHolder holder = tag.get();
            if (holder != null) {
                holder.refresh();
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
        }
    }
}
