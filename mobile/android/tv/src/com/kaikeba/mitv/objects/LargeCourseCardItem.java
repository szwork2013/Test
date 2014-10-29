package com.kaikeba.mitv.objects;

import android.content.Context;
import android.view.Gravity;
import android.widget.LinearLayout;
import com.kaikeba.mitv.Common;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.utils.ViewUtil;

/**
 * Created by sjyin on 14-8-20.
 */
public class LargeCourseCardItem extends LinearLayout {

    private int large_card_item_padding;
    private int large_card_item_margine;

    private CourseCardView innerItem;

    public LargeCourseCardItem(Context context, CourseCardItem courseCardItem, int from) {
        super(context);
        if (Common.FROM_RECOMMEND != from) {
            innerItem = CourseCardView.getCard(context, null, courseCardItem, from, this);
        } else {
            innerItem = new CourseCardView(context, null, courseCardItem, from, this);
        }
        large_card_item_padding = (int) getResources().getDimension(R.dimen.large_card_item_padding);
        large_card_item_margine = (int) getResources().getDimension(R.dimen.large_card_item_margine);
        init();
    }

    private void init() {
        LayoutParams innerParams = ViewUtil.getInstance().getLLParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, null);
        innerParams.setMargins(large_card_item_padding, large_card_item_padding, large_card_item_padding, large_card_item_padding);
        innerItem.setLayoutParams(innerParams);
        addView(innerItem);
        LayoutParams outerParams = ViewUtil.getInstance().getLLParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, null);
        outerParams.setMargins(large_card_item_margine, large_card_item_margine, large_card_item_margine, large_card_item_margine);
        setGravity(Gravity.CENTER);
        setLayoutParams(outerParams);
        setBackgroundColor(getResources().getColor(R.color.transparent));
    }

    public void setBottomViewContainerHidden(boolean hidden) {
        if (hidden) {
            setBackgroundColor(getResources().getColor(R.color.transparent));
        } else {
            setBackgroundResource(R.drawable.focus);
        }
        innerItem.setBottomViewContainerHidden(hidden, true);
    }
}
