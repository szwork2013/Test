package com.kaikeba.mitv.others;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.mitv.R;

/**
 * Created by kkb on 8/6/14.
 */
public class GalleryIndicator extends LinearLayout {
    private static final int MARGIN_TOP = 16;
    private static final int MARGIN_LEFT = 7;
    private static final int MARGIN_RIGHT = MARGIN_LEFT;
    public int pageCount;
    private Context context;
    private TextView selectedTextView;

    public GalleryIndicator(Context context, AttributeSet attrs, int pageCount) {
        super(context, attrs);

        this.context = context;
        this.pageCount = pageCount;

        initUI();
    }

    private void initUI() {
        setOrientation(LinearLayout.HORIZONTAL);
        setGravity(Gravity.CENTER);

        if (pageCount > 0) {
            for (int i = 0; i < pageCount; i++) {

                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams((int) getResources().getDimension(R.dimen.gallery_indicator_circle_width), (int) getResources().getDimension(R.dimen.gallery_indicator_circle_width));
                layoutParams.setMargins(MARGIN_LEFT, 0, MARGIN_RIGHT, 0);

                TextView textView = new TextView(context);
                textView.setText("" + (i + 1));
                textView.setTextColor(context.getResources().getColor(R.color.color_bai));
                textView.setLayoutParams(layoutParams);
                textView.setBackgroundResource((R.drawable.circle_grey));
                textView.setGravity(Gravity.CENTER);

                addView(textView);
            }
        }
    }

    public void scrollToPage(int index) {
        TextView textView = (TextView) getChildAt(index);
        if (textView != null) {
            textView.setBackgroundResource((R.drawable.circle_blue));
        }

        if (selectedTextView != null) {
            selectedTextView.setBackgroundResource((R.drawable.circle_grey));
        }

        selectedTextView = null;
        selectedTextView = textView;
    }

    public int getPageCount() {
        return pageCount;
    }

    public void setPageCount(int pageCount) {
        this.pageCount = pageCount;
    }
}
