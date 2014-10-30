package com.example.myapp.test9.decorate_mode;

/**
 * Created by sjyin on 14-10-13.
 */
public class Finery extends Person {

    protected Person component;

    public void decorate(Person component){
        this.component = component;
    }

    public void show(){
        if( component != null){
            component.show();
        }
    }
}
