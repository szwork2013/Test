package com.kaikeba.activity.fragment;


import android.app.Fragment;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.kaikeba.activity.ActiveAssigmentActivity;
import com.kaikeba.common.api.AssignmentAPI;
import com.kaikeba.common.entity.Assignment;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;

import java.util.ArrayList;

/**
 * 作业Fragment
 *
 * @author Super Man
 */
public class AssignmentFragment extends Fragment {

    private LinearLayout llAssignmentFuture;
    private LinearLayout llAssignmentBefore;
    private String courseId;
    private LayoutInflater inflater;
    private LinearLayout view_loading;
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    Toast.makeText(getActivity(), "账号已过期，请重新登录", Toast.LENGTH_SHORT).show();
                    break;
                default:
                    break;
            }
        }

        ;
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        this.inflater = inflater;
        View v = inflater.inflate(R.layout.my_course_module_assignment, container, false);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
        findViews(v);
        return v;
    }

    private void findViews(View v) {
        llAssignmentFuture = (LinearLayout) v.findViewById(R.id.ll_assignment_future);
        llAssignmentBefore = (LinearLayout) v.findViewById(R.id.ll_assignment_before);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        ImgLoaderUtil.threadPool.submit(new Runnable() {

            public void run() {
                ArrayList<Assignment> assignmentList = AssignmentAPI.getAllAssignment(courseId);
                final ArrayList<Assignment> futureAssignmentList = new ArrayList<Assignment>();
                final ArrayList<Assignment> beforeAssignmentList = new ArrayList<Assignment>();

                for (Assignment single : assignmentList) {
                    if (single.getDue_at() != null && DateUtils.getDateprice(single.getDue_at())) {
                        beforeAssignmentList.add(single);
                    } else if (single.getUnlock_at() != null && DateUtils.getDateprice(single.getUnlock_at())) {
                        beforeAssignmentList.add(single);
                    }
//					else if (single.getLock_info() != null && single.getLock_info().getLock_at() != null && DateUtils.getDateprice(single.getLock_info().getLock_at())) {
//						beforeAssignmentList.add(single);
//					}
                    else {
                        futureAssignmentList.add(single);
                    }
                }
                assignmentList.clear();
                assignmentList = null;
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        view_loading.setVisibility(View.GONE);
                        int i = 1;
                        // TODO Auto-generated method stub
                        for (Assignment singleOne : futureAssignmentList) {
                            View view = inflater.inflate(R.layout.my_course_module_assignment_item, null);
                            llAssignmentFuture.addView(view, i);
                            drawingViews(view, singleOne);
                            view.setOnClickListener(new MyClickListener(singleOne, futureAssignmentList));
                            i++;
                        }
                        llAssignmentBefore.setVisibility(View.VISIBLE);
                        int j = 1;
                        for (Assignment singleOne : beforeAssignmentList) {
                            View view = inflater.inflate(R.layout.my_course_module_assignment_item, null);
                            llAssignmentBefore.addView(view, j);
                            drawingViews(view, singleOne);
                            view.setOnClickListener(new MyClickListener(singleOne, beforeAssignmentList));
                            j++;
                        }
                    }
                });
            }
        });
    }

    private void drawingViews(View view, Assignment singleOne) {
        TextView tvAssignmengItemName = (TextView) view.findViewById(R.id.tv_assignmeng_item_name);
        TextView tvAssignmengItemTime = (TextView) view.findViewById(R.id.tv_assignmeng_item_time);
        TextView tvAssignmengItemPoint = (TextView) view.findViewById(R.id.tv_assignmeng_item_point);
        tvAssignmengItemName.setText(singleOne.getName());
        if (singleOne.getDue_at() != null) {
            tvAssignmengItemTime.setText(DateUtils.getCourseStartTime(singleOne.getDue_at()));
        } else if (singleOne.getUnlock_at() != null) {
            tvAssignmengItemTime.setText(DateUtils.getCourseStartTime(singleOne.getUnlock_at()));
        }
//		else if (singleOne.getLock_info() != null && singleOne.getLock_info().getLock_at() != null){
//			tvAssignmengItemTime.setText(DateUtils.getCourseStartTime(singleOne.getLock_info().getLock_at()));
//		}
        else {
            tvAssignmengItemTime.setText("");
        }
        tvAssignmengItemPoint.setText("满分" + singleOne.getPoints_possible());
    }

    class MyClickListener implements OnClickListener {

        private Assignment singleOne;
        private ArrayList<Assignment> assignments;

        public MyClickListener(Assignment singleOne, ArrayList<Assignment> assignments) {
            // TODO Auto-generated constructor stub
            this.singleOne = singleOne;
            this.assignments = assignments;
        }

        @Override
        public void onClick(View v) {
            if (singleOne.getDue_at() != null && DateUtils.getDateprice(singleOne.getDue_at())) {
                Toast.makeText(getActivity(), "题目已锁定", Toast.LENGTH_SHORT).show();
                return;
            }
            AssignmentItemFragment aif = new AssignmentItemFragment();
            Bundle b = new Bundle();
            b.putSerializable("assignment", singleOne);
            if (getActivity() instanceof ActiveAssigmentActivity) {
                b.putInt("index", assignments.indexOf(singleOne));
            }
            b.putSerializable("assignments", assignments);
            aif.setArguments(b);
            FragmentTransaction ft = getFragmentManager().beginTransaction();
            ft.replace(R.id.moduleAssignment_container, aif).addToBackStack("作业");
            ft.commit();
//			if (singleOne.getSubmission_types() != null && singleOne.getSubmission_types().contains("online_quiz")) {
//				new ProgressDialogHelper(getActivity(), R.drawable.icon_quiz_normal)
//				.showProgressDialog("进入测验", "正在加载，请稍后",
//						new ProgressCallBack() {
//							public void action() {
//								String quizId = null;
//								try {
//									quizId = RedirectTools.getQuizId(singleOne.getHtml_url());
//								} catch (Exception e1) {
//									// TODO Auto-generated catch block
//									e1.printStackTrace();
//								}
//								final ArrayList<Question> questions = QuizAPI.getSingleTopic(courseId, quizId);
//								handler.post(new Runnable(){
//									public void run() {
//										Question[] saveQuestions = null;
//										try {
//											saveQuestions = (Question[]) ObjectSerializableUtil.readObject("" + courseId + singleOne.getId());
//										} catch (Exception e) {
//											// TODO Auto-generated catch block
//											e.printStackTrace();
//										}
//
//										if (questions.size() == 0) {
//											handler.sendEmptyMessage(0);
//											return;
//										}
//										FragmentTransaction ft = getFragmentManager().beginTransaction();
//										QuestionFragment qFragment = new QuestionFragment();
//										Bundle b = new Bundle();
//										b.putString("courseId", courseId);
//										b.putString("quizId", singleOne.getId() + "");
//										b.putSerializable("questions", questions);
//										if (saveQuestions != null) {
//											b.putSerializable("saveQuestionArray", saveQuestions);
//										}
//										qFragment.setArguments(b);
//										ft.replace(R.id.moduleQuiz_container, qFragment);
//										ft.addToBackStack("测验题目");
//										ft.commit();
//									};
//								});
//							}
//				});
        }
//			else {
//				AssignmentItemFragment aif = new AssignmentItemFragment();
//				Bundle b = new Bundle();
//				b.putSerializable("assignment", singleOne);
//				b.putSerializable("assignments", assignments);
//				aif.setArguments(b);
//				FragmentTransaction ft = getFragmentManager().beginTransaction();
//				ft.replace(R.id.moduleAssignment_container, aif).addToBackStack("作业");
//				ft.commit();
//			}
//		}
    }

    class ViewHolder {

        TextView tvAssignmengItemName;
        TextView tvAssignmengItemTime;
        TextView tvAssignmengItemPoint;

        public ViewHolder(View v) {
            tvAssignmengItemName = (TextView) v.findViewById(R.id.tv_assignmeng_item_name);
            tvAssignmengItemTime = (TextView) v.findViewById(R.id.tv_assignmeng_item_time);
            tvAssignmengItemPoint = (TextView) v.findViewById(R.id.tv_assignmeng_item_point);
        }
    }

}
