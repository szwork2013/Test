package com.example.myapp.test4.entity;

/**
 * Created by sjyin on 14-9-26.
 */
public class ShareModel {
    private int res;
    private String name;

    public ShareModel(int res,String name){
        this.res = res;
        this.name = name;
    }

    public int getRes() {
        return res;
    }

    public String getName() {
        return name;
    }

    public void setRes(int res) {
        this.res = res;
    }

    public void setName(String name) {
        this.name = name;
    }
}
