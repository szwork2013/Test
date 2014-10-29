package com.kaikeba.common.entity.question;

import java.util.List;

public class SingleChoiceQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = 840302932376761261L;

    private String questionMsg;

    private List<String> answers;

    private List<String> answersId;

    private String saveAnswer;

    public List<String> getAnswersId() {
        return answersId;
    }

    public void setAnswersId(List<String> answersId) {
        this.answersId = answersId;
    }

    public String getSaveAnswer() {
        return saveAnswer;
    }

    public void setSaveAnswer(String saveAnswer) {
        this.saveAnswer = saveAnswer;
    }

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
