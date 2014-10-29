package com.kaikeba.common.util;

import com.kaikeba.ContextUtil;

import java.io.*;

public class ObjectSerializableUtil {

    /**
     * 将对象序列化到磁盘文件中
     *
     * @param
     * @throwsException
     */

    public static void writeObject(Object o, String path) throws Exception {
        if (o == null) {
            return;
        }
        String filePath = ContextUtil.getContext().getFilesDir().getPath();
        File f = new File(filePath + path);
        if (f.exists()) {
            f.delete();
        }
        FileOutputStream os = new FileOutputStream(f);
        //ObjectOutputStream 核心类
        ObjectOutputStream oos = new ObjectOutputStream(os);
        oos.writeObject(o);
        oos.close();
        os.close();
    }

    /**
     * 反序列化,将磁盘文件转化为对象
     *
     * @param
     * @return
     * @throwsException
     */

    public static Object readObject(String path) throws Exception {
        String filePath = ContextUtil.getContext().getFilesDir().getPath();
        File f = new File(filePath + path);
        InputStream is = new FileInputStream(f);
        // ObjectOutputStream 核心类
        ObjectInputStream ois = new ObjectInputStream(is);
        Object o = ois.readObject();
        ois.close();
        return o;

    }

}
