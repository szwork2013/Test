package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.Fragment;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.text.Html.ImageGetter;
import android.util.Log;
import android.view.*;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.AbsListView.LayoutParams;
import android.widget.*;
import android.widget.ExpandableListView.OnGroupClickListener;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.activity.*;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.AnnceReplyAPI;
import com.kaikeba.common.api.DiscusstionAPI;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Announcement;
import com.kaikeba.common.entity.AnnouncementReply;
import com.kaikeba.common.entity.User;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;

import java.lang.reflect.Type;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 通告详情Fragment
 *
 * @author Super Man
 */
public class AnnouncementDetailFragment extends Fragment {

    /*
     * dialog 相关
     */
    Dialog dialog;
    View viewDia;
    EditText diaInput;
    TextView tv_reply;
    TextView tv_reply_user;
    LayoutInflater inflater;
    ImageView previous;
    ImageView next;
    ImageGetter imgGetter = new Html.ImageGetter() {
        public Drawable getDrawable(String source) {
            Drawable drawable = null;
            Log.d("Image Path", source);
            URL url;
            try {
                url = new URL(source);
                drawable = Drawable.createFromStream(url.openStream(), "");
            } catch (Exception e) {
                return null;
            }
            drawable.setBounds(0, 0, drawable.getIntrinsicWidth(),
                    drawable.getIntrinsicHeight());
            return drawable;
        }
    };
    private ImageView iv_avatar;
    private TextView title;
    private TextView posted_at;
    private TextView user_name;
    private Announcement anncement;
    private ArrayList<Announcement> annList;
    private ArrayList<ArrayList<AnnouncementReply.ReplyView.Reply>> secondReplies;
    private String courseId;
    private AnnouncementReply annRepily;
    private ArrayList<AnnouncementReply.ReplyView> vReplyViews;
    private ExpandableListView ann_detail_eView;
    private IAdapter adapter;
    private Map<String, AnnouncementReply.Participant> parMap;
    private WebView wvMsg;
    private TextView tv_look_all;
    private LinearLayout ll_loadfile;
    private int annIndex;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    Toast.makeText(getActivity(), "success!", Toast.LENGTH_SHORT)
                            .show();
                    adapter.notifyDataSetChanged();
                    break;
                case 1:
                    Toast.makeText(getActivity(), "success!", Toast.LENGTH_SHORT)
                            .show();
                    adapter.notifyDataSetChanged();
                    ann_detail_eView.expandGroup((Integer) msg.obj);
                    break;
                case 2:
                    adapter.notifyDataSetChanged();
                    break;
                default:
                    break;
            }
        }

        ;
    };
    private OnClickListener dialogListener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            if ("".equals(diaInput.getText().toString())) {
                Toast.makeText(getActivity(), "消息不能为空", Toast.LENGTH_SHORT)
                        .show();
                return;
            }
            submitData(anncement.getId(), diaInput.getText().toString());
            dialog.dismiss();
        }
    };
    private OnClickListener mListener = new OnClickListener() {

        @SuppressWarnings("deprecation")
        @Override
        public void onClick(View v) {
            previous.setAlpha(255);
            next.setAlpha(255);
            int id = v.getId();
            switch (id) {
                case R.id.btn_back_normal:
                    if (getActivity() instanceof ModuleActivity) {
                        getActivity().onBackPressed();
                    } else {
                        if (getActivity() instanceof ActiveDisscussActivity) {
                            ((ActiveDisscussActivity) getActivity()).clickDisscuss();
                        } else if (getActivity() instanceof ActiveModuleActivity) {
                            ((ActiveModuleActivity) getActivity()).clickAnnounce();
                        } else if (getActivity() instanceof ActiveAssigmentActivity) {
                            ((ActiveAssigmentActivity) getActivity()).clickAssignment();
                        }
                    }
                    break;
                case R.id.tv_look_all:
                    Intent intent = new Intent(getActivity(), AnnouncementDetailActivity.class);
                    intent.putExtra(getResources().getString(R.string.announcement), anncement);
                    startActivity(intent);
                    break;
                case R.id.tv_reply_all:
                    showDialog();
                    tv_reply_user.setText("回复" + anncement.getAuthor().getDisplay_name() + ": ");
                    tv_reply.setOnClickListener(dialogListener);
                    break;
                case R.id.previous:
                    if (annIndex == 0) {
                        previous.setAlpha(80);
//					Toast.makeText(getActivity(), "已经是第一个", Toast.LENGTH_SHORT).show();
                        return;
                    } else {
                        annIndex--;
                        anncement = annList.get(annIndex);
                        loadDate();
                    }
                    break;
                case R.id.next:
                    if (annIndex == annList.size() - 1) {
                        next.setAlpha(80);
//					Toast.makeText(getActivity(), "已经是最后个", Toast.LENGTH_SHORT).show();
                        return;
                    } else {
                        annIndex++;
                        anncement = annList.get(annIndex);
                        loadDate();
                    }
                    break;
                default:
                    break;
            }
        }
    };

    @SuppressWarnings({"unchecked", "deprecation"})
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final View v = inflater.inflate(R.layout.my_course_announcement_detail, container, false);
        this.inflater = inflater;
        anncement = (Announcement) getArguments().getSerializable(getResources().getString(R.string.announcement));
        annList = (ArrayList<Announcement>) getArguments().getSerializable(getResources().getString(R.string.announcements));
        annIndex = annList.indexOf(anncement);
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
        ann_detail_eView = (ExpandableListView) v.findViewById(R.id.ann_detail_eView);
        v.findViewById(R.id.tv_reply_all).setOnClickListener(mListener);
        v.findViewById(R.id.btn_back_normal).setOnClickListener(mListener);
        previous = (ImageView) v.findViewById(R.id.previous);
        if (annIndex == 0) {
            previous.setAlpha(80);
        }
        previous.setOnClickListener(mListener);
        next = (ImageView) v.findViewById(R.id.next);
        next.setOnClickListener(mListener);
        View headerView = inflater.inflate(
                R.layout.my_course_ann_detail_header, null);
        View footerView = new View(getActivity());
        LayoutParams params = new LayoutParams(1, 80);
        footerView.setLayoutParams(params);

        ann_detail_eView.setOnGroupClickListener(new OnGroupClickListener() {

            @Override
            public boolean onGroupClick(ExpandableListView parent, View v,
                                        int groupPosition, long id) {
                return true;
            }
        });

        ann_detail_eView.addFooterView(footerView);
        findViews(headerView);
        ann_detail_eView.addHeaderView(headerView);
        return v;
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void findViews(View v) {
        wvMsg = (WebView) v.findViewById(R.id.wv_msg);
        WebSettings setting = wvMsg.getSettings();
        setting.setUseWideViewPort(true);
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        wvMsg.setWebViewClient(new WebViewClient());

        iv_avatar = (ImageView) v.findViewById(R.id.iv_avatar);
        title = (TextView) v.findViewById(R.id.title);
        posted_at = (TextView) v.findViewById(R.id.posted_at);
        user_name = (TextView) v.findViewById(R.id.user_name);
        tv_look_all = (TextView) v.findViewById(R.id.tv_look_all);
        tv_look_all.setOnClickListener(mListener);
        ll_loadfile = (LinearLayout) v.findViewById(R.id.ll_loadfile);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        loadDate();
    }

    private void loadDate() {
        if (anncement.getAttachments() == null
                || anncement.getAttachments().isEmpty()) {
            ll_loadfile.setVisibility(View.GONE);
        } else {
            int fileSize = anncement.getAttachments().size();
            for (int i = 0; i < fileSize; i++) {
                TextView tv_load_file = (TextView) inflater.inflate(
                        R.layout.load_file, null);
                ll_loadfile.addView(tv_load_file);
                tv_load_file.setText(anncement.getAttachments().get(i)
                        .getFilename());
                tv_load_file.setOnClickListener(new LoadFileListener(i,
                        anncement.getAttachments()));
            }
        }
        Bitmap bit = ImgLoaderUtil.getLoader().loadImg(
                anncement.getAuthor().getAvatar_image_url(), new ImgLoaderUtil.ImgCallback() {

                    @Override
                    public void refresh(Bitmap bitmap) {
                        if (bitmap == null) {
                            iv_avatar.setBackgroundResource(R.drawable.avatar_default);
                        } else {
                            iv_avatar.setBackground(new BitmapDrawable(getResources(), bitmap));
                        }
                    }
                }, handler);
        if (bit == null) {
            iv_avatar.setBackgroundResource(R.drawable.avatar_default);
        } else {
            iv_avatar.setBackground(new BitmapDrawable(getResources(), bit));
        }
        title.setText(anncement.getTitle());
        posted_at.setText(DateUtils.getCourseStartTime(anncement.getPosted_at()));
        user_name.setText(anncement.getAuthor().getDisplay_name());
        wvMsg.loadDataWithBaseURL(null, anncement.getMessage(), "text/html", "utf-8", null);
        ImgLoaderUtil.threadPool.submit(new Runnable() {
            @Override
            public void run() {
                annRepily = AnnceReplyAPI.getAllAnnceReply(courseId, ""
                        + anncement.getId());
                if (vReplyViews != null) {
                    vReplyViews.clear();
                    vReplyViews.addAll(annRepily.getView());
                } else {
                    vReplyViews = annRepily.getView();
                }
                ArrayList<AnnouncementReply.Participant> participants = annRepily
                        .getParticipants();
                if (parMap != null) {
                    parMap.clear();
                } else {
                    parMap = new HashMap<String, AnnouncementReply.Participant>();
                }
                for (AnnouncementReply.Participant participant : participants) {
                    parMap.put(participant.getId(), participant);
                }

                if (secondReplies != null) {
                    secondReplies.clear();
                } else {
                    secondReplies = new ArrayList<ArrayList<AnnouncementReply.ReplyView.Reply>>();
                }

                for (int i = 0; i < vReplyViews.size(); i++) {
                    ArrayList<AnnouncementReply.ReplyView.Reply> replys = new ArrayList<AnnouncementReply.ReplyView.Reply>();
                    secondReplies.add(replys);
                }

                for (int i = 0; i < vReplyViews.size(); i++) {
                    if (vReplyViews.get(i).getReplies() != null) {
                        secondReplies.get(i).addAll(
                                vReplyViews.get(i).getReplies());
                    }
                }

                if (adapter != null) {
                    handler.sendEmptyMessage(2);
                    return;
                } else {
                    adapter = new IAdapter(vReplyViews, secondReplies);
                }
                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        ann_detail_eView.setAdapter(adapter);
                        for (int i = 0; i < adapter.getGroupCount(); i++) {
                            ann_detail_eView.expandGroup(i);
                        }
                    }
                });
            }
        });
    }

    private void submitData(final String entryId, final String msg) {
        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                String json = DiscusstionAPI.replyDiscussion(courseId,
                        anncement.getId(), Long.parseLong(anncement.getId()), msg, "entry");
                Type type = new TypeToken<AnnouncementReply.ReplyView>() {
                }.getType();
                AnnouncementReply.ReplyView view = (AnnouncementReply.ReplyView) JsonEngine.parseJson(json, type);
                if (view.getReplies() == null) {
                    view.setReplies(new ArrayList<AnnouncementReply.ReplyView.Reply>());
                }
                vReplyViews.add(view);
                User user = API.getAPI().getUserObject();
                AnnouncementReply.Participant partipant = new AnnouncementReply().new Participant();
                partipant.setId(user.getId() + "");
                partipant.setAvatar_image_url(user.getAvatarUrl());
                partipant.setDisplay_name(user.getUserName());
                parMap.put(partipant.getId(), partipant);

                handler.sendEmptyMessage(0);
            }

        });
    }

    private void showCustomDia(final String entryId, final AnnouncementReply.ReplyView replyView,
                               final int groupPosition, final String name) {
        showDialog();
        tv_reply_user.setText("回复" + name + ": ");
        tv_reply.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                if ("".equals(diaInput.getText().toString())) {
                    Toast.makeText(getActivity(), "消息不能为空", Toast.LENGTH_SHORT)
                            .show();
                    return;
                }
                submitData(entryId, diaInput.getText().toString(), replyView,
                        groupPosition);
                dialog.dismiss();
            }
        });
    }

    private void showDialog() {
        if (dialog == null) {
            dialog = new Dialog(getActivity(), R.style.reply_dialog);
            viewDia = LayoutInflater.from(getActivity()).inflate(
                    R.layout.custom_dialog, null);
            dialog.setContentView(viewDia);
            diaInput = (EditText) viewDia.findViewById(R.id.et_reply);
            tv_reply = (TextView) viewDia.findViewById(R.id.tv_reply);

            diaInput.setOnKeyListener(new OnKeyListener() {
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    if (event.getAction() == KeyEvent.ACTION_DOWN) {
                        switch (keyCode) {
                            case KeyEvent.KEYCODE_DPAD_CENTER:
                                break;
                            case KeyEvent.FLAG_CANCELED:
                                dialog.dismiss();
                                return true;
                            case KeyEvent.KEYCODE_BACK:
                                dialog.dismiss();
                                return false;
                            default:
                                break;
                        }
                        System.out.println("----------------------------" + keyCode);
                    }
                    return false;
                }

            });

            tv_reply_user = (TextView) viewDia.findViewById(R.id.tv_reply_user);
            Window dialogWindow = dialog.getWindow();
            WindowManager.LayoutParams lp = dialogWindow.getAttributes();
            lp.x = 100; // 新位置X坐标
            lp.y = 100; // 新位置Y坐标
            lp.width = (int) Constants.window_width; // 宽度
            lp.height = 100; // 高度
            dialogWindow.setAttributes(lp);
        }
        diaInput.setText("");
        dialog.show();
    }

    private void submitData(final String entryId, final String msg,
                            final AnnouncementReply.ReplyView replyView, final int groupPosition) {

        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {

                User user = API.getAPI().getUserObject();
                if (replyView != null) {
                    String json = DiscusstionAPI.replyDiscussion(courseId,
                            anncement.getId(), Long.parseLong(entryId), msg,
                            "reply");
                    Type type = new TypeToken<AnnouncementReply.ReplyView.Reply>() {
                    }.getType();
                    AnnouncementReply.ReplyView.Reply view = (AnnouncementReply.ReplyView.Reply) JsonEngine.parseJson(json, type);
                    if (replyView.getReplies() == null) {
                        replyView
                                .setReplies(new ArrayList<AnnouncementReply.ReplyView.Reply>());
                    }
                    replyView.getReplies().add(view);
                } else {
                    String json = DiscusstionAPI.replyDiscussion(courseId,
                            anncement.getId(),
                            Long.parseLong(anncement.getId()), msg, "entry");
                    Type type = new TypeToken<AnnouncementReply.ReplyView>() {
                    }.getType();
                    AnnouncementReply.ReplyView view = (AnnouncementReply.ReplyView) JsonEngine.parseJson(json,
                            type);
                    if (view.getReplies() == null) {
                        view.setReplies(new ArrayList<AnnouncementReply.ReplyView.Reply>());
                    }
                    vReplyViews.add(view);
                }
                adapter.addLoadFlag();
                AnnouncementReply.Participant partipant = new AnnouncementReply().new Participant();
                partipant.setId(user.getId() + "");
                partipant.setAvatar_image_url(user.getAvatarUrl());
                partipant.setDisplay_name(user.getShortName());
                parMap.put(partipant.getId(), partipant);
                Message msg = Message.obtain();
                msg.obj = groupPosition;
                msg.what = 1;
                handler.sendMessage(msg);
            }

        });
    }

    class LoadFileListener implements OnClickListener {

        private int index;
        private ArrayList<Announcement.Attachment> attList;

        public LoadFileListener(int index, ArrayList<Announcement.Attachment> attList) {
            this.index = index;
            this.attList = attList;
        }

        public Integer getViewIndex() {
            return index;
        }

        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(attList
                    .get(index).getUrl()));
            startActivity(intent);
        }

    }

    class IAdapter extends BaseExpandableListAdapter {

        private LayoutInflater inflater;
        private List<AnnouncementReply.ReplyView> noAllReplyViews;
        private List<ArrayList<AnnouncementReply.ReplyView.Reply>> secondReplies;

        public IAdapter(ArrayList<AnnouncementReply.ReplyView> replyViews, List<ArrayList<AnnouncementReply.ReplyView.Reply>> secondReplies) {

            inflater = getActivity().getLayoutInflater();
            this.noAllReplyViews = replyViews;
            this.secondReplies = secondReplies;

            for (int i = 0; i < noAllReplyViews.size(); i++) {
                if (noAllReplyViews.get(i).getReplies() != null
                        && noAllReplyViews.get(i).getReplies().size() > 4) {

                    ArrayList<AnnouncementReply.ReplyView.Reply> replys = new ArrayList<AnnouncementReply.ReplyView.Reply>();
                    for (AnnouncementReply.ReplyView.Reply r : noAllReplyViews.get(i).getReplies()) {
                        int size = replys.size();
                        if (size < 4) {
                            replys.add(r);
                        }
                    }
                    noAllReplyViews.get(i).setReplies(replys);
                }
            }
        }

        public void addLoadFlag() {
            secondReplies
                    .add(new ArrayList<AnnouncementReply.ReplyView.Reply>());
        }

        @Override
        public int getGroupCount() {
            return noAllReplyViews.size();
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            if (noAllReplyViews.get(groupPosition).getReplies() == null) {
                return 0;
            }
            return noAllReplyViews.get(groupPosition).getReplies().size();
        }

        @Override
        public AnnouncementReply.ReplyView getGroup(int groupPosition) {
            return noAllReplyViews.get(groupPosition);
        }

        @Override
        public AnnouncementReply.ReplyView.Reply getChild(int groupPosition, int childPosition) {
            return noAllReplyViews.get(groupPosition).getReplies()
                    .get(childPosition);
        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return groupPosition + childPosition;
        }

        @Override
        public boolean hasStableIds() {
            return false;
        }

        @Override
        public View getGroupView(final int groupPosition, boolean isExpanded,
                                 View convertView, ViewGroup parent) {
            final AnnouncementReply.ReplyView replyView = noAllReplyViews.get(groupPosition);
            GViewHolder groupViewHolder = null;
            if (convertView == null) {
                convertView = inflater.inflate(
                        R.layout.my_course_ann_detail_group, null);
                groupViewHolder = new GViewHolder(convertView);
                convertView.setTag(groupViewHolder);
            } else {
                groupViewHolder = (GViewHolder) convertView.getTag();
            }

            groupViewHolder.btn_reply.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    String name = null;
                    if (parMap.get(replyView.getUser_id()) != null) {
                        name = parMap.get(replyView.getUser_id())
                                .getDisplay_name();
                    }
                    showCustomDia(replyView.getId(), replyView, groupPosition,
                            name);
                }
            });

            setGroupText(groupViewHolder, replyView);
            return convertView;
        }

        @Override
        public View getChildView(final int groupPosition, int childPosition,
                                 boolean isLastChild, View convertView, ViewGroup parent) {
            AnnouncementReply.ReplyView.Reply reply = noAllReplyViews.get(groupPosition).getReplies()
                    .get(childPosition);
            ;

            final CViewHolder holder;
            if (convertView == null) {
                convertView = getActivity().getLayoutInflater().inflate(
                        R.layout.my_course_ann_detail_child, null);
                holder = new CViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (CViewHolder) convertView.getTag();
            }
            if (!noAllReplyViews.get(groupPosition).isExpand()
                    && secondReplies.get(groupPosition).size() > 4
                    && childPosition == 2) {
                holder.rv_load_more.setVisibility(View.VISIBLE);
                holder.rv_main.setVisibility(View.GONE);
                holder.tv_reply_count.setText("共"
                        + secondReplies.get(groupPosition).size() + "条回复");
                holder.tv_load_more.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        noAllReplyViews.get(groupPosition).setExpand(true);
                        noAllReplyViews.get(groupPosition).setReplies(
                                secondReplies.get(groupPosition));
                        notifyDataSetChanged();
                    }
                });
            } else {
                holder.rv_load_more.setVisibility(View.GONE);
                holder.rv_main.setVisibility(View.VISIBLE);
            }
            setChildText(holder, reply, groupPosition);
            return convertView;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

        private void setGroupText(final GViewHolder holder, AnnouncementReply.ReplyView replyView) {
            if (parMap.get(replyView.getUser_id()) != null) {
                holder.name.setText(parMap.get(replyView.getUser_id())
                        .getDisplay_name());
                holder.iv_avatar.setImageBitmap(ImgLoaderUtil.getLoader()
                        .loadImg(
                                parMap.get(replyView.getUser_id())
                                        .getAvatar_image_url(),
                                new ImgLoaderUtil.ImgCallback() {

                                    @Override
                                    public void refresh(Bitmap bitmap) {
                                        holder.iv_avatar.setImageBitmap(bitmap);
                                    }
                                }, handler));
            }
            holder.posted_at.setText(DateUtils.getCourseStartTime(replyView
                    .getCreated_at()));
            holder.message.setText(Html.fromHtml(replyView.getMessage()));
        }

        private void setChildText(final CViewHolder holder, AnnouncementReply.ReplyView.Reply reply,
                                  int groupPosition) {
            if (getChildrenCount(groupPosition) > 4) {

            }
            if (parMap.get(reply.getUser_id() + "") != null) {
                holder.name.setText(parMap.get(reply.getUser_id() + "")
                        .getDisplay_name());
                holder.iv_avatar.setImageBitmap(ImgLoaderUtil.getLoader()
                        .loadImg(
                                parMap.get(reply.getUser_id() + "")
                                        .getAvatar_image_url(),
                                new ImgLoaderUtil.ImgCallback() {

                                    @Override
                                    public void refresh(Bitmap bitmap) {
                                        holder.iv_avatar.setImageBitmap(bitmap);
                                    }
                                }, handler));
            }
            holder.posted_at.setText(DateUtils.getCourseStartTime(reply
                    .getCreated_at()));
            holder.message.setText(reply.getMessage());
        }

        class GViewHolder {
            TextView name;
            TextView posted_at;
            ImageView iv_avatar;
            TextView message;
            TextView btn_reply;

            public GViewHolder(View v) {
                name = (TextView) v.findViewById(R.id.name);
                posted_at = (TextView) v.findViewById(R.id.posted_at);
                message = (TextView) v.findViewById(R.id.message);
                iv_avatar = (ImageView) v.findViewById(R.id.iv_avatar);
                btn_reply = (TextView) v.findViewById(R.id.btn_reply);
            }
        }

        class CViewHolder {
            TextView name;
            TextView posted_at;
            ImageView iv_avatar;
            TextView message;
            TextView tv_load_more;
            RelativeLayout rv_load_more;
            RelativeLayout rv_main;
            TextView tv_reply_count;

            public CViewHolder(View v) {
                name = (TextView) v.findViewById(R.id.name);
                posted_at = (TextView) v.findViewById(R.id.posted_at);
                message = (TextView) v.findViewById(R.id.message);
                tv_load_more = (TextView) v.findViewById(R.id.tv_load_more);
                iv_avatar = (ImageView) v.findViewById(R.id.iv_avatar);
                rv_load_more = (RelativeLayout) v
                        .findViewById(R.id.rv_load_more);
                rv_main = (RelativeLayout) v.findViewById(R.id.rv_main);
                tv_reply_count = (TextView) v.findViewById(R.id.tv_reply_count);
            }
        }
    }

}