package com.kaikeba.activity.phoneutil;

import android.os.Handler;
import com.kaikeba.common.api.API;
import com.kaikeba.common.api.CollectionAPI;
import com.kaikeba.common.entity.CourseModel;
import com.kaikeba.common.exception.DibitsExceptionC;


/**
 * Created by mjliu on 14-8-11.
 */
public class CollectManager {

    private static CollectManager instance;

    private CollectManager() {

    }

    public static CollectManager getInstance() {
        if (instance == null) {
            instance = new CollectManager();
        }
        return instance;
    }

    public void collect(boolean isCollectflag, Handler handler, CourseModel c) throws DibitsExceptionC {

        String userId = API.getAPI().getUserObject().getId() + "";
        if (isCollectflag) {
            CollectionAPI.deleteCollection(userId, c.getId() + "");
            handler.sendEmptyMessage(6);
        } else {
            CollectionAPI.addCollection(userId, c.getId() + "");
            handler.sendEmptyMessage(7);
        }
    }
}
