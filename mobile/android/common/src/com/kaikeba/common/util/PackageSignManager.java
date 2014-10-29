package com.kaikeba.common.util;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

/**
 * Created by mjliu on 14-9-11.
 */
public class PackageSignManager {

    public static boolean isReleaseSign(Context context) throws PackageManager.NameNotFoundException {
        long releaseSigHash = -708818263;//生产环境
        boolean developmentVerson = true;
        PackageManager pm = context.getPackageManager();
        List<PackageInfo> apps = pm
                .getInstalledPackages(PackageManager.GET_SIGNATURES);
        Iterator<PackageInfo> iter = apps.iterator();

        while (iter.hasNext()) {
            PackageInfo info = iter.next();
            String packageName = info.packageName;
            //按包名 取签名
            if (packageName.equals("com.kaikeba.phone")) {
                long sigHash = Arrays.hashCode(info.signatures[0].toByteArray());
                if (sigHash == releaseSigHash) {
                    developmentVerson = false;
                }
                Log.d("jack", "signatures::" + sigHash);
            }
        }
        return developmentVerson;
    }
}
