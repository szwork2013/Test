package com.kaikeba.mitv.fragment;

import android.app.Activity;
import android.content.Context;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.widget.MyhorizaScrollView;
import com.kaikeba.mitv.Listener.CustomOnKeyListener;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;

import java.util.List;

/**
 * Created by caojing on 14-5-19.
 */
public class FragmentHelper {

    private static LinearLayout.LayoutParams LP_FF =
            new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);

    public static String reFormatGalleryImageURL(String url) {
        return url.replace(".png", ".tablet.png!hs.ipad");
    }

    public static int getScreenWidthInPx(Activity activity) {
        return activity.getWindowManager().getDefaultDisplay().getWidth();       // 屏幕宽（像素，如：480px）
    }

    public static int getScreenWidthInDp(Activity activity) {
        DisplayMetrics dm = activity.getResources().getDisplayMetrics();

        float density = dm.density;        // 屏幕密度（像素比例：0.75/1.0/1.5/2.0）
        return (int) (getScreenWidthInPx(activity) / density);
    }

    public static int getGalleryImageWidth(Activity activity) {
        int valueInPx = getScreenWidthInPx(activity);
        if (valueInPx >= 1920) {
            return 888;
        } else if (valueInPx >= 1280) {
            return 592;
        } else if (valueInPx >= 960) {
            return 444;
        } else {
            return 444;
        }
    }

    public static int getGalleryImageHeight(Activity activity) {
        int valueInPx = getScreenWidthInPx(activity);
        if (valueInPx >= 1920) {
            return 390;
        } else if (valueInPx >= 1280) {
            return 260;
        } else if (valueInPx >= 960) {
            return 195;
        } else {
            return 195;
        }
    }

    public static int getGalleryImagePadding(Activity activity) {
        int valueInPx = getScreenWidthInPx(activity);
        if (valueInPx >= 1920) {
            return 20;
        } else if (valueInPx >= 1280) {
            return 20;
        } else if (valueInPx >= 960) {
            return 10;
        } else {
            return 10;
        }
    }

    public static void createCoursesView(Context context, String courseType,
                                         final List<CourseModel> courseList,
                                         LinearLayout viewContainer,
                                         int nextFocusUpId) {
        View line_guid = LayoutInflater.from(context).inflate(
                R.layout.common_line, null);
        ((TextView) line_guid.findViewById(R.id.common_line_tv))
                .setText(courseType);

        line_guid.setPadding(0, 10, 0, 0);
        viewContainer.addView(line_guid);

        final MyhorizaScrollView hsv = new MyhorizaScrollView(context);
        hsv.setHorizontalScrollBarEnabled(false);
        //水平滑动栏箭头的出现与消失

        hsv.setOnScrollListener(new MyhorizaScrollView.OnScrollListener1() {

            @Override
            public void onScroll() {
                Constants.SCROLLRIGHT_IS_END = false;
                Constants.SCROLLLEFT_IS_END = false;
            }

            @Override
            public void onRight() {
                Constants.SCROLLRIGHT_IS_END = true;
            }

            @Override
            public void onLeft() {
                Constants.SCROLLLEFT_IS_END = true;
            }
        });

        hsv.setLayoutParams(LP_FF);
        final LinearLayout ll_guid = new LinearLayout(context);
        ll_guid.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));
        ll_guid.setPadding(0, 18, 0, 0);
        hsv.addView(ll_guid);

        viewContainer.addView(hsv);
        // 导学课的布局
        // 初始化导学课布局的5个按钮
        for (int i = 0; i < courseList.size(); i++) {
            final View item = LayoutInflater.from(context).inflate(R.layout.common_item,
                    null);
            final ImageButton button = (ImageButton) item.findViewById(R.id.common_item_button);

            TextView courseName = (TextView) item.findViewById(R.id.common_item_title_0);

            button.setId(i);
            if (nextFocusUpId > 0) {
                button.setNextFocusUpId(nextFocusUpId);
            }
            button.setOnKeyListener(new CustomOnKeyListener(courseList.get(i), context));
            button.setOnFocusChangeListener(new View.OnFocusChangeListener() {

                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    // TODO Auto-generated method stub
                    if (hasFocus) {
                        if (v.getId() == 0 && v.getId() == courseList.size() - 1) {
                            MainActivity.setHorizonEdge(true, true);
                        } else if (v.getId() == 0) {
                            MainActivity.setHorizonEdge(true, false);
                        } else if (v.getId() == courseList.size() - 1) {
                            MainActivity.setHorizonEdge(false, true);
                        } else {
                            MainActivity.setHorizonEdge(false, false);
                        }
                    }
                }
            });
            BitmapHelp.getBitmapUtils(context).display(button, courseList.get(i).getCover_image());
            courseName.setText(courseList.get(i).getName());

            ll_guid.addView(item);
        }

    }
}
