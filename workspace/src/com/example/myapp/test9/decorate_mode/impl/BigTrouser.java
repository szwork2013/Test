package com.example.myapp.test9.decorate_mode.impl;

import com.example.myapp.test9.decorate_mode.Finery;

/**
 * Created by sjyin on 14-10-13.
 */
public class BigTrouser extends Finery {
    @Override
    public void show() {
        System.out.println("垮裤");
        super.show();
    }
}
