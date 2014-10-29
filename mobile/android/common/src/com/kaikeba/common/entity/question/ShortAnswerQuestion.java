package com.kaikeba.common.entity.question;

public class ShortAnswerQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = -2542071520509500086L;

    private String answer;

    private String jointMsg;

    public String getJointMsg() {
        return jointMsg;
    }

    public void setJointMsg(String jointMsg) {
        this.jointMsg = jointMsg;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

}
