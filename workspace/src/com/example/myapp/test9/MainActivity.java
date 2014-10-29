package com.example.myapp.test9;

import com.example.myapp.test9.decorate_mode.Person;
import com.example.myapp.test9.decorate_mode.impl.BigTrouser;
import com.example.myapp.test9.decorate_mode.impl.TShirts;

/**
 * Created by sjyin on 14-10-13.
 */
public class MainActivity {

    public static void main(String[] args){

        Person p = new Person("小明");

        System.out.println("第一种装扮：");

        TShirts tShirts = new TShirts();
        BigTrouser bigTrouser = new BigTrouser();

        tShirts.decorate(p);
        bigTrouser.decorate(tShirts);

        bigTrouser.show();
    }
}
