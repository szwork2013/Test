package com.kaikeba.mitv;

/**
 * Created by caojing on 14-5-17.
 */
public class CourseActivityHelper {

    public static String formatModuleName(String moduleName) {
        return formatStringByRemovePrefix(moduleName, " ");
    }

    public static String formatVideoTitle(String title) {
        return formatStringByRemovePrefix(title, "-");
    }

    private static String formatStringByRemovePrefix(String string, String token) {
        int index = string.indexOf(token);
        if (index == -1) {
            return string;
        } else {
            return string.substring(index + 1).trim();
        }
    }
}
