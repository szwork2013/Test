package com.example.myapp.test9.decorate_mode;

/**
 * Created by sjyin on 14-10-13.
 */
public class Person {
    private String name;

    public Person(){

    }

    public Person(String name) {
        this.name = name;
    }

    public void show(){
        System.out.println("装饰的" + name);
    }

}
