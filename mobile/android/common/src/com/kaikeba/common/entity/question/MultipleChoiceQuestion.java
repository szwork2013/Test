package com.kaikeba.common.entity.question;

import java.util.List;

public class MultipleChoiceQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = -480134459991277283L;

    private String questionMsg;

    private List<String> answers;

    public String getQuestionMsg() {
        return questionMsg;
    }

    public void setQuestionMsg(String questionMsg) {
        this.questionMsg = questionMsg;
    }

    public List<String> getAnswers() {
        return answers;
    }

    public void setAnswers(List<String> answers) {
        this.answers = answers;
    }
}
