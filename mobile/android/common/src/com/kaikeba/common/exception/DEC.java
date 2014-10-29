package com.kaikeba.common.exception;


/**
 * KaiKeBa错误码定义
 *
 * @author ZhouKe
 * @email Kenrick.Zhou@gmail.com
 */
public class DEC {

    /**
     * 加载所有错误码
     */
    public static void load() {
        try {
            Class.forName(Syntax.class.getName());
            Class.forName(Commons.class.getName());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static final class Business {
        public static final ErrorCode COURSE_ID = new ErrorCode(1001, 404, "课程ID错误");
        public static final ErrorCode USER_TOKEN = new ErrorCode(1002, 401, "用户认证，用户Token问题");
    }

    /**
     * 语法格式错误
     *
     * @author ZhouKe
     * @since 2011-07-03
     */
    public static final class Syntax {

        public static final ErrorCode EVENT_NAME = new ErrorCode(7001, 400, "活动名称不符合规则");

        public static final ErrorCode USER_NAME = new ErrorCode(7101, 400, "用户名不符合规则");
        public static final ErrorCode USER_EMAIL = new ErrorCode(7102, 400, "邮箱不符合规则");
        public static final ErrorCode USER_PASSWORD = new ErrorCode(7103, 400, "密码不符合规则");
        public static final ErrorCode USER_BIRTHDAY = new ErrorCode(7104, 400, "生日不符合规则");
        public static final ErrorCode USER_GENDER = new ErrorCode(7105, 400, "性别不符合规则 ");
        public static final ErrorCode USER_CITY = new ErrorCode(7106, 400, "城市不符合规则");
        public static final ErrorCode USER_SNS = new ErrorCode(7107, 400, "SNS不符合规则");
        public static final ErrorCode USER_NICKNAME = new ErrorCode(7108, 400, "用户昵称不符合规则");
        public static final ErrorCode USER_AVATAR = new ErrorCode(7109, 400, "用户头像丢失");
        public static final ErrorCode USER_SCHOOL = new ErrorCode(7110, 400, "用户学校信息不正确");


        public static final ErrorCode USER_NAME_REQUIRED = new ErrorCode(7111, 400, "用户名必填");
        public static final ErrorCode USER_EMAIL_REQUIRED = new ErrorCode(7112, 400, "邮箱必填");
        public static final ErrorCode USER_PASSWORD_REQUIRED = new ErrorCode(7113, 400, "密码必填");
        public static final ErrorCode USER_BIRTHDAY_REQUIRED = new ErrorCode(7114, 400, "生日必填");
        public static final ErrorCode USER_GENDER_REQUIRED = new ErrorCode(7115, 400, "性别必填 ");
        public static final ErrorCode USER_CITY_REQUIRED = new ErrorCode(7116, 400, "城市必填");
        public static final ErrorCode USER_NICKNAME_REQUIRED = new ErrorCode(7118, 400, "用户昵称必填");
        public static final ErrorCode USER_PHOTOURL_REQUIRED = new ErrorCode(7119, 400, "用户头像必填");

        public static final ErrorCode USER_NAME_CONFLICT = new ErrorCode(7121, 400, "用户头昵称冲突");
        public static final ErrorCode USER_EMAIL_CONFLICT = new ErrorCode(7122, 400, "用户头邮箱地址冲突");

        public static final ErrorCode USER_DESCRIPTION_TOO_LARGE = new ErrorCode(7123, 400, "用户简介太长");

        public static final ErrorCode USER_HOBBY_TOO_LARGE = new ErrorCode(7124, 400, "你对什么物品感兴趣内容太长");
        public static final ErrorCode USER_FAVORITE_TOO_LARGE = new ErrorCode(7125, 400, "你经常光顾的商店内容太长");
        public static final ErrorCode USER_JOB_TOO_LARGE = new ErrorCode(7126, 400, "你在从事什么职业内容太长");
        public static final ErrorCode USER_COMPANY_TOO_LARGE = new ErrorCode(7127, 400, "你曾在哪些公司任职内容太长");
        public static final ErrorCode USER_SCHOOL_TOO_LARGE = new ErrorCode(7128, 400, "就读学校太长");


        public static final ErrorCode THING_NAME = new ErrorCode(7201, 400, "物件名不符合规则");
        public static final ErrorCode THING_DESCRIPTION = new ErrorCode(7202, 400, "物件描述不符合规则");
        public static final ErrorCode THING_CODE = new ErrorCode(7203, 400, "物件code不符合规则");
        public static final ErrorCode THING_URL = new ErrorCode(7204, 400, "物件URL不符合规则");


        public static final ErrorCode BRAND_NAME = new ErrorCode(7301, 400, "品牌名不符合规则");
        public static final ErrorCode BRAND_DESCRIPTION = new ErrorCode(7302, 400, "品牌描述不符合规则");
        public static final ErrorCode BRAND_CODE = new ErrorCode(7303, 400, "品牌code不符合规则");

        public static final ErrorCode POST = new ErrorCode(7401, 400, "签到内容不符合规则");

        public static final ErrorCode TAG_NAME = new ErrorCode(7501, 400, "标签名不符合规则");
        public static final ErrorCode TAG_NAME_CONFLICT = new ErrorCode(7502, 400, "标签名称冲突");

        public static final ErrorCode EVENT_NAME_CONFLICT = new ErrorCode(7621, 400, "活动名称冲突");

        public static final ErrorCode REPLY_TEXT_TOO_LARGE = new ErrorCode(7641, 400, "回复内容太长");

        public static final ErrorCode GEO_COORDINATE = new ErrorCode(7701, 400, "坐标不符合规则 ");
        public static final ErrorCode GEO_ELEVATION = new ErrorCode(7702, 400, "海拔不符合规则");
        public static final ErrorCode GEO_LABEL = new ErrorCode(7703, 400, "地名不符合规则");
        public static final ErrorCode RATING_MIN = new ErrorCode(7711, 400, "评星最小值不符合规则");
        public static final ErrorCode RATING_MAX = new ErrorCode(7712, 400, "评星最大值不符合规则");
        public static final ErrorCode RATING_VALUE = new ErrorCode(7713, 400, "评星值不符合规则");
        public static final ErrorCode RATING_AVERAGE = new ErrorCode(7714, 400, "评星均值不符合规则 ");
        public static final ErrorCode RATING_COUNT = new ErrorCode(7715, 400, "评星人数不符合规则");


        public static final ErrorCode SCAN_TYPE = new ErrorCode(7801, 400, "扫描类型不符合规则");
        public static final ErrorCode SCAN_BARCODE = new ErrorCode(7802, 400, "条形码不符合规则");
        public static final ErrorCode SCAN_IMAGE = new ErrorCode(7803, 400, "图像不符合规则");
        public static final ErrorCode SCAN_QRCODE = new ErrorCode(7804, 400, "QRCode不符合规则");

        public static final ErrorCode CONTENT = new ErrorCode(7901, 400, "上传字符串不符合规则");

        public static final ErrorCode BADGE_NOT_USEABLE = new ErrorCode(6101, 400, "徽章不能被使用");
        public static final ErrorCode USER_BADGE_NOT_OPEN = new ErrorCode(6102, 400, "用户还没有获得该徽章");

        public static final ErrorCode CRON_EXPRESSION_NOT_CORRECT = new ErrorCode(5001, 400, "Cron表达式错误");
        public static final ErrorCode MAC = new ErrorCode(7902, 400, "MAC syntax error, MAC must be uppper case and no ':' interval!");


        public static final ErrorCode PROMOTION_APP_NAME = new ErrorCode(6201, 400, "推荐应用名不符合规则");
        public static final ErrorCode PROMOTION_APP_NICKNAME = new ErrorCode(6202, 400, "推荐应用昵称不符合规则");
        public static final ErrorCode PROMOTION_APP_NAME_REQUIRED = new ErrorCode(6211, 400, "推荐应用名必填");
        public static final ErrorCode PROMOTION_APP_ICON_REQUIRED = new ErrorCode(6212, 400, "推荐应用图标路径必填");
        public static final ErrorCode PROMOTION_APP_NICKNAME_REQUIRED = new ErrorCode(6213, 400, "推荐应用昵称必填");
        public static final ErrorCode PROMOTION_APP_NAME_CONFLICT = new ErrorCode(6221, 400, "推荐应用名称冲突");
        public static final ErrorCode PROMOTION_APP_NICKNAME_CONFLICT = new ErrorCode(6222, 400, "推荐应用昵称冲突");
    }

    /**
     * 通用错误码定义
     *
     * @author ZhouKe
     * @since 2011-07-03
     */
    public static class Commons {

        public static final ErrorCode CLIENT_REQUEST_ERROR = new ErrorCode(9000, 400, "客服端请求错误，泛指，不知道具体错误");

        public static final ErrorCode CLIENT_REQUEST_MEDIA_TYPE = new ErrorCode(9001, 400, "客户端请求的MediaType不被服务器接受");
        public static final ErrorCode CLIENT_UNPROCESSABLE_ENTITY = new ErrorCode(9002, 400, "客户端请求的内容的类型能被理解，但是暂时不能被处理");
        public static final ErrorCode CLIENT_NO_METHOD_SPECIFIED = new ErrorCode(9003, 400, "客户端请求没有指定HTTP方法");
        public static final ErrorCode CLIENT_METHOD_NOT_ALLOWED = new ErrorCode(9004, 400, "客户端请求的HTTP方法不被服务器接受");

        public static final ErrorCode CLIENT_REQUEST_NULL_ENTITY = new ErrorCode(9006, 400, "客户端请求所提交的表现实体为空");
        public static final ErrorCode CLIENT_REQUEST_ENTITY_TOO_LARGE_TEXT = new ErrorCode(9007, 413, "客户端请求所提交的表现实体过大（主要表现在字符数超过数据库限制）");
        public static final ErrorCode CLIENT_QUERY_ATTRIBUTES = new ErrorCode(9008, 400, "客户端请求的查询参数有误 ");
        public static final ErrorCode CLIENT_REQUEST_ENTITY_TOO_LARGE_IMAGE = new ErrorCode(9009, 413, "客户端请求所提交的表现实体过大（主要表现在上传图片超过规格限制）");
        public static final ErrorCode CLIENT_REQUEST_ENTITY_ERROR = new ErrorCode(9010, 400, "客户端请求所提交的表现实体错误");
        public static final ErrorCode CLIENT_PATH_PARAM = new ErrorCode(9011, 400, "客户端请求的路径参数有误 ");

        public static final ErrorCode CLIENT_CONFLICT = new ErrorCode(9019, 409, "客户端的请求与资源状态冲突，没有具体资源进行捕捉，所以不知道具体是什么冲突了。 具体资源应尝试Override冲突捕捉方法。");
        public static final ErrorCode CLIENT_CONFLICT_GET = new ErrorCode(9018, 409, "客户端的GET请求与资源状态冲突，没有具体资源进行捕捉，所以不知道具体是什么冲突了。 具体资源应尝试Override冲突捕捉方法。");
        public static final ErrorCode CLIENT_CONFLICT_PUT = new ErrorCode(9012, 409, "客户端的PUT请求与资源状态冲突，没有具体资源进行捕捉，所以不知道具体是什么冲突了。 具体资源应尝试Override冲突捕捉方法。");
        public static final ErrorCode CLIENT_CONFLICT_POST = new ErrorCode(9013, 409, "客户端的POST请求与资源状态冲突，没有具体资源进行捕捉，所以不知道具体是什么冲突了。 具体资源应尝试Override冲突捕捉方法。");
        public static final ErrorCode CLIENT_CONFLICT_DELETE = new ErrorCode(9014, 409, "客户端的DELETE请求与资源状态冲突，没有具体资源进行捕捉，所以不知道具体是什么冲突了。 具体资源应尝试Override冲突捕捉方法。");

        public static final ErrorCode CLIENT_CONFLICT_HAVE = new ErrorCode(9015, 409, "客户端的have请求与资源状态冲突，即用户重复请求拥有同一物件");
        public static final ErrorCode CLIENT_CONFLICT_WANT = new ErrorCode(9016, 409, "客户端的want请求与资源状态冲突，即用户重复请求想要同一物件");

        public static final ErrorCode CLIENT_RESOURCE_NOT_EXIST = new ErrorCode(9017, 400, "客户端请求的资源不存在");

        public static final ErrorCode CLIENT_AUTH_FAILED = new ErrorCode(9021, 401, "客户端认证失败");
        public static final ErrorCode CLIENT_USER_NO_PERMISSION = new ErrorCode(9022, 401, "客户端用户没有权限");

        public static final ErrorCode CLIENT_URI_NOT_FOUND = new ErrorCode(9023, 404, "客户端请求的URI没有定义");


        public static final ErrorCode SERVER_ERROR = new ErrorCode(9500, 500, "服务器错误，泛指，不知道具体错误");

        public static final ErrorCode SERVER_CONFIG_ERROR = new ErrorCode(9510, 500, "服务器配置文件配置错误");
        public static final ErrorCode SERVER_TRANS_PARAMETER_ERROR = new ErrorCode(9520, 500, "服务端自身传参错误");
        public static final ErrorCode SERVER_IO_ERROR = new ErrorCode(9530, 500, "服务端读写错误");
        public static final ErrorCode SERVER_SQL_ERROR = new ErrorCode(9590, 500, "服务器执行SQL时发生错误");

        public static final ErrorCode SERVER_SNS_API_ERROR = new ErrorCode(9591, 500, "服务器执行SNSAPI时发生错误");
        public static final ErrorCode SERVER_SNS_OAUTH_ERROR = new ErrorCode(9592, 500, "服务器执行SNS OAUTH时发生错误");
        public static final ErrorCode SERVER_DOMAIN_MODEL_UPDATE_ERROR = new ErrorCode(9593, 500, "服务器在更新领域模型时发生错误");


        public static final ErrorCode SERVER_OAUTH_EXPIRED = new ErrorCode(9900, 500, "OAuth认证过期");
        public static final ErrorCode OAUTH_SINA_EXPIRED = new ErrorCode(9901, 500, "Sina OAuth认证过期");
        public static final ErrorCode OAUTH_RENREN_EXPIRED = new ErrorCode(9902, 500, "Renren OAuth认证过期");
        public static final ErrorCode OAUTH_DOUBAN_EXPIRED = new ErrorCode(9903, 500, "Douban OAuth认证过期");
        public static final ErrorCode OAUTH_QQ_EXPIRED = new ErrorCode(9904, 500, "QQ OAuth认证过期");


    }

    /**
     * 针对领域模型的业务约束
     *
     * @author zoe
     */
    public static class Constraint {
        public static final ErrorCode MODEL_UNIDENTIFIED = new ErrorCode(8001, 500, "不可识别的领域模型！");
        public static final ErrorCode MODEL_INCONSISTENT = new ErrorCode(8002, 500, "领域模型不一致！");
    }
}