package com.kaikeba.common.api;

import com.google.gson.reflect.TypeToken;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.entity.Item;
import com.kaikeba.common.entity.Module;
import com.kaikeba.common.entity.ModuleVideo;
import com.kaikeba.common.exception.DEC;
import com.kaikeba.common.exception.DibitsExceptionC;
import com.kaikeba.common.util.ConfigLoader;
import com.kaikeba.common.util.Constants;
import com.kaikeba.common.util.DibitsHttpClient;
import com.kaikeba.common.util.ObjectSerializableUtil;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;


public class ModulesAPI extends API {

    /**
     * 获取指定课程的单元Modules
     *
     * @param courseID
     * @return
     * @throws DibitsExceptionC
     */
    private final static ArrayList<Module> getModules(String courseID, String token) throws DibitsExceptionC {
        ArrayList<Module> pList = null;
        if (!Constants.NET_IS_SUCCESS) {
            try {
                pList = (ArrayList<Module>) ObjectSerializableUtil.readObject(courseID + Constants.MODULE);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        if (pList != null) {
            return pList;
        }
        String url = buildModulesURL(courseID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, token);
        if (json != null) {
            json.trim();
        }
        Type type = new TypeToken<ArrayList<Module>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Module> modules = (ArrayList<Module>) JsonEngine.parseJson(json, type);
        try {
            ObjectSerializableUtil.writeObject(modules, courseID + Constants.MODULE);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return modules;
    }

    /**
     * 获取指定课程的单元Modules，用于首页（课程简介的浮层中）
     *
     * @param courseID
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Module> getModulesInPublic(String courseID) throws DibitsExceptionC {
        return getModules(courseID, ConfigLoader.getLoader().getCanvas().getAccessToken());
    }

    /**
     * 获取指定课程的单元Modules，用于用户进入自己的课程之后，有更多的与用户相关的信息
     *
     * @param courseID
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Module> getModulesInMine(String courseID) throws DibitsExceptionC {
        if (API.getAPI().getUserObject().getAccessToken() == null) {
            throw new DibitsExceptionC(DEC.Business.COURSE_ID, "user's token is null");
        } else {
            return getModules(courseID, API.getAPI().getUserObject().getAccessToken());
        }
    }

    /**
     * 获取指定课程的指定单元的条目Items
     *
     * @param courseID
     * @param moduleID
     * @return
     * @throws DibitsExceptionC
     */
    private final static ArrayList<Item> getModuleItmes(String courseID, String moduleID, String token) throws DibitsExceptionC {
        ArrayList<Item> pList = null;
        if (!Constants.NET_IS_SUCCESS) {
            try {
                pList = (ArrayList<Item>) ObjectSerializableUtil.readObject(courseID + moduleID + Constants.MODULE_ITEM);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        if (pList != null) {
            return pList;
        }
        String url = buildModuleItemsURL(courseID, moduleID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, token);
        Type type = new TypeToken<ArrayList<Item>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<Item> items = (ArrayList<Item>) JsonEngine.parseJson(json, type);
        try {
            ObjectSerializableUtil.writeObject(items, courseID + moduleID + Constants.MODULE_ITEM);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return items;
    }

    public final static List<ModuleVideo> getModuleVideos(String courseID, String token) throws DibitsExceptionC {
        List<ModuleVideo> pList = null;
        if (!Constants.NET_IS_SUCCESS) {
            try {
                pList = (List<ModuleVideo>) ObjectSerializableUtil.readObject(courseID + Constants.ModuleVideo);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        if (pList != null) {
            return pList;
        }
        String url = buildModuleVideosURL(courseID);
        System.out.println("GET: " + url);
        String json = DibitsHttpClient.doGet4Token(url, token);
        int index = json.indexOf("[");
        json = json.substring(index);
        Type type = new TypeToken<ArrayList<ModuleVideo>>() {
        }.getType();
        @SuppressWarnings("unchecked")
        ArrayList<ModuleVideo> items = (ArrayList<ModuleVideo>) JsonEngine.parseJson(json, type);

        if (items == null) {
            items = new ArrayList<ModuleVideo>();
        }

        try {
            ObjectSerializableUtil.writeObject(items, courseID + Constants.ModuleVideo);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return items;
    }

    public final static String buildModuleVideosURL(String courseID) {
        return "http://superclass.kaikeba.com/ocw/srv/api.php?num=666&courseid=" + courseID;
    }

    /**
     * 获取指定课程的指定单元的条目Items，用于首页（课程简介的浮层中）
     *
     * @param courseID
     * @param moduleID
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Item> getModuleItmesInPublic(String courseID, String moduleID) throws DibitsExceptionC {
        return getModuleItmes(courseID, moduleID, ConfigLoader.getLoader().getCanvas().getAccessToken());
    }

    /**
     * 获取指定课程的指定单元的条目Items，用于用户进入自己的课程之后，有更多的与用户相关的信息
     *
     * @param courseID
     * @param moduleID
     * @return
     * @throws DibitsExceptionC
     */
    public final static ArrayList<Item> getModuleItmesInMine(String courseID, String moduleID) throws DibitsExceptionC {
        return getModuleItmes(courseID, moduleID, API.getAPI().getUserObject().getAccessToken());
    }


    //=======================↓↓ build URL ↓↓=======================

    public final static String buildModulesURL(String courseID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseID)
                .append(SLASH_MODULES)
                .append(PAGINATION);
        return url.toString();
    }

    public final static String buildModuleItemsURL(String courseID, String moduleID) {
        StringBuilder url = new StringBuilder();
        url.append(HOST).append(SLASH_COURSES).append(SLASH).append(courseID)
                .append(SLASH_MODULES).append(SLASH).append(moduleID).append(SLASH_ITEMS)
                .append(PAGINATION);
        return url.toString();
    }


    public static void main(String[] args) throws DibitsExceptionC {

        API.getAPI().getUserObject().setAccessToken(ConfigLoader.getLoader().getCanvas().getTestToken());
        ArrayList<Module> modules = ModulesAPI.getModulesInPublic(String.valueOf(10));
        for (Module module : modules) {
            System.out.println("=======================================");
            System.out.println(module.getId());
            System.out.println(module.getWorkflowState());
            System.out.println(module.getPosition());
            System.out.println(module.getName());
            System.out.println(module.getUnlockAt());
            System.out.println(module.getRequireSequentialProgress());
            System.out.println("prerequisiteModuleIds:");
            ArrayList<Integer> ids = module.getPrerequisiteModuleIds();
            for (Integer id : ids) {
                System.out.println("\t" + id);
            }
            System.out.println(module.getState());
            System.out.println(module.getCompletedAt());
            System.out.println();
            System.out.println();
        }

        System.out.println();
        System.out.println();
        System.out.println("================================================================================================================");
        System.out.println("================================================================================================================");
        System.out.println("================================================================================================================");
        System.out.println();

        API.getAPI().getUserObject().setAccessToken(ConfigLoader.getLoader().getCanvas().getTestToken());
        ArrayList<Item> items = ModulesAPI.getModuleItmesInPublic(String.valueOf(8), String.valueOf(10));
        for (Item item : items) {
            System.out.println("=======================================");
            System.out.println(item.getId());
            System.out.println(item.getPosition());
            System.out.println(item.getTitle());
            System.out.println(item.getIndent());
            System.out.println(item.getType());
            System.out.println(item.getHtmlUrl() + "+++++++++++++++++++");
            System.out.println(item.getUrl());
            Item.CompletionRequirement completionRequirement = item.getCompletionRequirement();
            if (completionRequirement != null) {
                System.out.println("completionRequirement:");
                System.out.println("\t" + completionRequirement.getType());
                System.out.println("\t" + completionRequirement.getMinScore());
                System.out.println("\t" + completionRequirement.getCompleted());
            } else {
                System.out.println("completionRequirement: null");
            }
            System.out.println();
            System.out.println();
        }


    }

}
