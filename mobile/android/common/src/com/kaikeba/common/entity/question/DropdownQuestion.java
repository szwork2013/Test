package com.kaikeba.common.entity.question;

import java.util.List;

public class DropdownQuestion extends Question {

    /**
     *
     */
    private static final long serialVersionUID = 5625203928795465613L;

    private List<Object> objectMsg;

    private List<String> answerMsg;

    private List<List<String>> idsList;

    public List<List<String>> getIdsList() {
        return idsList;
    }

    public void setIdsList(List<List<String>> idsList) {
        this.idsList = idsList;
    }

    public List<String> getAnswerMsg() {
        return answerMsg;
    }

    public void setAnswerMsg(List<String> answerMsg) {
        this.answerMsg = answerMsg;
    }

    public List<Object> getObjectMsg() {
        return objectMsg;
    }

    public void setObjectMsg(List<Object> objectMsg) {
        this.objectMsg = objectMsg;
    }
}
