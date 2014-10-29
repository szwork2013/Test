package com.kaikeba.common.util;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Enumeration;
import java.util.Properties;


/**
 * 配置读取器
 *
 * @author ZhouKe
 * @version v1.0
 * @since 2011.11.30
 */
public class ConfigLoader {

    private static final String CLASS_HEAD = ConfigLoader.class.getName() + "$";
    /**
     * ConfigLoader配置文件的名称
     */
    private static final String DEV_CONFIG_FILE_NAME = "kaikeba_dev.properties";
    private static final String TEST_CONFIG_FILE_NAME = "kaikeba_test.properties";
    private static final String CONFIG_FILE_NAME = "kaikeba.properties";
    private static Log log = LogFactory.getLog(ConfigLoader.class);
    /**
     * 单例的Loader, 不要直接去用这个成员变量, </br>
     * 应使用 <code>LogComponentLoader.getLogComponentLoader()</code> 去获得Loader
     */
    private static volatile ConfigLoader loader = null;


    /**
     * 获取单例Loader
     * @return Loader的唯一实例
     */
    private ConfigLoader() {
        reload();
    }

    /**
     * @return
     */
    public static ConfigLoader getLoader() {
        if (loader == null) {
            synchronized (ConfigLoader.class) {
                if (loader == null) {
                    loader = new ConfigLoader();
                }
            }
        }

        return loader;
    }

    private static void onLoadProperties(Properties properties) throws UnsupportedEncodingException {
        Enumeration<?> keys = properties.propertyNames();
        while (keys.hasMoreElements()) {
            String key = (String) keys.nextElement();

            int lastPP = key.lastIndexOf('.');
            String clazzName = CLASS_HEAD + key.substring(0, lastPP).replace('.', '$');
            String fliedName = key.substring(lastPP + 1, key.length());


            try {
                Class<?> clazz = Class.forName(clazzName);

                Method getInstance = clazz.getDeclaredMethod("getInstance", new Class[0]);
                getInstance.setAccessible(true);

                Field field = clazz.getDeclaredField(fliedName);
                field.setAccessible(true);

                field.set(getInstance.invoke(null, new Object[0]), new String(((String) properties.get(key)).getBytes("ISO-8859-1"), "UTF-8"));

            } catch (ClassNotFoundException e) {
                log.fatal("ConfigLoader can not found specified class!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (SecurityException e) {
                log.fatal("ConfigLoader can not access specified Field!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (NoSuchFieldException e) {
                log.fatal("ConfigLoader can not found specified Field!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (IllegalArgumentException e) {
                log.fatal("ConfigLoader can not set specified Field!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (IllegalAccessException e) {
                log.fatal("ConfigLoader can not set specified Field!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (NoSuchMethodException e) {
                log.fatal("ConfigLoader's subConfigClass not provide getInstance() method!!!");
                e.printStackTrace();
                System.exit(1);
            } catch (InvocationTargetException e) {
                log.fatal("SubConfigClass's getInstance() define error!!!");
                e.printStackTrace();
                System.exit(1);
            }
        }
    }

    public static void main(String[] args) {
        ConfigLoader loader = ConfigLoader.getLoader();
        System.out.println(loader.getCanvas().getAccessToken());
        System.out.println(loader.getCanvas().getApiHost());
        System.out.println(loader.getCanvas().getDummyApiHost());
        System.out.println(loader.getCanvas().getTestToken());
//        System.out.println(loader.getWeibo().getRecommendText());
//        System.out.println(loader.getWeibo().getSupportAt());
//        System.out.println(loader.getDouban().getRecommendText());
//        System.out.println(loader.getDouban().getSupportAt());
        System.out.println(loader.getCanvas().getHtmlHead());
        System.out.println(loader.getCanvas().getHtmlTail());
    }

    /**
     * 重新加载配置文件
     */
    public void reload() {
        try {
            //1. 试图加载开发配置
            log.info("try load devlop config file from : classpath:" + DEV_CONFIG_FILE_NAME);
            if (loadConfig(DEV_CONFIG_FILE_NAME))
                return;
            log.info("not found devlop config file from : classpath:" + DEV_CONFIG_FILE_NAME);

            //2. 试图加载测试配置
            log.info("try load test config file from : classpath:" + TEST_CONFIG_FILE_NAME);
            if (loadConfig(TEST_CONFIG_FILE_NAME))
                return;
            log.info("not found test config file from : classpath:" + TEST_CONFIG_FILE_NAME);

            //3. 试图加载生产配置
            log.info("try load release config file from : classpath:" + CONFIG_FILE_NAME);
            if (loadConfig(CONFIG_FILE_NAME))
                return;
            log.info("not found release config file from : classpath:" + CONFIG_FILE_NAME);

            System.exit(1);
        } catch (Exception e) {
            log.fatal("ConfigLoader load config file failed!");
            e.printStackTrace();
            System.exit(1);
        }
    }

    protected boolean loadConfig(String configFileName) throws Exception {
        ClassLoader classLoader = getClass().getClassLoader();
        Properties properties = null;
        Enumeration<URL> urls = classLoader.getResources(configFileName);

        if (urls.hasMoreElements()) {
            URL url = (URL) urls.nextElement();
            properties = new Properties();
            properties.load(url.openStream());

            onLoadProperties(properties);
            return true;
        }

        return false;
    }

    public Canvas getCanvas() {
        return Canvas.getInstance();
    }

    public Upyun getUpyun() {
        return Upyun.getInstance();
    }

    public static class Canvas {

        private static volatile Canvas canvas = null;
        private String apiHost;
        private String dummyApiHost;
        private String perPage;
        private String loginURL;
        private String logoutURL;
        private String exchangeURL;
        private String openAccountID;
        private String rootAccountID;
        private String publicToken;
        private String accessToken;
        private String testToken;
        private String htmlHead;
        private String htmlTail;
        private String pageHtmlHead;
        private String pageHtmlTail;
        private String about4TabletURL;
        private String apiV4Host;

        private static Canvas getInstance() {
            if (canvas == null) {
                synchronized (Canvas.class) {
                    if (canvas == null) {
                        canvas = new Canvas();
                    }
                }
            }

            return canvas;
        }

        public final String getApiV4Host() {
            return apiV4Host;
        }

        public final String getApiHost() {
            return apiHost;
        }

        public final String getDummyApiHost() {
            return dummyApiHost;
        }

        public final String getPerPage() {
            return perPage;
        }

        public final String getLoginURL() {
            return loginURL;
        }

        public final String getLogoutURL() {
            return logoutURL;
        }

        public String getExchangeURL() {
            return exchangeURL;
        }

        public final String getOpenAccountID() {
            return openAccountID;
        }

        public final String getRootAccountID() {
            return rootAccountID;
        }

        public final String getPublicToken() {
            return publicToken;
        }

        public final String getAccessToken() {
            return accessToken;
        }

        public final String getTestToken() {
            return testToken;
        }

        public final String getHtmlHead() {
            return htmlHead;
        }

        public final String getHtmlTail() {
            return htmlTail;
        }

        public final String getPageHtmlHead() {
            return pageHtmlHead;
        }

        public final String getPageHtmlTail() {
            return pageHtmlTail;
        }

        public String getAbout4TabletURL() {
            return about4TabletURL;
        }
    }

    public static class Upyun {

        private static volatile Upyun upyun = null;
        private String key;
        private String bucketName;
        private String userName;
        private String userPassword;
        private String expiration;
        private String url;

        private static Upyun getInstance() {
            if (upyun == null) {
                synchronized (Upyun.class) {
                    if (upyun == null) {
                        upyun = new Upyun();
                    }
                }
            }

            return upyun;
        }

        public String getKey() {
            return key;
        }

        public String getBucketName() {
            return bucketName;
        }

        public String getExpiration() {
            return expiration;
        }

        public String getUserName() {
            return userName;
        }

        public String getUserPassword() {
            return userPassword;
        }

        public String getUrl() {
            return url;
        }
    }

}