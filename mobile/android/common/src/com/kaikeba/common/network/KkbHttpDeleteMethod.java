package com.kaikeba.common.network;

import org.apache.commons.httpclient.methods.PostMethod;

/**
 * Created by mjliu on 14-8-11.
 */
public class KkbHttpDeleteMethod extends PostMethod {
    public KkbHttpDeleteMethod(String url) {
        super(url);
    }

    @Override
    public String getName() {
        return "DELETE";
    }
}
