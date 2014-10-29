package com.kaikeba.activity.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import com.kaikeba.common.api.QuizAPI;
import com.kaikeba.common.entity.Quiz;
import com.kaikeba.common.util.DateUtils;
import com.kaikeba.common.util.ImgLoaderUtil;
import com.kaikeba.phone.R;
import org.jsoup.Jsoup;

import java.util.ArrayList;
import java.util.List;

/**
 * 测验Fragment
 *
 * @author Super Man
 */
public class QuizFragment extends Fragment {

    private ListView myCourseQuizListView;
    private ArrayList<Quiz> quizs;
    private String courseId;
    private QuestionFragment qFragment;
    private LinearLayout view_loading;
    private TextView tv_ass;
    private TextView tv_pra;
    private TextView tv_check;
    private QuizAdapter adapter;
    private ArrayList<Quiz> assList = new ArrayList<Quiz>();
    private ArrayList<Quiz> praList = new ArrayList<Quiz>();
    private ArrayList<Quiz> checkList = new ArrayList<Quiz>();
    private OnClickListener clickListener = new OnClickListener() {

        @Override
        public void onClick(View v) {
            setBackage(v);
            setTextColor(v);
            switch (v.getId()) {
                case R.id.tv1:
                    if (assList.isEmpty()) {
                        Toast.makeText(getActivity(), "无作业测验", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setData(assList);
                        handler.sendEmptyMessage(2);
                    }
                    break;
                case R.id.tv2:
                    if (praList.isEmpty()) {
                        Toast.makeText(getActivity(), "无练习测验", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setData(praList);
                        handler.sendEmptyMessage(2);
                    }
                    break;
                case R.id.tv3:
                    if (checkList.isEmpty()) {
                        Toast.makeText(getActivity(), "无调查", Toast.LENGTH_SHORT)
                                .show();
                    }
                    if (adapter != null) {
                        adapter.setData(checkList);
                        handler.sendEmptyMessage(2);
                    }
                    break;
                default:
                    break;
            }
        }
    };
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            super.handleMessage(msg);
            switch (msg.what) {
                case 0:
                    Toast.makeText(getActivity(), "题目为空", Toast.LENGTH_SHORT).show();
                    break;
                case 1:
                    Toast.makeText(getActivity(), "账号已过期，请重新登录", Toast.LENGTH_SHORT).show();
                    break;
                case 2:
                    adapter.notifyDataSetChanged();
                    break;
                default:
                    break;
            }
        }
    };
    @SuppressWarnings("unused")
    private OnItemClickListener listener = new OnItemClickListener() {

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position,
                                long id) {
            // TODO Auto-generated method stub
//
//			final Quiz quiz = quizs.get(position);
//
//			new ProgressDialogHelper(getActivity(), R.drawable.icon_quiz_normal)
//			.showProgressDialog("进入测验", "正在加载，请稍后...",
//					new ProgressCallBack() {
//
//						public void action() {
//							final ArrayList<Question> questions = QuizAPI.getSingleTopic(courseId, quiz.getId() + "");
//							handler.post(new Runnable(){
//								public void run() {
//									Question[] saveQuestions = null;
//									try {
//										saveQuestions = (Question[]) ObjectSerializableUtil.readObject("" + courseId + quiz.getId() + API.getAPI().getUserObject().getId());
//									} catch (Exception e) {
//										// TODO Auto-generated catch block
//										e.printStackTrace();
//									}
//
//									if (questions.size() == 0) {
//										handler.sendEmptyMessage(0);
//										return;
//									}
//									FragmentTransaction ft = getFragmentManager().beginTransaction();
//									if (qFragment == null) {
//										qFragment = new QuestionFragment();
//									}
//									Bundle b = new Bundle();
//									b.putString("courseId", courseId);
//									b.putString("quizId", quiz.getId() + "");
//									b.putSerializable("questions", questions);
//									if (saveQuestions != null) {
//										b.putSerializable("saveQuestionArray", saveQuestions);
//									}
//									qFragment.setArguments(b);
//									ft.replace(R.id.moduleQuiz_container, qFragment);
//									ft.addToBackStack("测验题目");
//									ft.commit();
//								};
//							});
//						}
//			});
        }
    };

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.my_course_quiz, container, false);
        tv_ass = (TextView) v.findViewById(R.id.tv1);
        tv_pra = (TextView) v.findViewById(R.id.tv2);
        tv_check = (TextView) v.findViewById(R.id.tv3);
        tv_ass.setOnClickListener(clickListener);
        tv_pra.setOnClickListener(clickListener);
        tv_check.setOnClickListener(clickListener);
        view_loading = (LinearLayout) v.findViewById(R.id.view_loading);
        myCourseQuizListView = (ListView) v
                .findViewById(R.id.myCourseQuizListView);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
//		myCourseQuizListView.setOnItemClickListener(listener);
        assList.clear();
        praList.clear();
        checkList.clear();
        ImgLoaderUtil.threadPool.submit(new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub

                quizs = QuizAPI.getAllQuizs(courseId);
                for (Quiz quiz : quizs) {
                    if ("assignment".equals(quiz.getQuiz_type())) {
                        assList.add(quiz);
                    } else if ("practice_quiz".equals(quiz.getQuiz_type())) {
                        praList.add(quiz);
                    } else if ("survey".equals(quiz.getQuiz_type())) {
                        checkList.add(quiz);
                    }
                }
//				String url = "http://learn.kaikeba.com/courses/" + courseId
//						+ "/quizzes?persist_healdess=1&access_token="
//						+ API.getAPI().getUserObject().getAccessToken();
//				final List<Quiz> quizList = new ArrayList<Quiz>();
//
//				for (int i = 0, len = quizs.size(); i < len; ++i) {
//
//					Quiz quiz = null;
//					try {
//						quiz = QuizAPI.load(url, String.valueOf(quizs.get(i).getId()));
//					} catch (Exception e) {
//						// TODO Auto-generated catch block
//						if (e instanceof NoAuthException) {
//							handler.sendEmptyMessage(1);
//						}
//						return;
//					}
//					if (quiz != null) {
//						quizList.add(quiz);
//					} else {
//						quizs.remove(quizs.get(i));
//						--len;
//						--i;
//					}
//				}
                adapter = new QuizAdapter(new ArrayList<Quiz>(), null);
                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        view_loading.setVisibility(View.GONE);
                        myCourseQuizListView.setAdapter(adapter);
                        adapter.setData(assList);
                        tv_ass.performClick();
                    }
                });
            }
        });
    }

    private void setBackage(View v) {
        if (v == tv_ass) {
            tv_ass.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_normal));
            tv_pra.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_check.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        }
        if (v == tv_pra) {
            tv_ass.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_pra.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_normal));
            tv_check.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_selected));
        }
        if (v == tv_check) {
            tv_ass.setBackground(getResources().getDrawable(
                    R.drawable.tab_left_selected));
            tv_pra.setBackground(getResources().getDrawable(
                    R.drawable.tab_middle_selected));
            tv_check.setBackground(getResources().getDrawable(
                    R.drawable.tab_right_normal));
        }
    }

    private void setTextColor(View v) {
        TextView[] views = {tv_ass, tv_pra, tv_check};
        for (TextView view : views) {
            if (view == v) {
                view.setTextColor(getResources().getColor(
                        R.color.activity_top_text_check));
            } else {
                view.setTextColor(getResources().getColor(
                        R.color.activity_top_text_normal));
            }
        }
    }

    class QuizAdapter extends BaseAdapter {

        private ArrayList<Quiz> quizs = new ArrayList<Quiz>();
//		private List<Quiz> quizList;

        public QuizAdapter(ArrayList<Quiz> quizs,
                           List<Quiz> quizList) {
            this.quizs = quizs;
//			this.quizList = quizList;
        }

        public void setData(ArrayList<Quiz> quizs) {
            this.quizs.clear();
            this.quizs.addAll(quizs);
        }

        @Override
        public int getCount() {
            // TODO Auto-generated method stub
            return quizs.size();
        }

        @Override
        public Object getItem(int position) {
            // TODO Auto-generated method stub
            return quizs.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // TODO Auto-generated method stub
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = getActivity().getLayoutInflater().inflate(
                        R.layout.my_course_quiz_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
//			if (quizs.get(position).getQuiz_type().equals("assignment"))
//			{
//				holder.tv_quiz_type.setText("作业测验");
//			}
//			else if (quizs.get(position).getQuiz_type().equals("survey")) {
//				holder.tv_quiz_type.setText("问卷调查");
//			}
//			else if (quizs.get(position).getQuiz_type().equals("practice_quiz")) {
//				holder.tv_quiz_type.setText("练习测验");
//			}

            if (quizs.get(position).getUnlock_at() != null && !DateUtils.getDateprice(quizs.get(position).getUnlock_at())) {
                holder.tv_quiz_due.setText("解锁时间:  ");
                holder.tv_quiz_due_date.setText(DateUtils.getCourseStartTime(quizs.get(position).getUnlock_at()));
            } else {
                holder.tv_quiz_due.setText("到期时间:  ");
                if (quizs.get(position).getDue_at() != null) {
                    holder.tv_quiz_due_date.setText(DateUtils.getCourseStartTime(quizs.get(position).getDue_at()));
                }
            }
            if (quizs.get(position) == null || quizs.get(position).getDescription() == null || quizs.get(position).getDescription().trim().length() == 0) {
                holder.tv_quiz_l_message.setVisibility(View.GONE);
            } else {
                holder.tv_quiz_l_message.setText(Jsoup.parse(quizs.get(position).getDescription()).text());
//				holder.tv_quiz_l_message.setText(Html.fromHtml(quizs.get(position).getDescription()).toString());
                holder.tv_quiz_l_message.setVisibility(View.VISIBLE);
            }
            holder.tv_quiz_title.setText(quizs.get(position).getTitle());
            holder.quiz_count.setText(quizs.get(position).getQuestion_count());
            if ("-1".equals(quizs.get(position).getAllowed_attempts())) {
                holder.quiz_attempts.setText("不限");
            } else {
                holder.quiz_attempts.setText(quizs.get(position).getAllowed_attempts());
            }
            holder.quiz_time_limit.setText(quizs.get(position).getTime_limit());
            return convertView;
        }

        class ViewHolder {
            TextView tv_quiz_due_date;
            TextView tv_quiz_due;
            TextView tv_quiz_l_message;
            TextView tv_quiz_title;
            TextView quiz_count;
            TextView quiz_attempts;
            TextView quiz_time_limit;

            ViewHolder(View v) {
                tv_quiz_title = (TextView) v.findViewById(R.id.tv_quiz_title);
                tv_quiz_due_date = (TextView) v.findViewById(R.id.tv_quiz_due_date);
                tv_quiz_due = (TextView) v.findViewById(R.id.tv_quiz_due);
                tv_quiz_l_message = (TextView) v.findViewById(R.id.tv_quiz_l_message);
                quiz_count = (TextView) v.findViewById(R.id.quiz_count);
                quiz_attempts = (TextView) v.findViewById(R.id.quiz_attempts);
                quiz_time_limit = (TextView) v.findViewById(R.id.quiz_time_limit);
            }
        }
    }
}
