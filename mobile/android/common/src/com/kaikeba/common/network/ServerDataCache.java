package com.kaikeba.common.network;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import com.kaikeba.common.conversion.JsonEngine;
import org.apache.http.HttpException;

import java.lang.reflect.Type;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by caojing on 14-2-21.
 */
public class ServerDataCache {
    public static final int ERROR_OK = 0;
    public static final int ERROR_WRONG_CACHE_KEY = -1;
    public static final int ERROR_HTTP = -2;
    public static final int ERROR_JSON = -3;
    public static final int ERROR_UNKNOW = -4;
    public static final int ERROR_AUTH = -5;
    public static final int ERROR_CANCEL = -6;
    public static final String BAD_AUTH_ERROR_STR = "Received authentication challenge is null";
    public static final int MAX_CACHE_ITEM = 60;
    private static final String BASE_URL = "https://api.appannie.com";
    public static final String ACCOUNT_URL = BASE_URL + "/v1/accounts";
    private static final String ACCOUNT_SALES_URL = BASE_URL + "/v1/accounts/%d/sales";
    private static final String APPS_URL = BASE_URL + "/v1/accounts/%d/apps";
    private static final String SHARED_APPS_URL = BASE_URL + "/v1/sharing/apps";
    private static final String APP_SALES_URL = BASE_URL + "/v1/accounts/%d/apps/%s/sales";
    private static final String APP_REVIEWS_URL = BASE_URL + "/v1/accounts/%d/apps/%s/reviews";
    private static final String APP_RANK_HISTORY_URL = BASE_URL + "/v1/accounts/%d/apps/%s/ranks";
    private static final String APP_RATINGS_URL = BASE_URL + "/v1/accounts/%d/apps/%s/ratings";
    private static final String APP_IAPS_URL = BASE_URL + "/v1/accounts/%d/apps/%s/iaps";
    private static final String CURRENCY_URL = BASE_URL + "/v1/meta/currencies";
    private static final String USER_PREFERENCES_URL = BASE_URL + "/v1/user/preference";
    private static final String FEEDBACK_URL = BASE_URL + "/v1/feedback";
    private static final String APP_DETAILS_URL = BASE_URL + "/v1/accounts/%d/apps/%s/details";
    public static long MAX_CACHE_SIZE_IN_BYTES;

    private static ServerDataCache mInstance = null;
    public String currency = null;
    public Context mContext;
    private LinkedList<String> mCacheKeyLRU = new LinkedList<String>();
    private int mCacheSizeInBytes = 0;
    private Map<String, Item> mCache = new ConcurrentHashMap<String, Item>();
    private Map<String, Item> mNewCacheForDb = new ConcurrentHashMap<String, Item>();
    private Map<String, List<LoadDataCallbacks>> mPendingCallback = new HashMap<String, List<LoadDataCallbacks>>();
    private AuthenticationFailCallback mAuthenticationFailCallback = null;
    private HttpRequestCallback mHttpRequestCallback = null;
    private Map<String, HttpRequestTask> mHttpRequestTasks = new HashMap<String, HttpRequestTask>();
    private AsyncTask mPreloadTask = null;

    protected ServerDataCache() {
        // Exists only to defeat instantiation.
        MAX_CACHE_SIZE_IN_BYTES = Runtime.getRuntime().maxMemory() / 20;
    }

    protected static Object getObject(String jsonString, Type type) {
        try {
            return JsonEngine.parseJson(jsonString, type);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ServerDataCache getInstance() {
        if (mInstance == null) {
            mInstance = new ServerDataCache();
        }
        return mInstance;
    }

    protected Item getCacheItem(String cacheKey, Type type) {
        Item item = mCache.get(cacheKey);
        if (item == null) {
            item = CreateDbHelper.getInstance().cacheItem(cacheKey, type);
            if (item != null) {
                putCacheItem(cacheKey, item);
            }
        }

        return item;
    }

    protected void putCacheItem(String cacheKey, Item item) {
        mCacheKeyLRU.addFirst(cacheKey);
        mCache.put(cacheKey, item);
        mCacheSizeInBytes += item.jsonLength;
    }

    public void clearCacheItem() {
        mCache.clear();
    }

    private synchronized void putNewCacheItem(String cacheKey, Item item) {
        mNewCacheForDb.put(cacheKey, item);
    }

    public synchronized void saveCache() {

        Log.v("AppAnnie", "Performance : cache saveCache begin");
        for (Map.Entry entry : mNewCacheForDb.entrySet()) {
            CreateDbHelper.getInstance().cacheInsert((String) entry.getKey(), (Item) entry.getValue());
        }
        mNewCacheForDb.clear();
        Log.v("AppAnnie", "Performance : cache saveCache end");
    }

    public void setHttpRequestCallback(HttpRequestCallback callback) {
        mHttpRequestCallback = callback;
    }

    public void setAuthenticationFailCallback(AuthenticationFailCallback callback) {
        mAuthenticationFailCallback = callback;
    }

    private String generateCacheKey(String url, Map<String, String> params) {
        if (params == null) {
            return url;
        }
        addCurrencyToParams(params);

        if (url != null) {
            SortedSet<String> keys = new TreeSet<String>(params.keySet());

            String newUrl = url + "?";
            for (String key : keys) {
                newUrl += key + "=" + params.get(key) + "&";
            }
            return newUrl;
        }
        return null;
    }

    private void callAndClearPendingCallbacks(String cacheKey, Object object, int errorCode) {
        HttpRequestTask httpRequestTask = mHttpRequestTasks.get(cacheKey);
        if (httpRequestTask != null) {
            httpRequestTask.cancel(true);
            mHttpRequestTasks.remove(cacheKey);
        }
        List<LoadDataCallbacks> pendingCallbacks = mPendingCallback.get(cacheKey);
        mPendingCallback.remove(cacheKey);
        if (pendingCallbacks == null) {
            return;
        }
        for (LoadDataCallbacks cb : pendingCallbacks) {
            if (errorCode == 0) {
                saveCache();
            }
            cb.onFinish(object, false, true, errorCode);
        }

    }

    public Object dataInCache(String cacheKey, Type type) {
        // Log.v("AppAnnie", "Performance : " + toString());
        // Log.v("AppAnnie", "Performance : Trying to Get Data In Cache; cacheKey = " + cacheKey);
        if (cacheKey == null) return null;

        Item item = getCacheItem(cacheKey, type);
        if (item == null) return null;

        item.lastQueryTime = System.currentTimeMillis() / 1000;
        return item.object;
    }

    private Map<String, String> addCurrencyToParams(Map<String, String> params) {
        if (params == null || currency == null || currency == "") return params;
        if (params.get("currency") == null) {
            params.put("currency", currency);
        }
        return params;
    }

//    public void preloadCache(boolean isForceLoad, final List<App> favoriteApps,
//                             final String currency) {
//        // if (true) return;
//        if (mPreloadTask != null) {
//            if (!isForceLoad) return;
//
////            mPreloadTask.cancel(true);
////            mPreloadTask = null;
//            return;
//        }
//         mPreloadTask = new AsyncTask<Void, Void, Void>() {
//             Thread currentThread;
//             private boolean waitAtCurrentThread() {
//                 try {
//                     Thread.sleep(600000);
//                     Log.e("AppAnnie", "Waiting is stopped by timeout");
//                     return false;
//                 } catch (InterruptedException e) {
//                     Log.v("AppAnnie", "Waiting is stopped normally");
//                 }
//                 return true;
//             }
//
//             private void waitOtherPendingTask() {
//                 while (mPendingCallback.size() > 0) {
//                     try {
//                         Thread.sleep(1000);
//                     } catch (InterruptedException e) {
//                         e.printStackTrace();
//                     }
//                 }
//             }
//
//             private boolean isFinishTask(boolean isCallbackPending) {
//                 if (isCallbackPending) {
//                     if (!waitAtCurrentThread()) return true;
//                 }
//
//                 if (MemoryUtils.isLowMemory()) return true;
//
//                 if (isCancelled()) return true;
//                 waitOtherPendingTask();
//                 if (mCacheKeyLRU.size() == MAX_CACHE_ITEM) return true;
//                 return false;
//             }
//             private void interruptTask(boolean isCallbackPending) {
//                 if (isCallbackPending && currentThread != null) {
//                     currentThread.interrupt();
//                 }
//             }
//             @Override
//             protected Void doInBackground(Void... params) {
//                 Log.v("AppAnnie", "Performance : cache preload begin");
//                 currentThread = Thread.currentThread();
//
//                 waitOtherPendingTask();
//                 //
//                 boolean isCallbackPending;
//                 isCallbackPending = getSharedAppList(false, new LoadDataCallbacks() {
//                     @Override
//                     public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                         interruptTask(isCallbackPending);
//                     }
//                 });
//
//                 if(isFinishTask(isCallbackPending)) return null;
//
//                 //
//                 isCallbackPending = getAccoutsList(false, new LoadDataCallbacks() {
//                     @Override
//                     public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                         interruptTask(isCallbackPending);
//                     }
//                 });
//
//                 if(isFinishTask(isCallbackPending)) return null;
//
//                 // load faves in 30 days
//                 for (App app : favoriteApps) {
//                     Map<String, String> paramsForAppSales = SalesActivity.getParamsOfAppSales("all",
//                             AbsOverflowMenuActivity.THIRTY_DAYS_SELECT_TYPE, app.getLastSalesDate());
//                     isCallbackPending = getAppSales(app.getAccountId(), app.getAppIdStr(), paramsForAppSales, false, new LoadDataCallbacks() {
//                         @Override
//                         public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                             interruptTask(isCallbackPending);
//                         }
//                     });
//
//                     if(isFinishTask(isCallbackPending)) return null;
//
//                     isCallbackPending = getAppIaps(app.getAccountId(), app.getAppIdStr(), false, new LoadDataCallbacks() {
//                         @Override
//                         public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                             interruptTask(isCallbackPending);
//                         }
//                     });
//
//                     if(isFinishTask(isCallbackPending)) return null;
//
//                 }
//
//                 // dashboards all time, all countries
//                 List<Account> accountList = Json2ObjectHelper.getAccountList(getAccountList());
//                 for (Account account : accountList) {
//
//                     isCallbackPending = ServerDataCache.getInstance().getAppList(account.getAccountId(), false, new LoadDataCallbacks() {
//                         @Override
//                         public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                             interruptTask(isCallbackPending);
//                         }
//                     });
//
//                     if(isFinishTask(isCallbackPending)) return null;
//
//                     Map<String, String> requestParams = new HashMap<String, String>();
//                     requestParams.put("break_down", "date");
//                     requestParams.put("end_date", account.getLastSalesDate());
//                     isCallbackPending = ServerDataCache.getInstance().getAccountSales(account.getAccountId(), requestParams, false, new LoadDataCallbacks() {
//                         @Override
//                         public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                             interruptTask(isCallbackPending);
//                         }
//                     });
//
//                     if(isFinishTask(isCallbackPending)) return null;
//                 }
//
//                 // shared app
//                 List<App> sharedApps = Json2ObjectHelper.getSharedAppList(ServerDataCache.getInstance().getSharedAppList());
//                 for (App app : sharedApps) {
//
//                     isCallbackPending = ServerDataCache.getInstance().getAppIaps(app.getAccountId(), app.getAppIdStr(), false,
//                             new LoadDataCallbacks() {
//                                 @Override
//                                 public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                                     interruptTask(isCallbackPending);
//                                 }
//                             });
//                     if(isFinishTask(isCallbackPending)) return null;
//
//                     Map<String, String> requestParams = SalesActivity.getParamsOfAppSales("all",
//                             AbsOverflowMenuActivity.ALL_SELECT_TYPE, app.getLastSalesDate());
//                     isCallbackPending = ServerDataCache.getInstance().getAppSales(app.getAccountId(), app.getAppIdStr(), requestParams, false,
//                             new LoadDataCallbacks() {
//                                 @Override
//                                 public void onFinish(JSONObject data, boolean isCacheHit, boolean isCallbackPending, int errorCode) {
//                                     interruptTask(isCallbackPending);
//                                 }
//                             });
//                     if(isFinishTask(isCallbackPending)) return null;
//                 }
//
//                 Log.v("AppAnnie", "Performance : cache preload end");
//                 return null;
//             }
//
//             @Override
//             protected void onPostExecute(Void result) {
//                 mPreloadTask = null;
//             }
//          }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
//    }

    /*
     * Return: pending status. True: callback is pending; False: callback is not pending
     */
    public boolean dataWithURL(String url, Map<String, String> params, boolean fromCache, Type type, LoadDataCallbacks callback) {
        String cacheKey = generateCacheKey(url, params);

        if (callback == null) {
            return false;
        }

        if (cacheKey == null) {
            callback.onFinish(null, false, false, ERROR_WRONG_CACHE_KEY);
            return false;
        }

        if (fromCache) {
            Object object = dataInCache(cacheKey, type);
            if (object != null) {
                callback.onFinish(object, true, false, ERROR_OK);
                return false;
            }
        }

        // fetch data from server,
        List<LoadDataCallbacks> callbacks = mPendingCallback.get(cacheKey);
        if (callbacks != null) {
            callbacks.add(callback);
            return true;
        } else {
            callbacks = new ArrayList<LoadDataCallbacks>(1);
            callbacks.add(callback);
            mPendingCallback.put(cacheKey, callbacks);

            HttpRequestTask httpRequestTask = new HttpRequestTask(cacheKey, url, params, type);
            httpRequestTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
            mHttpRequestTasks.put(cacheKey, httpRequestTask);
            return true;
        }
    }

    public void loginOut401(AuthenticationFailCallback mAuthenticationFailCallback) {
        this.mAuthenticationFailCallback = mAuthenticationFailCallback;
    }

    public interface HttpRequestCallback {
        String get(String url, Map<String, String> params) throws HttpException;
    }

    public interface LoadDataCallbacks {
        public void onFinish(Object data, boolean isCacheHit, boolean isCallbackPending, int errorCode);
    }

    public interface AuthenticationFailCallback {
        public void onAuthenticationFail();
    }

    public interface CheckFreshDataCallback {
        public void onCheckFinished(boolean hasFreshData);
    }

    public static class Item {
        public Object object;
        public Type type;
        public long jsonLength;
        public long lastQueryTime;
        public long lastUpdateTime;
        public long lastFailTime;
        public String lastFailReason;
//        public boolean isInsertIntoDb = false;
    }

    class HttpRequestTask extends AsyncTask<Void, Void, Void> {

        String mCacheKey;
        String mURL;
        Map<String, String> mParams;
        Object objects;
        Type mType;

        int mErrorCode;
        Object mData;

        HttpRequestTask(String cacheKey, String url, Map<String, String> params, Type type) {
            mCacheKey = cacheKey;
            mURL = url;
            mParams = params;
            mType = type;
        }

        @Override
        protected Void doInBackground(Void... p) {
            Item item = getCacheItem(mCacheKey, mType);
            if (item == null) {
                item = new Item();
                item.type = mType;
            }
            mErrorCode = ERROR_UNKNOW;
            mData = null;

            try {
                String jsonString;
                if (mHttpRequestCallback == null) {
                    jsonString = HttpRequestHelper.get(mURL, mParams);
                } else {
                    jsonString = mHttpRequestCallback.get(mURL, mParams);
                }
                item.lastUpdateTime = System.currentTimeMillis() / 1000;

                try {
                    Object object = getObject(jsonString, item.type);
//                    JSONObject object = new JSONObject(jsonString);
                    mData = object;
                    item.object = object;
                    item.jsonLength = jsonString.length();
                    putCacheItem(mCacheKey, item);
                    putNewCacheItem(mCacheKey, item);
                    mErrorCode = ERROR_OK;
                } catch (Exception e) {
                    e.printStackTrace();

                    mErrorCode = ERROR_JSON;
                }
            } catch (HttpException e) {
                e.printStackTrace();
                item.lastFailTime = System.currentTimeMillis() / 1000;
                item.lastFailReason = e.getMessage();
                if (BAD_AUTH_ERROR_STR.equals(e.getCause().getMessage())) {
                    mErrorCode = ERROR_AUTH;
                } else {
                    mErrorCode = ERROR_HTTP;
                }
            }

            return null;
        }

        protected void onPostExecute(Void result) {
            if (isCancelled()) return;

            // Execute in UI Thread
            if (mErrorCode == ERROR_AUTH) {
                if (mAuthenticationFailCallback != null) {
                    mAuthenticationFailCallback.onAuthenticationFail();
                }
            }
            callAndClearPendingCallbacks(mCacheKey, mData, mErrorCode);
        }

    }


}
