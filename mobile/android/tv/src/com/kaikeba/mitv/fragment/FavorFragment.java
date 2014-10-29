package com.kaikeba.mitv.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import com.kaikeba.common.HttpCallBack.LoadCallBack;
import com.kaikeba.mitv.Common;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.CourseCardView;
import com.kaikeba.mitv.objects.LargeCourseCardItem;
import com.kaikeba.mitv.utils.PretreatDataCache;
import com.kaikeba.mitv.utils.ViewUtil;
import com.lidroid.xutils.BitmapUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: kkb
 * Date: 14-8-4
 * Time: 下午9:46
 * To change this template use File | Settings | File Templates.
 */
public class FavorFragment extends Fragment {

    public static BitmapUtils bitmapUtils;
    Context context;
    /**
     * *********************
     */
    List<CourseCardItem> courses = new ArrayList<CourseCardItem>();
    CourseCardView selectedGridViewItem = null;
    private View view;
    private LinearLayout favorLL;
    private int courseCardHeight;
    private ScrollView scroll_favor;

    public static FavorFragment newInstance() {
        FavorFragment newFragment = new FavorFragment();
        return newFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_favor, container, false);
        scroll_favor = (ScrollView) view.findViewById(R.id.scroll_favor);
        scroll_favor.setFocusable(false);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        getCourseCardHeight();
        initView();
    }

    private void getCourseCardHeight() {
        int imgHeight = getResources().getDimensionPixelSize(R.dimen.small_size_card_height_from_favor);
        int topHight = getResources().getDimensionPixelSize(R.dimen.small_top_view_container_height);
        int large_card_item_padding = (int) getResources().getDimension(R.dimen.large_card_item_padding);
        courseCardHeight = imgHeight + topHight + large_card_item_padding * 2 * 2;
        ViewUtil.getInstance().setCourseCardHeight(courseCardHeight);
    }

    public void initData() {
        try {
            PretreatDataCache.loadCollectFromChche(new LoadCallBack() {
                @Override
                public void loadFinished(Object allCourseData) {
                    if (allCourseData != null) {
                        courses.clear();
                        courses.addAll((ArrayList<CourseCardItem>) allCourseData);
                        /*if(gridViewAdapter != null){
                            gridViewAdapter.notifyDataSetChanged();
                        }*/
                        if (courses.size() > 0)
                            fillFavorView();
                    }
                }
            });
        } catch (Exception e) {
            Log.d("jack", e.getMessage());
        }
    }

    private void fillFavorView() {
        int rowCnt = 4;
        int total = courses.size();
        int rowNum = total % rowCnt == 0 ? total / rowCnt : total / rowCnt + 1;
        favorLL.removeAllViews();
        CourseCardView.setCardNumber(courses.size());
        for (int i = 0; i < rowNum; i++) {
            LinearLayout ll = new LinearLayout(context);
            ll.setOrientation(LinearLayout.HORIZONTAL);
            LinearLayout.LayoutParams rowParams = ViewUtil.getInstance().getLLParams(LinearLayout.LayoutParams.MATCH_PARENT, courseCardHeight, null);
            ll.setLayoutParams(rowParams);
            rowParams.setMargins(0, ViewUtil.getInstance().getCourseItemMarginTop(), 0, 0);
            ll.setLayoutParams(rowParams);
            /*if(i == 0){
                ll.setNextFocusLeftId(-Integer.MAX_VALUE);
                ll.setNextFocusRightId(-Integer.MAX_VALUE);
            }*/
            drawFaverRow(ll, courses.subList(i * rowCnt, (i + 1) * rowCnt - courses.size() > 0 ? courses.size() : (i + 1) * rowCnt), rowCnt, rowNum, i);
            favorLL.addView(ll);
        }
        View view = new View(context);
        view.setLayoutParams(ViewUtil.getInstance().getLLParams(LinearLayout.LayoutParams.MATCH_PARENT, ViewUtil.getInstance().getCourseItemMarginTop(), null));
        favorLL.addView(view);
    }

    private void drawFaverRow(LinearLayout ll, final List<CourseCardItem> courseCardItems, int rowCnt, final int rowNum, final int index) {
        for (int i = 0; i < courseCardItems.size(); i++) {
            courseCardItems.get(i).setSmallSize(true);
            LinearLayout itemLL = new LinearLayout(context);
            itemLL.setLayoutParams(ViewUtil.getInstance().getLLParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT, 1));
            itemLL.setGravity(Gravity.CENTER);
            final LargeCourseCardItem cardView = ViewUtil.getInstance().initLargeCourseCard(context, courseCardItems.get(i), Common.FROM_FAVOR);
            itemLL.addView(cardView);
            if (index == 0) {
                cardView.setNextFocusUpId(R.id.tv_tab_favor);
            }
            ll.addView(itemLL);
            final int finalI = i;
//            cardView.setFocusable(false);
            cardView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean hasFocus) {
                    cardView.setBottomViewContainerHidden(!hasFocus);
                    if (hasFocus) {
                        if (view == cardView) {
                            if (finalI == 0) {
                                MainActivity.setHorizonEdge(true, false);
                            } else if (finalI == courseCardItems.size() - 1) {
                                MainActivity.setHorizonEdge(false, true);
                            } else {
                                MainActivity.setHorizonEdge(false, false);
                            }
                            if (finalI == courseCardItems.size() - 1 && finalI == 0) {
                                MainActivity.setHorizonEdge(true, true);
                            }
                        }
                        if (rowNum > 2) {
                            if (index == 0) {
                                ViewUtil.getInstance().scrollToTop(scroll_favor);
                            } else if (index == rowNum - 1) {
                                ViewUtil.getInstance().scrollToBottom(scroll_favor);
                            }
                        }
                    }
                }
            });

        }
        if (courseCardItems.size() < rowCnt) {
            for (int i = 0; i < rowCnt - courseCardItems.size(); i++) {
                LinearLayout itemLL = new LinearLayout(context);
                itemLL.setLayoutParams(ViewUtil.getInstance().getLLParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
                ll.addView(itemLL);
            }
        }
    }

    private void initView() {
        context = getActivity();
        courses = new ArrayList<CourseCardItem>();
        favorLL = (LinearLayout) view.findViewById(R.id.favorGridView);
        /*gridView = (GridView) getView().findViewById(R.id.favorGridView);
        gridViewAdapter = new CourseCardAdapter(context, courses);
        gridView.setAdapter(gridViewAdapter);
        gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        gridView.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                CourseCardItem cardItem = courses.get(position);
                cardItem.setFocused(true);

                if (selectedGridViewItem != null){
                    selectedGridViewItem.setBottomViewContainerHidden(true);
                }

                CourseCardView cardView = (CourseCardView) view;
                cardView.setBottomViewContainerHidden(false);

                selectedGridViewItem = cardView;

                CourseCardAdapter adapter = (CourseCardAdapter)adapterView.getAdapter();
                adapter.enlargeView(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }
        });

        gridView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int keyCode, KeyEvent keyEvent) {

                if (keyEvent.getAction() == KeyEvent.ACTION_DOWN) {
                    switch (keyCode) {
                        case KeyEvent.KEYCODE_DPAD_CENTER:
                        case KeyEvent.KEYCODE_ENTER:
                            CourseCardItem item = (CourseCardItem) gridView.getSelectedItem();
                            Intent intent = new Intent(getActivity(), ViewCourseActivity.class);
                            intent.putExtra("cardItem",item);
                            startActivity(intent);

                            return true;
                        default:
                            break;
                    }
                }

                return false;
            }
        });

        gridView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean b) {
                ;;
            }
        });*/
    }

    public void onResume() {
        super.onResume();

    }

    public void onPause() {
        super.onPause();

    }
}
