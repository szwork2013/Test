package com.kaikeba.api;

import org.apache.commons.httpclient.HttpException;

import java.io.IOException;

public class TestAPI {

    A a;

    public static void main(String[] args) throws HttpException, IOException {
//	    File f = new File("D://zzlu180.png");
//	    if (!f.isFile()) {
//	        System.out.println("is not a file");
//	    }
//	    PutMethod filePost = new PutMethod(
//	            "http://192.168.1.124/api/v1/users/11?access_token=" + ConfigLoader.getLoader().getCanvas().getTestToken());
//	    Part[] parts = { new StringPart("user[name]", "John Lu"), new FilePart("user[avatar][token]", f)};
//	    filePost.setRequestEntity(new MultipartRequestEntity(parts, filePost
//	            .getParams()));
//	    HttpClient clients = new HttpClient();
//
//	    int status = clients.executeMethod(filePost);
//	    try {
//	        BufferedReader rd = new BufferedReader(new InputStreamReader(
//	                filePost.getResponseBodyAsStream(), "UTF-8"));
//	        StringBuffer stringBuffer = new StringBuffer();
//	        String line;
//	        while ((line = rd.readLine()) != null) {
//	            stringBuffer .append(line);
//	        }
//	        rd.close();
//	        System.out.println("接受到的流是：" + stringBuffer + "—-" + status);
//	    } catch (Exception e) {
//	        throw new RuntimeException("error",e);
//
//	    }

//	    TestAPI api = new TestAPI();
//	    A a = api.new A();
//
//	    if (null != api.getA().getB().getStr()) {
//	        System.out.println("!!!!");
//	    }
//
//	    if (api.getA().getB().getStr() != null) {
//            System.out.println("!!!!");
//        }

    }

    /**
     * @return the a
     */
    public A getA() {
        return a;
    }


    class A {
        B b = null;

        /**
         * @return the b
         */
        public B getB() {
            return b;
        }


        class B {
            String str = null;


            /**
             * @return the str
             */
            public String getStr() {
                return str;
            }

        }

    }

}
