package com.kaikeba.common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * 日期格式化工具类
 *
 * @author sl 2011-11-17
 */
public class FormatDate {

    /**
     * 得到当前系统日期,格式:yyyy-mm-dd
     *
     * @return
     */
    public static String getCurrentDate() {

        return getFormatDate("yyyy-MM-dd");
    }

    /**
     * 返回年份
     *
     * @return
     */
    public static String getCurrentYear() {

        return getFormatDate("yyyy");
    }

    /**
     * 返回月份
     */
    public static String getCurrentMonth() {
        return getFormatDate("MM");
    }

    /**
     * 返回特定格式的日期 格式如下: yyyy-mm-dd
     *
     * @param formatString
     * @return
     */
    protected static String getFormatDate(String formatString) {
        String currentDate = "";
        SimpleDateFormat format1 = new SimpleDateFormat(formatString);
        currentDate = format1.format(new Date());
        return currentDate;
    }

    /**
     * 返回时间格式样式
     *
     * @return
     */
    public static String getFormateDateAll() {
        return getFormatDate("yyyy-MM-dd HH:mm:ss");
    }

    /**
     * 获取简化时间格式
     *
     * @return
     */
    public static String getFormateDateSimple() {
        return getFormatDate("yyyyMMddHHmmss");
    }

    /**
     * 获取几天后的时间
     *
     * @param d
     * @param day
     * @return
     */
    public static Date getDateAfterDay(Date d, int day) {
        Calendar now = Calendar.getInstance();
        now.setTime(d);
        now.set(Calendar.DATE, now.get(Calendar.DATE) + day);
        return now.getTime();
    }

    /**
     * 返回几个小时后的时间
     *
     * @param d
     * @param hour
     * @return
     */
    public static Date getDateAfterHour(Date d, int hour) {
        Calendar now = Calendar.getInstance();
        now.setTime(d);
        now.set(Calendar.HOUR, now.get(Calendar.HOUR) + hour);
        return now.getTime();
    }

    /**
     * 返回几分钟后的某个时间
     *
     * @param d
     * @param minutes
     * @return
     */
    public static Date getDateAfterMinute(Date d, int minutes) {
        Calendar now = Calendar.getInstance();
        now.setTime(d);
        now.set(Calendar.MINUTE, now.get(Calendar.MINUTE) + minutes);
        return now.getTime();
    }

    /**
     * 比较两个日期的大小 true date1比date2前 false date1比date2后
     *
     * @param date1
     * @param date2
     * @return
     */
    public static boolean dateCompare(Date date1, Date date2) {
        boolean dateComPareFlag = true;
        if (date2.compareTo(date1) != 1) {
            dateComPareFlag = false;
        }
        return dateComPareFlag;
    }

    /**
     * 返回两时间之差
     *
     * @param startTime
     * @param endTime
     * @return
     */
    public static long dateMinus(Date startTime, Date endTime) {
        return endTime.getTime() - startTime.getTime();
    }

    // 计算两个string类的时间差
    public static String time(String startTime, String endTime)
            throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");// 格式化时间
        Date outdate = sdf.parse(endTime);
        Date indate = sdf.parse(startTime);
        long totalhours = (outdate.getTime() - indate.getTime())
                / (1000 * 60 * 60);// 时
        long totalminutes = (outdate.getTime() - indate.getTime())
                / (1000 * 60) - totalhours * 60;// 分
        long totalseconds = (outdate.getTime() - indate.getTime()) / (1000)
                - totalminutes * 60;// 秒
        String total_time = totalhours + "时" + totalminutes + "分"
                + totalseconds + "秒";
        return total_time;
    }

    // 计算考试的剩余时间
    public static String examRemainTime(String startTime, String endTime)
            throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");// 格式化时间
        Date outdate = sdf.parse(endTime);
        Date indate = sdf.parse(startTime);
        long totalminutes = (outdate.getTime() - indate.getTime())
                / (1000 * 60);// 分
        long totalseconds = (outdate.getTime() - indate.getTime()) / (1000)
                - totalminutes * 60;// 秒
        String remainTime = totalminutes + "#" + totalseconds;
        return remainTime;
    }

}