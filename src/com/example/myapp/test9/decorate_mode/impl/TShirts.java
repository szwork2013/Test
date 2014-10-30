package com.example.myapp.test9.decorate_mode.impl;

import com.example.myapp.test9.decorate_mode.Finery;
import com.example.myapp.test9.decorate_mode.Person;

/**
 * Created by sjyin on 14-10-13.
 */
public class TShirts extends Finery {

    @Override
    public void show() {
        System.out.println("T shirt");
        super.show();
    }
}
