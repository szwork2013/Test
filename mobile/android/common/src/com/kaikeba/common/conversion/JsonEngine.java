package com.kaikeba.common.conversion;

import android.util.Log;
import com.google.gson.*;
import com.kaikeba.common.util.DateUtils;

import java.lang.reflect.Type;
import java.text.ParseException;
import java.util.Date;


public class JsonEngine {

    public static Object parseJson(String json,
                                   Class clazz) {
        Gson gson = new GsonBuilder()
                //.registerTypeAdapter(TinyUser.class, new User.Deserializer())
                .setPrettyPrinting()
                .registerTypeAdapter(Date.class, new JsonDeserializer<Date>() {

                    @Override
                    public Date deserialize(final JsonElement json, final Type typeOfT,
                                            JsonDeserializationContext context) throws JsonParseException {
                        try {
                            return DateUtils.parseDate(json.getAsString());
                        } catch (ParseException e) {
                            e.printStackTrace();
                            return null;
                        }
                    }
                })
                .create();
        return gson.fromJson(json, clazz);
    }

    public static String toJson(Object object, Type typeOfT) {
        Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .registerTypeAdapter(Date.class, new JsonDeserializer<Date>() {

                    @Override
                    public Date deserialize(final JsonElement json, final Type typeOfT,
                                            JsonDeserializationContext context) throws JsonParseException {
                        try {
                            return DateUtils.parseDate(json.getAsString());
                        } catch (ParseException e) {
                            e.printStackTrace();
                            return null;
                        }
                    }
                })
                .create();

        String jsonString = null;
        try {
            jsonString = gson.toJson(object, typeOfT);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return jsonString;

    }

    public static Object parseJson(String json, Type typeOfT) {
        Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .registerTypeAdapter(Date.class, new JsonDeserializer<Date>() {

                    @Override
                    public Date deserialize(final JsonElement json, final Type typeOfT,
                                            JsonDeserializationContext context) throws JsonParseException {
                        try {
                            return DateUtils.parseDate(json.getAsString());
                        } catch (ParseException e) {
                            e.printStackTrace();
                            return null;
                        }
                    }
                })
                .create();

//        json = "";
//        typeOfT = new TypeToken<CategoryCourseInfo>() {}.getType();
//        typeOfT = new TypeToken<ArrayList<CategoryCourseInfo>>() {}.getType();
        Object obj = null;
        try {
            obj = gson.fromJson(json, typeOfT);
//            Log.d("jack",obj.toString());
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("JSON", json);
        }
        return obj;
    }

    public static String generateJson(Object obj) {
        Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();
        return gson.toJson(obj);
    }
}
