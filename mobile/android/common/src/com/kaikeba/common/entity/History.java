package com.kaikeba.common.entity;

/**
 * Created by chris on 14-7-28.
 */
public class History {
    private int id;
    private String name;

    public History() {
        super();
    }

    public History(String name) {
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
