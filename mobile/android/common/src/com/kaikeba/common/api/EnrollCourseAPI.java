package com.kaikeba.common.api;

import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.ErrorInfo;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.HttpUrlUtil;

public class EnrollCourseAPI extends API {

    public static ErrorInfo entrollCourse(long lms_course_id) throws DibitsExceptionC {
        String url = buildURL(lms_course_id);
        String responseJson = DibitsHttpClient.doNewGet(url);
        ErrorInfo responseError = (ErrorInfo) JsonEngine.parseJson(responseJson, ErrorInfo.class);
        System.out.println("response body: ");
        System.out.println(responseError);
        return responseError;
    }

    private static String buildURL(long lms_course_id) {
        String url = HttpUrlUtil.ENROLL_COURSES + lms_course_id;
        return url;
    }
}
