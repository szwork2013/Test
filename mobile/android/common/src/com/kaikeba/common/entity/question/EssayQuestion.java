package com.kaikeba.common.entity.question;

public class EssayQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = 1745644804388902790L;

    private String questionMsg;

    private String answer;

    public String getQuestionMsg() {
        return questionMsg;
    }

    public void setQuestionMsg(String questionMsg) {
        this.questionMsg = questionMsg;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }
}
