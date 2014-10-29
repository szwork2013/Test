package com.kaikeba.common.util;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateUtils {

    public static final long DAY_SECONDS_MILLI = 24 * 60 * 60 * 1000;

    public static final String[] pattens = new String[]{
            "yyyy-MM-dd HH:mm:ss.SSS", "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm", "yyyy-MM-dd"};
    static Long minute = 60000l;
    static Long minute5 = 5 * minute;
    static Long hour = 60 * minute;
    static Long day = 24 * hour;
    static Long month = 30 * day;
    static Long year = 12 * month;

    public static Date parseDate(String json, DateFormat df) {
        try {
            if (json == null || json.trim().length() == 0) {
                return null;
            }

            return df.parse(json);
        } catch (ParseException e) {
            return null;
        }
    }

    public static Date parseDate(String json) throws ParseException {
        for (int i = 0; i < pattens.length; i++) {
            DateFormat df = new SimpleDateFormat(pattens[i]);
            Date date = parseDate(json, df);
            if (date != null) {
                return date;
            }
        }

        throw new ParseException("the date string can not be parse: " + json, 0);
    }

    public static String transTimeStamp(Timestamp t) {
        if (t == null) {
            return "";
        }
        Long getTime = t.getTime();
        Long nowTime = System.currentTimeMillis();
        Long distance = nowTime - getTime;

        if (distance < minute5) {
            return "\u521A\u521A";
        } else if (distance < hour) {
            return distance / minute + "\u5206\u949F\u524D";
        } else if (distance < day) {
            return distance / hour + "\u5C0F\u65F6\u524D";
        } else if (distance < month) {
            return distance / day + "\u5929\u524D";
        } else if (distance < year) {
            return distance / month + "\u6708\u524D";
        } else {
            return distance / year + "\u5E74\u524D";
        }
    }

    public static boolean getDateprice(Date courseStartTime) {

        Date currentTime = new Date(System.currentTimeMillis());
        long price = currentTime.getTime() - courseStartTime.getTime();
        if (price > 0) {
            return true;
        }
        return false;
    }

    public static String getCourseStartTime(Date courseStartTime) {
        return new SimpleDateFormat(pattens[3]).format(courseStartTime);
    }

    public static String getCurrentDate() {
        Date date = new Date(System.currentTimeMillis());
        return new SimpleDateFormat(pattens[3]).format(date);
    }

    public static Date StringToDate(String dateStr) {
        DateFormat dd = new SimpleDateFormat(pattens[3]);
        Date date = null;
        try {
            date = dd.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date;
    }

    public static Date StringToDate(String dateStr, String patten) {
        DateFormat dd = new SimpleDateFormat(patten);
        Date date = null;
        try {
            date = dd.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date;
    }

    public static String getDate(String type, String weekStr,
                                 String courseStartTime) {
        if (courseStartTime.equals("2020-01-01")) {
            return "精彩预告";
        }
        long price;
        Date currentTime = new Date(System.currentTimeMillis());
        if (type.equals("open")) {
            price = currentTime.getTime()
                    - StringToDate(courseStartTime).getTime();
            if (price > 0) {
                return "正在开课";
            } else {
                return courseStartTime;
            }
        } else {
            if (weekStr != null && weekStr.contains("周")) {
                weekStr = weekStr.substring(0, 1);
                long week = Long.parseLong(weekStr);
                price = StringToDate(courseStartTime).getTime()
                        - currentTime.getTime();
                long estTime = week * 7 * 24 * 60 * 60 * 1000;
                if (price > 0) {
                    return "即将开课";
                } else {
                    if (price + estTime > 0) {
                        return "正在开课";
                    } else {
                        return "已结束";
                    }
                }
            }
        }
        return null;
    }


    public static String StringToString(String dateStr, String weekStr) {
        long time = StringToDate(dateStr).getTime();
        if (weekStr != null && weekStr.contains("周")) {
            weekStr = weekStr.substring(0, 1);
            long week = Long.parseLong(weekStr);
            long estTime = week * 7 * 24 * 60 * 60 * 1000;
            long endTime = time + estTime;
            Date date = new Date(endTime);
            return new SimpleDateFormat(pattens[3]).format(date);
        }
        return null;
    }

    public static Integer getPercent(String startDate, String endDate) {
        long startPrice = System.currentTimeMillis()
                - StringToDate(startDate).getTime();
        long price = StringToDate(endDate).getTime()
                - StringToDate(startDate).getTime();
        int percent = (int) (startPrice * 100 / price);
        return percent;
    }

    public static boolean getCourseIsComming(String startDate, String endDate) {
        if (System.currentTimeMillis() > StringToDate(startDate).getTime()
                && System.currentTimeMillis() < StringToDate(endDate).getTime()) {
            return true;
        }
        return false;
    }

    public static Date getDateAfterHour(Date d, int hour) {
        Calendar now = Calendar.getInstance();
        now.setTime(d);
        now.set(Calendar.HOUR, now.get(Calendar.HOUR) + hour);
        return now.getTime();
    }

    public static String getCurrentTime() {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date curDate = new Date(System.currentTimeMillis());//获取当前时间
        String confirmed_at = formatter.format(curDate);
        return confirmed_at;
    }

    public static String getCurrentTimeEnroll() {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        Date curDate = new Date(System.currentTimeMillis());//获取当前时间
        String confirmed_at = formatter.format(curDate);
        return confirmed_at;
    }

    public static String getNearestTime(String startDate, String endDate) {
        java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd");
        java.util.Calendar c1 = java.util.Calendar.getInstance();
        java.util.Calendar c2 = java.util.Calendar.getInstance();
        try {
            c1.setTime(df.parse(startDate));
            c2.setTime(df.parse(endDate));
        } catch (java.text.ParseException e) {
            System.err.println("格式不正确");
        }
        int result = c1.compareTo(c2);
        if (result == 0)
            return startDate;
        else if (result < 0)
            return endDate;
        else
            return startDate;
    }

    public static String getYR(String data) throws ParseException {
        SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat sd2 = new SimpleDateFormat("yyyy年MM月dd日");

        //然后进行转化
        Date d = sd.parse(data);
        //将时间数插入sd2上
        String newStr = sd2.format(d);
        newStr = newStr.substring(5);
        return newStr;
    }
}
