package com.kaikeba.common.entity.question;

import java.util.List;

public class MatchQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = -3965602681622386274L;

    private String questionMsg;

    private List<String> answerKeyList;

    private List<String[]> answerValueList;

    private String[] saveAnswerList;

    public String[] getSaveAnswerList() {
        return saveAnswerList;
    }

    public void setSaveAnswerList(String[] saveAnswerList) {
        this.saveAnswerList = saveAnswerList;
    }

    public List<String> getAnswerKeyList() {
        return answerKeyList;
    }

    public void setAnswerKeyList(List<String> answerKeyList) {
        this.answerKeyList = answerKeyList;
    }

    public String getQuestionMsg() {
        return questionMsg;
    }

    public void setQuestionMsg(String questionMsg) {
        this.questionMsg = questionMsg;
    }

    public List<String[]> getAnswerValueList() {
        return answerValueList;
    }

    public void setAnswerValueList(List<String[]> answerValueList) {
        this.answerValueList = answerValueList;
    }

}
