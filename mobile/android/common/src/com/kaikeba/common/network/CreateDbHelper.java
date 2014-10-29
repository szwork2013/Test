package com.kaikeba.common.network;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;
import com.kaikeba.common.api.API;
import com.kaikeba.common.conversion.JsonEngine;
import com.kaikeba.common.storage.UserInfo;

import java.io.File;
import java.lang.reflect.Type;

//import net.sqlcipher.Cursor;
//import net.sqlcipher.database.SQLiteDatabase;
//import net.sqlcipher.database.SQLiteException;
//import net.sqlcipher.database.SQLiteOpenHelper;

public class CreateDbHelper extends SQLiteOpenHelper {

    public static final String ID = "_id";
    //TODO Add in caching for Rank History
    public static final String CACHE_TABLE_NAME = "cache";
    public static final String CREDENTIALS_PASSWORD = "password";
    public static final String CREDENTIALS_USERNAME = "username";
    public static final String CACHE_USER_ACCOUNT = "userAccount";
    public static final String CACHE_KEY = "key";
    public static final String CACHE_JSON_STRING = "jsonString";
    public static final String CACHE_LAST_QUERY_TIME = "lastQueryTime";
    public static final String CACHE_LAST_UPDATE_TIME = "lastUpdateTime";
    public static final String CACHE_LAST_FAIL_TIME = "lastFailTime";
    public static final String CACHE_LAST_FAIL_REASON = "lastFailReason";
    private static final String CACHE_TABLE_CREATE =
            "CREATE TABLE " + CACHE_TABLE_NAME + " (" +
                    "_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    CACHE_USER_ACCOUNT + " TEXT, " +
                    CACHE_KEY + " TEXT, " +
                    CACHE_JSON_STRING + " TEXT, " +
                    CACHE_LAST_QUERY_TIME + " INTEGER, " +
                    CACHE_LAST_UPDATE_TIME + " INTEGER, " +
                    CACHE_LAST_FAIL_TIME + " INTEGER, " +
                    CACHE_LAST_FAIL_REASON + " TEXT )";
    //This number should be increased if you want the helper to call 'onUpgrade' the next
    //time it's initialized.  This allows you to handle db upgrades any way you want.
    //Currently we remove all data except credentials.
    private static final int DB_VERSION_NUMBER = 17;
    private static CreateDbHelper dbHelperSingleton;
    private static SQLiteDatabase dbSingleton;
    private static File mDatabaseFile;
    private static CreateDbHelper mInstance = null;
    private static Context mContext = null;

    private CreateDbHelper(Context context) {
        super(context, "kkb_cache", null, DB_VERSION_NUMBER);
    }

    public static void setContext(Context context) {
        mContext = context;
    }

    public static CreateDbHelper getInstance() {
        if (mInstance == null) {
            mInstance = new CreateDbHelper(mContext);
            mInstance.initDbConnection(mContext);
        }
        return mInstance;
    }

    private static void initDbConnection(Context application) {
        if (null == dbSingleton) {
            dbHelperSingleton = new CreateDbHelper(application);


            mDatabaseFile = application.getDatabasePath("kkb_cache.db");
            dbSingleton = openDatabase(mDatabaseFile);

            // add Cache Table
            if (!mInstance.hasCacheTable()) {
//                mInstance.delete(dbSingleton, true);
                dbSingleton.execSQL(CACHE_TABLE_CREATE);
            }
        }
    }

    private static SQLiteDatabase openNoExistDatabase(File dbFile) {
        if (null == dbFile) return null;

        if (dbFile.exists()) {
            dbFile.delete();
        }

        dbFile.mkdirs();
        dbFile.delete();

        try {
            SQLiteDatabase db = SQLiteDatabase.openOrCreateDatabase(dbFile, null);
            dbHelperSingleton.onCreate(db);
            return db;
        } catch (SQLiteException e) {
            dbFile.delete();
            Log.e("kkb", "openOrCreateDatabase failed");
            return null;
        }

    }

    private static SQLiteDatabase openDatabase(File dbFile) {
        if (null == dbFile) return null;

        if (!dbFile.exists()) {
            return openNoExistDatabase(dbFile);
        }

        try {
            SQLiteDatabase db = SQLiteDatabase.openOrCreateDatabase(dbFile, null);
            return db;
        } catch (SQLiteException e) {
            dbFile.delete();
            return openNoExistDatabase(dbFile);
        }
    }

    public static void clean() {
//    	SQLiteDatabase db = dbSingleton;
//    	delete(dbSingleton, false);
        //Try to create the tables if they don't exist
        try {
            dbHelperSingleton.onCreate(dbSingleton);
        } catch (SQLiteException e) {
            Log.i("App Annie", "Tolerable exception in cleanHelper init db connection e = " + e);
        } catch (NullPointerException e2) {
            Log.i("App Annie", "Null exception in cleanHelper init db connection e = " + e2);
            dbSingleton = null;
            dbHelperSingleton = null;
            return;
        }
    }

    private boolean hasCacheTable() {
        try {
            Cursor cursor = dbSingleton.rawQuery("SELECT count(*) FROM " + CreateDbHelper.CACHE_TABLE_NAME, null);
            cursor.close();
            return true;
        } catch (SQLiteException e) {
            return false;
        }
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CACHE_TABLE_CREATE);
    }

    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // This database is only a cache for online data, so its upgrade policy is
        // to simply to discard the data and start over
//    	delete(db, true);
        onCreate(db);
    }


    public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        onUpgrade(db, oldVersion, newVersion);
    }

    private ServerDataCache.Item cursorToItem(Cursor cursor, Type type) {
        ServerDataCache.Item item = new ServerDataCache.Item();
        item.type = type;

        try {
            String jsonString = cursor.getString(cursor.getColumnIndex(CACHE_JSON_STRING));
            item.object = JsonEngine.parseJson(jsonString, item.type);
            item.jsonLength = jsonString.length();
        } catch (Exception e) {
            e.printStackTrace();
        }
        item.lastQueryTime = cursor.getLong(cursor.getColumnIndex(CACHE_LAST_QUERY_TIME));
        item.lastUpdateTime = cursor.getLong(cursor.getColumnIndex(CACHE_LAST_UPDATE_TIME));
        item.lastFailTime = cursor.getLong(cursor.getColumnIndex(CACHE_LAST_FAIL_TIME));
        item.lastFailReason = cursor.getString(cursor.getColumnIndex(CACHE_LAST_FAIL_REASON));
        return item;
    }

    public ServerDataCache.Item cacheItem(String cacheKey, Type type) {
        Cursor cursor = null;
        if (API.getAPI().alreadySignin()) {
            cursor = dbSingleton.rawQuery("SELECT * FROM " + CreateDbHelper.CACHE_TABLE_NAME +
                    " WHERE " + CreateDbHelper.CACHE_USER_ACCOUNT + " = '" + API.getAPI().getUserObject().getId() + "' and "
                    + CreateDbHelper.CACHE_KEY + " = '" + cacheKey + "'", null);
        } else {
            cursor = dbSingleton.rawQuery("SELECT * FROM " + CreateDbHelper.CACHE_TABLE_NAME +
                    " WHERE " + CreateDbHelper.CACHE_USER_ACCOUNT + " = '" + "1000" + "' and "
                    + CreateDbHelper.CACHE_KEY + " = '" + cacheKey + "'", null);
        }

        ServerDataCache.Item item = null;
        if (cursor != null && cursor.moveToFirst()) {
            item = cursorToItem(cursor, type);
        }
        cursor.close();
        return item;
    }

//    public Map<String, ServerDataCache.Item> cacheLoad() {
//        Cursor cursor = dbSingleton.rawQuery("SELECT * FROM " + CreateDbHelper.CACHE_TABLE_NAME +
//                " WHERE " + CreateDbHelper.CACHE_USER_ACCOUNT +" = '" + UserInfo.getInstance().username + "'" , null);
//        Map<String, ServerDataCache.Item> cache = new HashMap<String, ServerDataCache.Item>();
//        while(cursor.moveToNext()){
//            cache.put(cursor.getString(cursor.getColumnIndex(CACHE_KEY)), cursorToItem(cursor));
//        }
//        cursor.close();
//        return cache;
//    }

    public int cacheClear() {
        return dbSingleton.delete(CACHE_TABLE_NAME,
                CreateDbHelper.CACHE_USER_ACCOUNT + " = ? ",
                new String[]{UserInfo.getInstance().username});
    }

    public int cacheDelete(String cacheKey) {
        return dbSingleton.delete(CACHE_TABLE_NAME,
                CreateDbHelper.CACHE_USER_ACCOUNT + " = ? AND " + CreateDbHelper.CACHE_KEY + " = ? ",
                new String[]{UserInfo.getInstance().username, cacheKey});

    }

    public void cacheInsert(String cacheKey, ServerDataCache.Item item) {
        if (cacheKey == null || item == null || item.object == null) return;

        cacheDelete(cacheKey);
        Log.v("kkb", "cache insert " + cacheKey);
        ContentValues values = new ContentValues();
        if (API.getAPI().alreadySignin()) {
            values.put(CACHE_USER_ACCOUNT, API.getAPI().getUserObject().getId());
        } else {
            values.put(CACHE_USER_ACCOUNT, "1000");
        }
        values.put(CACHE_KEY, cacheKey);
        values.put(CACHE_JSON_STRING, JsonEngine.toJson(item.object, item.type));
        dbSingleton.insert(CreateDbHelper.CACHE_TABLE_NAME, null, values);
    }

    public void insertCredentials(String username, String password) {
        ContentValues values = new ContentValues();
        values.put(CreateDbHelper.CREDENTIALS_USERNAME, username);
        values.put(CreateDbHelper.CREDENTIALS_PASSWORD, password);
//        dbSingleton.insert(CreateDbHelper.CREDENTIALS_TABLE, null, values);
    }
}