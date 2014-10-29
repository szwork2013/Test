package com.kaikeba.common.entity.question;

import java.io.Serializable;

public class Question implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -7717224406871123557L;

    /**
     * 题目名称
     */
    private String questionName;

    /**
     * 题目分值
     */
    private String questionPoint;

    /**
     * 题目信息
     */
    private String topicMsg;

    private boolean isMark = false;

    private boolean isAnswer = false;

    private String question_id;

    public String getQuestion_id() {
        return question_id;
    }

    public void setQuestion_id(String question_id) {
        this.question_id = question_id;
    }

    public boolean getIsAnswer() {
        return isAnswer;
    }

    public void setIsAnswer(boolean isAnswer) {
        this.isAnswer = isAnswer;
    }

    public boolean isMark() {
        return isMark;
    }

    public void setMark(boolean isMark) {
        this.isMark = isMark;
    }

    public String getQuestionName() {
        return questionName;
    }

    public void setQuestionName(String questionName) {
        this.questionName = questionName;
    }

    public String getQuestionPoint() {
        return questionPoint;
    }

    public void setQuestionPoint(String questionPoint) {
        this.questionPoint = questionPoint;
    }

    public String getTopicMsg() {
        return topicMsg;
    }

    public void setTopicMsg(String topicMsg) {
        this.topicMsg = topicMsg;
    }
}
