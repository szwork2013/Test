package com.kaikeba.mitv.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;
import com.umeng.analytics.MobclickAgent;

public class MoreFragment extends Fragment {

    public Button btn1, btn2, btn3, btn4, btn5;
    Button buttonLostFocus;
    Activity mActivity;
    LinearLayout mView;
    LinearLayout mContentLL;
    private LinearLayout ll_right;
    private ImageView mImageView;
    private View more_introduction;
    private View more_guide;
    private View more_contact;
    private View public_apk;
    private View public_platfam;
    private Button previousSelectedButton;
    OnFocusChangeListener mOnFocusChangeListener = new OnFocusChangeListener() {
        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            if (hasFocus) {
                ll_right.removeAllViews();
                if (v instanceof Button) {
                    ((Button) v).setTextColor(getResources().getColor(R.color.white));
                }
                switch (v.getId()) {
                    case R.id.btn1:
                        v.setBackgroundResource(R.drawable.focus);
                        ll_right.addView(more_introduction);
//					mImageView.setImageResource(R.drawable.intro_kaikeba);
//					ll_right.addView(mImageView);
                        break;
                    case R.id.btn2:
                        v.setBackgroundResource(R.drawable.focus);
                        ll_right.addView(more_guide);
                        break;
                    case R.id.btn3:
                        v.setBackgroundResource(R.drawable.focus);
                        ll_right.addView(public_apk);
                        break;
                    case R.id.btn4:
                        v.setBackgroundResource(R.drawable.focus);
                        ll_right.addView(public_platfam);
                        break;
                    case R.id.btn5:
                        v.setBackgroundResource(R.drawable.focus);
                        ll_right.addView(more_contact);
                        break;
                    default:
                        break;
                }

                if (previousSelectedButton != null) {
                    previousSelectedButton.setTextColor(getResources().getColor(R.color.course_card_title_color));
                }

                buttonLostFocus = (Button) v;
                previousSelectedButton = buttonLostFocus;
            } else {
                v.setBackgroundColor(0x00ffffff);
                if (v instanceof Button) {
                    ((Button) v).setTextColor(getResources().getColor(R.color.tab_normal));
                }


//                buttonLostFocus.setBackgroundResource(R.color.transparent);
//                buttonLostFocus.setTextColor(getResources().getColor(R.color.color_lan));
            }
            if (hasFocus) {
                MainActivity.setHorizonEdge(true, true);
            }
        }
    };
    private int row = 0;

    public static MoreFragment newInstance() {
        MoreFragment newFragment = new MoreFragment();
        return newFragment;
    }

    public Button getPreviousSelectedButton() {
        return previousSelectedButton;
    }

    public int getRow() {
        return row;
    }

    public void setRow(int row) {
        this.row = row;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mView = (LinearLayout) inflater.inflate(R.layout.tab_more, container, false);
        mImageView = (ImageView) inflater.inflate(R.layout.custom_image, container, false);
        more_introduction = inflater.inflate(R.layout.more_introduction, container, false);
        more_guide = inflater.inflate(R.layout.more_guide, container, false);
        more_contact = inflater.inflate(R.layout.more_contact, container, false);
        public_apk = inflater.inflate(R.layout.public_apk, container, false);
        public_platfam = inflater.inflate(R.layout.public_platfom, container, false);
        mActivity = getActivity();
        ll_right = (LinearLayout) mView.findViewById(R.id.ll_right);
        btn1 = (Button) mView.findViewById(R.id.btn1);
        btn2 = (Button) mView.findViewById(R.id.btn2);
        btn3 = (Button) mView.findViewById(R.id.btn3);
        btn4 = (Button) mView.findViewById(R.id.btn4);
        btn5 = (Button) mView.findViewById(R.id.btn5);
        btn1.setOnFocusChangeListener(mOnFocusChangeListener);
        btn2.setOnFocusChangeListener(mOnFocusChangeListener);
        btn3.setOnFocusChangeListener(mOnFocusChangeListener);
        btn4.setOnFocusChangeListener(mOnFocusChangeListener);
        btn5.setOnFocusChangeListener(mOnFocusChangeListener);
        mImageView.setImageResource(R.drawable.intro_kaikeba);
        ll_right.addView(more_introduction);
//        ll_right.addView(mImageView);
        btn1.setNextFocusUpId(R.id.tv_tab_more);
        return mView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);


        public_apk.findViewById(R.id.iphone);
        public_apk.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocused) {

            }
        });
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("More"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("More");
    }


}

	
	
	
	
	