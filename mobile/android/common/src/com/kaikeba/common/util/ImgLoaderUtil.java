package com.kaikeba.common.util;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.os.Handler;
import android.util.Base64;

import java.io.*;
import java.lang.ref.SoftReference;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 图片加载器
 *
 * @author Allen
 */
public class ImgLoaderUtil {

    private final static String PATH = "mnt/sdcard/imageCache/";
    public static ExecutorService threadPool = Executors.newFixedThreadPool(5);
    private static volatile ImgLoaderUtil imgLoader = null;
    private Map<String, SoftReference<Bitmap>> imgCache = new LinkedHashMap<String, SoftReference<Bitmap>>();
    private ImageManagerutils manager = new ImageManagerutils();

    private ImgLoaderUtil() {

    }

    public static ImgLoaderUtil getLoader() {
        if (imgLoader == null) {
            synchronized (ImgLoaderUtil.class) {
                if (imgLoader == null) {
                    imgLoader = new ImgLoaderUtil();
                }
            }
        }
        return imgLoader;
    }

    /**
     * 将图片写入sdcard中
     *
     * @param bitmap
     * @param url
     * @throws Exception
     */
    public static final File writePic2SDCard(Bitmap bitmap, String url)
            throws Exception {
        File folder = new File(PATH);
        if (!folder.exists()) {
            folder.mkdir();
        }
        String filename = PATH + url;
        File file = new File(filename);
        if (!file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }

        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        FileOutputStream fos = null;
        ByteArrayInputStream bis = null;
        try {
            fos = new FileOutputStream(file);
            byte[] bitmapByte = bitmap2Byte(bitmap);
            bis = new ByteArrayInputStream(bitmapByte);
            int len = 0;
            byte[] b = new byte[bis.available()];
            while ((len = bis.read(b)) != -1) {
                fos.write(b, 0, len);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (null != bis) {
                bis.close();
            }
            if (null != fos) {
                fos.close();
            }
        }
        return file;
    }

    /**
     * bitMap 转化为数组
     *
     * @param bitmap
     * @return
     */
    public static final byte[] bitmap2Byte(Bitmap bitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
        return baos.toByteArray();
    }

    private static String base64String(String url) {
        return Base64.encodeToString(url.getBytes(), Base64.DEFAULT);
    }

    public Map<String, SoftReference<Bitmap>> getImgCache() {
        return imgCache;
    }

    public synchronized Bitmap loadImg(final String url,
                                       final ImgCallback callback, final Handler handler) {

        // 先从缓存中读取图片资源
        Bitmap bitmap = null;
        try {
            bitmap = manager.getImgFromCache(url);
            ;

            if (null == bitmap) {
                // 开启线程从网络上下载
                threadPool.submit(new Runnable() {
                    // submit方法确保下载是从线程池中的线程执行
                    @Override
                    public void run() {
                        final Bitmap bitmapFromUrl = manager
                                .getBitMapFromUrl(url);
                        try {
                            writePic2SDCard(bitmapFromUrl, url);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        handler.post(new Runnable() {

                            @Override
                            public void run() {
                                // TODO Auto-generated method stub
                                if (callback != null) {
                                    callback.refresh(bitmapFromUrl);
                                }
                            }
                        });
                    }
                });
            } else {
                //
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }

    public void removeImgFromCatche(String url) {
        if (imgCache.containsKey(base64String(url))) {
            Bitmap imageBit = imgCache.get(
                    Base64.encodeToString(url.getBytes(), Base64.DEFAULT))
                    .get();
            if (imageBit != null && !imageBit.isRecycled()) {
                imageBit.recycle();
                imgCache.remove(base64String(url));
                imageBit = null;
            }
        }
    }

    public interface ImgCallback {

        public void refresh(Bitmap bitmap);

    }

    class ImageManagerutils {

        /**
         * 从网络上下载
         *
         * @param url
         * @return
         */
        public Bitmap getBitMapFromUrl(String url) {
            Bitmap bitmap = null;
            URL u = null;
            HttpURLConnection conn = null;
            InputStream is = null;
            try {
                u = new URL(url);
                conn = (HttpURLConnection) u.openConnection();
                is = conn.getInputStream();
                bitmap = BitmapFactory.decodeStream(is);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return bitmap;
        }

		/*
         *
		 * 获得设置信息
		 */

        public Options getOptions(String path) {

            Options options = new Options();

            options.inJustDecodeBounds = true;// 只描边，不读取数据

            BitmapFactory.decodeFile(path, options);

            return options;

        }

        /**
         * 从文件中读取
         *
         * @return
         * @throws Exception
         */
        private Bitmap getBitMapFromSDCard(String url) throws Exception {
            Bitmap bitmap = null;
            File file = new File(PATH + base64String(url));
            if (!file.exists()) {
                return null;
            }
            Options opts = new Options();
            opts.inJustDecodeBounds = true;
            opts.inPreferredConfig = Bitmap.Config.RGB_565;
            InputStream fis = new FileInputStream(file);

            try {
                bitmap = BitmapFactory.decodeStream(fis);
            } catch (Exception e) {
                return null;
            }
            return bitmap;
        }

        public byte[] readStream(InputStream inStream) throws Exception {
            ByteArrayOutputStream outStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len = 0;
            while ((len = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, len);
            }
            outStream.close();
            inStream.close();
            return outStream.toByteArray();
        }

        /**
         * 从缓存中读取
         *
         * @param url
         * @return
         * @throws Exception
         */
        public Bitmap getImgFromCache(String url) throws Exception {
            Bitmap bitmap = null;
            // 从内存中读取
            if (imgCache.containsKey(base64String(url))) {
                synchronized (imgCache) {
                    SoftReference<Bitmap> bitmapReference = imgCache
                            .get(base64String(url));
                    if (null != bitmapReference) {
                        bitmap = bitmapReference.get();
                    }
                }
                // 否则从文件中读取
            } else if (null != (bitmap = getBitMapFromSDCard(url))) {
                // 将图片保存进内存中
                imgCache.put(base64String(url), new SoftReference<Bitmap>(
                        bitmap));
            }
            return bitmap;
        }

    }
}
