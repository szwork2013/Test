package com.kaikeba.common.api;

import android.content.Context;
import android.content.SharedPreferences;
import com.google.gson.reflect.TypeToken;
import com.kaikeba.ContextUtil;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Quiz;
import com.kaikeba.common.entity.question.*;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.exception.NoAuthException;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.DibitsHttpClient;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.lang.reflect.Type;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class QuizAPI extends API {

    /**
     * 题目类型
     */
    public static String[] questionTypes = {
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_MULTIPLE_CHOICE_QUESTION   /* 单选 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_TRUE_FALSE_QUESTION        /* 判断 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_SHORT_ANSWER_QUESTION	  /* 填空题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_FILL_IN_BLANKS_QUESTION	  /* 多项填空 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_MULTIPLE_ANSWER_QUESTION	  /* 多选题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_MULTIPLE_DROPDOWNS_QUESTION/* 下拉菜单题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_MATCH_QUESTION             /* 匹配题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_NUMERICAL_QUESTION		  /* 数值答案题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_ESSAY_QUESTION			  /* 问答题 */,
            DIV_DISPLAY_QUESTION_POINT + QUESTION_TYPE_TEXT_ONLY_QUESTION		  /* 描述 */};

    /**
     * 获取全部测验HTML
     *
     * @param courseId
     * @return
     */
    public static ArrayList<Quiz> getAllQuizs(String courseId) {
        String url = buildQuizsURL(courseId);
        String json;
        try {
            json = DibitsHttpClient.doGet4Token(url, API.getAPI()
                    .getUserObject().getAccessToken());
        } catch (DibitsExceptionC e) {
            e.printStackTrace();
            return null;
        }
        Type type = new TypeToken<ArrayList<Quiz>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Quiz> quizs = (ArrayList<Quiz>) JsonEngine.parseJson(json,
                type);
        return quizs;
    }

    private static String getCookie() {
        SharedPreferences appPrefs = ContextUtil.getContext()
                .getSharedPreferences("com.kaikeba.preferences",
                        Context.MODE_PRIVATE);
        return appPrefs.getString(COOKIE, "OAuth");
    }

    /**
     * 获取数据
     *
     * @param url
     * @throws Exception
     */
    public static Quiz load(String url, String quizId) throws Exception {
        Document doc = null;
        try {
            doc = Jsoup
                    .connect(url)
                    .timeout(60000)
                    .cookie(ConfigLoader.getLoader().getCanvas().getLoginURL(),
                            getCookie()).get();
        } catch (MalformedURLException e1) {
            e1.printStackTrace();
        } catch (IOException e1) {
            e1.printStackTrace();
            String msg = e1.getMessage();
            if (msg.contains("No authentication")) {
                throw new NoAuthException();
            }
        }
        if (doc == null) {
            return null;
        }
        Element e = doc.getElementById(SUMMARY_QUIZ + UNDER_LINE + quizId);
        if (e == null) {
            return null;
        }
        Quiz quiz = new Quiz();
        quiz.setTitle(e.getElementsByTag(HTML_TAG_A).text());
        Elements title = e.getElementsByClass(MESSAGE_TITLE);
        for (Element t : title) {
            Elements ess = t.getElementsByTag(HTML_TAG_SPAN);
            for (Element ee : ess) {
                if (ee.getElementsByClass(QUIZ_ID).isEmpty()) {
                    quiz.setScore(ee.text());
                }
            }
        }

        Elements esss = e.select(HTML_CLASS_USER_CONTENT);

        String attemp = e.child(1).ownText();
        if (attemp.contains(QUIZ_CHINESE_SURPLUS) || attemp.contains(QUIZ_CHINESE_ALLOW)) {
            String[] sur_time = attemp.split(API.TIME_SLICE);
            if (sur_time.length > 2) {
                quiz.setSurplusTime(sur_time[2].trim());
            } else {
                quiz.setSurplusTime(sur_time[1].trim());
            }
            String subtimeAndScore = esss.first().child(0).ownText();
            if (subtimeAndScore.contains(QUIZ_TIME_PM)
                    || subtimeAndScore.contains(QUIZ_TIME_AM)) {
                if (subtimeAndScore.contains(QUIZ_TIME_PM)) {
                    String[] textArray = subtimeAndScore.split(QUIZ_TIME_PM);
                    quiz.setSubmitTime(textArray[0].trim() + QUIZ_TIME_PM);
                    if (textArray.length > 1) {
                        String[] point = textArray[1].split("，");
                        quiz.setPoint(point[0]);
                        quiz.setTotalPoint(point[1]);
                    }

                } else {
                    String[] textArray = subtimeAndScore.split(QUIZ_TIME_AM);
                    if (textArray.length > 1) {
                        String[] point = textArray[1].split("，");
                        quiz.setPoint(point[0]);
                        quiz.setTotalPoint(point[1]);
                    }
                }

            }
        } else {
            quiz.setSurplusTime(SURPLUS_TIME_DEFAULT);
            quiz.setSubmitTime(SUBMIT_TIME_DEFAULT);
            quiz.setTotalPoint(TOTAL_POINT_DEFAULT);
            quiz.setPoint("0");
        }
        return quiz;
    }

    /**
     * 获取题目信息
     *
     * @param courseId
     * @param quizId
     * @return
     */
    public static ArrayList<Question> getSingleTopic(String courseId, String quizId) {

        ArrayList<Question> questionList = new ArrayList<Question>();
        Document doc = getConnDocument(courseId, quizId);
        Elements questionElements = doc.getElementsByClass(QUESTION_HOLDER);
        for (Element questionElement : questionElements) {
            Question mQuestion = getDate(questionElement);
            Element idElement = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT).get(0);
            String question_id = idElement.attr("id");
            mQuestion.setQuestion_id(question_id);
            Elements singleQuestion = questionElement.select(QUESTION_DIV_HEADER);
            if (singleQuestion.size() == 1) {
                Elements titleText = singleQuestion.get(0).children();
                for (int i = 0; i < titleText.size(); i++) {
                    if (i == 0) {
                        mQuestion.setQuestionName(titleText.get(i).text());
                    }
                    if (i == 1) {
                        mQuestion.setQuestionPoint(titleText.get(i).text());
                    }
                }
            }
            questionList.add(mQuestion);
        }
        return questionList;
    }

    /**
     * 获取题目具体信息， 待拆分
     *
     * @param question
     * @param msgMap
     * @return
     */
    private static Question getDate(Element questionElement) {

        Question mqQuestion = null;
        for (String type : questionTypes) {
            //单选
            if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[0])) {
                mqQuestion = getSingleChoiceInfo(questionElement);
            }
            //判断
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[1])) {
                mqQuestion = getTrueFalseQuestion(questionElement);
            }
            //填空
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[2])) {
                mqQuestion = getShortAnswerMsg(questionElement);
            }
            //多项填空
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[3])) {
                mqQuestion = getMuitipleBlankMsg(questionElement);
            }
            //多选
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[4])) {
                mqQuestion = getMuitipleChoiceMsg(questionElement);
            }
            //下拉菜单  display_question question multiple_answers_question
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[5])) {
                mqQuestion = getDropdownMsg(questionElement);
            }
            //匹配
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[6])) {
                mqQuestion = getMatchMsg(questionElement);
            }
            //数值
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[7])) {
                mqQuestion = getNumberAnswerMsg(questionElement);
            }
            //问答
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[8])) {
                mqQuestion = getEssayMsg(questionElement);
            }
            //提示
            else if (!questionElement.select(type).isEmpty() && type.equals(questionTypes[9])) {
                PromptQuestion question = new PromptQuestion();
                Elements answers = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
                question.setQuestionMsg(answers.text());
                mqQuestion = question;
            }
        }

        return mqQuestion;
    }

    /**
     * 获取HTML Document
     *
     * @param courseId
     * @param quizId
     * @return
     */
    private static Document getConnDocument(String courseId, String quizId) {
        String url = buildSingleTopicURL(courseId, quizId);
        Document doc = null;
        try {
            doc = Jsoup.connect(url).timeout(60000).cookie(ConfigLoader.getLoader().getCanvas().getLoginURL(), getCookie()).get();
        } catch (MalformedURLException e1) {
            e1.printStackTrace();
        } catch (IOException e1) {
            e1.printStackTrace();
        }
        return doc;
    }

    /**
     * 获取单选题信息
     *
     * @param questionElement
     * @param mqQuestion
     */
    private static Question getSingleChoiceInfo(Element questionElement) {
        SingleChoiceQuestion mQuestion = new SingleChoiceQuestion();
        Elements msgElement = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setQuestionMsg(msgElement.text());
        Elements answers = questionElement.getElementsByClass(HTML_CLASS_ANSWER);
        List<String> answerList = new ArrayList<String>();
        List<String> answersId = new ArrayList<String>();
        for (int i = 0; i < answers.size(); i++) {
            String[] array = answers.get(i).text().split("_");
            answerList.add(array[array.length - 1]);
            answersId.add(answers.get(i).getElementsByClass("question_input").get(0).attr("id"));
        }
        mQuestion.setAnswers(answerList);
        mQuestion.setAnswersId(answersId);
        return mQuestion;
    }

    private static Question getTrueFalseQuestion(Element questionElement) {
        JudgementQuestion mQuestion = new JudgementQuestion();
        Elements msgElement = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setQuestionMsg(msgElement.text());

        Elements answers = questionElement.getElementsByClass(HTML_CLASS_ANSWER);
        List<String> answersId = new ArrayList<String>();
        for (int i = 0; i < answers.size(); i++) {
            String[] array = answers.get(i).getElementsByClass("question_input").get(0).attr("id").split("_");
            answersId.add(array[array.length - 1]);
        }
        mQuestion.setAnswersId(answersId);
        return mQuestion;
    }

    /**
     * 获取填空题信息
     *
     * @param questionElement
     * @param mqQuestion
     */
    private static Question getShortAnswerMsg(Element questionElement) {
        ShortAnswerQuestion mQuestion = new ShortAnswerQuestion();
        Elements shortAnsDes = questionElement.getElementsByClass(HTML_CLASS_TEXT).get(0).children();
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < shortAnsDes.size(); i++) {
            Elements shortChilds = shortAnsDes.get(i).select(DIV_QUESTION_TEXT_USER_CONTENT);
            if (!shortChilds.isEmpty()) {
                str.append(shortChilds.text());
            }
            shortChilds = shortAnsDes.get(i).getElementsByClass(HTML_CLASS_ANSWERS);
            if (!shortChilds.isEmpty()) {
                str.append(SPILIT_TEXT);
            }
        }
        mQuestion.setJointMsg(str.toString());
        return mQuestion;
    }

    private static Question getNumberAnswerMsg(Element questionElement) {
        NumberQuestion mQuestion = new NumberQuestion();
        Elements shortAnsDes = questionElement.getElementsByClass(HTML_CLASS_TEXT).get(0).children();
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < shortAnsDes.size(); i++) {
            Elements shortChilds = shortAnsDes.get(i).select(DIV_QUESTION_TEXT_USER_CONTENT);
            if (!shortChilds.isEmpty()) {
                str.append(shortChilds.text());
            }
            shortChilds = shortAnsDes.get(i).getElementsByClass(HTML_CLASS_ANSWERS);
            if (!shortChilds.isEmpty()) {
                str.append(SPILIT_TEXT);
            }
        }
        mQuestion.setJointMsg(str.toString());
        return mQuestion;
    }

    /**
     * 获取多项填空题信息
     *
     * @param questionElement
     * @param mqQuestion
     */
    private static Question getMuitipleBlankMsg(Element questionElement) {
        //TODO
        MultipleBlankQuestion mQuestion = new MultipleBlankQuestion();
        Element textElement = questionElement.getElementsByClass(HTML_CLASS_TEXT).get(0);
        StringBuilder str = new StringBuilder();
        Elements spanElements = textElement.getElementsByTag("p").get(0).children();
        for (Element span : spanElements) {
            str = getMultipleBlankSpanElement(span, str);
        }
        mQuestion.setJointMsg(str.toString());
        return mQuestion;
    }

    private static StringBuilder getMultipleBlankSpanElement(Element span, StringBuilder str) {

        str.append(span.ownText());
        Elements childElements = span.children();
        for (Element ce : childElements) {
            if (ce.getElementsByClass("question_input") != null && ce.getElementsByClass("question_input").size() != 0 && ce.children().isEmpty()) {
                str.append("#EditText#");
            } else if (ce.getElementsByTag("span") != null) {
                str = getMultipleBlankSpanElement(ce, str);
            }
        }
        return str;
    }

    /**
     * 获取多选题信息
     *
     * @param questionElement
     * @param mqQuestion
     */
    private static Question getMuitipleChoiceMsg(Element questionElement) {
        MultipleChoiceQuestion mQuestion = new MultipleChoiceQuestion();
        Elements answers = questionElement.getElementsByClass(HTML_CLASS_ANSWER);
        Elements msgElement = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setQuestionMsg(msgElement.text());
        List<String> answerList = new ArrayList<String>();
        for (int i = 0; i < answers.size(); i++) {
            String[] array = answers.get(i).text().split("_");
            answerList.add(array[array.length - 1]);
        }
        mQuestion.setAnswers(answerList);
        return mQuestion;
    }

    /**
     * 获取问答题信息
     *
     * @param questionElement
     * @param mqQuestion
     */
    private static Question getEssayMsg(Element questionElement) {
        EssayQuestion mQuestion = new EssayQuestion();
        Elements answers = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setQuestionMsg(answers.text());
        return mQuestion;
    }

    /**
     * 获取下拉菜单题信息
     *
     * @param questionElement
     * @return
     */
    private static Question getDropdownMsg(Element questionElement) {
        DropdownQuestion mQuestion = new DropdownQuestion();
        Elements answers = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setObjectMsg(getDropdownObjectList(answers.text()));
//		List<List<String>> idsList = new ArrayList<List<String>>();
//		answers.get(0).getElementsByAttribute(key)
        return mQuestion;
    }

    /**
     * 获取下拉菜单信息
     *
     * @param str
     * @return
     */
    private static List<Object> getDropdownObjectList(String str) {
        List<Object> msgList = new ArrayList<Object>();
        String[] array = str.split("\\[选择\\]");
        for (String s : array) {
            if (s.contains("]")) {
                String[] spiltArray = s.split("]");
                List<String> strList = getList(spiltArray[0]);
                if (!strList.isEmpty()) {
                    msgList.add(getList(spiltArray[0]));
                }
                if (spiltArray.length > 1) {
                    msgList.add(spiltArray[1]);
                }
            } else {
                msgList.add(s);
            }
        }
        return msgList;
    }

    private static MatchQuestion getMatchMsg(Element questionElement) {
        MatchQuestion mQuestion = new MatchQuestion();
        Elements questionMsg = questionElement.select(DIV_QUESTION_TEXT_USER_CONTENT);
        mQuestion.setQuestionMsg(questionMsg.text());
        Elements answers = questionElement.getElementsByClass(HTML_CLASS_ANSWER);
        List<String> answerKeyList = new ArrayList<String>();
        List<String[]> answerValueList = new ArrayList<String[]>();
        try {
            for (int i = 0; i < answers.size(); i++) {
                String text = answers.get(i).text();
                String[] matchArray = text.split(" \\[ 选择 \\] ");
                answerKeyList.add(matchArray[0]);
                String[] answerList = matchArray[1].split(" ");
                answerValueList.add(answerList);
            }
        } catch (Exception e) {
            answerKeyList.add("题目已提交");
            String[] answerList = {"题目已提交"};
            answerValueList.add(answerList);
        }
        mQuestion.setAnswerKeyList(answerKeyList);
        mQuestion.setAnswerValueList(answerValueList);
        return mQuestion;
    }

    /**
     * 获取下拉菜单的值
     *
     * @param text
     * @return
     */
    private static List<String> getList(String text) {
        List<String> dateList = new ArrayList<String>();
        Pattern p = Pattern.compile("\"(.*?)\"");
        Matcher m = p.matcher(text);
        while (m.find()) {
            dateList.add(m.group().substring(1, m.group().length() - 1));
        }
        return dateList;
    }

    // =======================↓↓ build URL ↓↓=======================

    // /api/v1/courses/:course_id/quizzes
    private static String buildQuizsURL(String courseId) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseId)
                .append(SLASH_QUIZS);
        return url.toString();
    }


    private static String buildSingleTopicURL(String courseId, String quizId) {
        return "http://learn.kaikeba.com/courses/" + courseId + "/quizzes/"
                + quizId + "/take";
    }
}
