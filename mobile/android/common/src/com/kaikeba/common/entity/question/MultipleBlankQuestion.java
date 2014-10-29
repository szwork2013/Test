package com.kaikeba.common.entity.question;

public class MultipleBlankQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = -2093741670855858170L;

    private String[] answers;

    private String jointMsg;

    public String getJointMsg() {
        return jointMsg;
    }

    public void setJointMsg(String jointMsg) {
        this.jointMsg = jointMsg;
    }

    public String[] getAnswers() {
        return answers;
    }

    public void setAnswers(String[] answers) {
        this.answers = answers;
    }

}
