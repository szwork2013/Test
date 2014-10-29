package com.kaikeba.mitv.fragment;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.common.entity.ModuleVideo;
import com.kaikeba.common.util.NetworkUtil;
import com.kaikeba.mitv.CourseActivityHelper;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.UnitPageActivity;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

public class UnitContentFragment extends Fragment {

    Context mActivity;
    private List<ModuleVideo.ItemVideo> items;
    private String courseId;
    private List<Button> mButtonViews = new ArrayList<Button>();
    OnFocusChangeListener mOnFocusChangeListener = new OnFocusChangeListener() {
        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            for (Button buttonView : mButtonViews) {
                buttonView.setBackgroundColor(0x00ffffff);
                buttonView.setTextSize(TypedValue.COMPLEX_UNIT_PX, getResources().getDimension(R.dimen.custom_textview_font_size));
                int padding = (int) getResources().getDimension(R.dimen.custom_textview_padding);
                int leftPadding = (int) getResources().getDimension(R.dimen.custom_textview_padding_left);
                buttonView.setPadding(leftPadding, padding, padding, padding);
            }
            if (hasFocus) {
                v.setBackgroundResource(R.drawable.button_bg);
                ((TextView) v).setTextSize(TypedValue.COMPLEX_UNIT_PX, getResources().getDimension(R.dimen.custom_textview_selected_font_size));
                int padding = (int) getResources().getDimension(R.dimen.custom_textview_selected_padding);
                int leftPadding = (int) getResources().getDimension(R.dimen.custom_textview_padding_left);
                v.setPadding(leftPadding, padding, padding, padding);
            }
        }
    };
    private LinearLayout mContentLL;
    private LayoutInflater inflater;
    public UnitContentFragment(List<ModuleVideo.ItemVideo> items, String courseId) {
        // TODO Auto-generated constructor stub
        this.courseId = courseId;
        this.items = items;
    }

    public static UnitContentFragment newInstance(List<ModuleVideo.ItemVideo> items, String courseId) {
        UnitContentFragment newFragment = new UnitContentFragment(items, courseId);
        return newFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        this.inflater = inflater;
        mActivity = getActivity();
        View mView = inflater.inflate(R.layout.unit_page_item, container, false);
        mContentLL = (LinearLayout) mView.findViewById(R.id.ll2);
        init();
        return mView;
    }

    public void init() {
        for (ModuleVideo.ItemVideo item : items) {
//        	if (item.getType().equals("ExternalTool")) {
            Button textView = (Button) inflater.inflate(R.layout.custom_textview, null);
            mContentLL.addView(textView);
            textView.setText(CourseActivityHelper.formatVideoTitle(item.getItemTitle()));
            textView.setBackgroundColor(0x00ffffff);
            textView.setOnFocusChangeListener(mOnFocusChangeListener);
            textView.setOnKeyListener(new CustomOnKeyListener(item));
            mButtonViews.add(textView);
//        	}
        }
        mContentLL.clearFocus();
    }

    public void requestFoces() {
        mContentLL.getChildAt(0).requestFocus();
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("UnitContent"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("UnitContent");
    }

    class CustomOnKeyListener implements OnKeyListener {

        private ModuleVideo.ItemVideo item;

        public CustomOnKeyListener(ModuleVideo.ItemVideo item) {
            this.item = item;
        }

        @Override
        public boolean onKey(View arg0, int arg1, KeyEvent arg2) {
            // TODO Auto-generated method stub
            if (arg1 == KeyEvent.KEYCODE_DPAD_CENTER || arg1 == KeyEvent.KEYCODE_ENTER) {
//				if (item.getType() != null && (item.getType().equals("Page"))) {
//					if (item.getUrl() != null) {
//						String[] pageStr = item.getUrl().split("/");
//						String pageURL = pageStr[pageStr.length - 1];
//						Intent intent = new Intent();
//						intent.putExtra("courseID+pageURL", courseId + "##"
//								+ pageURL);
//						intent.putExtra("title", item.getTitle());
//						intent.setClass(getActivity(), UnitPageActivity.class);
//						getActivity().startActivity(intent);
//					}
//				}
//				else
                if (item.getVideoURL() != null) {
                    if (NetworkUtil.isNetworkAvailable(getActivity())) {
                        Intent intent = new Intent();
                        intent.putExtra("url", item.getVideoURL());
                        intent.setClass(getActivity(), UnitPageActivity.class);
                        getActivity().startActivity(intent);
                    } else {
                        Toast.makeText(getActivity(),
                                "断开网络连接", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(getActivity(),
                            "该选项无视频", Toast.LENGTH_SHORT).show();
                }
            }
            return false;
        }

    }

}
