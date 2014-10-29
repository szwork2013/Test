package com.kaikeba.activity.fragment;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.text.method.DigitsKeyListener;
import android.text.method.ScrollingMovementMethod;
import android.view.*;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.*;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import com.kaikeba.common.entity.question.*;
import com.kaikeba.phone.R;

import java.util.ArrayList;
import java.util.List;

/**
 * 题目Fragment
 *
 * @author Super Man
 */
public class QuestionFragment extends Fragment {

    View vv;
    private Activity context;
    private LayoutInflater inflater;
    private TextView tvQuizTitle;
    private TextView tvQuizMsgTitle;
    private ImageView ivQuizQuestionMark;
    private ImageView back;
    private TextView tvQuizQuestionTitle;
    private TextView tvQuizQuestionPoint;
    private LinearLayout llQuizQuestionMsg;
    private LinearLayout llQuizContent;
    private LinearLayout llQuizTopNav;
    private ImageButton ivQuizRightNavSave;
    private ImageButton ivQuizRightNavSubmit;
    private ImageButton ivQuizRightNavBack;
    private ImageButton ivQuizRightNavNext;
    private ArrayList<Question> questions;
    //当前题目索引
    private int questionIndex = 0;

    private String courseId;
    private String quizId;
    /**
     * 是否标记
     */
    private boolean[] IS_MARK;

    /**
     * 需要保存的题目信息
     */
    private Question[] saveQuestionArray;
    /**
     * 控件监听事件
     */
    private OnClickListener listener = new OnClickListener() {
        @Override
        public void onClick(View v) {
            // TODO 需要保存结果
            int id = v.getId();
            switch (id) {

                //右侧功能键相关
                case R.id.iv_quiz_right_nav_back:
                    ((HorizontalScrollView) vv.findViewById(R.id.scroll_view)).smoothScrollTo(0, 20);
                    if (questionIndex == 0) {
                        Toast.makeText(context, "已经是第一题", Toast.LENGTH_SHORT).show();
                    } else {
                        setIvMarkedBg();
                        questionIndex--;
                        setTopNavActiveViewBg();
                        scanQuestion();
                        llQuizTopNav.getChildAt(questionIndex).setVisibility(View.VISIBLE);
                    }
                    break;
                case R.id.iv_quiz_right_nav_next:
                    ((HorizontalScrollView) vv.findViewById(R.id.scroll_view)).smoothScrollTo(0, 20);
                    if (questions.size() - 1 == questionIndex) {
                        setLastQuestuinAction();
                    } else {
                        setIvMarkedBg();
                        questionIndex++;
                        setTopNavActiveViewBg();
                        scanQuestion();
                        setNavViewHide();
                    }
                    break;
                case R.id.iv_quiz_right_nav_save:
//				new ProgressDialogHelper(getActivity(), android.R.drawable.ic_dialog_map)
//					.showProgressDialog("保存答案", "正在保存，请稍后...",
//						new ProgressCallBack() {
//							public void action() {
//								//TODO
//								try {
//									ObjectSerializableUtil.writeObject(saveQuestionArray, courseId + quizId + API.getAPI().getUserObject().getId());
//									handler.sendEmptyMessage(0);
//								} catch (Exception e) {
//									// TODO Auto-generated catch block
//									e.printStackTrace();
//									handler.sendEmptyMessage(1);
//								}
//							}
//					});
                    break;
                case R.id.iv_quiz_right_nav_submit:
                    //TODO
                    break;
                //标记
                case R.id.iv_quiz_question_mark:
                    if (!IS_MARK[questionIndex]) {
                        ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
                        IS_MARK[questionIndex] = true;
                    } else {
                        ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
                        IS_MARK[questionIndex] = false;
                    }
                    if (saveQuestionArray[questionIndex] != null)
                        saveQuestionArray[questionIndex].setMark(IS_MARK[questionIndex]);
                    break;

                case R.id.back:
                    getActivity().onBackPressed();
                    break;
                default:
                    break;
            }
        }
    };
    private Handler handler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case 0:
                    Toast.makeText(context, "保存成功", Toast.LENGTH_LONG).show();
                    break;
                case 1:
                    Toast.makeText(context, "保存失败", Toast.LENGTH_LONG).show();
                    break;
                default:
                    break;
            }
        }

        ;
    };
    /**
     * 多选时是否选中
     */
    private boolean[] isSelect;
    private int multipleEditPosition = -1;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        vv = inflater.inflate(R.layout.quiz_content, container, false);
        findViews(vv);
        getSeriazableObj();
        setFlag();
        this.inflater = inflater;
        return vv;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        context = getActivity();
        initTopNavViews(questions.size());
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        questionIndex = 0;
        scanQuestion();
    }

    private void getSeriazableObj() {
        @SuppressWarnings("unchecked")
        ArrayList<Question> questions = (ArrayList<Question>) getArguments()
                .get("questions");
        this.questions = questions;
        saveQuestionArray = (Question[]) getArguments().get("saveQuestionArray");
        if (saveQuestionArray == null) {
            saveQuestionArray = new Question[questions.size()];
        }
        int size = questions.size();
        if (size != saveQuestionArray.length) {
            saveQuestionArray = new Question[size];
            for (int i = 0; i < size; i++) {
                saveQuestionArray[i] = questions.get(i);
            }
        }
        courseId = getArguments().getString(getResources().getString(R.string.courseId));
        quizId = getArguments().getString("quizId");
    }

    private void setFlag() {
        IS_MARK = new boolean[questions.size()];
        for (int i = 0; i < questions.size(); i++) {
            IS_MARK[i] = false;
        }
        for (int i = 0; i < saveQuestionArray.length; i++) {
            if (saveQuestionArray[i] != null && saveQuestionArray[i].isMark()) {
                IS_MARK[i] = true;
            }
        }
    }

    private void findViews(View v) {
        back = (ImageView) v.findViewById(R.id.back);
        back.setOnClickListener(listener);
        tvQuizTitle = (TextView) v.findViewById(R.id.tv_quiz_title);
        tvQuizTitle.setText("测验");

        llQuizTopNav = (LinearLayout) v.findViewById(R.id.ll_quiz_top_nav);

        tvQuizMsgTitle = (TextView) v.findViewById(R.id.tv_quiz_msg_title);
        ivQuizQuestionMark = (ImageView) v
                .findViewById(R.id.iv_quiz_question_mark);
        ivQuizQuestionMark.setOnClickListener(listener);

        tvQuizQuestionTitle = (TextView) v
                .findViewById(R.id.tv_quiz_question_title);
        tvQuizQuestionPoint = (TextView) v
                .findViewById(R.id.tv_quiz_question_point);
        llQuizQuestionMsg = (LinearLayout) v
                .findViewById(R.id.ll_quiz_question_msg);
        llQuizContent = (LinearLayout) v.findViewById(R.id.ll_quiz_content);

        // RightNavViews
        ivQuizRightNavSave = (ImageButton) v
                .findViewById(R.id.iv_quiz_right_nav_save);
        ivQuizRightNavSubmit = (ImageButton) v
                .findViewById(R.id.iv_quiz_right_nav_submit);
        ivQuizRightNavBack = (ImageButton) v
                .findViewById(R.id.iv_quiz_right_nav_back);
        ivQuizRightNavNext = (ImageButton) v
                .findViewById(R.id.iv_quiz_right_nav_next);
        ivQuizRightNavSave.setOnClickListener(listener);
        ivQuizRightNavSubmit.setOnClickListener(listener);
        ivQuizRightNavBack.setOnClickListener(listener);
        ivQuizRightNavNext.setOnClickListener(listener);
    }

    /**
     * 初始化顶部题目导航栏
     *
     * @param size
     */
    @SuppressWarnings("deprecation")
    private void initTopNavViews(int size) {

        Display display = context.getWindowManager().getDefaultDisplay();
        int width = display.getWidth();
        float ivWidth = (float) (width * 0.75 / size);
        float lLength = (float) (width * 0.75 / 10);
        if (ivWidth < lLength) {
            ivWidth = lLength;
        }
        for (int i = 0; i < size; i++) {
            TextView tv = new TextView(context);
            LayoutParams params = new LayoutParams((int) ivWidth,
                    LayoutParams.MATCH_PARENT);
            tv.setLayoutParams(params);
            tv.setGravity(Gravity.CENTER);

            if (i == 0) {
                tv.setBackgroundResource(R.drawable.progressbar_active);
            } else {
                if (IS_MARK[i]) {
                    tv.setBackgroundResource(R.drawable.progressbar_marked);
                } else {
                    tv.setBackgroundResource(R.drawable.progressbar_unread);
                }
            }
            llQuizTopNav.addView(tv, i, params);
            tv.setText(i + 1 + "");
        }
    }

    private void setNavViewHide() {
        if (questionIndex - 9 > 0) {
            llQuizTopNav.getChildAt(questionIndex - 10).setVisibility(View.GONE);
        }
    }

    /**
     * 设置顶部导航栏Image背景-活动的
     */
    private void setTopNavActiveViewBg() {
        View v = llQuizTopNav.getChildAt(questionIndex);
        v.setBackgroundResource(R.drawable.progressbar_active);
    }

    /**
     * 设置顶部导航栏Image背景-浏览过的
     */
    private void setTopNavPassViewBg() {
        View v = llQuizTopNav.getChildAt(questionIndex);
        v.setBackgroundResource(R.drawable.progressbar_passed);
    }

    /**
     * 设置顶部导航栏Image背景-标记
     */
    private void setTopNavMarkedViewBg() {
        View v = llQuizTopNav.getChildAt(questionIndex);
        v.setBackgroundResource(R.drawable.progressbar_marked);
    }

    /**
     * 浏览题目
     */
    private void scanQuestion() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                Question mQuestion = questions.get(questionIndex);
                if (mQuestion instanceof SingleChoiceQuestion) {
                    scanSingleChoiceQuestion();
                } else if (mQuestion instanceof JudgementQuestion) {
                    scanJudgementQuestion();
                } else if (mQuestion instanceof EssayQuestion) {
                    scanEssayQuestion();
                } else if (mQuestion instanceof ShortAnswerQuestion) {
                    scanShortQuestion();
                    llQuizContent.setVisibility(View.INVISIBLE);
                } else if (mQuestion instanceof NumberQuestion) {
                    scanNumberQuestion();
                    llQuizContent.setVisibility(View.INVISIBLE);
                } else if (mQuestion instanceof PromptQuestion) {
                    scanPromptQuestion();
                    llQuizContent.setVisibility(View.INVISIBLE);
                } else if (mQuestion instanceof MultipleBlankQuestion) {
                    scanMutipleQuestion();
                    llQuizContent.setVisibility(View.INVISIBLE);
                } else if (mQuestion instanceof MultipleChoiceQuestion) {
                    scanMutipleChoiceQuestion();
                } else if (mQuestion instanceof DropdownQuestion) {
                    scanDropdownQuestion();
                    llQuizContent.setVisibility(View.INVISIBLE);
                } else if (mQuestion instanceof MatchQuestion) {
                    scanMatchQuestion();
                }
            }
        });
    }

    /**
     * 移出View
     */
    private void removeViews() {
        llQuizQuestionMsg.removeAllViews();
        llQuizContent.removeAllViews();
        llQuizContent.setVisibility(View.VISIBLE);
    }

    /**
     * 设置题目与得分
     *
     * @param strs
     */
    private void setQueTitleConText(String... strs) {
        tvQuizQuestionTitle.setText(strs[0]);
        tvQuizQuestionPoint.setText(strs[1]);
        TextView tvQuestionMsg = new TextView(context);
        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT);
        tvQuestionMsg.setLayoutParams(params);
        tvQuestionMsg.setTextColor(getResources().getColor(R.color.question_text));
        tvQuestionMsg.setTextSize(getResources().getDimension(R.dimen.course_nav_title));
        tvQuestionMsg.setMovementMethod(ScrollingMovementMethod.getInstance());
        llQuizQuestionMsg.addView(tvQuestionMsg);
        if (strs.length > 2) {
            tvQuestionMsg.setText(strs[2]);
        }
    }

    /**
     * 浏览多选题
     */
    private void scanMutipleChoiceQuestion() {
        removeViews();
        MultipleChoiceQuestion mpQuestion = (MultipleChoiceQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("多选题");
        setQueTitleConText(mpQuestion.getQuestionName(),
                mpQuestion.getQuestionPoint(),
                mpQuestion.getQuestionMsg());
        View lvView = inflater.inflate(R.layout.quiz_singlechoice_listview, null);
        llQuizContent.addView(lvView);
        final List<String> strs = mpQuestion.getAnswers();

        isSelect = new boolean[strs.size()];
        for (int i = 0; i < isSelect.length; i++) {
            isSelect[i] = false;
        }

        ListView singleChoiceLV = (ListView) lvView.findViewById(R.id.lv_quiz_singlechoice);
        final ListAdapter listAdapter = new ListAdapter(strs, 2);

        //保存答案List
        final List<String> saveAnswers = new ArrayList<String>();

        if (saveQuestionArray[questionIndex] != null) {
            MultipleChoiceQuestion saveQuestion = (MultipleChoiceQuestion) saveQuestionArray[questionIndex];
            List<String> answers = saveQuestion.getAnswers();
            if (answers != null) {
                for (String s : answers) {
                    int savePosition = strs.indexOf(s);
                    isSelect[savePosition] = true;
                    saveAnswers.add(s);
                }
            }

            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
        } else {
            MultipleChoiceQuestion saveQuestion = new MultipleChoiceQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
        singleChoiceLV.setAdapter(listAdapter);
        singleChoiceLV.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
                                    long arg3) {
                if (isSelect[arg2] == false) {
                    isSelect[arg2] = true;
                    saveAnswers.add(strs.get(arg2));
                } else if (isSelect[arg2] == true) {
                    isSelect[arg2] = false;
                    saveAnswers.remove(strs.get(arg2));
                }
                listAdapter.notifyDataSetInvalidated();

                ((MultipleChoiceQuestion) saveQuestionArray[questionIndex]).setAnswers(saveAnswers);
                ((MultipleChoiceQuestion) saveQuestionArray[questionIndex]).setIsAnswer(true);
            }
        });
    }

    /**
     * 浏览单选题
     */
    private void scanSingleChoiceQuestion() {
        removeViews();
        SingleChoiceQuestion singleQuestion = (SingleChoiceQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("单选题");

        //设置题目与得分
        setQueTitleConText(singleQuestion.getQuestionName(),
                singleQuestion.getQuestionPoint(),
                singleQuestion.getQuestionMsg());

        View lvView = inflater.inflate(R.layout.quiz_singlechoice_listview, null);
        llQuizContent.addView(lvView);
        final List<String> strs = singleQuestion.getAnswers();
        ListView singleChoiceLV = (ListView) lvView.findViewById(R.id.lv_quiz_singlechoice);
        final ListAdapter listAdapter = new ListAdapter(strs, 1);
        if (saveQuestionArray[questionIndex] != null) {
            SingleChoiceQuestion saveQuestion = (SingleChoiceQuestion) saveQuestionArray[questionIndex];
            int savePosition = strs.indexOf(saveQuestion.getSaveAnswer());
            listAdapter.setSelectedPosition(savePosition);
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
        } else {
            SingleChoiceQuestion saveQuestion = new SingleChoiceQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
        singleChoiceLV.setScrollBarSize(0);
        singleChoiceLV.setAdapter(listAdapter);
        singleChoiceLV.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
                                    long arg3) {
                SingleChoiceQuestion saveQuestion = null;
                if (saveQuestionArray[questionIndex] != null) {
                    saveQuestion = (SingleChoiceQuestion) saveQuestionArray[questionIndex];
                }
                saveQuestion.setIsAnswer(true);
                listAdapter.setSelectedPosition(arg2);
                listAdapter.notifyDataSetInvalidated();
                saveQuestion.setSaveAnswer(strs.get(arg2));
            }
        });
    }

    /**
     * 浏览判断题
     */
    private void scanJudgementQuestion() {
        removeViews();
        JudgementQuestion judgementQuestion = (JudgementQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("判断题");
        setQueTitleConText(judgementQuestion.getQuestionName(),
                judgementQuestion.getQuestionPoint(),
                judgementQuestion.getQuestionMsg());
        View v = inflater.inflate(R.layout.quiz_question_judgement_item, null);
        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT);
        v.setLayoutParams(params);
        llQuizContent.addView(v);
        findJudgementViews(v);
    }

    /**
     * 浏览问答题
     */
    private void scanEssayQuestion() {
        removeViews();
        EssayQuestion essayQuestion = (EssayQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("问答题");
        setQueTitleConText(essayQuestion.getQuestionName(),
                essayQuestion.getQuestionPoint(),
                essayQuestion.getQuestionMsg());
        EditText et = new EditText(context);
        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT);
        et.setLayoutParams(params);
        llQuizContent.addView(et);

        if (saveQuestionArray[questionIndex] != null) {
            EssayQuestion saveQuestion = (EssayQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
            if (saveQuestion.getAnswer() != null) {
                et.setText(saveQuestion.getAnswer());
            }
        } else {
            EssayQuestion saveQuestion = new EssayQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
        et.setOnFocusChangeListener(new MyListener(saveQuestionArray[questionIndex]));
    }

    /**
     * 浏览填空题
     */
    private void scanShortQuestion() {
        removeViews();
        ShortAnswerQuestion shortQuestion = (ShortAnswerQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("填空题");
        setQueTitleConText(shortQuestion.getQuestionName(),
                shortQuestion.getQuestionPoint());
        llQuizQuestionMsg.removeAllViews();
        String joinMsg = shortQuestion.getJointMsg();
        addShortMutipleView(joinMsg);
    }

    /**
     * 浏览多选题
     */
    private void scanMutipleQuestion() {
        removeViews();
        MultipleBlankQuestion shortQuestion = (MultipleBlankQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("多项填空题");
        setQueTitleConText(shortQuestion.getQuestionName(),
                shortQuestion.getQuestionPoint());
        llQuizQuestionMsg.removeAllViews();
        String joinMsg = shortQuestion.getJointMsg();
        convertMultipleQuestion();
        addMutipleView(joinMsg);
    }

    /**
     * 转换Question
     */
    private void convertMultipleQuestion() {
        if (saveQuestionArray[questionIndex] != null) {
            MultipleBlankQuestion saveQuestion = (MultipleBlankQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
        } else {
            MultipleBlankQuestion dQuestion = new MultipleBlankQuestion();
            saveQuestionArray[questionIndex] = dQuestion;
        }
    }

    private void addMutipleView(String joinMsg) {
        multipleEditPosition = -1;
        String splitStr = "#EditText#";
        List<String> list = new ArrayList<String>();
        getStringList(list, joinMsg, splitStr);
        String[] answers = ((MultipleBlankQuestion) saveQuestionArray[questionIndex]).getAnswers();
        if (answers == null) {
            answers = new String[list.size()];
            ((MultipleBlankQuestion) saveQuestionArray[questionIndex]).setAnswers(answers);
        }
        for (int i = 0; i < list.size(); i++) {
            multipleEditPosition++;
            addTextView(llQuizQuestionMsg, list.get(i));
            if (i != list.size() - 1) {
                addMyEdit(answers);
            }
        }
        if (joinMsg.endsWith(splitStr)) {
            addMyEdit(answers);
        }
    }

    private void addMyEdit(String[] answers) {
        final MyEditText etMsg = new MyEditText(context, multipleEditPosition);
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);
        etMsg.setLayoutParams(params);
        etMsg.setHint("请输入...");
        etMsg.setSingleLine();
        llQuizQuestionMsg.addView(etMsg);
        if (answers[multipleEditPosition] != null) {
            etMsg.setText(answers[multipleEditPosition]);
        }
        etMsg.setOnFocusChangeListener(new MyListener(saveQuestionArray[questionIndex]));
    }

    private void addShortMutipleView(String joinMsg) {
        String splitStr = "#EditText#";
        List<String> list = new ArrayList<String>();
        getStringList(list, joinMsg, splitStr);
        for (int i = 0; i < list.size(); i++) {

            addTextView(llQuizQuestionMsg, list.get(i));
            if (i != list.size() - 1) {
                addShortMutilEdit();
            }
        }
        if (joinMsg.endsWith(splitStr)) {
            addShortMutilEdit();
        }
    }

    private void addShortMutilEdit() {
        EditText etMsg = new EditText(context);
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);
        etMsg.setLayoutParams(params);
        etMsg.setHint("请输入...");
        etMsg.setSingleLine();
        llQuizQuestionMsg.addView(etMsg);
        setShortSaveMsg(etMsg);
        etMsg.setOnFocusChangeListener(new MyListener(saveQuestionArray[questionIndex]));
    }

    /**
     * 设置填空题-保存的数据
     *
     * @param et
     */
    private void setShortSaveMsg(EditText et) {
        if (saveQuestionArray[questionIndex] != null) {
            ShortAnswerQuestion saveQuestion = (ShortAnswerQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
            if (saveQuestion.getAnswer() != null) {
                et.setText(saveQuestion.getAnswer());
            }
        } else {
            ShortAnswerQuestion saveQuestion = new ShortAnswerQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
    }

    /**
     * 浏览数值题
     */
    private void scanNumberQuestion() {
        removeViews();
        NumberQuestion shortQuestion = (NumberQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("数值题");
        setQueTitleConText(shortQuestion.getQuestionName(),
                shortQuestion.getQuestionPoint());
        llQuizQuestionMsg.removeAllViews();
        String joinMsg = shortQuestion.getJointMsg();
        String splitStr = "#EditText#";
        List<String> list = new ArrayList<String>();
        getStringList(list, joinMsg, splitStr);
        for (int i = 0; i < list.size(); i++) {

            addTextView(llQuizQuestionMsg, list.get(i));

            if (i != list.size() - 1) {
                addNumberEdit();
            }
        }
        if (joinMsg.endsWith(splitStr)) {
            addNumberEdit();
        }
    }

    private void addNumberEdit() {
        EditText etMsg = new EditText(context);
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);
        etMsg.setLayoutParams(params);
        etMsg.setHint("请输入数字...");
        etMsg.setSingleLine();
        etMsg.setKeyListener(new DigitsKeyListener(false, true));
        llQuizQuestionMsg.addView(etMsg);
        setNumberSaveMsg(etMsg);
        etMsg.setOnFocusChangeListener(new MyListener(saveQuestionArray[questionIndex]));
    }

    /**
     * 设置数值题-保存的数据
     *
     * @param et
     */
    private void setNumberSaveMsg(EditText et) {
        if (saveQuestionArray[questionIndex] != null) {
            NumberQuestion saveQuestion = (NumberQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
            if (saveQuestion.getAnswer() != null) {
                et.setText(saveQuestion.getAnswer());
            }
        } else {
            NumberQuestion saveQuestion = new NumberQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
    }

    private void getStringList(List<String> list, String joinMsg, String splitStr) {
        if (joinMsg.contains(splitStr)) {
            int index = joinMsg.indexOf(splitStr);
            String ss = joinMsg.substring(0, index);
            list.add(ss);
            String secondStr = joinMsg.substring(splitStr.length() + ss.length(), joinMsg.length());
            getStringList(list, secondStr, splitStr);
        }
    }

    private void scanMatchQuestion() {
        removeViews();
        MatchQuestion mQuestion = (MatchQuestion) questions.get(questionIndex);
        tvQuizMsgTitle.setText("匹配题");

        //设置题目与得分
        setQueTitleConText(mQuestion.getQuestionName(),
                mQuestion.getQuestionPoint(),
                mQuestion.getQuestionMsg());

        ListView lvView = new ListView(context);
        LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT);
        lvView.setLayoutParams(params);
        lvView.setDivider(null);
        llQuizContent.addView(lvView);
        MatchQuestion saveQuestion = null;
        if (saveQuestionArray[questionIndex] != null) {
            saveQuestion = (MatchQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
        } else {
            saveQuestion = new MatchQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
        }
        if (saveQuestion.getSaveAnswerList() == null) {
            saveQuestion.setSaveAnswerList(new String[mQuestion.getAnswerValueList().size()]);
        }
        //TODO
        if (!mQuestion.getAnswerKeyList().isEmpty()) {
            lvView.setAdapter(new MatchQueAdapter(mQuestion.getAnswerKeyList(), mQuestion.getAnswerValueList(), saveQuestion.getSaveAnswerList()));
        }
    }

    /**
     * 浏览提示
     */
    private void scanPromptQuestion() {
        removeViews();
        PromptQuestion promptQuestion = (PromptQuestion) questions
                .get(questionIndex);
        saveQuestionArray[questionIndex] = promptQuestion;
        tvQuizMsgTitle.setText("提示");
        promptQuestion.setIsAnswer(true);
        setQueTitleConText("",
                "",
                promptQuestion.getQuestionMsg());
    }

    /**
     * 浏览下拉列表题
     */
    private void scanDropdownQuestion() {
        removeViews();
        DropdownQuestion dropQuestion = (DropdownQuestion) questions
                .get(questionIndex);
        tvQuizMsgTitle.setText("下拉选择题");
        setQueTitleConText(dropQuestion.getQuestionName(),
                dropQuestion.getQuestionPoint());
        llQuizQuestionMsg.removeAllViews();
        List<Object> objMsg = dropQuestion.getObjectMsg();
        convertQuestion(objMsg);
        addDropdownView(objMsg);
    }

    /**
     * 转换Question
     */
    private void convertQuestion(List<Object> objMsg) {
        if (saveQuestionArray[questionIndex] != null) {
            DropdownQuestion saveQuestion = (DropdownQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
        } else {
            DropdownQuestion dQuestion = new DropdownQuestion();
            saveQuestionArray[questionIndex] = dQuestion;
            dQuestion.setObjectMsg(new ArrayList<Object>());
        }
    }

    /**
     * 添加下拉菜单题view
     *
     * @param objMsg
     */
    @SuppressWarnings("unchecked")
    private void addDropdownView(List<Object> objMsg) {
        final List<Object> saveObjMsg = ((DropdownQuestion) saveQuestionArray[questionIndex]).getObjectMsg();
        for (int i = 0; i < objMsg.size(); i++) {

            if (objMsg.get(i) instanceof String) {
                if (saveObjMsg.size() == i) {
                    saveObjMsg.add(objMsg.get(i));
                }
                addTextView(llQuizQuestionMsg, objMsg.get(i).toString());
            } else if (objMsg.get(i) instanceof List) {
                if (saveObjMsg.size() == i) {
                    saveObjMsg.add(new ArrayList<String>());
                }
                List<String> oList = (List<String>) objMsg.get(i);
                List<String> newData = new ArrayList<String>();
                newData.add("[选择]");
                newData.addAll(oList);
                final MySpinner mSpinner = new MySpinner(context, i);
                ArrayAdapter<String> adapter = new ArrayAdapter<String>(context, android.R.layout.simple_spinner_item, newData);
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                mSpinner.setAdapter(adapter);
                llQuizQuestionMsg.addView(mSpinner);
                if (!((List<String>) saveObjMsg.get(i)).isEmpty()) {
                    String spinnerAnswer = ((List<String>) saveObjMsg.get(i)).get(0);
                    int selectIndex = newData.indexOf(spinnerAnswer);
                    mSpinner.setSelection(selectIndex);
                }
                mSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {
                        // TODO Auto-generated method stub
                        ((DropdownQuestion) saveQuestionArray[questionIndex]).setIsAnswer(true);
                        int objIndex = mSpinner.getIndex();
                        List<String> strList = (List<String>) saveObjMsg.get(objIndex);
                        strList.clear();
                        strList.add(mSpinner.getItemAtPosition(position).toString());
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {
                        // TODO Auto-generated method stub

                    }
                });
            }
        }
    }

    /**
     * 添加TextView
     */
    private void addTextView(ViewGroup container, String textValue) {
        TextView tvMsg = new TextView(context);
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT);
        tvMsg.setTextColor(getResources().getColor(R.color.question_text));
        tvMsg.setTextSize(getResources().getDimension(R.dimen.course_nav_title));
        tvMsg.setLayoutParams(params);
        container.addView(tvMsg);
        tvMsg.setText(textValue);
    }

    /**
     * 判断题时设置背景
     *
     * @param v
     */
    private void findJudgementViews(View v) {
        final LinearLayout llQuizJudgementTrue = (LinearLayout) v
                .findViewById(R.id.ll_quiz_judgement_true);
        final LinearLayout llQuizJudgementFalse = (LinearLayout) v
                .findViewById(R.id.ll_quiz_judgement_false);
        final TextView tvTrue = (TextView) v
                .findViewById(R.id.tv_quiz_question_judge_true);
        final TextView tvFalse = (TextView) v
                .findViewById(R.id.tv_quiz_question_judge_false);
        final ImageView ivTrue = (ImageView) v
                .findViewById(R.id.iv_quiz_question_judge_true);
        final ImageView ivFalse = (ImageView) v
                .findViewById(R.id.iv_quiz_question_judge_false);

        if (saveQuestionArray[questionIndex] != null) {
            JudgementQuestion saveQuestion = (JudgementQuestion) saveQuestionArray[questionIndex];
            if (saveQuestion.isMark()) {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
            } else {
                ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
            }
            if (saveQuestion.isAnswer()) {
                setJudgeBackround(llQuizJudgementTrue, llQuizJudgementFalse, ivTrue, ivFalse);
            } else {
                setJudgeBackround(llQuizJudgementFalse, llQuizJudgementTrue, ivFalse, ivTrue);
            }
        } else {
            JudgementQuestion saveQuestion = new JudgementQuestion();
            saveQuestionArray[questionIndex] = saveQuestion;
            ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
        }

        llQuizJudgementTrue.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                setJudgeBackround(llQuizJudgementTrue, llQuizJudgementFalse, ivTrue, ivFalse);
                JudgementQuestion saveQuestion = null;
                if (saveQuestionArray[questionIndex] != null) {
                    saveQuestion = (JudgementQuestion) saveQuestionArray[questionIndex];
                }
                saveQuestion.setAnswer(true);
                saveQuestion.setIsAnswer(true);
                setTextViewBg(tvFalse, tvTrue);
            }
        });
        llQuizJudgementFalse.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                setJudgeBackround(llQuizJudgementFalse, llQuizJudgementTrue, ivFalse, ivTrue);
                JudgementQuestion saveQuestion = null;
                if (saveQuestionArray[questionIndex] != null) {
                    saveQuestion = (JudgementQuestion) saveQuestionArray[questionIndex];
                }
                saveQuestion.setAnswer(false);
                saveQuestion.setIsAnswer(true);
                setTextViewBg(tvTrue, tvFalse);
            }
        });
    }

    private void setTextViewBg(TextView tv1, TextView tv2) {
        tv2.setTextColor(getResources().getColor(R.color.question_text));
        tv1.setTextColor(getResources().getColor(R.color.choose_text));
    }

    /**
     * 设置判断题背景
     *
     * @param l1
     * @param l2
     * @param iv1
     * @param iv2
     */
    private void setJudgeBackround(LinearLayout l1, LinearLayout l2, ImageView iv1, ImageView iv2) {
        l1.setBackgroundResource(R.drawable.itembg_checked);
        iv1.setBackgroundResource(R.drawable.checkmark_selected);
        l2.setBackgroundColor(getResources().getColor(R.color.lucency_bg));
        iv2.setBackgroundResource(R.drawable.checkmark_normal);
    }

    private void setIvMarkedBg() {
        if (!IS_MARK[questionIndex]) {
            setTopNavPassViewBg();
            ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_normal);
        } else {
            setTopNavMarkedViewBg();
            ivQuizQuestionMark.setBackgroundResource(R.drawable.button_mark_selected);
        }
    }

    /**
     * 最后一题时的动作
     */
    private void setLastQuestuinAction() {
        AlertDialog.Builder ad = new AlertDialog.Builder(getActivity(),
                android.R.style.Theme_DeviceDefault_Light_Dialog);
        ad.setTitle("提示");
        ad.setMessage("已经是最后一题，要保存并提交么?");
        for (Question q : saveQuestionArray) {
            if (!q.getIsAnswer()) {
                ad.setMessage("已经是最后一题，您还有未做完的题，确认提交么？");
                break;
            }
        }
        ad.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {

            }
        });
        ad.setPositiveButton("确认", new DialogInterface.OnClickListener() {// 退出按钮
            @Override
            public void onClick(DialogInterface dialog, int i) {
                // TODO
                ivQuizRightNavSave.performClick();
                ivQuizRightNavSubmit.performClick();
            }
        });
        ad.show();
    }

    /**
     * 选择Adapter
     *
     * @author Super Man
     */
    class ListAdapter extends BaseAdapter {

        private List<String> choices;
        private int selectedPosition = -1;
        private int choiceModel = -1;

        public ListAdapter(List<String> choices, int choiceModel) {
            this.choices = choices;
            this.choiceModel = choiceModel;
        }

        @Override
        public int getCount() {
            return choices.size();
        }

        @Override
        public Object getItem(int position) {
            return choices.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        public void setSelectedPosition(int position) {
            selectedPosition = position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.quiz_single_choice_item, null);
                holder = new ViewHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.choice.setText(choices.get(position));

            if (choiceModel == 1) {
                if (selectedPosition == position) {
                    holder.llLayout.getBackground().setAlpha(255);
                    holder.mark.setBackgroundResource(R.drawable.checkmark_selected);
                    holder.choice.setTextColor(getResources().getColor(R.color.question_text));
                } else {
                    holder.llLayout.getBackground().setAlpha(0);
                    holder.mark.setBackgroundResource(R.drawable.checkmark_normal);
                    holder.choice.setTextColor(getResources().getColor(R.color.choose_text));
                }
            } else if (choiceModel == 2) {
                if (isSelect[position] == true) {
                    holder.llLayout.getBackground().setAlpha(255);
                    holder.mark.setBackgroundResource(R.drawable.checkmark_selected);
                    holder.choice.setTextColor(getResources().getColor(R.color.question_text));
                } else {
                    holder.llLayout.getBackground().setAlpha(0);
                    holder.mark.setBackgroundResource(R.drawable.checkmark_normal);
                    holder.choice.setTextColor(getResources().getColor(R.color.choose_text));
                }
            }
            return convertView;
        }

        class ViewHolder {
            private TextView choice;
            private ImageView mark;
            private LinearLayout llLayout;

            public ViewHolder(View v) {
                choice = (TextView) v.findViewById(R.id.tv_quiz_title);
                mark = (ImageView) v.findViewById(R.id.iv_quiz_single_choice_mark);
                llLayout = (LinearLayout) v.findViewById(R.id.ll_choice);
            }
        }
    }

    class MyListener implements OnFocusChangeListener {

        private Question question;

        public MyListener(Question question) {
            this.question = question;
        }

        @Override
        public void onFocusChange(View v, boolean hasFocus) {
            question.setIsAnswer(true);
            if (!hasFocus) {
                if (question instanceof EssayQuestion) {
                    ((EssayQuestion) question).setAnswer(((EditText) v).getText().toString());
                } else if (question instanceof ShortAnswerQuestion) {
                    ((ShortAnswerQuestion) question).setAnswer(((EditText) v).getText().toString());
                } else if (question instanceof NumberQuestion) {
                    ((NumberQuestion) question).setAnswer(((EditText) v).getText().toString());
                } else if (question instanceof MultipleBlankQuestion) {
                    ((MultipleBlankQuestion) question).getAnswers()[((MyEditText) v).getIndex()] = ((MyEditText) v).getText().toString();
                }
            }
        }

    }

    class MyEditText extends EditText {

        private int index;

        public MyEditText(Context context, int index) {
            super(context);
            this.index = index;
        }

        public int getIndex() {
            return index;
        }

        public void setIndex(int index) {
            this.index = index;
        }
    }

    class MatchQueAdapter extends BaseAdapter {

        private List<String> answersKeyList;
        private List<String[]> answersValueList;

        private String[] saveAnswersArray;

        public MatchQueAdapter(List<String> answersKeyList, List<String[]> answersValueList, String[] saveAnswersArray) {
            this.answersKeyList = answersKeyList;
            this.answersValueList = answersValueList;
            this.saveAnswersArray = saveAnswersArray;
        }

        @Override
        public int getCount() {
            return answersKeyList.size();
        }

        @Override
        public Object getItem(int position) {
            return answersKeyList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = inflater.inflate(R.layout.quiz_question_match_item, null);
                holder = new ViewHolder(convertView, position);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            holder.tv_quiz_question_match.setText(answersKeyList.get(position));

            if (saveAnswersArray[position] != null) {
                for (int i = 0; i < answersValueList.get(position).length; i++) {
                    if (answersValueList.get(position)[i] == saveAnswersArray[position]) {
                        holder.sp_quiz_question_match.setSelection(i);
                        break;
                    }
                }
            }
            return convertView;
        }

        class ViewHolder {
            TextView tv_quiz_question_match;
            Spinner sp_quiz_question_match;

            public ViewHolder(View v, final int mPosition) {
                tv_quiz_question_match = (TextView) v.findViewById(R.id.tv_quiz_question_match);
                sp_quiz_question_match = (Spinner) v.findViewById(R.id.sp_quiz_question_match);
                sp_quiz_question_match.setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {
                        // TODO Auto-generated method stub
                        ((MatchQuestion) saveQuestionArray[questionIndex]).setIsAnswer(true);
                        String msg = ((TextView) view).getText().toString();
                        saveAnswersArray[mPosition] = msg;
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {
                        // TODO Auto-generated method stub

                    }
                });
                ArrayAdapter<String> adapter = new ArrayAdapter<String>(context, android.R.layout.simple_spinner_item, answersValueList.get(mPosition));

                //设置下拉列表的风格
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

                //将adapter 添加到spinner中
                sp_quiz_question_match.setAdapter(adapter);
            }
        }
    }

    class MySpinner extends Spinner {

        //Spinner所在位置
        private int index;

        public MySpinner(Context ctx, int index) {
            // TODO Auto-generated constructor stub
            super(ctx);
            this.index = index;
        }

        public int getIndex() {
            return index;
        }

        public void setIndex(int index) {
            this.index = index;
        }

    }

}
