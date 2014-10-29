package com.kaikeba.common.exception;

import java.util.HashMap;
import java.util.LinkedHashMap;

/**
 * Dibits 错误代码定义
 *
 * @author ZhouKe
 * @email Kenrick.Zhou@gmail.com
 */
public class ErrorCode {

    private static HashMap<Integer, ErrorCode> errorCodes = new LinkedHashMap<Integer, ErrorCode>();
    /**
     * http status
     */
    private int statusCode;
    /**
     * error code value
     */
    private int code;
    /**
     * description of error code.
     */
    private String desc;

    /**
     * 默认status Code 为 400
     *
     * @param code
     * @param desc
     */
    public ErrorCode(int code, String desc) {
        this.code = code;
        this.desc = desc;
        this.statusCode = 404;
        errorCodes.put(code, this);
    }

    public ErrorCode(int code, int statusCode, String desc) {
        this.code = code;
        this.desc = desc;
        this.statusCode = statusCode;
        errorCodes.put(code, this);
    }

    /**
     * 根据code 获取ErrorCode.
     *
     * @param code
     * @return
     */
    public static ErrorCode get(Integer code) {
        ErrorCode errorCode = errorCodes.get(code);
        if (errorCode == null) {
            errorCode = new ErrorCode(code, "undefinded error code.");
        }
        return errorCode;
    }

    /**
     * 根据 ErrorCode 编码生成ErrorCode
     *
     * @param code
     * @return
     */
    public static ErrorCode valueOf(Integer code) {
        ErrorCode errorCode = errorCodes.get(code);
        if (errorCode == null) {
            errorCode = new ErrorCode(code, "undefinded error code.");
        }
        return errorCode;
    }

    public int getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(code).append("|").append(desc);
        return sb.toString();
    }
}