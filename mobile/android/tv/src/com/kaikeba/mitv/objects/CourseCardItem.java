package com.kaikeba.mitv.objects;

import com.kaikeba.common.entity.CourseModel;

/**
 * Created by kkb on 8/6/14.
 */
public class CourseCardItem extends CourseModel {
    private int rateLevel;
    private boolean isFocused;
    private boolean isSmallSize;
    private boolean isRecommend;

    private int cardWidth;
    private int cardHeight;

    public CourseCardItem(int courseId, String courseTitle, int rateLevel, String courseImage) {
        this.id = courseId;
        this.name = courseTitle;
        this.rateLevel = rateLevel;
        this.cover_image = courseImage;
    }

    public int getRateLevel() {
        return rateLevel;
    }

    public void setRateLevel(int rateLevel) {
        this.rateLevel = rateLevel;
    }

    public boolean isFocused() {
        return isFocused;
    }

    public void setFocused(boolean isFocused) {
        this.isFocused = isFocused;
    }

    public boolean isSmallSize() {
        return isSmallSize;
    }

    public void setSmallSize(boolean isSmallSize) {
        this.isSmallSize = isSmallSize;
    }

    public int getCardWidth() {
        return cardWidth;
    }

    public void setCardWidth(int cardWidth) {
        this.cardWidth = cardWidth;
    }

    public int getCardHeight() {
        return cardHeight;
    }

    public void setCardHeight(int cardHeight) {
        this.cardHeight = cardHeight;
    }

    public void setCardLayout(int width, int height) {
        this.cardWidth = width;
        this.cardHeight = height;
    }

    public boolean getIsRecommend() {
        return isRecommend;
    }

    public void setIsRecommend(boolean isRecommend) {
        this.isRecommend = isRecommend;
    }

}
