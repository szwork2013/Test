package com.kaikeba.common.storage;

import java.util.ArrayList;

/**
 * Created with IntelliJ IDEA.
 * User: caojing
 * Date: 6/30/14
 * Time: 8:24 PM
 * To change this template use File | Settings | File Templates.
 */
public class LocalStorage {

    private static LocalStorage singleton;
    private ArrayList<Long> ids = new ArrayList<Long>();

    private LocalStorage() {

    }

    static public LocalStorage sharedInstance() {
        if (singleton == null) {
            singleton = new LocalStorage();
        }
        return singleton;
    }

    public ArrayList<Long> getIds() {
        return ids;
    }

    public void setIds(ArrayList<Long> ids) {
        this.ids = ids;
    }
}
