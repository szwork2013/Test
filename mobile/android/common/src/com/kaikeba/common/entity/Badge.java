package com.kaikeba.common.entity;

import java.io.Serializable;

public class Badge implements Serializable {

    /**
     *
     */
    private static final long serialVersionUID = -7603307252708991576L;
    private Long id;
    private String badgeTitle;
    private String image4small;
    private String image4big;

    public Long getId() {
        return id;
    }

    public String getBadgeTitle() {
        return badgeTitle;
    }

    public String getImage4small() {
        return image4small;
    }

    public String getImage4big() {
        return image4big;
    }
}
