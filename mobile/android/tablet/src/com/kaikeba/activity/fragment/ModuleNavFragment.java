package com.kaikeba.activity.fragment;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.TextView;
import com.kaikeba.activity.ActiveAssigmentActivity;
import com.kaikeba.activity.ActiveDisscussActivity;
import com.kaikeba.activity.ActiveModuleActivity;
import com.kaikeba.activity.ModuleActivity;
import com.kaikeba.common.util.Constants;
import com.kaikeba.phone.R;

import java.util.HashMap;
import java.util.Map;

/**
 * 单元导航Fragment
 *
 * @author Allen
 */
public class ModuleNavFragment extends Fragment {

    View v;
    private FragmentManager fm;
    private FragmentTransaction ft;
    private Bundle mBundle;
    private ModuleContentFragment moduleContFmt;
    private ModuleIntroFragment moduleIntro;
    private AnnouncementFragment annFragment;
    private ModuleUsersFragment userFragment;
    private QuizFragment qf;
    private AssignmentFragment assignmentFragment;
    private DiscussionFragment disFragment;
    private OnCheckedChangeListener rgListener = new OnCheckedChangeListener() {

        @Override
        public void onCheckedChanged(final RadioGroup group, final int checkedId) {
            if (Constants.isFirst) {
                getActivity().findViewById(R.id.announcement_container).setVisibility(View.INVISIBLE);
                getActivity().findViewById(R.id.moduleDiscusion_container).setVisibility(View.INVISIBLE);
                getActivity().findViewById(R.id.moduleAssignment_container).setVisibility(View.INVISIBLE);
            }
            switch (group.getCheckedRadioButtonId()) {
                case R.id.rb_1:
                    Constants.goWhich = 1;
                    showFragment(moduleContFmt);
                    break;
                case R.id.rb_2:
                    Constants.goWhich = 2;
                    showFragment(moduleContFmt);
                    break;
                case R.id.rb_3:
                    ft = fm.beginTransaction();
                    if (moduleContFmt == null) {
                        moduleContFmt = new ModuleContentFragment();
                        moduleContFmt.setArguments(mBundle);
                        ft.setCustomAnimations(android.R.animator.fade_in,
                                android.R.animator.fade_out);
                        ft.add(R.id.module_content_container, moduleContFmt, "ModuleContentFragment");
                    }
                    ft.show(moduleContFmt);
                    if (moduleIntro != null) {
                        ft.hide(moduleIntro);
                    }
                    ft.commit();
                    break;
                case R.id.rb_4:
                    if (Constants.isFirst) {

                    } else if (disFragment == null) {
                        ft = fm.beginTransaction();
                        disFragment = new DiscussionFragment();
                        disFragment.setArguments(mBundle);
                        ft.replace(R.id.moduleDiscusion_container, disFragment);
                        ft.commit();
                    }
                    break;
                case R.id.rb_5:
                    if (Constants.isFirst) {

                    } else if (annFragment == null) {
                        ft = fm.beginTransaction();
                        annFragment = new AnnouncementFragment();
                        annFragment.setArguments(mBundle);
                        ft.replace(R.id.announcement_container, annFragment);
                        ft.commit();
                    }
                    break;
                case R.id.rb_6:
                    if (userFragment == null) {
                        ft = fm.beginTransaction();
                        userFragment = new ModuleUsersFragment();
                        userFragment.setArguments(mBundle);
                        ft.replace(R.id.moduleUsers_container, userFragment);
                        ft.commit();
                    }
                    break;
                case R.id.rb_7:
                    if (qf == null) {
                        ft = fm.beginTransaction();
                        qf = new QuizFragment();
                        qf.setArguments(mBundle);
                        ft.replace(R.id.moduleQuiz_container, qf);
                        ft.commit();
                    }
                    break;
                case R.id.rb_8:
                    if (Constants.isFirst) {

                    } else if (assignmentFragment == null) {
                        ft = fm.beginTransaction();
                        assignmentFragment = new AssignmentFragment();
                        assignmentFragment.setArguments(mBundle);
                        ft.replace(R.id.moduleAssignment_container, assignmentFragment);
                        ft.commit();
                    }
                    break;
                default:
                    break;
            }
            handler.postDelayed(new Runnable() {
                public void run() {
                    switchContainer(group.getCheckedRadioButtonId());
                }

                ;
            }, 25);
        }
    };
    private FrameLayout module_content_container;
    private FrameLayout announcement_container;
    private FrameLayout moduleUsers_container;
    private FrameLayout moduleQuiz_container;
    private FrameLayout moduleDiscusion_container;
    private FrameLayout moduleAssignment_container;
    private Map<Integer, FrameLayout> containerMap;
    private FrameLayout curContainer;
    private ImageView backBtn;
    private RadioGroup radioGroup;
    private TextView tv_loaded;
    private TextView tv_load_all_course;
    private TextView iv_badge;
    private Handler handler = new Handler();
    private OnClickListener listener = new OnClickListener() {

        @Override
        public void onClick(final View v) {
            getActivity().finish();
        }
    };

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.module_nav, container, false);
        fm = getFragmentManager();
        String courseId = null;
        String courseName = null;
        String bgUrl = null;
        if (getActivity() instanceof ModuleActivity) {
            ModuleActivity moduleActivity = (ModuleActivity) getActivity();
            courseId = moduleActivity.getCourse().getId() + "";
            courseName = moduleActivity.getCourse().getCourseName();
            bgUrl = moduleActivity.getCourse().getCoverImage();
        } else {
            if (getActivity() instanceof ActiveModuleActivity) {
                ActiveModuleActivity moduleActivity = (ActiveModuleActivity) getActivity();
                courseId = moduleActivity.getCourse().getId() + "";
                courseName = moduleActivity.getCourse().getCourseName();
                bgUrl = moduleActivity.getCourse().getCoverImage();
            } else if (getActivity() instanceof ActiveAssigmentActivity) {
                ActiveAssigmentActivity moduleActivity = (ActiveAssigmentActivity) getActivity();
                courseId = moduleActivity.getCourse().getId() + "";
                courseName = moduleActivity.getCourse().getCourseName();
                bgUrl = moduleActivity.getCourse().getCoverImage();
            } else if (getActivity() instanceof ActiveDisscussActivity) {
                ActiveDisscussActivity moduleActivity = (ActiveDisscussActivity) getActivity();
                courseId = moduleActivity.getCourse().getId() + "";
                courseName = moduleActivity.getCourse().getCourseName();
                bgUrl = moduleActivity.getCourse().getCoverImage();
            }
        }
        initView(v);
        putView();
        curContainer = module_content_container;
        setListener();
        mBundle = new Bundle();
        mBundle.putString(getResources().getString(R.string.courseId), courseId);
        mBundle.putString("courseName", courseName);
        mBundle.putString("bgUrl", bgUrl);
        TextView courseTitle = (TextView) v.findViewById(R.id.course_nav_title);
        courseTitle.setText(courseName);
        return v;
    }

    @SuppressLint("UseSparseArrays")
    private void putView() {
        containerMap = new HashMap<Integer, FrameLayout>();
        containerMap.put(R.id.rb_1, module_content_container);
        containerMap.put(R.id.rb_2, module_content_container);
        containerMap.put(R.id.rb_3, module_content_container);
        containerMap.put(R.id.rb_4, moduleDiscusion_container);
        containerMap.put(R.id.rb_5, announcement_container);
        containerMap.put(R.id.rb_6, moduleUsers_container);
        containerMap.put(R.id.rb_7, moduleQuiz_container);
        containerMap.put(R.id.rb_8, moduleAssignment_container);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (getActivity() instanceof ModuleActivity) {
            radioGroup.getChildAt(2).performClick();
        } else {
            if (getActivity() instanceof ActiveModuleActivity) {
                radioGroup.getChildAt(4).performClick();
            } else if (getActivity() instanceof ActiveAssigmentActivity) {
                radioGroup.getChildAt(7).performClick();
            } else if (getActivity() instanceof ActiveDisscussActivity) {
                radioGroup.getChildAt(3).performClick();
            }
            Constants.isFirst = false;
        }
    }

    //TODO
    public void setVideoCount(int loadedVideo, int allVideo) {
        tv_loaded.setText("已下载视频: " + loadedVideo + "个");
        iv_badge.setText("" + allVideo);
        if (allVideo == 0) iv_badge.setVisibility(View.GONE);
    }

    private void initView(View v) {
        backBtn = (ImageView) v.findViewById(R.id.btn_back_normal);
        module_content_container = (FrameLayout) getActivity().findViewById(
                R.id.module_content_container);
        announcement_container = (FrameLayout) getActivity().findViewById(
                R.id.announcement_container);
        moduleUsers_container = (FrameLayout) getActivity().findViewById(
                R.id.moduleUsers_container);
        moduleQuiz_container = (FrameLayout) getActivity().findViewById(
                R.id.moduleQuiz_container);
        moduleDiscusion_container = (FrameLayout) getActivity().findViewById(
                R.id.moduleDiscusion_container);
        moduleAssignment_container = (FrameLayout) getActivity().findViewById(
                R.id.moduleAssignment_container);
        tv_loaded = (TextView) v.findViewById(R.id.tv_loaded);
        iv_badge = (TextView) v.findViewById(R.id.iv_badge);
        tv_load_all_course = (TextView) v.findViewById(R.id.tv_load_all_course);

        radioGroup = (RadioGroup) v.findViewById(R.id.rg_tab);
        v.findViewById(R.id.rb_8);
        v.findViewById(R.id.rb_1);
        v.findViewById(R.id.rb_2);
        v.findViewById(R.id.rb_3);
        v.findViewById(R.id.rb_4);
        v.findViewById(R.id.rb_5);
        v.findViewById(R.id.rb_6);
        v.findViewById(R.id.rb_7);
    }

    private void setListener() {
        backBtn.setOnClickListener(listener);
        tv_load_all_course.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                ModuleContentFragment mFragment = (ModuleContentFragment) getFragmentManager().findFragmentByTag("ModuleContentFragment");
                mFragment.loadAllModule();
            }
        });
        radioGroup.setOnCheckedChangeListener(rgListener);
    }

    private void switchContainer(int v) {
        curContainer.setVisibility(View.INVISIBLE);
        curContainer = containerMap.get(v);
        curContainer.setVisibility(View.VISIBLE);
    }

    public void clickAnnounce() {
        if (Constants.ACTIVITY_VIEW == 2) {
            radioGroup.clearCheck();
            radioGroup.getChildAt(4).performClick();
            Constants.ACTIVITY_VIEW = 1;
        } else {
            getActivity().onBackPressed();
        }
    }

    public void clickAssignment() {
        if (Constants.ACTIVITY_VIEW == 2) {
            radioGroup.clearCheck();
            radioGroup.getChildAt(7).performClick();
            Constants.ACTIVITY_VIEW = 1;
        } else {
            getActivity().onBackPressed();
        }
    }

    public void clickDisscuss() {
        if (Constants.ACTIVITY_VIEW == 2) {
            radioGroup.clearCheck();
            radioGroup.getChildAt(3).performClick();
            Constants.ACTIVITY_VIEW = 1;
        } else {
            getActivity().onBackPressed();
        }
    }

    /**
     * Fragment 处理，显示、隐藏
     *
     * @param moduleContFmt
     */
    private void showFragment(ModuleContentFragment moduleContFmt) {
        if (moduleIntro != null) {
            moduleIntro.refreshUI();
        }
        ft = fm.beginTransaction();
        if (moduleIntro == null) {
            moduleIntro = new ModuleIntroFragment();
            moduleIntro.setArguments(mBundle);
            ft.add(R.id.module_content_container, moduleIntro);
        }
        ft.show(moduleIntro);
        if (moduleContFmt != null) {
            ft.hide(moduleContFmt);
        }
        MyCourseItemFragment fg = (MyCourseItemFragment) fm
                .findFragmentByTag("单元条");
        ft.commit();
    }

    public View getNavView() {
        return v;
    }
}