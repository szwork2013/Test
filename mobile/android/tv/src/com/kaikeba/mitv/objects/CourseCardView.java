package com.kaikeba.mitv.objects;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.entity.CollectInfo;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.widget.NetImageView;
import com.kaikeba.mitv.Common;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.utils.ViewUtil;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kkb on 8/6/14.
 */
public class CourseCardView extends LinearLayout {

    static ArrayList<CourseCardView> viewList = new ArrayList<CourseCardView>(100);
    static int cardNumber = 10;
    static int cardIndex = 0;
    public int small_size_card_width;
    public int small_size_card_height ;
    private float small_size_font_size_focused ;
    private int top_view_padding_left_right;
    private int small_top_view_container_height;
    private int smaller_size_card_width;
    private int smaller_size_card_height;
    private int smaller_size_card_text_size;
    private int smaller_size_card_top_view_height;
    private int smaller_size_card_top_view_padding_left;
    private int small_size_card_width_from_favor;
    private int small_size_card_height_from_favor;
    private Context context;
    private CourseCardItem courseCardItem;
    private TextView courseTextView;
    private LinearLayout topViewContainer;
    private LinearLayout imageLL;
    private LayoutParams imgLLParams;
    private List<CollectInfo> collectList;
    private int from;
    private ViewGroup mParentView;
    private NetImageView imageView;
    public CourseCardView(Context context, AttributeSet attrs, CourseCardItem courseCardItem, int from, ViewGroup parent) {
        super(context, attrs);
        mParentView = parent;
        this.context = context;
        this.from = from;
        this.courseCardItem = courseCardItem;
        initDimension();
        initUI();
    }

    public static void setCardNumber(int number) {
        cardNumber = number;
        viewList.clear();
        for (int i = viewList.size(); i < cardNumber; i++) {
            viewList.add(null);
        }
//        Log.e("KKB", "viewList.size() = " + viewList.size());
        cardIndex = 0;
    }

    public static CourseCardView getCard(Context context, AttributeSet attrs, CourseCardItem courseCardItem, int from
            , ViewGroup parent) {
        CourseCardView cardView = viewList.get(cardIndex);
//        Log.e("KKB", "viewList.size() = " + viewList.size() + " " + cardIndex + " " + cardView);
        if (cardView == null) {
            cardView = new CourseCardView(context, attrs, courseCardItem, from, parent);
            viewList.set(cardIndex, cardView);
        } else {
            if (cardView.mParentView != null)
                cardView.mParentView.removeAllViews();
            cardView.setImageSize(from);
            cardView.mParentView = parent;
            ContextUtil.imageLoader.displayImage(courseCardItem.getCover_image(), cardView.imageView, ContextUtil.options);
            cardView.courseTextView.setText(courseCardItem.getName());
        }

        cardIndex++;

        return cardView;
    }

    private void initDimension() {

        smaller_size_card_width = getResources().getDimensionPixelSize(R.dimen.smaller_size_card_width);
        smaller_size_card_height = getResources().getDimensionPixelSize(R.dimen.smaller_size_card_height);
        smaller_size_card_top_view_height = getResources().getDimensionPixelSize(R.dimen.smaller_size_card_top_view_height);
        smaller_size_card_top_view_padding_left = getResources().getDimensionPixelSize(R.dimen.smaller_size_card_top_view_padding_left);
        smaller_size_card_text_size = getResources().getDimensionPixelSize(R.dimen.smaller_size_card_text_size);
        small_size_card_width = getResources().getDimensionPixelSize(R.dimen.small_size_card_width);
        small_size_card_height = getResources().getDimensionPixelSize(R.dimen.small_size_card_height);
        small_top_view_container_height = getResources().getDimensionPixelSize(R.dimen.small_top_view_container_height);
        small_size_font_size_focused = getResources().getDimension(R.dimen.small_size_font_size_focused);
        top_view_padding_left_right = getResources().getDimensionPixelSize(R.dimen.top_view_padding_right);

        small_size_card_width_from_favor = getResources().getDimensionPixelSize(R.dimen.small_size_card_width_from_favor);
        small_size_card_height_from_favor = getResources().getDimensionPixelSize(R.dimen.small_size_card_height_from_favor);

    }

    private void initUI() {
        setOrientation(LinearLayout.VERTICAL);
        /* Image */

        imageLL = new LinearLayout(context);
        setImageSize(from);
        imageLL.setBackgroundColor(getResources().getColor(R.color.focuse_bg));
        imageLL.setGravity(Gravity.CENTER_HORIZONTAL);
        imageView = new NetImageView(context);
        imageView.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, null));
        ContextUtil.imageLoader.displayImage(courseCardItem.getCover_image(), imageView, ContextUtil.options);
        imageView.setScaleType(ImageView.ScaleType.FIT_XY);
        imageLL.addView(imageView);

        /* topViewContainer */
        int topViewHeight = (from == Common.FROM_RECOMMEND) ? smaller_size_card_top_view_height : small_top_view_container_height;
        topViewContainer = new LinearLayout(context);
        topViewContainer.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, topViewHeight, null));
        topViewContainer.setGravity(Gravity.CENTER_VERTICAL);
        topViewContainer.setBackgroundResource(R.drawable.card_bg_default);
        if (from == Common.FROM_RECOMMEND) {
            topViewContainer.setPadding(smaller_size_card_top_view_padding_left, 0, smaller_size_card_top_view_padding_left, 0);
        } else {
            topViewContainer.setPadding(top_view_padding_left_right, 0, top_view_padding_left_right, 0);
        }
        float courseTxtSize = (from == Common.FROM_RECOMMEND) ? smaller_size_card_text_size : small_size_font_size_focused;
        courseTextView = new TextView(context);
        courseTextView.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, null));
        courseTextView.setText(courseCardItem.getName());
        courseTextView.setGravity(Gravity.CENTER_VERTICAL);
        courseTextView.setSingleLine(true);
        courseTextView.setEllipsize(TextUtils.TruncateAt.END);
        courseTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, courseTxtSize);
        courseTextView.setTextColor(context.getResources().getColor(R.color.course_card_title_color));
        topViewContainer.addView(courseTextView);

        addView(imageLL);
        addView(topViewContainer);

    }

    public void setImageSize(int from) {
        int width = small_size_card_width;
        int height = small_size_card_height;

        if (from == Common.FROM_RECOMMEND) {
            width = smaller_size_card_width;
            height = smaller_size_card_height;
        } else if (from == Common.FROM_FAVOR || from == Common.FROM_HISTORY) {
            width = small_size_card_width_from_favor;
            height = small_size_card_height_from_favor;
        }

        imgLLParams = new LayoutParams(width, height);
        imageLL.setLayoutParams(imgLLParams);
    }

    public void setBottomViewContainerHidden(boolean hidden, boolean fromLargeCard) {

        if (hidden) {
            topViewContainer.setBackgroundResource(R.drawable.card_bg_default);
            courseTextView.setTextColor(context.getResources().getColor(R.color.course_card_title_color));
            setBackgroundColor(getResources().getColor(R.color.transparent));
        } else {
            topViewContainer.setBackgroundResource(R.drawable.card_bg_selected);
            courseTextView.setTextColor(context.getResources().getColor(R.color.color_bai));
        }
        if (from == Common.FROM_RECOMMEND) {
            topViewContainer.setPadding(smaller_size_card_top_view_padding_left, 0, smaller_size_card_top_view_padding_left, 0);
        } else {
            topViewContainer.setPadding(top_view_padding_left_right, 0, top_view_padding_left_right, 0);
        }
    }

    public void setLayout(int width, int height) {
        setLayoutParams(new AbsListView.LayoutParams(width, height));
    }
}
