package com.kaikeba.common.exception;

public class NoAuthException extends Exception {

    /**
     *
     */
    private static final long serialVersionUID = -5773267263998628332L;

    public NoAuthException() {
        super();
    }

    @Override
    public String getMessage() {
        // TODO Auto-generated method stub
        return "账号过期";
    }
}
