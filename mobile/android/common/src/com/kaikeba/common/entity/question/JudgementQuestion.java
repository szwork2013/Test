package com.kaikeba.common.entity.question;

import java.util.List;

public class JudgementQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = 2002396336402854670L;

    private String questionMsg;

    private boolean answer;

    private List<String> answersId;

    public List<String> getAnswersId() {
        return answersId;
    }

    public void setAnswersId(List<String> answersId) {
        this.answersId = answersId;
    }

    public String getQuestionMsg() {
        return questionMsg;
    }

    public void setQuestionMsg(String questionMsg) {
        this.questionMsg = questionMsg;
    }

    public boolean isAnswer() {
        return answer;
    }

    public void setAnswer(boolean answer) {
        this.answer = answer;
    }

}
