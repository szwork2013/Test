package com.kaikeba.common.util;

import java.sql.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

//import com.digimobistudio.dibits.entity.Scan;


public class Syntax {

    public static void main(String[] args) {
//        System.out.println(checkUserName("中文中文中文一"));
//        System.out.println(checkUserName("ab"));
//        System.out.println(checkUserName("rA去啊啊"));
        System.out.println(checkUserRealName("中"));
        System.out.println(checkUserRealName("中文"));
        System.out.println(checkUserRealName("中文中文中文"));
        System.out.println(checkUserRealName("中文中文中文文"));
        System.out.println(checkUserRealName("abcasdf"));
    }

    public static final ERROR_INFO getUserNameErrorInfo(String name) {
//    	char [] charArr = name.toCharArray();
        if (name.isEmpty())
            return ERROR_INFO.USER_ERROR_EMPTY;
        if (name.length() < 3 || name.length() > 18) {
            return ERROR_INFO.USER_ERROR_LENGTH;
        }
        Pattern pattern = Pattern.compile("^[a-zA-Z0-9_\\u4e00-\\u9fa5][\\u4e00-\\u9fa5\\w\\.-]*$");
        Matcher matcher = pattern.matcher(name);
        if (!matcher.find())
            return ERROR_INFO.USER_ERROR_ILLEGAL;
        return ERROR_INFO.SUCCESS;
    }


//    public static final boolean checkUserName(String name) {
//        if (name.getBytes().length<2) return false;
//        if (name.getBytes().length>21) return false;
//        
//        Pattern pattern = Pattern.compile("^[a-zA-Z\\u4e00-\\u9fa5][\\u4e00-\\u9fa5\\w\\.-]*$");
//        Matcher matcher = pattern.matcher(name);
//        if (!matcher.find())
//        {
//            return false;
//        }
//        return true;
//    }

    public static final boolean checkUserRealName(String name) {
        if (name.getBytes().length < 6) return false;
        if (name.getBytes().length > 20) return false;

        Pattern pattern = Pattern.compile("^[\\u4e00-\\u9fa5]*$");
        Matcher matcher = pattern.matcher(name);
        if (!matcher.find()) {
            return false;
        }
        return true;
    }

    public static final ERROR_INFO getUserEmailErrorInfo(String email) {
        if (email.equals("")) {
            return ERROR_INFO.EMAIL_ERROR_EMPTY;
        } else {
            //ignore
        }

        Pattern pattern = Pattern
                .compile("^([\\w-])++(\\.?[\\w-])*+\\+{1}+([\\w-])++(\\.?[\\w-])*@([\\w-])+((\\.[\\w-]+)+)$"
                        + "|^([\\w-])++(\\.?[\\w-])*+@([\\w-])+((\\.[\\w-]+)+)$");
        Matcher matcher = pattern.matcher(email);
        if (!matcher.find()) {
            return ERROR_INFO.EMAIL_ERROR_ILLEGAL;
        } else {
            //ignore
        }
        return ERROR_INFO.SUCCESS;
    }

    public static final ERROR_INFO getUserPasswordErrorInfo(String password) {
        if (password.equals(""))
            return ERROR_INFO.PASSWORD_ERROR_EMPTY;
        if (password.length() < 6 || password.length() > 16)
            return ERROR_INFO.PASSWORD_ERROR_LENGTH;
        Pattern p = Pattern.compile("[\u4e00-\u9fa5]");
        Matcher m = p.matcher(password);
        if (m.find()) {
            return ERROR_INFO.PASSWORD_ERROR_CHINESE;
        }
//        if (password.getBytes().length>20) return false;

//        Pattern pattern = Pattern.compile(  "^[~`!@#%&()-={};:'\",<>/\\"+
//                                            "\\|\\[\\]\\.\\*\\+\\?\\^\\$\\w]*$");
//        Matcher matcher = pattern.matcher(password);
//        if (!matcher.find())
//        {
//            return false;
//        }
        return ERROR_INFO.SUCCESS;
    }

    public static final boolean checkUserBirthday(Date Birthday) {
        final boolean isOK = true;
        {
            // TODO checkUserBirthday
        }
        return isOK;
    }

    public static final boolean checkUserGender(byte gender) {
        final boolean isOK = true;
        {
            // TODO checkUserGender
        }
        return isOK;
    }

    public static final boolean checkThingName(String name) {
        final boolean isOK = true;
        {
            // TODO checkThingName
        }
        return isOK;
    }

//-----------------------¡ü¡ü¡ü Check User ¡ü¡ü¡ü-----------------------
//================================================================
//-----------------------¡ý¡ý¡ý Check Thing ¡ý¡ý¡ý----------------------

    public static final boolean checkThingCode(String code) {
        final boolean isOK = true;
        {
            // TODO checkThingCode
        }
        return isOK;
    }

//    public static final boolean checkThingDescription(String description) {
//        final boolean isOK = true;
//        {
//            // TODO checkThingDescription
//        }
//        return isOK;
//    }

    public static final boolean checkThingURL(String url) {
        final boolean isOK = true;
        {
            // TODO checkThingURL
        }
        return isOK;
    }

    public static final boolean checkBrandName(String name) {
        final boolean isOK = true;
        {
            // TODO checkBrandName
        }
        return isOK;
    }

//-----------------------¡ü¡ü¡ü Check Thing ¡ü¡ü¡ü-----------------------
//================================================================
//-----------------------¡ý¡ý¡ý Check Brand ¡ý¡ý¡ý----------------------

    public static final boolean checkBrandDescription(String description) {
        final boolean isOK = true;
        {
            // TODO checkBrandDescription
        }
        return isOK;
    }

    public static final boolean checkBrandCode(String code) {
        final boolean isOK = true;
        {
            // TODO checkBrandCode
        }
        return isOK;
    }

    public static final boolean checkBrandURL(String url) {
        final boolean isOK = true;
        {
            // TODO checkBrandURL
        }
        return isOK;
    }

    public static final boolean checkGeoCoordinate(Float coordinate) {
        final boolean isOK = true;
        {
            // TODO checkGeoCoordinate
        }
        return isOK;
    }

//-----------------------¡ü¡ü¡ü Check Brand ¡ü¡ü¡ü----------------------
//================================================================
//-----------------------¡ý¡ý¡ý Check GeoPt ¡ý¡ý¡ý----------------------

    public static final boolean checkGeoElevation(int elevation) {
        final boolean isOK = true;
        {
            // TODO checkGeoElevation
        }
        return isOK;
    }

    public static final boolean checkGeoLabel(String label) {
        final boolean isOK = true;
        {
            // TODO checkGeoLabel
        }
        return isOK;
    }

    public static final boolean checkScanBarcode(String barcode) {
        final boolean isOK = true;
        {
            // TODO checkScanBarcode
        }
        return isOK;
    }

//-----------------------¡ü¡ü¡ü Check GeoPt ¡ü¡ü¡ü----------------------
//================================================================
//-----------------------¡ý¡ý¡ý Check Scan ¡ý¡ý¡ý-----------------------

//    public static final boolean checkScanType(String type) {
//        if (type.equals(Scan.T_BARCODE) ||
//                type.equals(Scan.T_IMAGE) ||
//                type.equals(Scan.T_QRCODE)) {
//            return true;
//        }
//        return false;
//    }

    public static final boolean checkScanImage(String image) {
        final boolean isOK = true;
        {
            // TODO checkScanImage
        }
        return isOK;
    }

    public static final boolean checkScanQRcode(String qrCode) {
        final boolean isOK = true;
        {
            // TODO checkScanQRcode
        }
        return isOK;
    }

    public static final boolean checkRatingMin(int min) {
        if (min == 1) {
            return true;
        } else {
            return false;
        }
    }


//-----------------------¡ü¡ü¡ü Check Scan ¡ü¡ü¡ü-----------------------
//================================================================
//----------------------¡ý¡ý¡ý Check Rating ¡ý¡ý¡ý----------------------

    public static final boolean checkRatingMax(int max) {
        if (max == 5) {
            return true;
        } else {
            return false;
        }
    }

    public static final boolean checkRatingValue(byte value) {
        if ((value > 0) && (value < 6)) {
            return true;
        } else {
            return false;
        }
    }

    public static final boolean checkRatingAverage(float average) {
        if ((average >= 0f) && (average <= 5f)) {
            return true;
        } else {
            return false;
        }
    }

    public static final boolean checkRatingCount(int count) {
        if (count > 0) {
            return true;
        } else {
            return false;
        }
    }

    public enum ERROR_INFO {
        //成功
        SUCCESS,
        //邮件错误
        EMAIL_ERROR_EMPTY,
        EMAIL_ERROR_ILLEGAL,
        //用户错误
        USER_ERROR_EMPTY,
        USER_ERROR_ILLEGAL,
        USER_ERROR_LENGTH,
        //密码错误
        PASSWORD_ERROR_LENGTH,
        PASSWORD_ERROR_EMPTY,
        PASSWORD_ERROR_CHINESE;

        public static String getType(ERROR_INFO type) {
            String typeStr = "";
            switch (type) {
                case EMAIL_ERROR_EMPTY:
                    typeStr = "邮箱不能为空！";
                    break;
                case EMAIL_ERROR_ILLEGAL:
                    typeStr = "邮箱格式错误，请输入正确的邮箱！";
                    break;
                case USER_ERROR_EMPTY:
                    typeStr = "用户名不能为空！";
                    break;
                case USER_ERROR_LENGTH:
                    typeStr = "用户名长度必须为3-18位！";
                    break;
                case USER_ERROR_ILLEGAL:
                    typeStr = "用户名不规范：用户名由中英文、数字、下划线组成！";
                    break;
                case PASSWORD_ERROR_EMPTY:
                    typeStr = "密码不能为空！";
                    break;
                case PASSWORD_ERROR_LENGTH:
                    typeStr = "密码长度必须为6-16位！";
                    break;
                case PASSWORD_ERROR_CHINESE:
                    typeStr = "密码中不能包含中文！";
                    break;
            }
            return typeStr;
        }
    }


//----------------------¡ü¡ü¡ü Check Rating ¡ü¡ü¡ü----------------------
//================================================================
//-----------------------¡ý¡ý¡ý Check ???? ¡ý¡ý¡ý-----------------------

}