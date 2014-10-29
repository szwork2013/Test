/*
 * Copyright (C) 2010 The MobileSecurePay Project
 * All right reserved.
 * author: shiqun.shi@alipay.com
 * 
 *  提示：如何获取安全校验码和合作身份者id
 *  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
 *  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
 *  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
 */

package com.kaikeba.common.alipay;

//
// 请参考 Android平台安全支付服务(msp)应用开发接口(4.2 RSA算法签名)部分，并使用压缩包中的openssl RSA密钥生成工具，生成一套RSA公私钥。
// 这里签名时，只需要使用生成的RSA私钥。
// Note: 为安全起见，使用RSA私钥进行签名的操作过程，应该尽量放到商家服务器端去进行。
public final class Keys {

    //合作身份者id，以2088开头的16位纯数字
    public static final String DEFAULT_PARTNER = "2088901480525295";

    //收款支付宝账号
    public static final String DEFAULT_SELLER = "paypal@kaikeba.com";

    //商户私钥，自助生成
    public static final String PRIVATE = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAL0w92Uv1vTqLWRV\n" +
            "nGGBHDmsC4VozMJl8w+GwujLGwU+tpG/9+m260247TqJiAdVL2H7rncPNFAO+9P9\n" +
            "pzaUZkBwfNVrd9JkobaLTqN2UTK7jebiDlPjV71xed3/SvdB4+OjEF4HnLGwL3RL\n" +
            "i1dolm6/INz3lQUNjbAvs+kleip9AgMBAAECgYAibMeHZPYTKI1L5XwIDesp31FV\n" +
            "XCVt9gkNOTM8EsD+6lNkH+8nWr5kLRMVhLL4yppNlPNA/MZDDwbpow0LFGOqY6tn\n" +
            "IxvOYOXlIeRUpV861GplBR0ropg4mrPHYVIAlC/WOVKsoG20Ydws41tZJfia/cEH\n" +
            "MInQ5WBcOpIxk6n84QJBAO+53ReD3lhgG4UTAkXdJDhcFTG5Om4i+YAzJujuDPuU\n" +
            "rFVxsYGOKHXLcrRGl7WF4sgBfqJv0JoOZCsMEGiQTkUCQQDKCN9UKzjAD+3Zvgh/\n" +
            "TmB7p5oZN/OzmAFiVlz8cYauzeiOlSo2tK1YhODc7O+WLLaBlmgyC7wvogozRiUU\n" +
            "VqrZAkEAqM20BY7xzkE+n6IXA6MIkjclJXJM1qkCD2f1iie2NKEoCLKaT6QOkYPF\n" +
            "LXRX95Zjbnq+9RrPROvFVRqVo0uaEQJAAlCttno0UUcdc6RQ1pygUGpwQp+4hDNW\n" +
            "uLjCogXvBCvJ4XBmJnBVmDEVnpJ8gF0MzllZ4lDuHCGgOkwwepYvqQJBAJKMIdkY\n" +
            "UgbYS8ihShqYku5fluBe6Xlt2wmApzvnoShYyvP2tppmYCx9dBadHa5cDmrCQvUS\n" +
            "3qA0sp/MZbO0GjI=";

    //支付宝公钥
    public static final String PUBLIC = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";

}
