package com.kaikeba.common.conversion;

//import java.sql.Timestamp;
//import java.util.ArrayList;
//import java.util.List;
//
//import org.apache.commons.logging.Log;
//import org.json.JSONArray;

import org.json.JSONException;
import org.json.JSONObject;
//
//import com.digimobistudio.dibits2.client.entity.event.TinyEvent;
//import com.digimobistudio.dibits2.client.entity.location.Location;
//import com.digimobistudio.dibits2.client.entity.post.NewsFriendsPost;
//import com.digimobistudio.dibits2.client.entity.post.PostForHotPhotoWall;
//import com.digimobistudio.dibits2.client.entity.post.PostWithReply;
//import com.digimobistudio.dibits2.client.entity.post.reply.Reply;
//import com.digimobistudio.dibits2.client.entity.thing.TinyThing;
//import com.digimobistudio.dibits2.client.entity.user.FollowUser;
//import com.digimobistudio.dibits2.client.entity.user.MiniUser;
//import com.digimobistudio.dibits2.client.entity.user.TinyUser;
//import com.google.gson.JsonArray;

public class JsonParser {

    public static Object parseOneObject(String json, String name) {
        try {
            JSONObject jsonObj = new JSONObject(json);
            return jsonObj.get(name);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

//	public static ArrayList<PostForHotPhotoWall> parsePostHotWall(String json) {
//		try {
//			JSONArray array = new JSONArray(json);
//			int length = array.length();
//			ArrayList<PostForHotPhotoWall> list = new ArrayList<PostForHotPhotoWall>(
//					length);
//			for (int i = 0; i < length; i++) {
//				JSONObject object = (JSONObject) array.get(i);
//				String photoURL = object.getString("photoURL");
//				Integer dibitsID = object.getInt("dibitsID");
//				String updated = object.getString("updated");
//				String published = object.getString("published");
//				String type = object.getString("type");
//				PostForHotPhotoWall onePhotoWallPost = new PostForHotPhotoWall(
//						photoURL, dibitsID, Timestamp.valueOf(updated),
//						Timestamp.valueOf(published), Short.parseShort(type));
//				list.add(onePhotoWallPost);
//			}
//			return list;
//		} catch (JSONException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//		return null;
//	}
//
//	public static ArrayList<NewsFriendsPost> parseFriendsPost(String result) {
//		try {
//			JSONArray jsonArray = new JSONArray(result);
//			int length = jsonArray.length();
//			ArrayList<NewsFriendsPost> list = new ArrayList<NewsFriendsPost>(
//					length);
//			for (int i = 0; i < length; i++) {
//				try {
//					JSONObject object = jsonArray.getJSONObject(i);
//					NewsFriendsPost post = new NewsFriendsPost();
//					Integer dibitsId = object.getInt("dibitsID");
//					Short type = (short) object.getInt("type");
//					String content = null;
//					if (object.has("content")) {
//						content = object.getString("content");
//						post.setContent(content);
//					}
//					String photoURL = object.getString("photoURL");
//
//					Integer photoWidth = object.getInt("photoWidth");
//					Integer photoHight = null;
//					if (object.has("photoHeight")) {
//						photoHight = object.getInt("photoHeight");
//						post.setPhotoHeight(photoHight);
//					}
//					Integer reLikeCount = object.getInt("reLikeCount");
//					Integer reHateCount = object.getInt("reHateCount");
//					Integer reHaveCount = object.getInt("reHaveCount");
//					Integer reWantCount = object.getInt("reWantCount");
//					Integer replyCount = object.getInt("replyCount");
//					String location = null;
//					if (object.has("location")) {
//						location = object.getString("location");
//						post.setLocation(location);
//					}
//					String published = object.getString("published");
//					String updated = object.getString("updated");
//
//					// publisher
//					JSONObject publisherObject = object
//							.getJSONObject("publisher");
//					Integer publisherId = publisherObject.getInt("userID");
//					String publisherName = publisherObject.getString("userName");
//					String publisherIconString = publisherObject
//							.getString("photoURL");
//					MiniUser publisher = new MiniUser(publisherId, publisherName,
//							publisherIconString);
//
//					// thing
//					JSONObject thingObject = object.getJSONObject("thing");
//					Integer thingId = thingObject.getInt("thingID");
//					String thingName = thingObject.getString("thingName");
//					TinyThing thing = new TinyThing(thingId, thingName);
//
//					// event
//					TinyEvent event = null;
//					if (object.has("event")) {
//						JSONObject eventObject = object.getJSONObject("event");
//						Integer eventID = eventObject.getInt("eventID");
//						String eventName = eventObject.getString("eventName");
//						event = new TinyEvent(eventID, eventName);
//						post.setEvent(event);
//					}
//
//					// reply
//					JSONArray replyArray = object.getJSONArray("replyOverview");
//					int replyArrayLength = replyArray.length();
//					ArrayList<Reply> replyList = new ArrayList<Reply>(
//							replyArrayLength);
//					for (int j = 0; j < replyArrayLength; j++) {
//						JSONObject replyObject = replyArray.getJSONObject(j);
//						JSONObject replyUserObject = replyObject
//								.getJSONObject("user");
//						Integer replyUserId = replyUserObject.getInt("userID");
//						String replyUseName = replyUserObject.getString("userName");
//						String replyPhotoUrl = replyUserObject
//								.getString("photoURL");
//						TinyUser replyUser = new TinyUser(replyUserId,
//								replyUseName, replyPhotoUrl);
//
//						String replyContent = replyObject.getString("content");
//						String replypublished = replyObject.getString("published");
//						Reply reply = new Reply(null, replyUser, replyContent,
//								null, Timestamp.valueOf(replypublished));
//						replyList.add(reply);
//					}
//					post.setDibitsID(dibitsId);
//					post.setType(type);
//
//					post.setPhotoURL(photoURL);
//
//					post.setPhotoWidth(photoWidth);
//					post.setReHate(reHateCount);
//					post.setReHave(reHaveCount);
//					post.setReLike(reLikeCount);
//					post.setReWant(reWantCount);
//					post.setReplyCount(replyCount);
//
//					post.setPublished(Timestamp.valueOf(published));
//					post.setUpdated(Timestamp.valueOf(updated));
//					post.setPublisher(publisher);
//					post.setThing(thing);
//					post.setReplyOverview(replyList);
//
//					list.add(post);
//				} catch (Throwable e) {
//					e.printStackTrace();
//				}
//			}
//			return list;
//
//		} catch (JSONException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//		return null;
//	}
//
//	/*
//	 * {"haveCount":50,"userID":11,"following":true, "likeCount":8,
//	 * "photoURL":"http://172.16.95.241/v2.0/user/middle/b-2.jpg",
//	 * "hateCount":0,"wantCount":9,"gender":0,"userName":"宋廷蓼",
//	 * "published":"2012-04-28 19:09:38.0","follow_me":true}
//	 */
//	public static ArrayList<FollowUser> parseFollowUsers(String json) {
//		try {
//
//			JSONArray array = new JSONArray(json);
//			int size = array.length();
//			System.out.println("FollowUser list size= " + size);
//			ArrayList<FollowUser> list = new ArrayList<FollowUser>(size);
//			for (int i = 0; i < size; i++) {
//
//				JSONObject object = array.getJSONObject(i);
//				Integer haveCount = object.getInt("haveCount");
//				Integer id = object.getInt("userID");
//
//				String following = object.getString("following");
//				Integer likeCount = object.getInt("likeCount");
//				String photoUrl = object.getString("photoURL");
//				Integer hateCount = object.getInt("hateCount");
//				Integer wantCount = object.getInt("wantCount");
//				Integer gender = object.getInt("gender");
//				String userName = object.getString("userName");
//				String published = object.getString("published");
//				String follow_me = object.getString("follow_me");
//				FollowUser followUser = new FollowUser(haveCount, id,
//						following, likeCount, photoUrl, hateCount, wantCount,
//						gender, userName, published, follow_me);
//				list.add(followUser);
//			}
//			System.out.println("FollowUser list == " + list);
//			return list;
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return null;
//	}
//
//	/*
//	 * {"lon":116.348678553941, "category":702, "address":"北京海淀区知春路6号",
//	 * "name":"锦秋国际大厦","lat":39.9758721296206}
//	 */
//	public static ArrayList<Location> parseLocation(String json) {
//		try {
//			JSONArray array = new JSONArray(json);
//			int size = array.length();
//			System.out.println("FollowUser list size= " + size);
//			ArrayList<Location> list = new ArrayList<Location>(size);
//			for (int i = 0; i < size; i++) {
//
//				JSONObject object = array.getJSONObject(i);
//				Double lon = object.getDouble("lon");
//				Double lat = object.getDouble("lat");
//				String category = object.getString("category");
//				String address = object.getString("address");
//				String name = object.getString("name");
//				Location location = new Location(lon,lat,category,address,name);
//				list.add(location);
//			}
//			return list;
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return null;
//	}
}