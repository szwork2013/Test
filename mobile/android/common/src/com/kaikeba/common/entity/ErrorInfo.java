package com.kaikeba.common.entity;

import java.util.List;

/**
 * Created by baige on 14-8-6.
 */
public class ErrorInfo {
    private String message;
    private boolean status = true;
    private Error error;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean getStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Error getError() {
        return error;
    }

    public void setError(Error error) {
        this.error = error;
    }

    public static class Error {
        private List<String> email;
        private List<String> username;

        public List<String> getEmail() {
            return email;
        }

        public void setEmail(List<String> email) {
            this.email = email;
        }

        public List<String> getUsername() {
            return username;
        }

        public void setUsername(List<String> username) {
            this.username = username;
        }
    }
}
