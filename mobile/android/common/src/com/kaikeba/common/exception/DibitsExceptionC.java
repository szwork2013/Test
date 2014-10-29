package com.kaikeba.common.exception;

/**
 * Dibits2.0 客户端异常
 *
 * @author ZhouKe
 * @email Kenrick.Zhou@gmail.com
 */
public class DibitsExceptionC extends Exception {
    private static final long serialVersionUID = -9220226931342450134L;

    protected ErrorCode errorCode;

    protected String classCode;
    protected String stackHash;

    protected String message;

    public DibitsExceptionC(int dibitsCode, String message) {
        this.errorCode = ErrorCode.valueOf(dibitsCode);
        this.message = message;
    }

    public DibitsExceptionC(ErrorCode errorCode, String msg) {
        this.errorCode = errorCode;
        this.message = msg;
    }

    public DibitsExceptionC(String result) {
        parseErrorResult(result);
    }

    // 加载所有错误码的定义
    static {
        DEC.load();
    }

    /**
     * 解析错误结果
     *
     * @param result
     */
    private void parseErrorResult(String result) {
        if (result == null || result.trim().length() == 0)
            errorCode = DEC.Commons.SERVER_ERROR;

        String[] segments = result.split("\\|");
        if (segments.length == 2) {
            errorCode = DEC.Commons.SERVER_ERROR;
            stackHash = segments[0];
            message = segments[1];
        } else if (segments.length == 4) {
            errorCode = ErrorCode.valueOf(Integer.valueOf(segments[0]));
            classCode = segments[1];
            stackHash = segments[2];
            message = segments[3];
        } else {
            errorCode = DEC.Commons.SERVER_ERROR;
            message = result;
        }
    }

    public int getErrorCode() {
        return errorCode.getCode();
    }

    public String getClassCode() {
        return classCode;
    }

    public String getStackHash() {
        return stackHash;
    }


    public String toString() {
        return "Dibits 2.0 Error Info: [errorCode=" + errorCode
                + ", classCode=" + classCode + ", stackHash=" + stackHash
                + ", message=" + message + "]";
    }

    public String getMessageX() {
        return message;
    }

    public String getMessage() {
        return toString();
    }

    public String getMessage2() {
        if (errorCode == null) {
            return null;
        }
        return errorCode.getDesc();
    }
}