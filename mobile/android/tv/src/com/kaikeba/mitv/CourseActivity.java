package com.kaikeba.mitv;

import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.entity.Course;
import com.kaikeba.common.entity.Module;
import com.kaikeba.common.entity.ModuleVideo;
import com.kaikeba.common.util.BitmapHelp;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.NetworkUtil;
import com.kaikeba.mitv.fragment.UnitContentFragment;
import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.umeng.analytics.MobclickAgent;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CourseActivity extends FragmentActivity {

    @ViewInject(R.id.courseName)
    private TextView courseName;

    @ViewInject(R.id.colledgeName)
    private TextView schoolName;

    @ViewInject(R.id.tv_instructor_name)
    private TextView instructorName;

    @ViewInject(R.id.courseBreaf)
    private TextView courseBrief;

    @ViewInject(R.id.iv_cover)
    private ImageView ivCover;

    @ViewInject(R.id.vp_unit)
    private ViewPager vpUnit;

    private Course mCourse;

    private int currIndex = 0;

    @ViewInject(R.id.tv_module_name)
    private TextView moduleName;

    private ArrayList<Fragment> fragmentsList;

    private ArrayList<Module> modules;
    private List<ModuleVideo> moduleVideos;
    private List<String> modulesIds = new ArrayList<String>();
    private List<String> itemIds = new ArrayList<String>();
    private Map<String, String> urlMap = new HashMap<String, String>();
    private boolean runFlag = true;
    private Handler handler = new Handler() {

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.course);
        ViewUtils.inject(this);
        setText();
        initDate();
        if (!NetworkUtil.isNetworkAvailable(CourseActivity.this)) {
            Toast.makeText(CourseActivity.this, "网络未连接", Toast.LENGTH_LONG).show();
        }
    }

    private void setText() {
        BitmapUtils bitmapUtils = BitmapHelp.getBitmapUtils(getApplicationContext());
        mCourse = (Course) getIntent().getSerializableExtra("course");
        courseName.setText(mCourse.getCourseName());
        schoolName.setText("单位： " + mCourse.getSchoolName());
        instructorName.setText("讲师： " + mCourse.getInstructorName());
        courseBrief.setText("课程简介： " + mCourse.getCourseBrief());
        bitmapUtils.display(ivCover, mCourse.getCoverImage());
    }

    private void initDate() {
        Log.v("CourseActivity", "initData start");
        fragmentsList = new ArrayList<Fragment>();
        Map<String, String> params = new HashMap<String, String>();
        Type type = new TypeToken<String>() {
        }.getType();
        params.put("Authorization", "Bearer " + ConfigLoader.getLoader().getCanvas().getAccessToken());
//        ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModulesURL(mCourse.getId().toString()), params, false,type, new ServerDataCache.LoadDataCallbacks() {
//            @Override
//            public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                if (errorCode != ServerDataCache.ERROR_OK) return;
//
//                Log.v("CourseActivity", "initData load Modules");
//                Type type = new TypeToken<ArrayList<Module>>() {
//                }.getType();
//                final ArrayList<Module> modulesOriginal = (ArrayList<Module>) JsonEngine.parseJson((String)data, type);
//                Type type1 = new TypeToken<String>() {
//                }.getType();
//
////                Map<String, String> params = new HashMap<String, String>();
////                params.put("Authorization", "Bearer sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I");
//                ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModuleVideosURL(mCourse.getId().toString()),
//                        null, false,type1 ,new ServerDataCache.LoadDataCallbacks() {
//                    @Override
//                    public void onFinish(Object json, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                        if (errorCode != ServerDataCache.ERROR_OK) return;
//                        String jsonO=(String)json;
//                        Log.v("CourseActivity", "initData load video url");
//                        int index = jsonO.indexOf("[");
//                        jsonO = jsonO.substring(index);
//                        Type type = new TypeToken<ArrayList<ModuleVideo>>() {
//                        }.getType();
//                        @SuppressWarnings("unchecked")
//                        ArrayList<ModuleVideo> moduleVideos = (ArrayList<ModuleVideo>) JsonEngine.parseJson(jsonO, type);
//
//                        if (moduleVideos == null) {
//                            moduleVideos = new ArrayList<ModuleVideo>();
//                        }
//
//                        if (moduleVideos != null && !moduleVideos.isEmpty()) {
//                            Constants.videoUrlIsNull = false;
//                        }
//                        modules = new ArrayList<Module>();
//                        int moduleIndex = 0;
//                        for (ModuleVideo mVideo : moduleVideos) {
//                            modulesIds.add("" + mVideo.getModuleID());
//                            for (ModuleVideo.ItemVideo item : mVideo.getVideoList()) {
//                                itemIds.add(mVideo.getModuleID() + "#" + item.getItemID());
//                                urlMap.put(mVideo.getModuleID() + "#" + item.getItemID(), item.getVideoURL());
//                            }
//
//                            if (mVideo.getVideoList().size() > 0) {
//                                UnitContentFragment ucf = UnitContentFragment.newInstance(mVideo.getVideoList(), mCourse.getId().toString());
//                                fragmentsList.add(ucf);
//                                modules.add(modulesOriginal.get(moduleIndex));
//                            }
//
//                            moduleIndex++;
//                        }
//
//                        vpUnit.setAdapter(new MyFragmentPagerAdapter(getSupportFragmentManager(), fragmentsList));
//                        vpUnit.setCurrentItem(0);
//                        vpUnit.setOnPageChangeListener(new MyOnPageChangeListener());
//                        moduleName.setText(CourseActivityHelper.formatModuleName(modules.get(currIndex).getName()));
//
//                        Log.v("CourseActivity", "initData end");
//
////                        ServerDataCache.getInstance().dataWithURL(ModulesAPI.buildModuleItemsURL(mCourse.getId().toString(), ),
////                                null, false, new ServerDataCache.LoadDataCallbacks() {
////                            @Override
////                            public void onFinish(String data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
////                                if (errorCode != ServerDataCache.ERROR_OK) return;
////
////                                String url = buildModuleItemsURL(courseID, moduleID);
////                                System.out.println("GET: " + url);
////                                String json = DibitsHttpClient.doGet4Token(url, token);
////                                Type type = new TypeToken<ArrayList<Item>>() {
////                                }.getType();
////                                ArrayList<Item> items = (ArrayList<Item>) JsonEngine.parseJson(json, type);
////                                return items;
////
////                            }
////                        })
//
//
////                        // ----------------
////                        if (moduleVideos != null && !moduleVideos.isEmpty()) {
////                            Constants.videoUrlIsNull = false;
////                        }
////                        for (ModuleVideo mVideo : moduleVideos) {
////                            modulesIds.add("" + mVideo.getModuleID());
////                            for (ItemVideo item : mVideo.getVideoList()) {
////                                itemIds.add(mVideo.getModuleID() + "#" + item.getItemID());
////                                urlMap.put(mVideo.getModuleID() + "#" + item.getItemID(), item.getVideoURL());
////                            }
////                        }
////
////                        for (final Module m : modules) {
////                            if (!runFlag) {
////                                return;
////                            }
////                            final List<Item> items = ModulesAPI.getModuleItmesInPublic(mCourse.getId().toString(), m.getId().toString());
////                            for (Item item : items) {
////                                if (itemIds.contains(m.getId() + "#" + item.getId())) {
////                                    item.setVideoUrl(urlMap.get(m.getId() + "#" + item.getId()));
////                                }
////                            }
////                            UnitContentFragment ucf = UnitContentFragment.newInstance(items, mCourse.getId().toString());
////                            fragmentsList.add(ucf);
////
////                            vpUnit.setAdapter(new MyFragmentPagerAdapter(getSupportFragmentManager(), fragmentsList));
////                            vpUnit.setCurrentItem(0);
////                            vpUnit.setOnPageChangeListener(new MyOnPageChangeListener());
////                            moduleName.setText(modules.get(currIndex).getName());
////                        }
//                    }
//                });
//            }
//        });
//		new Thread() {
//			public void run() {
//				try {
//					fragmentsList = new ArrayList<Fragment>();
//					modules = ModulesAPI.getModulesInPublic(mCourse.getId().toString());
//					if (!runFlag) {
//						return;
//					}
//					moduleVideos = ModulesAPI.getModuleVideos(mCourse.getId().toString(), "sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I");
//					if (!runFlag) {
//						return;
//					}
//					if (moduleVideos != null && !moduleVideos.isEmpty()) {
//						Constants.videoUrlIsNull = false;
//					}
//					for (ModuleVideo mVideo : moduleVideos) {
//						modulesIds.add("" + mVideo.getModuleID());
//						for (ItemVideo item : mVideo.getVideoList()) {
//							itemIds.add(mVideo.getModuleID() + "#" + item.getItemID());
//							urlMap.put(mVideo.getModuleID() + "#" + item.getItemID(), item.getVideoURL());
//						}
//					}
//
//					for (final Module m : modules) {
//						if (!runFlag) {
//							return;
//						}
//						final List<Item> items = ModulesAPI.getModuleItmesInPublic(mCourse.getId().toString(), m.getId().toString());
//						for (Item item : items) {
//							if (itemIds.contains(m.getId() + "#" + item.getId())) {
//								item.setVideoUrl(urlMap.get(m.getId() + "#" + item.getId()));
//							}
//						}
//						UnitContentFragment ucf = UnitContentFragment.newInstance(items, mCourse.getId().toString());
//						fragmentsList.add(ucf);
//
//					}
//					handler.post(new Runnable(){
//						@Override
//						public void run() {
//							vpUnit.setAdapter(new MyFragmentPagerAdapter(getSupportFragmentManager(), fragmentsList));
//							vpUnit.setCurrentItem(0);
//							vpUnit.setOnPageChangeListener(new MyOnPageChangeListener());
//							moduleName.setText(modules.get(currIndex).getName());
//						}
//					});
//				} catch (DibitsExceptionC e) {
//					// TODO Auto-generated catch block
//					e.printStackTrace();
//					return;
//				}
//			};
//		}.start();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        Log.v("CourseActivity", "dispatchKeyEvent " + event.getKeyCode());

        if (modules == null || modules.size() == 0) {
            return super.dispatchKeyEvent(event);
        }

        if (event.getAction() == KeyEvent.ACTION_UP) {
            int keyCode = event.getKeyCode();
            // 第一行的时候，Activity自己处理
            switch (keyCode) {
                case KeyEvent.KEYCODE_DPAD_LEFT:
//				if (currIndex > 0) {
//					vpUnit.setCurrentItem(--currIndex);
//				}
//				((UnitContentFragment)fragmentsList.get(currIndex)).requestFoces();
                    moduleName.setText(CourseActivityHelper.formatModuleName(modules.get(currIndex).getName()));
                    ((ImageView) findViewById(R.id.arrow_left)).setImageResource(R.drawable.arrow_left);
                    ((ImageView) findViewById(R.id.arrow_right)).setImageResource(R.drawable.arrow_right);
                    if (currIndex == 0) {
                        ((ImageView) findViewById(R.id.arrow_left)).setImageResource(R.drawable.arrow_left_disabled);
                    }
                    break;
                case KeyEvent.KEYCODE_DPAD_RIGHT:
//				if (currIndex < modules.size() - 1) {
//					vpUnit.setCurrentItem(++currIndex);
//				}
//				((UnitContentFragment)fragmentsList.get(currIndex)).requestFoces();
                    moduleName.setText(CourseActivityHelper.formatModuleName(modules.get(currIndex).getName()));
                    ((ImageView) findViewById(R.id.arrow_left)).setImageResource(R.drawable.arrow_left);
                    ((ImageView) findViewById(R.id.arrow_right)).setImageResource(R.drawable.arrow_right);
                    if (currIndex == modules.size() - 1) {
                        ((ImageView) findViewById(R.id.arrow_right)).setImageResource(R.drawable.arrow_right_disabled);
                    }
                    break;
                case KeyEvent.KEYCODE_DPAD_UP:
                    break;
                case KeyEvent.KEYCODE_DPAD_DOWN:
                    break;
                case KeyEvent.KEYCODE_BACK:
                    runFlag = false;
                    finish();
                    break;
                default:
                    break;
            }
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    private void setBackageGround() {
//    	tvTabMore.setBackgroundColor(0x00ffffff);
    }

    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    public class MyOnPageChangeListener implements OnPageChangeListener {

        @Override
        public void onPageSelected(int arg0) {
            currIndex = arg0;
            ((UnitContentFragment) fragmentsList.get(currIndex)).requestFoces();
        }

        @Override
        public void onPageScrolled(int arg0, float arg1, int arg2) {
        }

        @Override
        public void onPageScrollStateChanged(int arg0) {
        }
    }

}
