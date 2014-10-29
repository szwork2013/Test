package com.kaikeba.mitv.fragment;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.*;
import android.view.View.OnKeyListener;
import android.widget.*;
import android.widget.LinearLayout.LayoutParams;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.entity.TvViewPagerInfo;
import com.kaikeba.common.network.ServerDataCache;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.KKDialog;
import com.kaikeba.common.widget.MyGallery;
import com.kaikeba.common.widget.NetImageView;
import com.kaikeba.mitv.Common;
import com.kaikeba.mitv.MainActivity;
import com.kaikeba.mitv.R;
import com.kaikeba.mitv.ViewCourseActivity;
import com.kaikeba.mitv.adapter.MainAdapter;
import com.kaikeba.mitv.adapter.MainGalleryAdapter;
import com.kaikeba.mitv.objects.CourseCardItem;
import com.kaikeba.mitv.objects.CourseCardView;
import com.kaikeba.mitv.objects.CourseListItem;
import com.kaikeba.mitv.objects.LargeCourseCardItem;
import com.kaikeba.mitv.others.GalleryIndicator;
import com.kaikeba.mitv.utils.PretreatDataCache;
import com.kaikeba.mitv.utils.UrlManager;
import com.kaikeba.mitv.utils.ViewUtil;
import com.lidroid.xutils.BitmapUtils;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("deprecation")
public class MainTabFragment extends Fragment {

    private static final String TAG = "TestFragment";
    private static final int CARD_MARGIN_LEFT_PARENT = 57;
    private static final int CARD_MARGIN_RIGHT_PARENT = 57;
    public static BitmapUtils bitmapUtils;
    public View mView;
    public MyGallery mGallery;
    public LinearLayout mContentLL;
    public int galleryIndex = -1;
    /**
     * **** frame layout *******
     */
    public ScrollView scrollView;
    public TextView categoryTitle;
    Context context;
    MainGalleryAdapter mGalleryAdapter;
    boolean isFirst = true;
    LayoutInflater inflater;
    LinearLayout contentLinearLayout;
    GalleryIndicator galleryIndicator;
    private int main_tab_padding_left_right;
    private int large_card_item_padding;
    private int courseCardHeight;
    private int courseItemMarginTop;
    private int galleryTotalIndex;
    private int curPos;
    private boolean hotRecommend = false;
    private boolean guessLike = false;
    private boolean compileRecommend = false;
    private LinearLayout view_loading_fail;
    private ImageView loading_fail;
    private RelativeLayout view_loading;
    private TextView courseListItemTxt;

    //by mj.l
    private List<CourseCardItem> allCourseList = new ArrayList<CourseCardItem>();
    private ArrayList<CourseListItem> mainCourses;
    private MainAdapter mainCourseAdapter;
    private ListView mainCourseListView;
    private List<CourseCardItem> courses = new ArrayList<CourseCardItem>();
    private boolean isFirstIn = true;
    private ScrollView sViewCatCourses;
    private LinearLayout llCatCourses;
    private List<CourseCardItem> compileRecommendCourseList = new ArrayList<CourseCardItem>();
    private List<CourseCardItem> guessLikeCourseList = new ArrayList<CourseCardItem>();
    private List<CourseCardItem> hotRecommendCourseList = new ArrayList<CourseCardItem>();
    private List<CourseCardItem> viwepagerCourseList = new ArrayList<CourseCardItem>();
    private List<TvViewPagerInfo> viewPagerInfos = new ArrayList<TvViewPagerInfo>();
    private ImageView shuiyinImg;

    public static MainTabFragment newInstance() {
        MainTabFragment newFragment = new MainTabFragment();
        return newFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        this.inflater = inflater;
        isFirst = true;
        mView = (View) inflater.inflate(R.layout.tab_content_main, container, false);
        shuiyinImg = (ImageView) mView.findViewById(R.id.mi_shuiyin);
        main_tab_padding_left_right = (int) getResources().getDimension(R.dimen.main_tab_padding_left_right);
        courseItemMarginTop = (int) getResources().getDimension(R.dimen.card_item_margin_top);
        courseCardHeight = ViewUtil.getInstance().getCourseCardHeight();
        view_loading_fail = (LinearLayout) mView.findViewById(R.id.view_loading_fail);
        loading_fail = (ImageView) mView.findViewById(R.id.loading_fail);
        view_loading = (RelativeLayout) mView.findViewById(R.id.view_loading);
        getCourseCardHeight();
        ViewUtil.getInstance().setCourseItemMarginTop(courseItemMarginTop);
        categoryTitle = (TextView) mView.findViewById(R.id.category_title_txt);
        categoryTitle.setNextFocusUpId(R.id.tv_tab_main);
        categoryTitle.setNextFocusDownId(R.id.coursesListView);
        categoryTitle.setNextFocusRightId(R.id.main_gallery);
        view_loading_fail.setOnKeyListener(new OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {

                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                        loadAllData(true);
                    }
                }
                return true;
            }
        });

        mContentLL = (LinearLayout) mView.findViewById(R.id.main_content_ll);
        mGallery = (MyGallery) mView.findViewById(R.id.main_gallery);
        mGallery.setCallbackDuringFling(false);
//        mGallery.setFocusable(false);
//        mGallery.clearFocus();
        context = getActivity().getApplicationContext();
        bitmapUtils = BitmapHelp.getBitmapUtils(context);
        loadAllData(true);
        return mView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initView();
        setShuiyinImg();
        addGalleryIndicator();
        initGallery();
    }

    private void setShuiyinImg() {
        ApplicationInfo appInfo = null;
        try {
            appInfo = getActivity().getPackageManager().getApplicationInfo(getActivity().getPackageName(), PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        String channel = appInfo.metaData.getString("UMENG_CHANNEL");
        if (channel.equals("MiBox")) {
            shuiyinImg.setVisibility(View.VISIBLE);
        } else {
            shuiyinImg.setVisibility(View.GONE);
        }
    }

    private void getCourseCardHeight() {
        int imgHeight = getResources().getDimensionPixelSize(R.dimen.small_size_card_height);
        int topHight = getResources().getDimensionPixelSize(R.dimen.small_top_view_container_height);
        int large_card_item_padding = (int) getResources().getDimension(R.dimen.large_card_item_padding);
        courseCardHeight = imgHeight + topHight + large_card_item_padding * 2 * 2;
    }

    public void initGallery() {
        mGallery.setOnKeyListener(new OnKeyListener() {

            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                // TODO Auto-generated method stub
//                if (event.getAction() == KeyEvent.ACTION_UP) {
//                    // 第一行的时候，Activity自己处理
//                    switch (keyCode) {
//                        case KeyEvent.KEYCODE_DPAD_LEFT:
//                            break;
//                        case KeyEvent.KEYCODE_DPAD_RIGHT:
//                            break;
//                        case KeyEvent.KEYCODE_DPAD_UP:
//                            break;
//                        case KeyEvent.KEYCODE_DPAD_DOWN:
//                            break;
//                        case KeyEvent.KEYCODE_ENTER:
//
//                            break;
//                        default:
//                            break;
//                    }
//                    return true;
//                }
//                else
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER || keyCode == KeyEvent.KEYCODE_ENTER) {
                        for (CourseCardItem c : mGalleryAdapter.getCourse()) {
                            if (mGalleryAdapter.getCourse().get(galleryIndex).getId() == c.getId()) {
                                Intent intent = new Intent(getActivity(), ViewCourseActivity.class);
                                intent.putExtra("cardItem", c);
                                getActivity().startActivity(intent);
                            }
                        }
                    }
                }
                return false;
            }
        });
        final Activity finalActivity = getActivity();
        mGallery.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(final AdapterView<?> parent, View view,
                                       final int position, long id) {
                if (view == null) return;
                galleryTotalIndex = parent.getCount();
                final NetImageView imageView = (NetImageView) view;
                imageView.setNextFocusUpId(R.id.tv_tab_main);
                imageView.setNextFocusLeftId(R.id.category_title_txt);
                if (!isFirst) {
                    galleryIndex = position;
                }
                imageView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                    @Override
                    public void onFocusChange(View v, boolean hasFocus) {
                        if (!hasFocus) {
                            imageView.setBackgroundColor(Color.TRANSPARENT);
                            galleryIndex = -1;
                        } else {
                            galleryIndex = position;
                            imageView.setBackgroundResource(R.drawable.focus);
                            imageView.setPadding(FragmentHelper.getGalleryImagePadding(finalActivity),
                                    FragmentHelper.getGalleryImagePadding(finalActivity),
                                    FragmentHelper.getGalleryImagePadding(finalActivity),
                                    FragmentHelper.getGalleryImagePadding(finalActivity));
                            if (position == 0) {
                                imageView.setNextFocusLeftId(R.id.category_title_txt);
                            }
                            if (position == 3) {
                                MainActivity.setHorizonEdge(false, true);
                            } else {
                                MainActivity.setHorizonEdge(false, false);
                            }
                            ViewUtil.getInstance().scrollToTop(scrollView);
                        }
                    }
                });
                if (position == 3) {
                    MainActivity.setHorizonEdge(false, true);
                } else {
                    MainActivity.setHorizonEdge(false, false);
                }
                if (!isFirst) {
                    imageView.setBackgroundResource(R.drawable.focus);
                }
                isFirst = false;

                imageView.setLayoutParams(new Gallery.LayoutParams(
                        FragmentHelper.getGalleryImageWidth(finalActivity),
                        FragmentHelper.getGalleryImageHeight(finalActivity)));

                imageView.setPadding(FragmentHelper.getGalleryImagePadding(finalActivity),
                        FragmentHelper.getGalleryImagePadding(finalActivity),
                        FragmentHelper.getGalleryImagePadding(finalActivity),
                        FragmentHelper.getGalleryImagePadding(finalActivity));

                for (int i = 0; i < parent.getChildCount(); i++) {
                    NetImageView temp = (NetImageView) parent.getChildAt(i);
                    if (temp != imageView) {
                        temp.setBackgroundColor(0x00ffffff);
                        temp.setPadding(FragmentHelper.getGalleryImagePadding(finalActivity),
                                FragmentHelper.getGalleryImagePadding(finalActivity),
                                FragmentHelper.getGalleryImagePadding(finalActivity),
                                FragmentHelper.getGalleryImagePadding(finalActivity));

                        temp.setLayoutParams(new Gallery.LayoutParams(
                                FragmentHelper.getGalleryImageWidth(finalActivity) / 2,
                                FragmentHelper.getGalleryImageHeight(finalActivity) / 2));
                    }
                }

                galleryIndicator.scrollToPage(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {

            }
        });
    }

    private void showLoading() {
        view_loading.setVisibility(View.VISIBLE);
        view_loading.setFocusable(true);
        view_loading.requestFocus();
        view_loading_fail.setVisibility(View.GONE);
    }

    private void showNoData() {
        view_loading.setVisibility(View.GONE);
        KKDialog.getInstance().showNoDataDialog(getActivity(),
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        KKDialog.getInstance().dismiss();
                    }
                },
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        loadAllData(true);

                        KKDialog.getInstance().dismiss();
                    }
                });
        view_loading_fail.setVisibility(View.GONE);
//        view_loading_fail.setFocusable(true);
//        view_loading_fail.requestFocus();
    }

    private void showData() {
        view_loading.setVisibility(View.GONE);
        view_loading_fail.setVisibility(View.GONE);
    }

    private void initView() {
        scrollView = (ScrollView) getView().findViewById(R.id.tab_main_scrollview);
        sViewCatCourses = (ScrollView) mView.findViewById(R.id.sv_category_courses);
        llCatCourses = (LinearLayout) mView.findViewById(R.id.ll_category_courses);
    }

    public void showSelectedCategory() {
        CourseListItem item = (CourseListItem) mainCourseAdapter.getItem(mainCourseListView.getSelectedItemPosition());
        reloadCoursesListViewData(item);

    }

    private void initCoursesList(final boolean fromCache) {
        mainCourseListView = (ListView) mView.findViewById(R.id.coursesListView);
//        mainCourseListView.setFocusable(true);
//        mainCourseListView.setSelection(0);

        mainCourses = new ArrayList<CourseListItem>();
        mainCourseAdapter = new MainAdapter(getActivity(), mainCourses);
        mainCourseListView.setAdapter(mainCourseAdapter);

        Type categoryType = new TypeToken<ArrayList<CourseListItem>>() {
        }.getType();
        ServerDataCache.getInstance().dataWithURL(UrlManager.getInstance().getCATEGORYURL(), null, true, categoryType, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    mainCourses.addAll((ArrayList<CourseListItem>) data);
                    if (mainCourseAdapter != null) {
                        mainCourseAdapter.notifyDataSetChanged();
                        loadGuessLike(fromCache);
                    }
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
        mainCourseListView.setNextFocusUpId(R.id.category_title_txt);
        mainCourseListView.setSelector(new ColorDrawable(Color.TRANSPARENT));
        mainCourseListView.clearFocus();
        mainCourseListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {

            }
        });

        mainCourseListView.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                curPos = position;
                courseListItemTxt = (TextView) view.findViewById(R.id.courseTitleTextView);
                if (isFirstIn) {
                    sViewCatCourses.setVisibility(View.GONE);
                    scrollView.setVisibility(View.VISIBLE);
                    isFirstIn = false;
                } else {
                    for (int i = 0; i < adapterView.getChildCount(); i++) {
                        View itemView = adapterView.getChildAt(i);
                        if (!itemView.equals(view)) {
                            TextView textView = (TextView) itemView.findViewById(R.id.courseTitleTextView);
                            textView.setTextColor(getResources().getColor(R.color.course_card_title_color));
                        }
                    }
                    courseListItemTxt.setTextColor(getResources().getColor(R.color.color_bai));
                    CourseListItem item = (CourseListItem) adapterView.getSelectedItem();
                    reloadCoursesListViewData(item);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
            }
        });

        mainCourseListView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocused) {
                if (hasFocused) {
                    if (courseListItemTxt != null) {
                        courseListItemTxt.setTextColor(getResources().getColor(R.color.color_bai));
                    }
                    categoryTitle.setTextColor(getResources().getColor(R.color.course_card_title_color));
                    sViewCatCourses.setVisibility(View.VISIBLE);
                    scrollView.setVisibility(View.GONE);
                    if (mainCourseListView.getSelectedItemPosition() == 0) {
                        CourseListItem item = (CourseListItem) mainCourseAdapter.getItem(0);
                        reloadCoursesListViewData(item);
                    }
                } else {
                    if (courseListItemTxt != null) {
                        courseListItemTxt.setTextColor(getResources().getColor(R.color.tab_color_focused));
                    }
                }
            }
        });

        categoryTitle.setFocusable(true);
        categoryTitle.requestFocus();

        categoryTitle.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    if (courseListItemTxt != null) {
                        courseListItemTxt.setTextColor(getResources().getColor(R.color.course_card_title_color));
                    }
                    categoryTitle.setTextColor(getResources().getColor(R.color.color_bai));
                    sViewCatCourses.setVisibility(View.GONE);
                    scrollView.setVisibility(View.VISIBLE);
                    setBottomView();
                } else {
                    categoryTitle.setTextColor(getResources().getColor(R.color.tab_color_focused));
                }
            }
        });

//        mainCourseListView.requestFocus();
    }

    private void addGalleryIndicator() {
        galleryIndicator = new GalleryIndicator(getActivity(), null, mGallery.getCount());
        LinearLayout main_dot = (LinearLayout) getView().findViewById(R.id.main_dot);
//        contentLinearLayout = (LinearLayout) getView().findViewById(R.id.ll_tab_main);
//        LinearLayout.LayoutParams params = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT,1);
//        galleryIndicator.setGravity(Gravity.CENTER);
        main_dot.addView(galleryIndicator);
    }

    private void reloadCoursesListViewData(CourseListItem item) {
        if (allCourseList != null && item != null) {
            courses.clear();
            for (CourseCardItem courseCardItem : allCourseList) {
                if (item.getId() == courseCardItem.getCategory_id()) {
                    courses.add(courseCardItem);
                }
            }
            initCatCoursesView();
        }
    }

    private void initCatCoursesView() {
        if (courses == null || courses.size() <= 0) {
            return;
        }
        llCatCourses.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, null));
        llCatCourses.setOrientation(LinearLayout.VERTICAL);

        removeAllViews();

        int rowCnt = 4;
        int catLLNum = courses.size() % 4 == 0 ? courses.size() / 4 : courses.size() / 4 + 1;
        CourseCardView.setCardNumber(courses.size());
        for (int i = 0; i < catLLNum; i++) {
            LinearLayout ll = new LinearLayout(context);
            LayoutParams rowParams = ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, courseCardHeight, null);
            rowParams.setMargins(0, courseItemMarginTop, 0, 0);
            ll.setLayoutParams(rowParams);
            ll.setPadding(main_tab_padding_left_right - large_card_item_padding * 2, 0, main_tab_padding_left_right - large_card_item_padding * 2, 0);
            // spilit courses by rowCnt
            drawCatCoursesRow(ll, courses.subList(i * rowCnt, (i + 1) * rowCnt - courses.size() < 0 ? (i + 1) * rowCnt : courses.size()), catLLNum, i);
            llCatCourses.addView(ll);
        }

        View view = new View(context);
        view.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, courseItemMarginTop, null));
        llCatCourses.addView(view);
    }

    //    List<LargeCourseCardItem> itemList = new ArrayList<LargeCourseCardItem>();
    private void drawCatCoursesRow(LinearLayout ll, final List<CourseCardItem> courseCardItems, final int catLLNum, final int rows) {

        for (int i = 0; i < courseCardItems.size(); i++) {
            courseCardItems.get(i).setSmallSize(true);
            LinearLayout llItem = new LinearLayout(context);
            llItem.setLayoutParams(ViewUtil.getInstance().getLLParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1));
            llItem.setGravity(Gravity.CENTER);
            final LargeCourseCardItem item = ViewUtil.getInstance().initLargeCourseCard(getActivity(), courseCardItems.get(i), Common.FROM_MAIN);
            item.setId(i + ((rows) * courseCardItems.size()));
//            itemList.add(item);
            llItem.addView(item);
            ll.addView(llItem);
            final int finalI = i;
            item.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean hasFocus) {
                    item.setBottomViewContainerHidden(!hasFocus);
                    if (hasFocus) {
                        if (view == item) {
                            if (finalI == courseCardItems.size() - 1 && finalI == 0) {
                                MainActivity.setHorizonEdge(false, true);
                            } else {
                                if (finalI == 0) {
                                    MainActivity.setHorizonEdge(false, false);
                                } else if (finalI == courseCardItems.size() - 1) {
                                    MainActivity.setHorizonEdge(false, true);
                                } else {
                                    MainActivity.setHorizonEdge(false, false);
                                }
                            }
                        }
                        if (catLLNum > 2) {
                            if (rows == 0) {
                                ViewUtil.getInstance().scrollToTop(sViewCatCourses);
                            } else if (rows == catLLNum - 1) {
                                ViewUtil.getInstance().scrollToBottom(sViewCatCourses);
                            }
                        }
                        if (rows == catLLNum - 1) {
                            MainActivity.setVerticalEdge(true);
                        } else {
                            MainActivity.setVerticalEdge(false);
                        }

                    } else {
                        MainActivity.setVerticalEdge(false);
                        MainActivity.setHorizonEdge(false, false);
                    }
                }
            });
            if (rows == 0) {
                item.setNextFocusUpId(R.id.tv_tab_main);
            }
            if (item.getId() == 0) {
                item.setNextFocusLeftId(R.id.coursesListView);
            }
        }

//        for(int i = 0;i < itemList.size() ;i ++){
//            LargeCourseCardItem item = itemList.get(i);
//            if(rows == 0){
//                item.setNextFocusUpId(R.id.tv_tab_main);
//            }
//            if(item.getId() == 0){
//                item.setNextFocusLeftId(R.id.coursesListView);
//            }
////            else {
////                item.setNextFocusLeftId(item.getId() - 1);
////            }
////
////            item.setNextFocusRightId(item.getId() + 1);
//        }

        // add linearlayout
        if (rows == (courses.size() / 4)) {
            if (courses.size() % 4 != 0) {
                for (int i = 0; i < 4 - courses.size() % 4; i++) {
                    LinearLayout llItem = new LinearLayout(context);
                    llItem.setLayoutParams(ViewUtil.getInstance().getLLParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1));
                    llItem.setGravity(Gravity.CENTER);
                    ll.addView(llItem);
                }
            }
        }

    }

    private void setCourse(List<CourseModel> courses, CourseModel course) {
        boolean flag = false;
        for (CourseModel mCourse : courses) {
            if (course.getId() == mCourse.getId()) {
                flag = true;
                break;
            }
        }
        if (!flag) {
            courses.add(0, course);
            MainActivity.getMainActivity().refreshView();
        }
    }

    private void loadAllData(final boolean fromCache) {
        if (fromCache) {
            showLoading();
        }
        String allCourseUrl = UrlManager.getInstance().getCOURSES_URL();
        Type all_course_type = new TypeToken<ArrayList<CourseCardItem>>() {
        }.getType();
        final long cur = System.currentTimeMillis();
        ServerDataCache.getInstance().dataWithURL(allCourseUrl, null, fromCache, all_course_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    List<CourseCardItem> allcourse = new ArrayList<CourseCardItem>();
                    allcourse = (List<CourseCardItem>) data;
                    allCourseList.clear();
                    for (CourseCardItem info : allcourse) {
                        if (info.getStatus().equals("online")) {
                            allCourseList.add(info);
                        }
                    }
                    initCoursesList(fromCache);
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
                long last = System.currentTimeMillis();
                Log.d("jack", "消耗：：" + (last - cur));
            }
        });
    }

    private void setCompileRecommendCourseList(List<Integer> list) {
        if (allCourseList != null && list != null) {
            compileRecommendCourseList.clear();
            for (int i = 0; i < list.size(); i++) {
                for (int j = 0; j < allCourseList.size(); j++) {
                    if (allCourseList.get(j).getId() == list.get(i)) {
                        allCourseList.get(j).setSmallSize(true);
                        compileRecommendCourseList.add(allCourseList.get(j));
                        break;
                    }
                }
            }
            compileRecommend = true;
            setBottomView();
        }
    }

    private void setGuessLikeCourseList(List<Integer> list) {
        if (allCourseList != null && list != null) {
            guessLikeCourseList.clear();
            for (int i = 0; i < list.size(); i++) {
                for (int j = 0; j < allCourseList.size(); j++) {
                    if (allCourseList.get(j).getId() == list.get(i)) {
                        allCourseList.get(j).setSmallSize(true);
                        guessLikeCourseList.add(allCourseList.get(j));
                        break;
                    }
                }
            }
            guessLike = true;
            setBottomView();
        }
    }

    private void sethotRecommendCourseList(List<Integer> list) {
        if (allCourseList != null && list != null) {
            hotRecommendCourseList.clear();
            for (int i = 0; i < list.size(); i++) {
                for (int j = 0; j < allCourseList.size(); j++) {
                    if (allCourseList.get(j).getId() == list.get(i)) {
                        allCourseList.get(j).setSmallSize(true);
                        hotRecommendCourseList.add(allCourseList.get(j));
                        break;
                    }
                }
            }
            hotRecommend = true;
            setBottomView();
        }
    }

    private void setViwepagerCourseList() {
        if (allCourseList != null && viewPagerInfos != null) {
            viwepagerCourseList.clear();
            for (int i = 0; i < viewPagerInfos.size(); i++) {
                int index = viewPagerInfos.get(i).getUrl().indexOf("courses/");
                String id = viewPagerInfos.get(i).getUrl().substring(index + 8);
                Log.d("jack", "id:" + id);
                for (int j = 0; j < allCourseList.size(); j++) {
                    if (id.equals(allCourseList.get(j).getId() + "")) {
                        viwepagerCourseList.add(allCourseList.get(j));
                        break;
                    }
                }
            }
        }
    }

    private void loadRecommend(final boolean fromCache) {
        Type compile_recommend_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String compile_recommend_url = UrlManager.getInstance().getCOMPILE_RECOMMEND();
        ServerDataCache.getInstance().dataWithURL(compile_recommend_url, null, fromCache, compile_recommend_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    setCompileRecommendCourseList((List<Integer>) data);
                    loadViewPage(fromCache);
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void loadGuessLike(final boolean fromCache) {
        Type guess_like_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String guess_like_url = UrlManager.getInstance().getGUESS_LIKE() + PretreatDataCache.getCollectedID();
        ServerDataCache.getInstance().dataWithURL(guess_like_url, null, fromCache, guess_like_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    setGuessLikeCourseList((List<Integer>) data);
                    loadHotRecommend(fromCache);
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void loadHotRecommend(final boolean fromCache) {
        Type hot_recommend_type = new TypeToken<ArrayList<Integer>>() {
        }.getType();
        String hot_recommend_url = UrlManager.getInstance().getHOT_RECOMMEND();
        ServerDataCache.getInstance().dataWithURL(hot_recommend_url, null, fromCache, hot_recommend_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    sethotRecommendCourseList((List<Integer>) data);
                    loadRecommend(fromCache);
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void loadViewPage(final boolean fromCache) {
        Type viwepager_type = new TypeToken<ArrayList<TvViewPagerInfo>>() {
        }.getType();
        String viwepager_url = UrlManager.getInstance().getVIWEPAGER();
        ServerDataCache.getInstance().dataWithURL(viwepager_url, null, fromCache, viwepager_type, new ServerDataCache.LoadDataCallbacks() {
            @Override
            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
                if (data != null) {
                    viewPagerInfos = (List<TvViewPagerInfo>) data;
                    setViwepagerCourseList();
                    for (TvViewPagerInfo info : viewPagerInfos) {
                        Log.i(TAG, "info.getViwepager_img()== " + info.getViwepager_img());
                    }
                    mGalleryAdapter = new MainGalleryAdapter(context, viwepagerCourseList, viewPagerInfos);
                    mGallery.setAdapter(mGalleryAdapter);
                    mGallery.clearFocus();
                    showData();
                } else {
                    if (fromCache) {
                        showNoData();
                    }
                }
            }
        });
    }

    private void initBottomView(int index, String title, List<CourseCardItem> list) {

        /************************************** [ 猜你喜欢 ]*******************************************/
        View lineRecommand = LayoutInflater.from(context).inflate(R.layout.common_line, null);
        ((TextView) lineRecommand.findViewById(R.id.common_line_tv)).setText(title);

        lineRecommand.setPadding(main_tab_padding_left_right * 2, 0, 0, 0);
        mContentLL.addView(lineRecommand);
        mContentLL.addView(initGridView(index, list));
        if ("编辑推荐".equals(title)) {
            View view = new View(context);
            view.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, courseItemMarginTop, null));
            mContentLL.addView(view);
        }
    }

//    private static final int CARD_WRAP_HEIGHT = 266;

    private View initGridView(final int index, final List<CourseCardItem> list) {

        LinearLayout scrView = new LinearLayout(context);
        scrView.setOrientation(LinearLayout.HORIZONTAL);
        scrView.setLayoutParams(ViewUtil.getInstance().getLLParams(LayoutParams.MATCH_PARENT, courseCardHeight, null));
        scrView.setPadding(main_tab_padding_left_right - large_card_item_padding * 2, 0, main_tab_padding_left_right - large_card_item_padding * 2, 0);

        for (int i = 0; i < list.size(); i++) {
            CourseCardItem courseItem = list.get(i);
            LinearLayout llItem = new LinearLayout(context);
            llItem.setLayoutParams(ViewUtil.getInstance().getLLParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1));
            llItem.setGravity(Gravity.CENTER);

            final LargeCourseCardItem itemCardView = ViewUtil.getInstance().initLargeCourseCard(getActivity(), courseItem, Common.FROM_MAIN);
            llItem.addView(itemCardView);
            scrView.addView(llItem);
            final int finalI = i;
            itemCardView.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean hasFocus) {
                    itemCardView.setBottomViewContainerHidden(!hasFocus);
                    if (hasFocus) {
                        if (view == itemCardView) {
                            if (finalI == 0) {
                                MainActivity.setHorizonEdge(false, false);
                            } else if (finalI == list.size() - 1) {
                                MainActivity.setHorizonEdge(false, true);
                            } else {
                                MainActivity.setHorizonEdge(false, false);
                            }
                            if (finalI == list.size() - 1) {
                                MainActivity.setHorizonEdge(false, true);
                            }
                        }

                        if (index == 1) {// 编辑推荐
                            ViewUtil.getInstance().scrollToBottom(scrollView);
                        }
                    }
                }
            });

            if (i == 0) {
                itemCardView.setNextFocusLeftId(R.id.category_title_txt);
            }
        }

        if (list.size() < 4) {
            for (int i = 0; i < 4 - list.size(); i++) {
                LinearLayout itemLL = new LinearLayout(context);
                itemLL.setLayoutParams(ViewUtil.getInstance().getLLParams(0, LayoutParams.WRAP_CONTENT, 1));
                scrView.addView(itemLL);
            }
        }

        return scrView;
    }

    public void setBottomView() {
        if (guessLike && hotRecommend && compileRecommend) {
            removeAllViews();
            CourseCardView.setCardNumber(20);

            if (guessLikeCourseList.size() >= 4) {
                initBottomView(0, "猜你喜欢", guessLikeCourseList.subList(0, 4));
            } else {
                initBottomView(0, "猜你喜欢", guessLikeCourseList.subList(0, guessLikeCourseList.size()));
            }
            if (hotRecommendCourseList.size() >= 4) {
                initBottomView(1, "热门推荐", hotRecommendCourseList.subList(0, 4));
            } else {
                initBottomView(1, "热门推荐", hotRecommendCourseList.subList(0, hotRecommendCourseList.size()));
            }
            if (compileRecommendCourseList.size() >= 4) {
                initBottomView(2, "编辑推荐", compileRecommendCourseList.subList(0, 4));
            } else {
                initBottomView(2, "编辑推荐", compileRecommendCourseList.subList(0, compileRecommendCourseList.size()));

            }
        }
    }

    public void removeAllViews() {
        if (mContentLL != null) {
            mContentLL.removeAllViews();
        }
        if (llCatCourses != null) {
            llCatCourses.removeAllViews();
        }
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onPageStart("MainTab"); //统计页面
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPageEnd("MainTab");
    }
}
