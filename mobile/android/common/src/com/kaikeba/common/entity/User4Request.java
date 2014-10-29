package com.kaikeba.common.entity;


import com.kaikeba.common.api.API;

public class User4Request {

    private User user;

    //    private Pseudonym pseudonym;
//
    public User4Request(String username, String email, String password, String confirmed_at, String from) {
        this.user = new User(username, email, password, confirmed_at, from);
//        this.pseudonym = new Pseudonym(email, password);
    }

    //
    public User4Request(String nickName, String avatarURL) {
        this.user = new User(nickName, avatarURL);
    }

    //    public class Pseudonym {
//        private String  unique_id;
//        private String  password;
//        private Integer send_confirmation;
//
//        public Pseudonym(String email, String password) {
//            this.unique_id = email;
//            this.password = password;
//            this.send_confirmation = API.SEND_CONFIR;
//        }
//
//		public String getUnique_id() {
//			return unique_id;
//		}
//
//		public String getPassword() {
//			return password;
//		}
//
//		public Integer getSend_confirmation() {
//			return send_confirmation;
//		}
//
//
//    }
//
//
    public User getUser() {
        return user;
    }

    public static class User {
        private String name;
        private String username;
        private String email;
        private String password;
        private String from;
        private String confirmed_at;
        private String short_name;
        private String sortable_name;
        private String time_zone;
        private String locale;
        private Avatar avatar;


        public User(String username, String email, String password, String confirmed_at, String from) {
            this.username = username;
            this.email = email;
            this.password = password;
            this.from = from;
            this.confirmed_at = confirmed_at;
        }

        public User(String nickName) {
            this.short_name = nickName;
            this.sortable_name = name;
            this.time_zone = API.TIME_ZONE;
            this.locale = API.LOCALE;
        }

        public User(String nickName, String avatarURL) {
            this.short_name = nickName;
            this.sortable_name = name;
            this.avatar = new Avatar(null, avatarURL);
        }

        public class Avatar {
            private String token;
            private String url;

            public Avatar(String token, String avatarURL) {
                this.token = token;
                this.url = avatarURL;
            }

            public String getToken() {
                return token;
            }

            public String getUrl() {
                return url;
            }

        }
//
//		public String getName() {
//			return name;
//		}
//
//		public String getShort_name() {
//			return short_name;
//		}
//
//		public String getSortable_name() {
//			return sortable_name;
//		}
//
//		public String getTime_zone() {
//			return time_zone;
//		}
//
//		public String getLocale() {
//			return locale;
//		}
//
//		public Avatar getAvatar() {
//			return avatar;
//		}


    }
//
//	public Pseudonym getPseudonym() {
//		return pseudonym;
//	}

}

